/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        31.05.2021
 * @description    Class used to handle contact match logic on a case
 * @testClass      CX_ContactMatchQueueableTest
 */
public without sharing class CX_ContactMatchQueueable implements Queueable, Database.AllowsCallouts {
    List<Case> casesMatch;
    String contactSearchRetrieverName;

    private CX_ContactMatchQueueable() {}

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        01.06.2021
     * @description    Constructor with 2 parameters
     * @param          List<Case> - A list of cases to be matched with contacts
     * @param          String - The search implementation retrievers name to be used
     */
    public CX_ContactMatchQueueable(List<Case> casesMatch, String contactSearchRetrieverName) {
        this.casesMatch = casesMatch;
        this.contactSearchRetrieverName = contactSearchRetrieverName;
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        01.06.2021
     * @description    Method fired by the platform, calls the method that will handle the logic
     * @param          QueueableContext - The queueable execution context
     */
    public void execute(QueueableContext context) {
        for(Case caseMatch : this.casesMatch) {
            if(Test.isRunningTest()) {
                handleContactMatch(JSON.serialize(caseMatch), this.contactSearchRetrieverName);
            } else {
                handleContactMatchAsync(JSON.serialize(caseMatch), this.contactSearchRetrieverName);
            }
        }
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        01.06.2021
     * @description    Async Method that handles the matching logic
     * @param          String - A Case JSON
     * @param          String - The contact search implementation retriever name
     */
    @future(callout = true)
    private static void handleContactMatchAsync(String caseStr, String contactSearchRetrieverName) {
        handleContactMatch(caseStr, contactSearchRetrieverName);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        01.06.2021
     * @description    Method that handles the matching logic
     * @param          String - A Case JSON
     * @param          String - The contact search implementation retriever name
     */
    private static void handleContactMatch(String caseStr, String contactSearchRetrieverName) {
        Savepoint sp;
        final CX_Logger logger = new CX_Logger(CX_Logger.LogMode.MODE_PLATFORM_EVENT);

        try {
            Case caseMatch = (Case) JSON.deserialize(caseStr, Case.class);

            List<Contact> contactsSalesforce = CX_ContactDAO.getInstance().getContactByEmailOrPhone(caseMatch.SuppliedEmail, CX_Utils.removeNumberFormatting(caseMatch.Phone_Number__c));
            Map<String, List<Contact>> contactsByEmail = new Map<String, List<Contact>>();
            CX_CollectionUtils.loadMap(contactsByEmail, 'Email', contactsSalesforce);

            Map<String, List<Contact>> contactsByPhone = new Map<String, List<Contact>>();
            CX_CollectionUtils.loadMap(contactsByPhone, 'Phone', contactsSalesforce);
            CX_CollectionUtils.loadMap(contactsByPhone, 'MobilePhone', contactsSalesforce);
            CX_CollectionUtils.loadMap(contactsByPhone, 'OtherPhone', contactsSalesforce);
            CX_CollectionUtils.loadMap(contactsByPhone, 'VOIP_Phone__c', contactsSalesforce);

            Boolean multipleMatchesById = checkMultipleMatches(caseMatch, contactsByEmail, contactsByPhone, 'Id');
            if(multipleMatchesById != null && multipleMatchesById) {
                sp = Database.setSavepoint();
                processMultipleMatchedCase(caseMatch);
                return;
            }

            CX_ContactSearch contactSearch = ((CX_ContactSearchRetriever) Type.forName(contactSearchRetrieverName).newInstance()).retrieveImplementation();

            Map<String, CX_ContactSearchWrapper> searchResult = contactSearch.searchContact(caseMatch.SuppliedEmail, CX_Utils.removeNumberFormatting(caseMatch.Phone_Number__c));
            
            List<Contact> contactsSearch = new List<Contact>();
            
            for(String type : searchResult.keySet()) {
                contactsSearch.addAll(CX_ContactMatchUtils.parseToContacts(searchResult.get(type).data, type, true));
            }

            if(contactsSearch.isEmpty() && contactsSalesforce.isEmpty()) {
                createNewCaseContact(caseMatch);
                return;
            }
            
            sp = Database.setSavepoint();

            CX_CollectionUtils.loadMap(contactsByEmail, 'Email', contactsSearch);
            CX_CollectionUtils.loadMap(contactsByPhone, 'Phone', contactsSearch);

            multipleMatchesById = checkMultipleMatches(caseMatch, contactsByEmail, contactsByPhone, 'Id');
            Boolean multipleMatchesByPersonId = checkMultipleMatches(caseMatch, contactsByEmail, contactsByPhone, 'PersonId__c');

            if((multipleMatchesById == null || !multipleMatchesById) || (multipleMatchesByPersonId == null || !multipleMatchesByPersonId)) {
                processContactMatching(caseMatch, contactsByEmail.get(caseMatch.SuppliedEmail), contactsByPhone.get(CX_Utils.removeNumberFormatting(caseMatch.Phone_Number__c)), searchResult);
            } else {
                processMultipleMatchedCase(caseMatch);
            }
        } catch(CalloutException ex) {
            Database.rollback(sp);
            throw ex;
        } catch(Exception ex) {
            Database.rollback(sp);
            logger.logError(ex, 'CX_ContactMatchQueueable', 'handleContactMatch');
        }
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        01.06.2021
     * @description    Checks if a case has multiple matches
     * @param          Case - A case with the phone and email
     * @param          Map<String, List<Contact>> - A map containing contacts matched by Email
     * @param          Map<String, List<Contact>> - A map containing contacts matched by Phone
     * @param          String - The Id field to check if the contacts match when above maps have only 1 record each
     * @return         Boolean - Does the case have multiple matches?
     */
    private static Boolean checkMultipleMatches(Case caseMatch, Map<String, List<Contact>> contactsByEmail, Map<String, List<Contact>> contactsByPhone, String field) {
        List<Contact> emailContacts = contactsByEmail.get(caseMatch.SuppliedEmail);
        List<Contact> phoneContacts = contactsByPhone.get(CX_Utils.removeNumberFormatting(caseMatch.Phone_Number__c));

        Boolean hasSameIds = validateSameIds(emailContacts, phoneContacts, field);    
        return hasSameIds == null ? null : !hasSameIds;
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        01.06.2021
     * @description    Validates if the IDs are the same
     * @param          List<Contact> - A list of contacts matched by Email
     * @param          List<Contact> - A list of contacts matched by Phone
     * @param          String - The Id field to check if the contacts match
     * @return         Boolean - Are the Ids the same?
     */
    private static Boolean validateSameIds(List<Contact> emailContacts, List<Contact> phoneContacts, String field) {
        List<Contact> records = new List<Contact>();

        if(emailContacts != null && !emailContacts.isEmpty()) {
            records.addAll(emailContacts);
        }

        if(phoneContacts != null && !phoneContacts.isEmpty()) {
            records.addAll(phoneContacts);    
        }

        Set<String> peopleId = new Set<String>();
        for(Contact contact : records) {
            String value = contact.get(field) != null ? (String)contact.get(field) : null;
            peopleId.add(value);
        }

        return peopleId.isEmpty() || (peopleId.size() == 1 && peopleId.contains(null)) ? null : peopleId.size() == 1;
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        31.05.2021
     * @description    Updates a case that was matched with multiple contacts
     * @param          Case - a case matched with multiple contacts
     */
    private static void processMultipleMatchedCase(Case record) {
        update new Case(
            Id = record.Id, 
            CX_MultipleMatchedContacts__c = true, 
            CX_Contact_Email__c = record.SuppliedEmail, 
            CX_Contact_Phone__c = CX_Utils.removeNumberFormatting(record.Phone_Number__c)
        );
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        31.05.2021
     * @description    Creates a new contact structure and matches it with the case
     * @param          Case - a Case that didn't match with a Contact
     */
    private static void createNewCaseContact(Case record) {
        CX_ContactCreationWrapper wrapper = new CX_ContactCreationWrapper();
        wrapper.firstName = record.First_Name__c;
        wrapper.lastName = record.Last_Name__c;
        wrapper.email = record.SuppliedEmail;
        wrapper.phone = CX_Utils.removeNumberFormatting(record.Phone_Number__c);
        wrapper.street = record.Street_Address__c;
        wrapper.zip = record.Zip_Postal_Code__c;
        wrapper.usePhoneField = String.isNotBlank(wrapper.phone);
        wrapper.unknownAddress = String.isBlank(wrapper.zip) || String.isBlank(wrapper.street);

        Contact caseContact = CX_ContactCreation.getInstance().createContact(wrapper, record);
        update new Case(Id = record.Id, ContactId = caseContact.Id);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        01.06.2021
     * @description    Process a Case that was matched with 0 or 1 contact by email and 0 or 1 contact by phone (at least 1 list will have a record)
     * @param          Case - a Case to be updated with a Contact
     * @param          List<Contact> - a list of Contact matched by email (contains 0 or 1 record)
     * @param          List<Contact> - a list of Contact matched by phone (contains 0 or 1 record)
     * @param          Map<String, CX_ContactSearchWrapper> - a map containing the search result
     */
    private static void processContactMatching(Case record, List<Contact> emailContacts, List<Contact> phoneContacts, Map<String, CX_ContactSearchWrapper> searchResult) {
        Contact contactMatch;
        List<CX_ContactSearchWrapper.HouseHold> contactsData;
        
        if(emailContacts != null && !emailContacts.isEmpty()) {
            contactMatch = emailContacts[0];
            contactsData = searchResult.get('email').data.HouseHoldByEmail;
        } else {
            contactMatch = phoneContacts[0];
            contactsData = searchResult.get('phone').data.HouseHoldByPhone;
        }

        if(String.isBlank(contactMatch.Id)) {
            CX_ContactSearchWrapper.HouseHold contactData = CX_ContactMatchUtils.searchByPersonId(contactsData, contactMatch.PersonID__c);
            contactMatch = CX_ContactMatchUtils.restoreContact(contactData);
        }

        update new Case(Id = record.Id, ContactId = contactMatch.Id);
    }
}