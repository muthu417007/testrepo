public class BW_SFS_CreateConsumerInEBS {
    @InvocableMethod(label='Create Consumer in EBS Aync' description='Create Consumer in EBS Aync')
    public static List<List<String>> CreateConsumerInEBS(List<Request> req) {
    List<List<String>> strEBSResult = new List<List<String>>();
    List<String> resId = new List<String>();
    for(Request r:req){
        BW_SFS_EBSConsumerCreateUpdate.BW_SFS_EBSConsumerCreateUpdate(r.payLoad,r.ContactId,r.AccountId,r.ParentObject,r.ParentRecordId);  //This is to Sabrix API Callout
        resId.add(string.valueOf(r.ContactId));
            strEBSResult.add(resId);
        }
    	return strEBSResult;
    }
    public class Request {
        @InvocableVariable(required=true)
         public String payload;
        @InvocableVariable(required=true)
         public Id ContactId;
        @InvocableVariable(required=true)
         public Id AccountId;
        @InvocableVariable(required=true)
         public String ParentObject;
         @InvocableVariable(required=true)
         public Id ParentRecordId;
   }
   /////////////
}