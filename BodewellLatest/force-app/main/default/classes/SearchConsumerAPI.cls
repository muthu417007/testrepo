//THIS IS API CLASS FOR SEARCHING THE CONSUMER IN EBS
public without sharing class SearchConsumerAPI {
	@AuraEnabled(Cacheable = true)    
    public Static String SearchConsumerAPI(String body, String strNamedCredential){
		String reqbody=body;
        String res;
        if(utility.isSandbox){
                res=RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_DEV_Token',strNamedCredential,null,'POST',body);
                //res=RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_QA_Token',strNamedCredential,null,'POST',body);
            }
            else {
                res=RequestMuleAPIData.getMuleAPIData('Production_MuleAuth','PROD_EBS_Token','PROD_CommerceCloudSearchConsumer',null,'POST', body);
            }
        ///system.debug('res:'+ res);
        return res;
    }
}