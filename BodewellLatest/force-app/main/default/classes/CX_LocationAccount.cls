/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        11.06.2021
 * @description    Class used to handle Location logic
 * @testClass      CX_LocationAccountTest
 */
public without sharing class CX_LocationAccount {
    private static final CX_LocationAccount INSTANCE = new CX_LocationAccount();
    private static Set<Id> processedLocationIds = new Set<Id>();

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.06.2021
     * @description    Returns the singleton instance
     * @return         CX_LocationAccount - a CX_LocationAccount singleton instance
     */
	public static CX_LocationAccount getInstance() {
		return INSTANCE;
	}

    private CX_LocationAccount() { }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        22.06.2021
     * @description    Fills the zip and street search fields (indexed) on locations to help when querying
     * @param          List<Account> - an account list to process
    */
    public void fillAddressIndexedFields(List<Account> accounts) {
        RecordTypeInfo locationRT =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Location');

        for(Account acc : accounts) {
            if(acc.RecordTypeId == locationRT.getRecordTypeId() && (CX_Utils.isChanged(acc, Account.BillingPostalCode) || CX_Utils.isChanged(acc, Account.BillingStreet))) {
                System.debug('billingpostalcode validation'); 
                if (acc.BillingPostalCode?.length() >= 5){
				acc.Zip_Search__c = acc.BillingPostalCode?.substring(0,5);
                }
                    else { 
                        acc.Zip_Search__c = acc.BillingPostalCode?.substring(0,4);
                    }
                //acc.Zip_Search__c = acc.BillingPostalCode?.substring(0, 5); commented to allow internation zip codes.
                acc.Street_Search__c = acc.BillingStreet;
            }
        }
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.06.2021
     * @description    Updates the case location zone and region
     * @param          List<Case> - a case list to process
    */
    public void updateCaseLocationZoneRegion(List<Case> cases) {
        RecordTypeInfo dssoRT =  Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('DSSO_Case');
        Set<Id> locationIds = new Set<Id>();

        for(Case record : cases) {
            if(record.RecordTypeId != dssoRT.getRecordTypeId() && String.isNotBlank(record.AccountId) && CX_Utils.isChanged(record, Case.AccountId) && validateNewLocation(record)) {
                locationIds.add(record.AccountId);
            }
        }

        if(!locationIds.isEmpty()) {
            List<Account> locations = CX_AccountDAO.getInstance().getLocationsById(locationIds);
            enqueueUpdateLocationQueueable(locations);
        }
        
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.06.2021
     * @description    Validates if the Case location will not be processed after being updated in it's own process
     * @param          Case - a case to validate
     * @return         Boolean - should the location be processed?
    */
    private Boolean validateNewLocation(Case record) {
        Boolean isAsync = Test.isRunningTest() ? System.isQueueable() : System.isFuture();

        if(isAsync && processedLocationIds.contains(record.AccountId)) {
            processedLocationIds.remove(record.AccountId);
            return false;
        }
        return true;
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.06.2021
     * @description    Updates the location zone and region
     * @param          List<Account> - an account list to process
    */
    public void updateLocationZoneRegion(List<Account> accounts) {
        RecordTypeInfo locationRT =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Location');
        
        List<Account> locations = new List<Account>();

        for(Account record : accounts) {
            if(record.RecordTypeId == locationRT.getRecordTypeId() && String.isNotBlank(record.BillingPostalCode) && CX_Utils.isChanged(record, Account.BillingPostalCode) && (Trigger.isInsert || !CX_Utils.isChanged(record, Account.Service_Region_Zone__c))) {
                locations.add(record);
                processedLocationIds.add(record.Id);
            }
        }

        enqueueUpdateLocationQueueable(locations);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.06.2021
     * @description    Enqueue the location list to be processed
     * @param          List<Account> - an location list to split and enqueue
    */
    private void enqueueUpdateLocationQueueable(List<Account> locations) {
        if(locations == null || locations.isEmpty()) {
            return;
        }

        List<List<Account>> locationsExecutionList = (List<List<Account>>) CX_CollectionUtils.splitToSubList(locations, Limits.getLimitFutureCalls());
        for(List<Account> subList : locationsExecutionList) {
            System.enqueueJob(new CX_UpdateLocationQueueable(subList));
        }
    }
}