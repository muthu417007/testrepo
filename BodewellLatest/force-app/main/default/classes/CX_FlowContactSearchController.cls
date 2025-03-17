/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        28.06.2021
 * @description    Class for handling the contact search logic for the flow
 * @testClass      CX_FlowContactSearchControllerTest
 */
public without sharing class CX_FlowContactSearchController {
    private static final String SEARCH_RETRIEVER_IMPLEMENTATION = 'CX_ContactSearchRetrieverGraphQL';

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        28.06.2021
     * @description    Returns salesforce contacts matched by the Email/Phone
     * @param          String - The email to match
     * @param          String - The phone to match
     * @return         String - A list of salesforce contacts in JSON format
     */
    @AuraEnabled
    public static String getContacts(String email, String phone) {
        List<Contact> contacts;

        try {
            contacts = CX_ContactDAO.getInstance().getContactByEmailOrPhone(email, phone);
        } catch(Exception ex) {
            CX_Utils.throwHandledException(ex, 'An error occurred while getting the contacts!');
        }

        return JSON.serialize(contacts);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        28.06.2021
     * @description    Returns external contacts matched by the Email/Phone
     * @param          String - The email to match
     * @param          String - The phone to match
     * @return         String - A list of external contacts in JSON format
     */
    @AuraEnabled
    public static String getExternalContacts(String email, String phone) {
        List<CX_ContactSearchWrapper.HouseHold> contactsData = new List<CX_ContactSearchWrapper.HouseHold>();

        try {
            CX_ContactSearch contactSearch = ((CX_ContactSearchRetriever) Type.forName(SEARCH_RETRIEVER_IMPLEMENTATION).newInstance()).retrieveImplementation();
            Map<String, CX_ContactSearchWrapper> searchResult = contactSearch.searchContact(email, phone);
            
            for(String type : searchResult.keySet()) {
                CX_ContactSearchWrapper wrapper = searchResult.get(type);
                CX_ContactMatchUtils.parseToContacts(wrapper.data, type, true);

                contactsData.addAll(wrapper.getRecordsByType(type));
            }
        } catch(Exception ex) {
            CX_Utils.throwHandledException(ex, 'An error occurred while getting the external contacts!');
        }

        return JSON.serialize(contactsData);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        28.06.2021
     * @description    Restores an archived contact
     * @param          String - The contact to be matched in JSON format
     * @param          String - The external contact search result
     */
    @AuraEnabled
    public static Id restoreContact(String contactMatchStr, String searchResultStr) {   
        Savepoint sp = Database.setSavepoint();
        Contact contactMatch;

        try {
            contactMatch = (Contact) JSON.deserialize(contactMatchStr, Contact.class);

            List<CX_ContactSearchWrapper.HouseHold> searchContacts = (List<CX_ContactSearchWrapper.HouseHold>) JSON.deserialize(searchResultStr, List<CX_ContactSearchWrapper.HouseHold>.class);
            CX_ContactSearchWrapper.HouseHold contactData = CX_ContactMatchUtils.searchByPersonId(searchContacts, contactMatch.PersonId__c);
            contactMatch = CX_ContactMatchUtils.restoreContact(contactData);

        } catch (Exception ex) {
            Database.rollback(sp);
            CX_Utils.throwHandledException(ex, 'An error occurred while matching a contact!');
        }

        return contactMatch.Id;
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        06.07.2021
     * @description    Relates a case and a contact
     * @param          Id - Case Id
     * @param          Id - Contact Id
     */
    @AuraEnabled
    public static void relateContactCase(Id caseId, Id contactId) {   
        try {
            update new Case(Id = caseId, ContactId = contactId);
        } catch (Exception ex) {
            CX_Utils.throwHandledException(ex, 'An error occurred while relating the contact and a case!');
        }
    }
}