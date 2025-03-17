/**
   * @description created by : Gowsic
   * Test class : GetEBSWarehouseLocationTest
*/
public class GetEBSWarehouseLocation {
	/**
	 * @description return location warehouse data.
	 * @param strInput
	 * @return location warehouse number.
	*/
	@InvocableMethod(label='Get EBS Ware house Location' description='Get EBS Ware house Location')
    public static List<string> GetEBSWarehouseLocation(List<String> strInput) {
        List<string> strEBSResult = new List<string>(); 
        String response;
        //response=RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_Token','Sandbox_CommerceCloudWarehouse',null,'POST',strInput.get(0));
        //response=RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_QA_Token','Sandbox_CommerceCloudWarehouse_QA',null,'POST',strInput.get(0));
        if(utility.isSandbox){
            response=RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_QA_Token','Sandbox_CommerceCloudWarehouse_QA',null,'POST',strInput.get(0));
        }
        else {
            response=RequestMuleAPIData.getMuleAPIData('Production_MuleAuth','PROD_EBS_Token','PROD_CommerceCloudWarehouse',null,'POST', strInput.get(0));
        }
        ///////////////////////
        JSONParser parser = JSON.createParser(response);
        JSONParser parser1 = JSON.createParser(response);
        Double grandTotal = 0.0;
        String strOrigSysDocumentRef = '';
        String strPONumber = '';
        String strWarehouse = '';
        Integer SDSLOCPos = 0;
        Integer SDSLOCPos1 = 0;
        Integer OutputSDSLOCPos = 0;
        String OutputSDSLOC = '';
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'loc_type')) {
                parser.nextToken();
                SDSLOCPos = SDSLOCPos + 1;
                if(parser.getText() == 'sds_loc'){
                    OutputSDSLOCPos = SDSLOCPos;
                }
            }
        }
        SDSLOCPos1 = 0;
        while (parser1.nextToken() != null) {
            if ((parser1.getCurrentToken() == JSONToken.FIELD_NAME) && (parser1.getText() == 'agent_id')) {
                parser1.nextToken();
                SDSLOCPos1 = SDSLOCPos1 + 1;
                if (SDSLOCPos1 == OutputSDSLOCPos)
                {
                    OutputSDSLOC = parser1.getText();
                }
                else
                {
                    system.debug('OUTPUT_agent_id DIFFERENT SDS POS: ' + parser1.getText());
                }
            }
        }
        //return OutputSDSLOC;
        //////////////////
        strEBSResult.add(OutputSDSLOC);
        return strEBSResult; 
    }
}