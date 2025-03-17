public class BW_SFS_ConsumerTechRelationUpdate {
	@future(callout=true)
    public static void BW_SFS_ConsumerTechRelationUpdate(String Payload, Id ServiceAppointmentId)
    {   
        String varXCustTechRelationID = '';
        String response;
        response = CreateConsumerTechnicianRelationAPI.CreateConsumerTechnicianRelationAPI(Payload);
        JSONParser parser = JSON.createParser(response);
        String varOutput = '';
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == System.Label.EBSResponseAttribute_ConsAccountRelationshipId)) {
                parser.nextToken();
                varXCustTechRelationID = parser.getText();
            }
        }
        //
        List<BW_SFS_Consumer_Techn_Relation_Details__e> ObjConsumerCreation = new List<BW_SFS_Consumer_Techn_Relation_Details__e>();
        ObjConsumerCreation.add(new BW_SFS_Consumer_Techn_Relation_Details__e(ServiceAppointmentId__c = ServiceAppointmentId,
                                               Consumer_Tech_Relationship_Number__c = varXCustTechRelationID));
        //ObjConsumerCreation.add(new BW_SFS_Consumer_Techn_Relation_Details__e(ServiceAppointmentId__c = ServiceAppointmentId,
        ////                                       Consumer_Tech_Relationship_Number__c = '12345'));
        List<Database.SaveResult> results = EventBus.publish(ObjConsumerCreation);
    }
    ////////////
}