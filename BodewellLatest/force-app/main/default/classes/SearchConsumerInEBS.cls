//THIS CLASS IS USED TO SEARCH FOR THE CONSUMER IN EBS
public class SearchConsumerInEBS {
	@InvocableMethod(label='Search Consumer in EBS' description='Search Consumer in EBS')
    public static List<string> SearchConsumerInEBS(List<Requests> strInput) {
        for (Requests input : strInput) {
            List<string> strEBSResult = new List<string>(); 
            String response;
            response = SearchConsumerAPI.SearchConsumerAPI(input.varPayload);
            JSONParser parser = JSON.createParser(response);
            String OutputAccountNumber = '';
            String OutputConsumerFirstname = '';
            String OutputConsumerLastname = '';
            Integer OutputsCount = 0;
            Map<String, String> OutputMap = new Map<String, String>();
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == System.Label.EBSResponseAttribute_AccountNumber)) {
                    parser.nextToken();
                    OutputAccountNumber = parser.getText();
                }
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == System.Label.EBSResponseAttribute_PersonFirstName)) {
                    parser.nextToken();
                    OutputConsumerFirstname = parser.getText();
                }
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == System.Label.EBSResponseAttribute_PersonLastName)) {
                    parser.nextToken();
                    OutputConsumerLastname = parser.getText();
                    OutputsCount = OutputsCount + 1;
                }
                if (String.isNotBlank(OutputAccountNumber) && String.isNotBlank(OutputConsumerFirstname) && String.isNotBlank(OutputConsumerLastname))
                {
                    OutputMap.put(OutputAccountNumber, OutputConsumerFirstname + ' ' + OutputConsumerLastname);
                }
            }
            if (OutputsCount > 1)
            {
                String value = input.varConsumerFirstName + ' ' + input.varConsumerLastName;
                for(String key : OutputMap.keySet()){
                  if(OutputMap.get(key) == value){
                      OutputAccountNumber = key;
                  }
            	}
            }
            strEBSResult.add(OutputAccountNumber);
            return strEBSResult;
        }
        return null;
    }
    public class Requests{
    	@InvocableVariable
        public String varPayload;
        
        @InvocableVariable
        public String varConsumerFirstName;
        
        @InvocableVariable
        public String varConsumerLastName;
    }
}