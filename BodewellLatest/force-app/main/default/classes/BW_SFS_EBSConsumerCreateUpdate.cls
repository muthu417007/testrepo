public class BW_SFS_EBSConsumerCreateUpdate {
	@future(callout=true)
    public static void BW_SFS_EBSConsumerCreateUpdate(String Payload, Id ContactId, Id AccountId,String ParentObject,Id ParentRecordId)
    {   
        String varXAccountNumber = '';
        String varXPartyID = '';
        String varXCustAccountID = '';
        String varShipToORGID = '';
        String varBillToORGID = '';
        String varSoldToORGID = '';
        Boolean FlagFoundInEBS = true;
        String response;
        response = CreateConsumerAPI.CreateConsumerAPI(Payload);
        JSONParser parser = JSON.createParser(response);
        String varOutput = '';
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == System.Label.EBSResponseAttribute_XCustAccountID)) {
                parser.nextToken();
                varXCustAccountID = parser.getText();
            }
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == System.Label.EBSResponseAttribute_XAccountNumber)) {
                parser.nextToken();
                varXAccountNumber = parser.getText();
            }
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == System.Label.EBSResponseAttribute_XPartyID)) {
                parser.nextToken();
                varXPartyID = parser.getText();
            }
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == System.Label.EBSResponseAttribute_XShip_TO_ORG_ID)) {
                parser.nextToken();
                varShipToORGID = parser.getText();
            }
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == System.Label.EBSResponseAttribute_XBill_TO_ORG_ID)) {
                parser.nextToken();
                varBillToORGID = parser.getText();
            }
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == System.Label.EBSResponseAttribute_XSold_TO_ORG_ID)) {
                parser.nextToken();
                //varSoldToORGID = parser.getText();
                varSoldToORGID = '';
            }
        }
        List<BW_SFS_EBS_Consumer_Creation_Details__e> ObjConsumerCreation = new List<BW_SFS_EBS_Consumer_Creation_Details__e>();
        ObjConsumerCreation.add(new BW_SFS_EBS_Consumer_Creation_Details__e(ContactId__c = ContactId,
                                               AccountId__c = AccountId,
                                               X_ACCOUNT_NUMBER_for_Create__c = varXAccountNumber,
                                               X_CUST_ACCOUNT_ID_for_Create__c = varXCustAccountID,
                                               X_PARTY_ID_for_Create__c = varXPartyID,
                                               EBS_Ship_to_ORG_ID_for_Create__c = varShipToORGID,
                                               EBS_Bill_to_ORG_ID_for_Create__c = varBillToORGID,
                                               EBS_Sold_to_ORG_ID_for_Create__c = varSoldToORGID,
                                               Parent_Object_Name__c = ParentObject,
                                               Parent_Record_Id__c = ParentRecordId,
                                               Found_in_EBS__c = FlagFoundInEBS));
        List<Database.SaveResult> results = EventBus.publish(ObjConsumerCreation);
    }
    ///////////
}