/**
* @author Abhishek
* @date 06/02/2024
* @description This class is used to get Subscription payload for hitting API
*/
public class BWC_SubscriptionOrderPayloadGenerator {
    /*
* @description This method is used to generate payload for subscription API
* @param orderInstance - Instance of Order record
* @return String
*/
    public static String generateJsonFromString(Order orderInstance) {
        try {
            System.debug('inside generateJsonFromString');
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('P_ORG_ID', '82');
            gen.writeNullField('P_OPERATING_UNIT');
            gen.writeStringField('P_API_VERSION_NUMBER', '1.0');
            gen.writeStringField('P_INIT_MSG_LIST', 'T');
            gen.writeStringField('P_RETURN_VALUES', 'T');
            gen.writeStringField('P_ACTION_COMMIT', 'T');
            gen.writeFieldName('P_BILLING_PLAN_HEADER_TBL');
            
            gen.writeStartObject();
            System.debug('inside generateJsonFromString loop');
            gen.writeFieldName('P_BILLING_PLAN_HEADER_TBL_ITEM');
            
            for(OrderItem orderItemInstance: [SELECT Id,
                                              OrderItemExternalId__c,
                                              UnitPrice,
                                              BWC_SO_Order_Frequency__c
                                              FROM OrderItem 
                                              WHERE OrderId=:orderInstance.Id 
                                              AND OrderItemExternalId__c != null
                                              AND BWC_SO_Order_Frequency__c != null]) {                                                  
                                                  System.debug('orderItemInstance-->'+orderItemInstance);
                                                  gen.writeStartArray();
                                                  gen.writeStartObject();
                                                  gen.writeNullField('CREATED_BY');
                                                  gen.writeNullField('CREATION_DATE');
                                                  gen.writeNullField('LAST_UPDATED_BY');
                                                  gen.writeNullField('LAST_UPDATE_DATE');
                                                  gen.writeNullField('LAST_UPDATE_LOGIN');
                                                  gen.writeNullField('PROGRAM_APPLICATION_ID');
                                                  gen.writeNullField('PROGRAM_ID');
                                                  gen.writeNullField('PROGRAM_UPDATE_DATE');
                                                  gen.writeNullField('REQUEST_ID');
                                                  gen.writeNullField('ORIG_SYS_BILL_PLAN_HDR_REF');
                                                  gen.writeNullField('DB_FLAG');
                                                  gen.writeStringField('OPERATION', 'CREATE');
                                                  gen.writeNullField('LOCK_CONTROL');
                                                  gen.writeNullField('BILLING_PLAN_HEADER_ID');
                                                  gen.writeStringField('SOURCE_ORDER_HEADER_ID', orderInstance.BWC_HeaderId__c);
                                                  gen.writeStringField('SOURCE_ORDER_LINE_ID', orderItemInstance.OrderItemExternalId__c);
                                                  gen.writeStringField('BILLING_PLAN_STATUS', 'OPEN');
                                                  gen.writeStringField('BILL_WITH_SOURCE_LINE', 'Y');
                                                  //gen.writeStringField('BILLING_FREQUENCY', orderItemInstance.BWC_SO_Order_Frequency__c);
                                                  gen.writeStringField('BILLING_FREQUENCY', '1');
                                                  gen.writeStringField('BILLING_PERIOD', 'MTH');
                                                  Datetime GMTDate = DateTime.now()+1;
                                                  String strConvertedDate = GMTDate.format('yyyy-MM-dd\'T\'HH:mm:ss')+'0Z';
                                                  gen.writeStringField('START_DATE', strConvertedDate);
                                                  gen.writeStringField('BILLING_AMOUNT', String.valueOf(orderItemInstance.UnitPrice));
                                                  gen.writeStringField('NUMBER_OF_BILLING_PLAN_LINES', '1');
                                                  gen.writeStringField('TYPE_OF_BILLING', 'F');
                                                  gen.writeNullField('RETURN_STATUS');
                                                  gen.writeStringField('LINE_INDEX', '1');
                                                  gen.writeStringField('GENERATE_BILLING_PLAN_LINES', 'Y');
                                                  gen.writeNullField('USAGE_UNIT_DESC');
                                                  gen.writeNullField('TYPE_OF_USAGE');
                                                  gen.writeEndObject();
                                                  gen.writeEndArray();
                                              }
            
            gen.writeEndObject(); 
            gen.writeEndObject();
            
            String generatedJson = gen.getAsString();
            System.debug('generatedJson-->'+generatedJson);
            return generatedJson;
        }
        catch(Exception ex){
            system.debug('Error Message subscriptionOrderPayload line number'+ ex.getLineNumber());
            system.debug('Error Message '+ ex.getMessage());
            return null;
        }
    }
}