/**
 * This class is responsible for hitting the Subscription API to Oracle.
 * Author: Abhishek
 * Date: 06/02/2024
 */
public class BWC_SubscriptionOrder {
    
    /**
     * This method is used to hit the Mule subscription API with given order instance.
     * 
     * @param orderInstance Instance of Order record
     * @return String Response from the API
     */
    @AuraEnabled(Cacheable = true)
    public static  Map<String, List<String>> subscriptionOrder(Order orderInstance) {

    /**************************************************************************************************************/

    String billingPlanHeaderId;
    String status;
    String fakeResponse = '{"X_BILLING_PLAN_HEADER_TBL" : {"P_BILLING_PLAN_HEADER_TBL_ITEM": [{"BILLING_PLAN_HEADER_ID" : "12345"}] }}';
    String result;
    list<String> orderProductList = new list<String>();
    Map<String, List<String>> headerIdOrderProdId = new Map<String, List<String>>();
    String jsonRequest;

    /*SubscriptionCreate request = new SubscriptionCreate();
    request.P_ORG_ID = '82';	//82
    //request.P_OPERATING_UNIT = null; //null
	//request.P_API_VERSION_NUMBER = '1.0';	//1.0
	//request.P_INIT_MSG_LIST = 'T';	//T
	//request.P_RETURN_VALUES = 'T';	//T
	//request.P_ACTION_COMMIT = 'T    ';*/
    JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('P_ORG_ID', '82');
         gen.writeFieldName('P_BILLING_PLAN_HEADER_TBL');
        gen.writeStartObject();
        gen.writeFieldName('P_BILLING_PLAN_HEADER_TBL_ITEM');
    
    Date todaysDate = system.today();
    String year = String.valueOf(todaysDate.year());
     String month =  String.valueOf(todaysDate.month()).length() == 1 ? '0'+String.valueOf(todaysDate.month()) : String.valueOf(todaysDate.month());
     String day =  String.valueOf(todaysDate.day()).length() == 1 ? '0'+String.valueOf(todaysDate.day()) : String.valueOf(todaysDate.day());
     String enrollDate = year + '-'+month+'-'+day;
    SubscriptionCreate.cls_P_BILLING_PLAN_HEADER_TBL headerTable = new SubscriptionCreate.cls_P_BILLING_PLAN_HEADER_TBL();

    list<SubscriptionCreate.cls_P_BILLING_PLAN_HEADER_TBL_ITEM> tableItemList = new list<SubscriptionCreate.cls_P_BILLING_PLAN_HEADER_TBL_ITEM>();
    for(OrderItem orderItemInstance: 
    [SELECT Id, OrderItemExternalId__c,UnitPrice,BWC_SO_Order_Frequency__c FROM OrderItem WHERE OrderId=:orderInstance.Id 
    AND Product2.Name = 'BODEWELL CARE+ MONTHLY PROTECTION PLAN'])//OrderItemExternalId__c != null AND BWC_SO_Order_Frequency__c != null
    { 
        orderProductList.add(orderItemInstance.Id);
         gen.writeStartArray();
         gen.writeStartObject();
          gen.writeStringField('OPERATION', 'CREATE');
          //gen.writeStringField('SOURCE_ORDER_HEADER_ID', orderInstance.BWC_HeaderId__c);
          //gen.writeStringField('SOURCE_ORDER_LINE_ID', orderItemInstance.OrderItemExternalId__c);
          gen.writeStringField('SOURCE_ORDER_HEADER_ID', orderInstance.BWC_HeaderId__c);
          gen.writeStringField('SOURCE_ORDER_LINE_ID', orderItemInstance.OrderItemExternalId__c);
          gen.writeStringField('BILLING_PLAN_STATUS', 'OPEN');
         gen.writeStringField('BILL_WITH_SOURCE_LINE', 'N');
         gen.writeStringField('BILLING_FREQUENCY', '1');
          gen.writeStringField('BILLING_PERIOD', 'MTH');
          gen.writeStringField('START_DATE', enrollDate);
          //gen.writeStringField('BILLING_AMOUNT', String.valueOf(orderItemInstance.UnitPrice));
          gen.writeStringField('BILLING_AMOUNT', String.valueOf(orderItemInstance.UnitPrice));
          gen.writeStringField('NUMBER_OF_BILLING_PLAN_LINES', '12');
          gen.writeStringField('TYPE_OF_BILLING', 'F');
          gen.writeStringField('LINE_INDEX', '1');
          gen.writeStringField('GENERATE_BILLING_PLAN_LINES', 'Y');
          gen.writeEndObject();
          gen.writeEndArray();
          //loop end here
        
        

        /*SubscriptionCreate.cls_P_BILLING_PLAN_HEADER_TBL_ITEM tableItem = new SubscriptionCreate.cls_P_BILLING_PLAN_HEADER_TBL_ITEM();
        tableItem.OPERATION = 'CREATE';	//CREATE
        tableItem.SOURCE_ORDER_HEADER_ID = orderInstance.BWC_HeaderId__c;	//49016732
        tableItem.SOURCE_ORDER_LINE_ID = orderItemInstance.OrderItemExternalId__c;	//189388320

        //tableItem.SOURCE_ORDER_HEADER_ID = orderInstance.BWC_HeaderId__c;	//49016732
        //tableItem.SOURCE_ORDER_LINE_ID = orderItemInstance.OrderItemExternalId__c;	//189388320

        tableItem.BILLING_PLAN_STATUS = 'OPEN';	//OPEN
        tableItem.BILL_WITH_SOURCE_LINE = 'N';	//N
        tableItem.BILLING_FREQUENCY = '1';	//1
        tableItem.BILLING_PERIOD = 'MTH';	//MTH
        tableItem.START_DATE = enrollDate;	//2024-09-09
        tableItem.BILLING_AMOUNT = String.valueOf(orderItemInstance.UnitPrice);	//200
        tableItem.NUMBER_OF_BILLING_PLAN_LINES = '12';	//12
        tableItem.TYPE_OF_BILLING = 'F';	//F
        //tableItem.RETURN_STATUS = null;
        tableItem.LINE_INDEX = '1';	//1
        tableItem.GENERATE_BILLING_PLAN_LINES = 'Y';	//Y
        //tableItem.USAGE_UNIT_DESC = null;
        //tableItem.TYPE_OF_USAGE = null;
        tableItemList.add(tableItem);*/
     }
    /*headerTable.P_BILLING_PLAN_HEADER_TBL_ITEM = tableItemList;
    request.P_BILLING_PLAN_HEADER_TBL = headerTable;*/
    gen.writeEndObject(); 
    gen.writeEndObject();
            
    jsonRequest = gen.getAsString();
    system.debug('subscriptionOrder jsonRequest - ' + jsonRequest);
    /*String jsonRequest = JSON.serialize(request);
    System.debug(jsonRequest);*/
    
    result = test.isRunningTest() ? fakeResponse : Utility.isSandbox ? RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth', 'Sandbox_EBS_QA_Token', 'Sandbox_CommerceCloud_SubscriptionOracleQA', null, 'POST', jsonRequest) : RequestMuleAPIData.getMuleAPIData('Production_MuleAuth', 'PROD_EBS_Token', 'Sandbox_CommerceCloud_SubscriptionOracle', null, 'POST', jsonRequest);
    system.debug('subscriptionOrder result - ' + result);


    
    JSONParser parser = JSON.createParser(result);
    while(parser.nextToken() != null)
            {
                if (parser.getCurrentToken() == JSONToken.START_OBJECT) 
                {
                    continue;
                }
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) 
                {
                    String fieldName = parser.getText();
                    parser.nextToken(); // Move to the value of the field
                    if (fieldName == 'X_RETURN_STATUS') 
                    {
                        status = parser.getText();
                        system.debug('Integration status - ' + status);
                    }
                    if(status == 'E')
                    {
                        system.debug('In faliure status, Subscription failed');
                        break;
                    }
                    if(status == 'S' && fieldName == 'BILLING_PLAN_HEADER_ID')
                    {
                        system.debug('In success status, Subscription passed');
                        billingPlanHeaderId = parser.getText();
                            
                        break;
                    }

                } 
            } 
        headerIdOrderProdId.put(billingPlanHeaderId, orderProductList);
        return headerIdOrderProdId;
        //return billingPlanHeaderId; 
    }
    


    /**************************************************************************************************************/
        /*
        String fakeResponse = '{"X_BILLING_PLAN_HEADER_TBL" : {"P_BILLING_PLAN_HEADER_TBL_ITEM": [{"BILLING_PLAN_HEADER_ID" : "12345"}] }}';
        // Generate JSON payload from the order instance
        String reqbody = BWC_SubscriptionOrderPayloadGenerator.generateJsonFromString(orderInstance);
        String res;
        String subscriptionOrderBilllingPlainId;
        // Determine whether it is running for test and also if it's a sandbox environment or not
        res = test.isRunningTest() ? fakeResponse : Utility.isSandbox ? RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth', 'Sandbox_EBS_QA_Token', 'Sandbox_CommerceCloud_SubscriptionOracleQA', null, 'POST', reqbody) : RequestMuleAPIData.getMuleAPIData('Production_MuleAuth', 'PROD_EBS_Token', 'Sandbox_CommerceCloud_SubscriptionOracle', null, 'POST', reqbody);
        CreateSubscriptionWrapper jsonData = (CreateSubscriptionWrapper)JSON.deserialize(res, CreateSubscriptionWrapper.class);
        subscriptionOrderBilllingPlainId = jsonData.P_BILLING_PLAN_HEADER_TBL.P_BILLING_PLAN_HEADER_TBL_ITEM[0].BILLING_PLAN_HEADER_ID;
        System.debug(res);
        return subscriptionOrderBilllingPlainId;
    }

  
    
    // Inner classes for defining wrapper and payload structure
    
    // Wrapper for Subscription Payload
    public class CreateSubscriptionWrapper {
        // Instance of BillingPlanHeaderTable
        BillingPlanHeaderTable P_BILLING_PLAN_HEADER_TBL;
    }
    
    // Wrapper for Billing Plan Header Table
    public class BillingPlanHeaderTable {
        // List of Billing Plan Header Table Items
        List<BillingPlanHeaderTableItem> P_BILLING_PLAN_HEADER_TBL_ITEM = new List<BillingPlanHeaderTableItem>();
    }
    
    // Item in Billing Plan Header Table
    public class BillingPlanHeaderTableItem {
        // ID of the billing plan header
        String BILLING_PLAN_HEADER_ID;
    }
    */
