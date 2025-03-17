//THIS IS API CLASS FOR CREATING THE CONSUMER TECHNICIAN RELATIONSHIP IN EBS
public class CreateConsumerTechnicianRelationAPI {
	@AuraEnabled(Cacheable = true)    
    public Static String CreateConsumerTechnicianRelationAPI(String body){
		String reqbody=body;
        String res;
        if(utility.isSandbox){
                res=RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_QA_Token','Sandbox_CommerceCloudCreateConsumerTechRelation_QA',null,'POST',body);
                //res=RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_DEV_Token','Sandbox_CommerceCloudCreateConsumerTechRelation_DEV',null,'POST',body);
            }
            else {
                res=RequestMuleAPIData.getMuleAPIData('Production_MuleAuth','PROD_EBS_Token','PROD_CommerceCloudCreateConsumer',null,'POST', body);
            }
        ////system.debug('res:'+ res);
        return res;
    }
}