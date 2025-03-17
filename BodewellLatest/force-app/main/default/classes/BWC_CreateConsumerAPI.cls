public class BWC_CreateConsumerAPI {
    @AuraEnabled(Cacheable = true)    
    public Static String CreateConsumerAPI(String body){
        String reqbody=body;
        String res;
        if(!test.isRunningTest()){
            if(utility.isSandbox){
                res=RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_QA_Token','Sandbox_CommerceCloudCreateConsumer_QA',null,'POST',body);
                //res=RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_DEV_Token','Sandbox_CommerceCloudCreateConsumer_DEV',null,'POST',body);
            }
            else {
                res=RequestMuleAPIData.getMuleAPIData('BWC_Production_MuleAuth','BWC_PROD_EBS_Token','BWC_PROD_CommerceCloudCreateConsumer',null,'POST', body);
            }
        }
        else {
            res = '{"X_Account_Number": "105462631", "X_BILL_TO_ORG_ID": "223832565", "X_SHIP_TO_ORG_ID": "223832564"}';
            res = '{"X_Account_Number": "105462631", "X_BILL_TO_ORG_ID": "223832565", "X_SHIP_TO_ORG_ID": "223832564"}';
            res = '{"X_Account_Number": "105462631", "X_BILL_TO_ORG_ID": "223832565", "X_SHIP_TO_ORG_ID": "223832564"}';
            res = '{"X_Account_Number": "105462631", "X_BILL_TO_ORG_ID": "223832565", "X_SHIP_TO_ORG_ID": "223832564"}';
            res = '{"X_Account_Number": "105462631", "X_BILL_TO_ORG_ID": "223832565", "X_SHIP_TO_ORG_ID": "223832564"}';
            res = '{"X_Account_Number": "105462631", "X_BILL_TO_ORG_ID": "223832565", "X_SHIP_TO_ORG_ID": "223832564"}';
            res = '{"X_Account_Number": "105462631", "X_BILL_TO_ORG_ID": "223832565", "X_SHIP_TO_ORG_ID": "223832564"}';
        }
        //system.debug('res:'+ res);
        return res;
    }
}