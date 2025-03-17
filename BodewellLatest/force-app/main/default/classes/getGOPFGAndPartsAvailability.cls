/**
   * @description created by : Satya Reddy
   * This class is to call oracle inventory GOP API to get the FG AND Parts Availability
   * Test class : 
*/

public class getGOPFGAndPartsAvailability {
/**
	 * @description return FG And Parts Availabilitites from EBS.
	 * @param body - JSON
	 * @return json format of FG And PArts availabilities.
	*/
@AuraEnabled(Cacheable = true)    
    public Static String getGOPFGAndPartsAvailability(String body){
		String reqbody=body;
        String res;
        

        if(utility.isSandbox){
           		res= RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth',
                                                   'Sandbox_INV_GOP_V2_Token','Sandbox_Inv_GOP_V2',null,'POST',reqbody);
        } else {
            res= RequestMuleAPIData.getMuleAPIData('Production_MuleAuth',
                                                   'Prod_INV_GOP_V2_Token','Prod_Inv_GOP_V2',null,'POST',reqbody);
        }
        return res;
    } 
}