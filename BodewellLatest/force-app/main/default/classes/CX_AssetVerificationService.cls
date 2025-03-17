/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        14.06.2021
 * @description    Class that handles the Asset Verification process integration logic
 */
public with sharing class CX_AssetVerificationService {
    private static final CX_AssetVerificationService INSTANCE = new CX_AssetVerificationService();
    private final CX_Logger logger = new CX_Logger(CX_Logger.LogMode.MODE_PLATFORM_EVENT);

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        14.06.2021
     * @description    Returns the singleton instance
     * @return         CX_AssetVerificationService - a CX_AssetVerificationService singleton instance
     */
	public static CX_AssetVerificationService getInstance() {
		return INSTANCE;
	}

    private CX_AssetVerificationService() { }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        14.06.2021
     * @description    Gets asset info in an external system using the model number
     * @param          String - The asset Model number
     * @return         ModelNumberResponse - The asset info from the external system
     */
    public ModelNumberResponse getAssetInfo(String modelNumber) {
        Http http = new Http();

        HttpRequest request = new HttpRequest();
        request.setMethod('POST');

        if(CX_Utils.isSandbox()) {
            request.setEndpoint('callout:Sandbox_ValidateModelNumber');   
        } else {
            request.setEndpoint('callout:Production_ValidateModelNumber');
        }
        
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('geasfdccode','ApplServiceCloudGEA');
        request.setHeader('appname','SiebelXML');

        request.setBody('{"request": "ModelNumberValidateRequest","payload": {"ModelNumber": "' + modelNumber.toUpperCase().trim() +'","BrandCode": "", "ProductTypeCode": "", "ProductLineCode": ""}}');

        HttpResponse response = http.send(request);

        ModelNumberResponse responseData;

        if (response.getStatusCode() == 200) {
            responseData = ModelNumberResponse.parse(response.getBody());
        } else {
            logger.logCalloutError(request, response, 'CX_AssetVerificationService', 'getAssetInfo', 'retrieving asset info');
            throw new CalloutException('Error while retrieving asset info!');
        }

        return responseData;
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        15.06.2021
     * @description    Creates/Updates an Asset in an external system and records the result in the asset record
     * @param          Asset - The Asset record in SF
     * @param          User - The user creating the asset 
     * @param          String - The asset installation date in String format (yyyyMMdd)
     * @param          Long - The consumers last Consumer Number
     */
    public void createNewAsset(Asset newAsset, User currentUser, String installDate, Long consumerNumber) {
        Http http = new Http();

        HttpRequest request = new HttpRequest();
        request.setMethod('POST');

        if(CX_Utils.isSandbox()) {
            request.setEndpoint('callout:Sandbox_Create_Asset');   
        } else {
            request.setEndpoint('callout:Production_Create_Asset');
        }
        
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('geasfdccode','ApplServiceCloudGEA');
        request.setHeader('appname','SiebelXML');

        request.setBody(JSON.serialize(CX_NewAssetWrapper.preparePayload(newAsset, currentUser, installDate, consumerNumber)));

        HttpResponse response = http.send(request);
        newAsset.Create_Asset_Response__c = response.getBody();

        if (response.getStatusCode() != 200) {
            logger.logCalloutError(request, response, 'CX_AssetVerificationService', 'createNewAsset', 'creating new asset');
        }
    }
}