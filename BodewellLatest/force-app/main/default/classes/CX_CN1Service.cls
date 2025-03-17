/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        14.06.2021
 * @description    Class that handles the CN1 Contact integration logic
 */
public with sharing class CX_CN1Service {
    private static final CX_CN1Service INSTANCE = new CX_CN1Service();
    private final CX_Logger logger = new CX_Logger(CX_Logger.LogMode.MODE_PLATFORM_EVENT);

        /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        14.06.2021
     * @description    Returns the singleton instance
     * @return         CX_CN1Service - a CX_CN1Service singleton instance
     */
	public static CX_CN1Service getInstance() {
		return INSTANCE;
	}

    private CX_CN1Service() { }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        14.06.2021
     * @description    Inserts/Updates the contact in the CN1 service, and returns the CN1 Customer Number
     * @param          Contact - The contact to be processed
     * @param          Account - The contact location
     * @param          User - The user doing the action
     * @return         CN1Response - The customer insert/update response 
     */
    public CN1Response getCN1CustomerNumber(Account currentAccount, Account location, User currentUser) {
        system.debug('in getCN1CustomerNumber');
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setTimeout(50000);

        if(CX_Utils.isSandbox()) {
            request.setEndpoint('callout:Sandbox_CN1_Customer_Number');
        } else {
            request.setEndpoint('callout:Production_CN1_Customer_Number');
        }
        
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('geasfdccode','ApplServiceCloudGEA');
        request.setHeader('appname','SiebelXML');

        String payload = JSON.serialize(CX_CN1CustomerNumberWrapper.preparePayload(currentAccount, location, currentUser));
        request.setBody(payload);

        HttpResponse response = http.send(request);

        CN1Response responseData;

        if (response.getStatusCode() == 200) {
            responseData = CN1Response.parse(response.getBody());
			system.debug('CN1Response: '+responseData);
            //if(response.getBody().contains('INVALID CREATE USER ID')) {
               // logger.logCalloutError(request, response, 'CX_CN1Service', 'getCN1CustomerNumber', 'saving the contact information');
                //throw new CalloutException('CUSTOM_ERROR: You don\'t have a valid SSO ID to create contacts, contact your admin!');
            //} 
            //else if(String.isBlank(responseData.ConsumerNo)) {
              //  logger.logCalloutError(request, response, 'CX_CN1Service', 'getCN1CustomerNumber', 'saving the contact information');
               // throw new CalloutException('CUSTOM_ERROR: Error while saving the contact information!');
            //}
        } else {
            logger.logCalloutError(request, response, 'CX_CN1Service', 'getCN1CustomerNumber', 'saving the contact information');
            throw new CalloutException('CUSTOM_ERROR: Error while saving the contact information!');
        }

        return responseData;
    } 
}