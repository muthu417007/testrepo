/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        11.06.2021
 * @description    Class used to handle Location zone/region update logic
 * @testClass      CX_UpdateLocationQueueableTest
 */
public with sharing class CX_UpdateLocationQueueable implements Queueable, Database.AllowsCallouts {
    List<Account> locations;
    
    private CX_UpdateLocationQueueable() {}

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.06.2021
     * @description    Constructor with 1 parameter
     * @param          List<Account> - Locations
     */
    public CX_UpdateLocationQueueable(List<Account> locations) {
        this.locations = locations;
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.06.2021
     * @description    Method fired by the platform, calls the method that will handle the logic
     * @param          QueueableContext - The queueable execution context
     */
    public void execute(QueueableContext context) {
        for(Account location : this.locations) {
            if(Test.isRunningTest()) {
                handleLocationUpdate(JSON.serialize(location));
            } else {
                handleLocationUpdateAsync(JSON.serialize(location));
            }
        }
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.06.2021
     * @description    Async Method that handles the location update logic
     * @param          String - A location in JSON format
     */
    @future(callout = true)
    private static void handleLocationUpdateAsync(String locationStr) {
        handleLocationUpdate(locationStr);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.06.2021
     * @description    Method that handles the location update logic
     * @param          String - A location in JSON format
     */
    private static void handleLocationUpdate(String locationStr) {
        final CX_Logger logger = new CX_Logger(CX_Logger.LogMode.MODE_PLATFORM_EVENT);

        try {
            Account location = (Account) JSON.deserialize(locationStr, Account.class);

            if(String.isBlank(location.BillingPostalCode)) {
                return;
            }

            ZoneDetailsResponse result = verifyAddress(location.BillingPostalCode);

            if(result == null) {
                return;
            }

            Account updateAccount = new Account(Id = location.Id);
            updateAccount.Region__c = Decimal.valueOf(result.RegionNo);
            updateAccount.Zone__c = result.ZoneCode;

            updateAccount.Service_Region_Zone__c = result.ZoneCode != null && result.ZoneCode == '09' ? 'Customer Care' : 'Factory Service';
            
            update updateAccount;
        } catch(Exception ex) {
            logger.logError(ex, 'CX_UpdateLocationQueueable', 'handleLocationUpdate');
        }
        
    }

    public static ZoneDetailsResponse verifyAddress(String zip) {
        final CX_Logger logger = new CX_Logger(CX_Logger.LogMode.MODE_PLATFORM_EVENT);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');

        if(CX_Utils.isSandbox()){
            request.setEndpoint('callout:Sandbox_ZoneDetails');   
        } else {
            request.setEndpoint('callout:Production_ZoneDetails');
        }
        
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('geasfdccode','ApplServiceCloudGEA');
        request.setHeader('appname','SiebelXML');

        request.setBody('{"request": "ZoneDetailsRequest","payload": {"PostalAreaCode": "' + zip +'"}}');
        request.setTimeout(25000);

        HttpResponse response = http.send(request);

        ZoneDetailsResponse resp;

        if (response.getStatusCode() == 200 && !response.getBody().contains('error-text')) {
            resp = zoneDetailsResponse.parse(response.getBody());
        } else {
            logger.logCalloutError(request, response, 'CX_UpdateLocationQueueable', 'verifyAddress', 'retrieving location info');
        }

        return resp;
    }
}