//THIS IS API CLASS FOR ADDING THE CONSUMER LOCATION IN EBS
public class AddConsumerLocationAPI {
	@AuraEnabled(Cacheable = true)    
    public Static String AddConsumerLocationAPI(String body){
		String reqbody=body;
        String res;
        if(utility.isSandbox){
                //res=RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_QA_Token','Sandbox_CommerceCloudAddLocation_QA',null,'POST',body);
                    res=RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_DEV_Token','Sandbox_CommerceCloudAddLocation_DEV',null,'POST',body);
            }
            else {
                res=RequestMuleAPIData.getMuleAPIData('Production_MuleAuth','PROD_EBS_Token','PROD_CommerceCloudAddLocation',null,'POST', body);
            }
        //system.debug('res:'+ res);
        return res;
    }
}