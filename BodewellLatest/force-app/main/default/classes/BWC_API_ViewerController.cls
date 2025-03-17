public class BWC_API_ViewerController {
    @AuraEnabled(cacheable = true)
    public static String hitMuleAPI(String Name){
        try{
            String response;
            BWC_Mule_API__c muleApiInstance = [SELECT Id,
                                               BWC_Payload__c,
                                               BWC_Status__c,
                                               BWC_NamedCredRef__c,
                                               BWC_Respone__c 
                                               FROM BWC_Mule_API__c
                                               WHERE Name = :Name
                                               LIMIT 1];
            if(!test.isRunningTest()){
                if(utility.isSandbox){
                    response = RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_QA_Token',muleApiInstance.BWC_NamedCredRef__c,null,'POST',muleApiInstance.BWC_Payload__c);
                }
                else{
                    response = RequestMuleAPIData.getMuleAPIData('BWC_Production_MuleAuth','BWC_PROD_EBS_Token',muleApiInstance.BWC_NamedCredRef__c,null,'POST',muleApiInstance.BWC_Payload__c);
                }
            }
            else{
                response='{"X_HEADER_REC": {"HEADER_ID": "Header123","FLOW_STATUS_CODE": "BOOKED","ORDER_NUMBER": "Order123"},"X_LINE_TBL":{"X_LINE_TBL_ITEM": [{"LINE_ID": "Line1","ORDERED_ITEM": "sf3"}]}}';
            }
            return response;
        }
        catch(Exception e){
            System.debug('Exception BWC_API_ViewerController.hitMuleAPI message' + e.getMessage());
            System.debug('Exception BWC_API_ViewerController.hitMuleAPI Line Number' + e.getLineNumber());
            return null;
        }
    }
    @AuraEnabled(cacheable = true)
    public static List<BWC_Mule_API__c> fetchMuleApiRecords(){
        try{
            return [SELECT Id,
                    Name,
                    BWC_Payload__c,
                    BWC_Status__c,
                    BWC_NamedCredRef__c,
                    BWC_Respone__c 
                    FROM BWC_Mule_API__c]; 
        }
        catch(Exception e){
            System.debug('Exception BWC_API_ViewerController.fetchMuleApiRecords message' + e.getMessage());
            System.debug('Exception BWC_API_ViewerController.fetchMuleApiRecords Line Number' + e.getLineNumber());
            return null;
        }
    }
}