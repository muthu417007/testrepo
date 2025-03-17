/**
   * @description created by : Gowsic
   * Test class : ProcessConcessionViaEBSTest
*/
public class ProcessConcessionViaEBS {
    /**
	 * @description returns created order in EBS.
	 * @param strInput
	 * @return creates Order in EBS.
	*/

	@InvocableMethod(label='Process Concession Via EBS' description='Process Concession Via EBS')
    public static List<string> ProcessConcessionViaEBS(List<String> strInput) {
        List<string> strEBSResult = new List<string>();
        String response;
        //response=RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_Token','Sandbox_CommerceCloud',null,'POST', strInput.get(0));
        //response=RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_QA_Token','Sandbox_CommerceCloud_QA',null,'POST', strInput.get(0));
        if(utility.isSandbox){
            response=RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_QA_Token','Sandbox_CommerceCloud_QA',null,'POST', strInput.get(0));
        }
        else {
            response=RequestMuleAPIData.getMuleAPIData('Production_MuleAuth','PROD_EBS_Token','PROD_CommerceCloud',null,'POST', strInput.get(0));
        }
        ////////////////////////////////
        JSONParser parser = JSON.createParser(response);
        Double grandTotal = 0.0;
        String strOrigSysDocumentRef = '';
        String strPONumber = '';
        String strOrderNumber = '';
        String strOrderStatus = '';
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'order_number')) {
                parser.nextToken();
                strOrderNumber += parser.getText();
            }
        }
        strEBSResult.add(strOrderNumber);
        return strEBSResult; 
    }
}