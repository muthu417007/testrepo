//THIS CLASS IS USED TO CREATE FOR THE CONSUMER IN EBS
public class CreateConsumerInEBS {
	@InvocableMethod(label='Create Consumer in EBS' description='Create Consumer in EBS')
    public static List<string> CreateConsumerInEBS(List<Requests> strInput) {
        for (Requests input : strInput) {
            List<string> strEBSResult = new List<string>(); 
            String response;
            response = CreateConsumerAPI.CreateConsumerAPI(input.varPayload);
            JSONParser parser = JSON.createParser(response);
            String varOutput = '';
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == System.Label.EBSResponseAttribute_XAccountNumber)) {
                    parser.nextToken();
                    varOutput = parser.getText();
                }
            }
            strEBSResult.add(varOutput);
            return strEBSResult;
        }
        return null;
    }
    public class Requests{
    	@InvocableVariable
        public String varPayload;
    }
}