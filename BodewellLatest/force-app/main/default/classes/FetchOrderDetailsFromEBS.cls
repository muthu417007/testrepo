/**
   * @description created by : Gowsic
   * Test class : FetchOrderDetailsFromEBSTest
*/
public class FetchOrderDetailsFromEBS {
	/**
	 * @description return OrderDetails from EBS.
	 * @param strInput
	 * @return orderdetail response for a given order number.
	*/
	@InvocableMethod(label='Fetch Order Details From EBS' description='Fetch Order Details From EBS')
    public static List<string> FetchOrderDetailsFromEBS(List<String> strInput) {
        List<string> strEBSResult = new List<string>();
        String response;
        //response=RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_Token','Sandbox_CommerceCloudGetOrderDetails',null,'POST', strInput.get(0));
        //response=RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_QA_Token','Sandbox_CommerceCloudGetOrderDetails_QA',null,'POST', strInput.get(0));
        if(utility.isSandbox){
            response=RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_QA_Token','Sandbox_CommerceCloudGetOrderDetails_QA',null,'POST', strInput.get(0));
        }
        else {
            response=RequestMuleAPIData.getMuleAPIData('Production_MuleAuth','PROD_EBS_Token','PROD_CommerceCloudGetOrderDetails',null,'POST', strInput.get(0));
        }
        ////////////////////////////////
        JSONParser parser = JSON.createParser(response);
        Double grandTotal = 0.0;
        String strOrigSysDocumentRef = '';
        String strPONumber = '';
        String strBookedFlag = '';
        String strAttribute9 = '';
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'BOOKED_FLAG') && strBookedFlag =='') {
                parser.nextToken();
                strBookedFlag = parser.getText();
            }
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'ATTRIBUTE9') && strAttribute9 =='') {
                parser.nextToken();
                strAttribute9 = parser.getText();
            }
        }
        //return strOrderNumber;
        ///////////////////////////
        strEBSResult.add(strBookedFlag + '$' + strAttribute9);
        return strEBSResult; 
    }
}