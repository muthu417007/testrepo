/**
 * @author         Gabriel Alves
 * @company        PolSource
 * @created        22.06.2021
 * @description    Class for handling the creation of new Location Accounts
 * @testClass      CX_CreateLocationControllerTest
 */
public with sharing class CX_CreateLocationController {

    private static final RecordTypeInfo ACCOUNT_LOCATION_RT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Location');
    
    @AuraEnabled
    public static Account createLocation (Account location) {
        try {
            location.RecordTypeId = ACCOUNT_LOCATION_RT.getRecordTypeId();
            insert validateLocation(location);
            return location;
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage('Error creating Case: ' + e.getMessage());
            throw ex;
        }
    }

    private static Account validateLocation (Account location) {
        if(String.isBlank(location.BillingPostalCode)) {
            throw new ValidateLocationException('Zip Code is required');
        }
        if (String.isBlank(location.Name)) {
            location.Name = location.BillingStreet + ' ' + location.BillingCity + ', ' + location.BillingState + ' ' + location.BillingPostalCode;
        }
        return updateAccount(location, CX_UpdateLocationQueueable.verifyAddress(location.BillingPostalCode));
    }

    private static Account updateAccount (Account location, ZoneDetailsResponse result) {
        if (result != null) {
            location.Region__c = Decimal.valueOf(result.RegionNo);
            location.Zone__c = result.ZoneCode;
            location.Service_Region_Zone__c = result.ZoneCode != null && result.ZoneCode == '09' ? 'Customer Care' : 'Factory Service';
        }
        
        return location;
    }

    public class ValidateLocationException extends Exception {}
}