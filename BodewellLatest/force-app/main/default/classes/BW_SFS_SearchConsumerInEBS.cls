public class BW_SFS_SearchConsumerInEBS {
	@InvocableMethod(label='Search Consumer in EBS Aync' description='Search Consumer in EBS Aync')
    public static List<List<String>> SearchConsumerInEBS(List<Request> req) {
    List<List<String>> strEBSResult = new List<List<String>>();
    List<String> resId = new List<String>();
    for(Request r:req){
        BW_SFS_EBSConsumerSearchUpdate.BW_SFS_EBSConsumerSearchUpdate(r.Payload_EmailPhoneSearch,r.Payload_GlobalSearch,r.varEmail,r.varPhone,r.ContactId,r.AccountId,r.ParentObject,r.ParentRecordId,r.varConsumerFirstname,r.varConsumerLastname,r.varShippingAddress1,r.varShippingCity,r.varShippingState,r.varShippingCountry,r.varBillingAddress1,r.varBillingCity,r.varBillingState,r.varBillingCountry); 
        resId.add(string.valueOf(r.ContactId));
            strEBSResult.add(resId);
        }
    	return strEBSResult;
    }
    public class Request {
        @InvocableVariable(required=true)
         public String Payload_EmailPhoneSearch;
        @InvocableVariable(required=true)
         public String Payload_GlobalSearch;
        @InvocableVariable(required=true)
         public String varEmail;
        @InvocableVariable(required=true)
         public String varPhone;
        @InvocableVariable(required=true)
         public Id ContactId;
        @InvocableVariable(required=true)
         public Id AccountId;
         @InvocableVariable(required=true)
         public String ParentObject;
         @InvocableVariable(required=true)
         public Id ParentRecordId;
        @InvocableVariable(required=true)
         public String varConsumerFirstname;
        @InvocableVariable(required=true)
         public String varConsumerLastname;
        
        @InvocableVariable(required=true)
         public String varShippingAddress1;
        @InvocableVariable(required=true)
         public String varShippingCity;
        @InvocableVariable(required=true)
         public String varShippingState;
        @InvocableVariable(required=true)
         public String varShippingCountry;
        
        @InvocableVariable(required=true)
        public String varBillingAddress1;
        @InvocableVariable(required=true)
         public String varBillingCity;
        @InvocableVariable(required=true)
         public String varBillingState;
        @InvocableVariable(required=true)
         public String varBillingCountry;
        
   }
    //////////////
}