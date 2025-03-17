/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        07.06.2021
 * @description    Class used to keep Account queries
 */
public inherited sharing class CX_AccountDAO {
    private static final CX_AccountDAO INSTANCE = new CX_AccountDAO();

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        07.06.2021
     * @description    Returns the singleton instance
     * @return         CX_AccountDAO - a CX_AccountDAO singleton instance
     */
	public static CX_AccountDAO getInstance() {
		return INSTANCE;
	}

    private CX_AccountDAO() { }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        07.06.2021
     * @description    Returns a Account querying with its locationId
     * @param          Set<String> - location ids
     * @return         List<Account> - A list of Accounts
     */
    public List<Account> getAccountByLocationId(Set<String> locationIds) {
        return [
            SELECT 
                ID,
                LocationID__c 
            FROM 
                Account 
            WHERE 
                LocationID__c in :locationIds
        ];
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.06.2021
     * @description    Returns a Location Account querying with its Id
     * @param          Set<Id> - location ids
     * @return         List<Account> - A list of Accounts
     */
    public List<Account> getLocationsById(Set<Id> accountIds) {
        RecordTypeInfo locationRT =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Location');

        return [
            SELECT 
                ID,
                BillingStreet,
                BillingCity,
                BillingPostalCode,
                BillingState,
                LocationID__c 
            FROM 
                Account 
            WHERE 
                Id in :accountIds
                AND RecordTypeId = :locationRT.getRecordTypeId()
        ];
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        16.06.2021
     * @description    Returns a Location relation list querying with a contact id
     * @param          Id - Contact Id
     * @return         List<GEA_AccountContactRelation__c> - A list of Accounts Contact relations
     */
    public List<GEA_AccountContactRelation__c> getLocationRelationsByContactId(Id contactId) {
        return [
            SELECT 
                ID,
                Account__c
            FROM 
                GEA_AccountContactRelation__c
            WHERE 
                Contact__c = :contactId
        ];
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        22.06.2021
     * @description    Returns a Location Account querying with its zip code and street
     * @param          String - location's zip code
     * @param          String - location's street
     * @return         List<Account> - A list of Locations
     */
    public List<Account> getLocationsByZipCodeAndStreet(String zipCode, String street) {
        RecordTypeInfo locationRT =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Location');

        return [
            SELECT 
                ID,
                BillingStreet,
                BillingCity,
                BillingPostalCode,
                BillingState,
                LocationID__c 
            FROM 
                Account 
            WHERE 
                Zip_Search__c = :zipCode.substring(0, 5)
                AND Street_Search__c  = :street
                AND RecordTypeId = :locationRT.getRecordTypeId()
        ];
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        22.06.2021
     * @description    Returns a Location Account querying with its zip code and street
     * @param          String - location's phone
     * @return         List<Account> - A list of Locations
     */
    public List<Account> getLocationsByPhone(String phone) {
        RecordTypeInfo locationRT =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Location');

        return [
            SELECT 
                ID,
                BillingStreet,
                BillingCity,
                BillingPostalCode,
                BillingState,
                LocationID__c 
            FROM 
                Account 
            WHERE 
                Phone = :phone
                AND RecordTypeId = :locationRT.getRecordTypeId()
        ];
    }

    /**
     * @author         Gabriel Alves
     * @company        PolSource
     * @created        28.06.2021
     * @description    Returns the Location Accounts related to a Contact by the GEA_AccountContactRelation__c object
     * @param          Id - location's Id
     * @return         List<Account> - A list of Locations
     */
    public List<Account> getLocationsByContactId (Id contactId) {
        Id locationRecTypeId = Account.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Location').getRecordTypeId();
    
        return 
        [SELECT Id, 
                Name, 
                BillingStreet, 
                BillingCity, 
                BillingState, 
                BillingPostalCode
           FROM Account 
          WHERE RecordTypeId = :locationRecTypeId 
                AND Id IN (SELECT Account__c FROM GEA_AccountContactRelation__c WHERE Contact__c = :contactId)];
    }
    /**
     * @author         Gunhan Gultekin
     * @company        PolSource
     * @created        05.07.2021(dd.mm.yyyy)
     * @description    Returns the Location Accounts related to a Contact by the GEA_AccountContactRelation__c object except the selected location
     * @param          Id - contactId
     * @param          Id - currrent location Id releated to case 
     * @return         List<Account> - A list of Locations
     */
    public List<Account> getLocationsByContactId (Id contactId,Id currentLocationId) {
        Id locationRecTypeId = Account.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Location').getRecordTypeId();
      system.debug('in getLocationsByContactId');
        return 
        [SELECT Id, 
                Name, 
                BillingStreet, 
                BillingCity, 
                BillingState, 
                BillingPostalCode
           FROM Account 
          WHERE RecordTypeId = :locationRecTypeId 
                AND Id IN (SELECT Account__c FROM GEA_AccountContactRelation__c WHERE Contact__c = :contactId)
                AND Id != :currentLocationId];
    }
    
}