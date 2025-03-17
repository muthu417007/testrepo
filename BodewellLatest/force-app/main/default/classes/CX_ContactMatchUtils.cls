/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        04.06.2021
 * @description    Class with reusable methods to help with the whole contact match/search/restore process
 * @testClass      CX_ContactMatchUtilsTest
 */
public without sharing class CX_ContactMatchUtils {
    private static Map<String, CX_ContactSearchWrapper.HouseHold> contactCache = new Map<String, CX_ContactSearchWrapper.HouseHold>();
 
    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        04.06.2021
     * @description    Searches a specific contact in a list of the contact returned in the search
     * @param          List<CX_ContactSearchWrapper.HouseHold> - The contacts returned in a search
     * @param          String - The personId of the requested contact data
     * @return         CX_ContactSearchWrapper - The requested contact data
     */
    public static CX_ContactSearchWrapper.HouseHold searchByPersonId(List<CX_ContactSearchWrapper.HouseHold> data, String personId) {
        CX_ContactSearchWrapper.HouseHold requestedContact = contactCache.get(personId);

        if(requestedContact == null) {
            for(CX_ContactSearchWrapper.HouseHold record : data) {
                if(record.PersonID == personId) {
                    contactCache.put(personId, record);
                    requestedContact = record;
                    break;
                }
            }
        }
        return requestedContact;
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        07.06.2021
     * @description    Restore the whole structure of a Archived Contact (Contact, Location (Account and GEA_AccountContactRelation__c), Contact Information (Contact_Information__c) and Assets (Asset) )
     * @param          CX_ContactSearchWrapper - The searched contact data to restore
     * @return         Contact - The restored contact
     */
    public static Contact restoreContact(CX_ContactSearchWrapper.HouseHold contactData) {
        Contact newContact = parseToContact(contactData, false);
        upsert newContact PersonID__c;

        handleLocationMatch(contactData, newContact);
        handleAssetMatch(contactData, newContact);
        handleContactInformationMatch(contactData, newContact);
        handleCommunicationChannels(contactData, newContact);

        return newContact;     
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        07.06.2021
     * @description    Handles the Location and Relation logic
     * @param          CX_ContactSearchWrapper.HouseHold - The contact data to be restored
     * @param          Contact - The Contact record of the new contact that is being created
     */
    private static void handleLocationMatch(CX_ContactSearchWrapper.HouseHold contactData, Contact newContact) {
        Set<String> locationIds = new Set<String>();
        for(CX_ContactSearchWrapper.Location location : contactData.Locations) {
            locationIds.add(location.LocationID);
        }

        Map<String, Account> locationSFByLocationId = new Map<String, Account>();
        CX_CollectionUtils.loadMap(locationSFByLocationId, 'LocationID__c', CX_AccountDAO.getInstance().getAccountByLocationId(locationIds));

        List<Account> newLocations = new List<Account>();
        List<GEA_AccountContactRelation__c> newRelations = new List<GEA_AccountContactRelation__c>();

        for(CX_ContactSearchWrapper.Location location : contactData.Locations) {
            Account locationSF = locationSFByLocationId?.get(location.LocationID);
            processLocation(location, locationSF, newContact, newLocations, newRelations);
        }

        if(!newLocations.isEmpty()) {
            insert newLocations;

            for(Account locationSF : newLocations) {
                processLocation(null, locationSF, newContact, null, newRelations);
            }
        }

        if(!newRelations.isEmpty()) {
            insert newRelations;
        }
        

        if(String.isBlank(newContact.AccountId)) {
            newContact.AccountId = newRelations[0].Account__c;
        }
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        07.06.2021
     * @description    Checks if it's needed to create a new Location (Account) or just a relation, and creates it
     * @param          CX_ContactSearchWrapper.Location - The location data to be restored
     * @param          Account - The possible location match already in SF
     * @param          Contact - The Contact record of the new contact that is being created
     * @param          List<Account> - A list containing all the locations that will be inserted
     * @param          List<GEA_AccountContactRelation__c> - A list containing all the relations that will be inserted
     */
    private static void processLocation(CX_ContactSearchWrapper.Location location, Account locationSF, Contact newContact, List<Account> newLocations, List<GEA_AccountContactRelation__c> newRelations) {
        if(locationSF != null) {
            newRelations.add(new GEA_AccountContactRelation__c(
                Contact__c = newContact.Id,
                Account__c = locationSF.Id
            ));

            return;
        }

        newLocations.add(new Account(
            Name = location.AddressLine1 + ' ' + location.Locality + ' ' + location.Region + ' ' + location.PostalCode,
            BillingStreet = location.AddressLine1,
            BillingCity = location.Locality,
            BillingState = location.Region,
            BillingPostalCode = location.PostalCode,
            LocationID__c = location.LocationID,
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Location').getRecordTypeId()
        ));
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        07.06.2021
     * @description    Handles the Asset logic
     * @param          CX_ContactSearchWrapper.HouseHold - The contact data to be restored
     * @param          Contact - The Contact record of the new contact that is being created
     */
    private static void handleAssetMatch(CX_ContactSearchWrapper.HouseHold contactData, Contact newContact) {
        Set<String> assetIds = new Set<String>();
        Set<String> assetLocationIds = new Set<String>();

        for(CX_ContactSearchWrapper.Asset assetData : contactData.Assets) {
            assetIds.add(assetData.AssetID);
            assetLocationIds.add(assetData.LocationID);
        }

        Map<String, Asset> assetSFByAssetId = new Map<String, Asset>();
        CX_CollectionUtils.loadMap(assetSFByAssetId, 'AssetID__c', CX_AssetDAO.getInstance().getAssetByAssetId(assetIds));

        Map<String, Account> locationSFByLocationId = new Map<String, Account>();
        CX_CollectionUtils.loadMap(locationSFByLocationId, 'LocationID__c', CX_AccountDAO.getInstance().getAccountByLocationId(assetLocationIds));

        List<Asset> newAssets = new List<Asset>();

        for(CX_ContactSearchWrapper.Asset assetData : contactData.Assets) {
            Asset assetSF = assetSFByAssetId?.get(assetData.AssetID);
            processAsset(assetData, assetSF, newAssets, locationSFByLocationId);
        }

        if(!newAssets.isEmpty()) {
            insert newAssets;
        }
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        07.06.2021
     * @description    Checks if it's needed to create a new Asset, and creates it
     * @param          CX_ContactSearchWrapper.Asset - The asset data to be restored
     * @param          Asset - The possible asset match already in SF
     * @param          List<Asset> - A list containing all the assets that will be inserted
     * @param          Map<String, Account> - A map of location by Location Id, to be related with a new asset
     */
    private static void processAsset(CX_ContactSearchWrapper.Asset assetData, Asset assetSF, List<Asset> newAssets, Map<String, Account> locationSFByLocationId) {
        if(assetSF != null) {
            return;
        }

        Asset newAsset = new Asset();
        /*newAsset.AssetClassName__c = assetData.AssetClassName;*/
        newAsset.AssetID__c = assetData.AssetID;
        newAsset.BrandName__c = assetData.BrandName;
        newAsset.CleansedEngineeringModelNumber__c = assetData.CleansedModelNumber;
        newAsset.AccountId = locationSFByLocationId.get(assetData.LocationID).Id;
        newAsset.MACAddress__c = assetData.MACAddress;
        newAsset.OriginalEngineeringModelNumber__c = assetData.OriginalEngineeringModelNumber;
        newAsset.ProductDescription__c = assetData.ProductDescription;
        newAsset.Product_Line_Desc__c = assetData.ProductLineName;
        newAsset.SerialNumber = assetData.SerialNumber;
        newAsset.Model_Number__c = assetData.CleansedModelNumber;

        if(assetData.AssetScrappedOn != null){
            String dateString = assetData.AssetScrappedOn.subString(0,10);
            /*newAsset.AssetScrappedOn__c = date.valueOf(dateString);*/
        }

        if(assetData.AssetShippedOn != null){
            String dateString = assetData.AssetShippedOn.subString(0,10);
            newAsset.AssetShippedOn__c = date.valueOf(dateString);
        }

        if(assetData.OwnershipStartedOn != null){
            String dateString3 = assetData.OwnershipStartedOn.subString(0,10);
            newAsset.OwnershipStartedOn__c = date.valueOf(dateString3);
        }

        newAssets.add(newAsset);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        07.06.2021
     * @description    Creates or updates the Contact Information records that were archived
     * @param          CX_ContactSearchWrapper.HouseHold - The contact data to be restored
     * @param          Contact - The Contact record of the new contact that is being created
     */
    private static void handleContactInformationMatch(CX_ContactSearchWrapper.HouseHold contactData, Contact newContact) {
        List<Contact_Information__c> contactsInformation = new List<Contact_Information__c>();

        for(CX_ContactSearchWrapper.PersonDetail contactDetail : contactData.Details) {
            Contact_Information__c contactDetailSF = new Contact_Information__c();
            contactDetailSF.Contact__c = newContact.Id;
            contactDetailSF.ID_Type__c = 'GE Consumer Number';
            contactDetailSF.PersonDetailID__c = contactDetail.PersonDetailID;
            contactDetailSF.Identifier__c = contactDetail.GEConsumerNo;
            contactsInformation.add(contactDetailSF);
        }

        upsert contactsInformation PersonDetailID__c;
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        07.06.2021
     * @description    Handles the communication channels logic (phone and email)
     * @param          CX_ContactSearchWrapper.HouseHold - The contact data to be restored
     * @param          Contact - The Contact record of the new contact that is being created
     */
    private static void handleCommunicationChannels(CX_ContactSearchWrapper.HouseHold contactData, Contact newContact) {
        String email = getPrimaryEmail(contactData);
        newContact.Email = String.isNotBlank(email) ? email : newContact.Email;

        Map<String, Map<String, String>> phoneConfig = loadPhoneConfig();

        for(CX_ContactSearchWrapper.Phone phone : contactData.Phone) {
            String phoneType = String.isNotBlank(phone.PhoneTypeName) ? phone.PhoneTypeName.toUpperCase() : 'UNKNOWN';
            Map<String, String> phoneTypeConfig = phoneConfig.get(phoneType);

            if(phoneTypeConfig != null) {
                newContact.put(phoneTypeConfig.get('numberField'), phone.PhoneNumber);
                newContact.put(phoneTypeConfig.get('isPrimaryField'), phone.isPrimaryPhone == '1');
                newContact.put(phoneTypeConfig.get('useTypeField'), phone.PhoneUseTypeName);
            }
        }

        update newContact;
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        07.06.2021
     * @description    Stores a Map containing a translation from the fields in the Wrapper to the fields on the Contact object, for each type of phone
     * @return         Map<String, Map<String, String>> - The map containing the translations per type of phone
     */
    private static Map<String, Map<String, String>> loadPhoneConfig() {
        Map<String, Map<String, String>> phoneConfig = new Map<String, Map<String, String>>();
        
        Map<String, String> cellularConfig = new Map<String, String> { 'numberField' => 'MobilePhone', 'isPrimaryField' => 'Mobile_is_Primary__c', 'useTypeField' => 'Mobile_Use_Type__c'};
        phoneConfig.put('CELLULAR', cellularConfig);

        Map<String, String> landLineConfig = new Map<String, String> { 'numberField' => 'Phone', 'isPrimaryField' => 'Phone_is_Primary__c', 'useTypeField' => 'Phone_Use_Type__c'};
        phoneConfig.put('LAND LINE', landLineConfig);

        Map<String, String> unknown = new Map<String, String> { 'numberField' => 'OtherPhone', 'isPrimaryField' => 'Other_Phone_is_Primary__c', 'useTypeField' => 'Other_Phone_Use_Type__c'};
        phoneConfig.put('UNKNOWN', unknown);

        Map<String, String> voipConfig = new Map<String, String> { 'numberField' => 'VOIP_Phone__c', 'isPrimaryField' => 'VOIP_Phone_is_Primary__c', 'useTypeField' => 'VOIP_Use_Type__c'};
        phoneConfig.put('VOIP', voipConfig);

        return phoneConfig;
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        31.05.2021
     * @description    Converts the contacts returned by the search to the sObject Contact
     * @param          CX_ContactSearchWrapper.Data - The data variable with all the records
     * @param          String - The type of the contacts to converted, email or phone 
     * @return         List<Contact> - The converted contacts
     */
    public static List<Contact> parseToContacts(CX_ContactSearchWrapper.Data data, String type) {
        return parseToContacts(data, type, false);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        08.06.2021
     * @description    Converts the contacts returned by the search to the sObject Contact
     * @param          CX_ContactSearchWrapper.Data - The data variable with all the records
     * @param          String - The type of the contacts to converted, email or phone 
     * @param          Boolean - Should the primary phone be add to the contact?
     * @return         List<Contact> - The converted contacts
     */
    public static List<Contact> parseToContacts(CX_ContactSearchWrapper.Data data, String type, Boolean parsePrimaryPhone) {
        List<CX_ContactSearchWrapper.HouseHold> dataList;

        if(type == 'email') {
            dataList = data.HouseHoldByEmail;
        }
        else {
            dataList = data.HouseHoldByPhone;
        }

        List<Contact> contacts = new List<Contact>();

        for(CX_ContactSearchWrapper.HouseHold record : dataList) {
            Contact parsedContact = record.contactSalesforce != null ? record.contactSalesforce : parseToContact(record, parsePrimaryPhone);
            record.contactSalesforce = parsedContact;
            contacts.add(parsedContact);
        }
        
        return contacts;
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        08.06.2021
     * @description    Converts a contact returned by the search to the sObject Contact
     * @param          CX_ContactSearchWrapper.HouseHold - The contact data
     * @param          Boolean - Should the primary phone be add to the contact?
     * @return         Contact - The converted contact
     */
    private static Contact parseToContact(CX_ContactSearchWrapper.HouseHold record, Boolean parsePrimaryPhone) {
        return new Contact(
            FirstName = record.FirstName?.replaceAll('<[^>]+>', ' ').trim(),
            MiddleName = record.MiddleName?.replaceAll('<[^>]+>', ' ').trim(),
            LastName = String.isNotBlank(record.LastName?.replaceAll('<[^>]+>', ' ').trim()) ? record.LastName?.replaceAll('<[^>]+>', ' ').trim() : record.FirstName?.replaceAll('<[^>]+>', ' ').trim(),
            PersonID__c = record.PersonID,
            Gender__c = record.Gender,
            Email = record.EmailAddresses != null ? getPrimaryEmail(record) : null,
            Phone = parsePrimaryPhone && record.Phone != null ? getPrimaryPhone(record) : null,
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId()
        );
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        31.05.2021
     * @description    Gets the contacts primary email
     * @param          HouseHold - The contact data
     * @return         String - The primary email
     */
    private static String getPrimaryEmail(CX_ContactSearchWrapper.HouseHold data) {
        for(CX_ContactSearchWrapper.EmailAddress email : data.EmailAddresses) {
            if(email.IsPrimaryEmail == '1') {
                return email.EmailAddress;
            }
        }

        return null;
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        31.05.2021
     * @description    Gets the contacts primary phone
     * @param          HouseHold - The contact data
     * @return         String - The primary phone
     */
    private static String getPrimaryPhone(CX_ContactSearchWrapper.HouseHold data) {
        for(CX_ContactSearchWrapper.Phone phone : data.Phone) {
            if(phone.isPrimaryPhone == '1') {
                return phone.PhoneNumber;
            }
        }

        return null;
    }
}