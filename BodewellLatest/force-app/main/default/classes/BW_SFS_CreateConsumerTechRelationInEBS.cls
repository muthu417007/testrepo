public class BW_SFS_CreateConsumerTechRelationInEBS {
	@InvocableMethod(label='Create Consumer Tech Relation in EBS Aync' description='Create Consumer Tech Relation in EBS Aync')
    public static List<List<String>> CreateConsumerTechRelationInEBS(List<Request> req) {
    List<List<String>> strEBSResult = new List<List<String>>();
    List<String> resId = new List<String>();
    for(Request r:req){
		BW_SFS_ConsumerTechRelationUpdate.BW_SFS_ConsumerTechRelationUpdate(r.payLoad,r.ServiceAppointmentId);  //This is to Sabrix API Callout
        resId.add(string.valueOf(r.ServiceAppointmentId));
        	strEBSResult.add(resId);
        }  
    	return strEBSResult;
    }
    public class Request {
        @InvocableVariable(required=true)
         public String payload;
        @InvocableVariable(required=true)
         public Id ServiceAppointmentId;
   }
    ////////////
}