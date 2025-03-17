/**
 * @author         Gunhan Gultekin
 * @company        PolSource
 * @created        22.06.2021
 * @description    Controller Class for cx_createContactAssetLocation LWC component
 * @testClass      CX_CreateContactAssetLocationCntTest
 */
public with sharing class CX_CreateContactAssetLocationController {

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        20.07.2021
     * @description    Returns a case
     * @param          Id - The case id
     * @return         Case - The case record
     */
    @AuraEnabled(Cacheable = true)
    public static Case getCase(Id caseId) {
        return CX_CaseDAO.getInstance().getCase(caseId);
    }

    /**
     * @author         Gunhan Gultekin
     * @company        PolSource
     * @created        02.06.2021
     * @description    validates the asset using model number. A callout is made to Siebel
     * @param          String - modelNumber that user populated
     * @return         String - retunrs the serialized ModelNumberResponse
     */
    @AuraEnabled
    public static String validateAsset(String modelNumber){
        ModelNumberResponse assetInfo = new ModelNumberResponse();
        try {
            assetInfo = CX_AssetVerificationService.getInstance().getAssetInfo(modelNumber);
        } catch (Exception ex) {
            CX_Utils.throwHandledException(ex, 'An error occurred while validating model');
        }
        return JSON.serialize(assetInfo);
    }
    /**
     * @author         Gunhan Gultekin
     * @company        PolSource
     * @created        02.06.2021
     * @description    Creates the assest on both SF and SeibelSide
     * @param          String - asInfo JSON string that keeps the validated Asset info
     * @param          String - CaseId releatedCaseId
     * @param          String - modelNumber that user populated
     * @param          String - serialNumber that user populated
     * @param          Date - installDate  that user populated
     * @param          String - inWarranty  that user populated
     * @return         String - retunrs an error message or 'ok' for successfull transactions;
     */
    @AuraEnabled
    public static String createAsset(String asInfo,String caseId,String modelNumber,String serialNumber,Date installDate,String inWarranty){
        ModelNumberResponse assetInfo = new ModelNumberResponse();
        try {
            assetInfo = (ModelNumberResponse)JSON.deserialize(asInfo, ModelNumberResponse.class);
            Case currentCase = CX_CaseDAO.getInstance().getCase(Id.valueOf(caseId));
            CX_AssetVerification.getInstance().createAsset(modelNumber, serialNumber, installDate, currentCase, assetInfo,inWarranty);      
        } catch (Exception ex) {
            CX_Utils.throwHandledException(ex, 'An error occurred while creating asset'+ ex.getMessage());
        }
        return 'ok';  
    }
    
    /**
     * @author         Gunhan Gultekin
     * @company        PolSource
     * @created        02.06.2021
     * @description    Creates the assest on both SF and SeibelSide
     * @param          String - Json String that deserialized
     * @param          Id     - CaseId transaction case
     * @return         String - returns the created contact.
     */
    @AuraEnabled
    public static contact createContact(String wrapperString, Id caseId){
        system.debug('in createContact');
        Contact tContact = new Contact();
        try {
            CX_ContactCreationWrapper wrap = (CX_ContactCreationWrapper)JSON.deserializeStrict(wrapperString, CX_ContactCreationWrapper.class);
           
            Case currentCase;

            if(String.isNotBlank(caseId)) {
                currentCase = CX_CaseDAO.getInstance().getCase(caseId);
            }
        
            tContact = CX_ContactCreation.getInstance().createContact(wrap, currentCase);
           
        } catch (Exception ex) {
            system.debug('Exception'+ex+' at line'+ex.getMessage()+'@@linenumber:'+ex.getLinenumber());
            CX_Utils.throwHandledException(ex, 'An error occurred while creating contactAndLocation');
        }
        return tContact;
    }
}