/**************************************************************************************************************/
    public static void  DummyParsing() 
    {

        Date todaysDate = system.today();
    String year = String.valueOf(todaysDate.year());
     String month =  String.valueOf(todaysDate.month()).length() == 1 ? '0'+String.valueOf(todaysDate.month()) : String.valueOf(todaysDate.month());
     String day =  String.valueOf(todaysDate.day()).length() == 1 ? '0'+String.valueOf(todaysDate.day()) : String.valueOf(todaysDate.day());
     String enrollDate = year + '-'+month+'-'+day;
        
        String jsonRequest;
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('P_ORG_ID', '82');
         gen.writeFieldName('P_BILLING_PLAN_HEADER_TBL');
        gen.writeStartObject();
        gen.writeFieldName('P_BILLING_PLAN_HEADER_TBL_ITEM');
        //loop start here
         gen.writeStartArray();
         gen.writeStartObject();
          gen.writeStringField('OPERATION', 'CREATE');
          //gen.writeStringField('SOURCE_ORDER_HEADER_ID', orderInstance.BWC_HeaderId__c);
          //gen.writeStringField('SOURCE_ORDER_LINE_ID', orderItemInstance.OrderItemExternalId__c);
          gen.writeStringField('SOURCE_ORDER_HEADER_ID', '49016732');
          gen.writeStringField('SOURCE_ORDER_LINE_ID', '189388324');
          gen.writeStringField('BILLING_PLAN_STATUS', 'OPEN');
         gen.writeStringField('BILL_WITH_SOURCE_LINE', 'N');
         gen.writeStringField('BILLING_FREQUENCY', '1');
          gen.writeStringField('BILLING_PERIOD', 'MTH');
          gen.writeStringField('START_DATE', enrollDate);
          //gen.writeStringField('BILLING_AMOUNT', String.valueOf(orderItemInstance.UnitPrice));
          gen.writeStringField('BILLING_AMOUNT', '200');
          gen.writeStringField('NUMBER_OF_BILLING_PLAN_LINES', '12');
          gen.writeStringField('TYPE_OF_BILLING', 'F');
          gen.writeStringField('LINE_INDEX', '1');
          gen.writeStringField('GENERATE_BILLING_PLAN_LINES', 'Y');
          gen.writeEndObject();
          gen.writeEndArray();
          //loop start here
        gen.writeEndObject(); 
        gen.writeEndObject();
            
            jsonRequest = gen.getAsString();
            system.debug('dummyparsing jsonRequest - ' + jsonRequest);
        

        String fakeResponse = '{"X_BILLING_PLAN_HEADER_TBL" : {"P_BILLING_PLAN_HEADER_TBL_ITEM": [{"BILLING_PLAN_HEADER_ID" : "12345"}] }}';
        String res;
        res = test.isRunningTest() ? fakeResponse : Utility.isSandbox ? RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth', 'Sandbox_EBS_QA_Token', 'Sandbox_CommerceCloud_SubscriptionOracleQA', null, 'POST', jsonRequest) : RequestMuleAPIData.getMuleAPIData('Production_MuleAuth', 'PROD_EBS_Token', 'Sandbox_CommerceCloud_SubscriptionOracle', null, 'POST', jsonRequest);

        system.debug('dummyparsing res - ' + res);
        JSONParser parser = JSON.createParser(res);
        String status;
    while(parser.nextToken() != null)
            {
                if (parser.getCurrentToken() == JSONToken.START_OBJECT) 
                {
                    continue;
                }
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) 
                {
                    String fieldName = parser.getText();
                    parser.nextToken(); // Move to the value of the field
                    if (fieldName == 'X_RETURN_STATUS') 
                    {
                        status = parser.getText();
                        system.debug('dummyparsing Integration status - ' + status);
                    }
                    if(status == 'E' && fieldName == 'BILLING_PLAN_HEADER_ID')
                    {
                        system.debug('dummyparsing In faliure status, Subscription failed, BILLING_PLAN_HEADER_ID value - ' + parser.getText());
                        break;
                    }
                    if(status == 'S' && fieldName == 'BILLING_PLAN_HEADER_ID')
                    {
                        system.debug('dummyparsing In success status, Subscription passed, BILLING_PLAN_HEADER_ID - ' + parser.getText());
                       
                            
                        break;
                    }

                } 
            } 

    }

/*SubscriptionCreate request = new SubscriptionCreate();
        request.P_ORG_ID = '82';	//82
        //request.P_OPERATING_UNIT = null; //null
        //request.P_API_VERSION_NUMBER = '1.0';	//1.0
        //request.P_INIT_MSG_LIST = 'T';	//T
        //request.P_RETURN_VALUES = 'T';	//T
        //request.P_ACTION_COMMIT = 'T'; //T

        SubscriptionCreate.cls_P_BILLING_PLAN_HEADER_TBL headerTable = new SubscriptionCreate.cls_P_BILLING_PLAN_HEADER_TBL();

        list<SubscriptionCreate.cls_P_BILLING_PLAN_HEADER_TBL_ITEM> tableItemList = new list<SubscriptionCreate.cls_P_BILLING_PLAN_HEADER_TBL_ITEM>();
      
            SubscriptionCreate.cls_P_BILLING_PLAN_HEADER_TBL_ITEM tableItem = new SubscriptionCreate.cls_P_BILLING_PLAN_HEADER_TBL_ITEM();
            tableItem.OPERATION = 'CREATE';	//CREATE
            tableItem.SOURCE_ORDER_HEADER_ID = '49016732';
            tableItem.SOURCE_ORDER_LINE_ID = '189388324';
            tableItem.BILLING_PLAN_STATUS = 'OPEN';	//OPEN
            tableItem.BILL_WITH_SOURCE_LINE = 'N';	//N
            tableItem.BILLING_FREQUENCY = '1';	//1
            tableItem.BILLING_PERIOD = 'MTH';	//MTH
            tableItem.START_DATE = '2024-03-20';	//2024-09-09
            tableItem.BILLING_AMOUNT = '200';
            tableItem.NUMBER_OF_BILLING_PLAN_LINES = '12';	//12
            tableItem.TYPE_OF_BILLING = 'F';	//F
            //tableItem.RETURN_STATUS = null;
            tableItem.LINE_INDEX = '1';	//1
            tableItem.GENERATE_BILLING_PLAN_LINES = 'Y';	//Y
            //tableItem.USAGE_UNIT_DESC = null;
            //tableItem.TYPE_OF_USAGE = null;
            tableItemList.add(tableItem);
       
        headerTable.P_BILLING_PLAN_HEADER_TBL_ITEM = tableItemList;
        request.P_BILLING_PLAN_HEADER_TBL = headerTable;
        String jsonRequest = JSON.serialize(request);
        System.debug('dummyparsing jsonRequest - ' + jsonRequest);*/

}