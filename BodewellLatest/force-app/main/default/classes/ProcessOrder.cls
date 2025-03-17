/**
* @author Abhishek
* @date 04/08/2023
* @description This class is used to send commerce data to oracle database after ordersummary creation.
*/
public without sharing class ProcessOrder {
    /*
* @description This method is Invocable and it is calling from BW Order Summary flow
* @param orderIdInstance - This parameter is coming from flow
* @return
*/
    @InvocableMethod(label='Process Order Summary Via BW Order Summary' description='Process Order Summary Via BW Order Summary')
    public static void createOrderInOracle(List<String> orderIdInstance){
        
        Map<Id,OrderItem> orderItemMap = new Map<Id,OrderItem>([SELECT Id, Product2.Name, OrderId, Order.OwnerId, Order.Owner.Name FROM OrderItem 
        WHERE OrderId IN : orderIdInstance AND Product2.Name = 'BODEWELL MEMBERSHIP']);
        

        try{

            for(OrderItem orderItemInstance : orderItemMap.values())
            {
                system.debug('In new code for Enrollment');
                system.debug('(orderItemInstance.Order.OwnerId - ' + orderItemInstance.Order.OwnerId);
                system.debug('orderItemInstance.Order.Owner.Name - ' + orderItemInstance.Order.Owner.Name);
                BWC_ManageSubscription.enroll(orderItemInstance.Order.OwnerId);
            }
            for(Id idInstance : orderIdInstance){
                orderCreationInOracle(idInstance);
            }
        }
        catch(Exception e){
            System.debug('Exception ProcessOrder message-->'+e.getMessage());
            System.debug('Exception ProcessOrder line number-->'+e.getLineNumber());
        } 
    }
    /*
* @description This is future method which is used to call callOracleApi method
* @param orderIdInstance - This parameter is coming from flow
* @return
*/
    @future(callout=true)
    public static void orderCreationInOracle(String orderIdInstance){ 
        callOracleApi(orderIdInstance,'create order');
    }
    /*
* @description This is method is used to hit process order api and store data in order and orderitem from oracle databas
* @param orderIdInstance - This parameter is coming from flow
* @param orderStatusCheck - This parameter is status check for create or delete the order in oracle
* @return
*/
    public static void callOracleApi(String orderIdInstance,String orderStatusCheck){
        try{
            String closedStatus = 'Closed';
            List<String> orderIdListInstance = new List<String>();
            List<OrderItem> orderItemList = new List<OrderItem>();
            Map<String,String> productSkuVSJsonLineId = new Map<String,String>();
            String response;
            orderIdListInstance.add(orderIdInstance);
            JSONGenerator gen = OrderBodyCreater.createJsonBodyForOrder(orderIdListInstance);
            String jsonString = gen != null ? gen.getAsString() : '';
            
            System.debug('ORALCE PAYLOAD: -> '+jsonString);
            
            if(!test.isRunningTest()){
                if(utility.isSandbox){
                    response = RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_QA_Token','Sandbox_CommerceCloudProcessOrderQA',null,'POST',jsonString);
                }
                else{
                    response = RequestMuleAPIData.getMuleAPIData('BWC_Production_MuleAuth','BWC_PROD_EBS_Token','BWC_PROD_CommerceCloudProcessOrder',null,'POST',jsonString);
                }
            }
            else{
                response='{"X_HEADER_REC": {"HEADER_ID": "Header123","FLOW_STATUS_CODE": "BOOKED","ORDER_NUMBER": "Order123"},"X_LINE_TBL":{"X_LINE_TBL_ITEM": [{"LINE_ID": "Line1","ORDERED_ITEM": "sf3"}]}}';
            }
            System.debug('response-->'+response);
            ProcessOrderResponseWrapper jsonData = (ProcessOrderResponseWrapper)JSON.deserialize(response, ProcessOrderResponseWrapper.class);
            
            Order ord = [SELECT Id, 
                         CreatedById,
                         BWC_ORIG_SYS_DOCUMENT_REF__c,
                         OrderReferenceNumber,
                         BillToContactId,
                         BWC_OracleOrderStatus__c,
                         BWC_HeaderId__c,
                         BWC_Oracle_Order_Payload__c,
                         BWC_Oracle_Order_Response__c,
                         BWC_Bill_To_Org_Id__c,
                         BWC_Consumer_Name__c,
                         BWC_Consumer_Number__c,
                         BWC_Ship_To_Org_Id__c,
                         Status,
                         ShippingCity,
                         ShippingCountry,
                         ShippingPostalCode,
                         ShippingState,
                         ShippingStreet
                         FROM Order 
                         WHERE Id = :orderIdInstance];
            
            User userInstance = [SELECT Id, 
                                 AccountId,
                                 ContactId
                                 FROM User 
                                 WHERE Id = :ord.CreatedById
                                 LIMIT 1];
            
            List<ContactPointAddress> conPointAddressList = [SELECT Id,
                                                             Name,
                                                             BWC_Ship_To_Org_Id__c,
                                                             BWC_Bill_To_Org_Id__c,
                                                             BWC_Account_Number__c,
                                                             Address,
                                                             City,
                                                             Country,
                                                             PostalCode,
                                                             State,
                                                             Street
                                                             FROM ContactPointAddress 
                                                             WHERE IsDefault = TRUE 
                                                             AND AddressType='Shipping' 
                                                             AND ParentId=:userInstance.AccountId
                                                             LIMIT 1];  
            
            List<BWC_Product_Service__c> productServiceList = [SELECT Id,
                                                               BWC_Order_Id__c
                                                               FROM BWC_Product_Service__c 
                                                               WHERE Cart_Item__r.CartId = :[SELECT Id 
                                                                                             FROM WebCart 
                                                                                             WHERE CreatedbyId = :userInstance.Id 
                                                                                             AND Status = :closedStatus
                                                                                             Order By CreatedDate DESC  
                                                                                             LIMIT 1][0].Id];
            
            for(BWC_Product_Service__c productServiceRecord : productServiceList){
                productServiceRecord.BWC_Order_Id__c = orderIdInstance;
            }
            
            if(!productServiceList.isEmpty()){
                update productServiceList;
            }
            
            System.debug('contactPointAddress>>'+conPointAddressList);
            ord.BWC_Oracle_Order_Payload__c = jsonString;
            // ord.BWC_Oracle_Order_Response__c = response;
            if('create order'.equals(orderStatusCheck)){
                ord.BWC_OracleOrderStatus__c = jsonData.X_HEADER_REC.FLOW_STATUS_CODE; 
                ord.BWC_HeaderId__c = jsonData.X_HEADER_REC.HEADER_ID;
                ord.Order_Number__c = jsonData.X_HEADER_REC.ORDER_NUMBER;
                ord.Status = jsonData.X_HEADER_REC.FLOW_STATUS_CODE;
                ord.BWC_Bill_To_Org_Id__c = conPointAddressList[0].BWC_Bill_To_Org_Id__c;
                ord.BWC_Ship_To_Org_Id__c = conPointAddressList[0].BWC_Ship_To_Org_Id__c;
                ord.BWC_Consumer_Name__c = conPointAddressList[0].Name;
                ord.BWC_Consumer_Number__c = conPointAddressList[0].BWC_Account_Number__c;
                ord.ShippingCity = conPointAddressList[0].City;
                ord.ShippingCountry = conPointAddressList[0].Country;
                ord.ShippingPostalCode = conPointAddressList[0].PostalCode;
                ord.ShippingState = conPointAddressList[0].State;
                ord.ShippingStreet = conPointAddressList[0].Street;
                ord.OrderReferenceNumber = ord.BWC_ORIG_SYS_DOCUMENT_REF__c;
                ord.BillToContactId = userInstance.ContactId;
            }
            else if('cancel order'.equals(orderStatusCheck)){
                ord.Status = 'cancelled';  
                ord.Description = jsonData.X_HEADER_REC.FLOW_STATUS_CODE; 
            }
            update ord;
            
            for(Integer i = 0;i < jsonData.X_LINE_TBL.X_LINE_TBL_ITEM.size();i++){
                productSkuVSJsonLineId.put(jsonData.X_LINE_TBL.X_LINE_TBL_ITEM[i].ORDERED_ITEM,jsonData.X_LINE_TBL.X_LINE_TBL_ITEM[i].LINE_ID);
            }
            
            for(OrderItem orderItemInstance : [SELECT Id,
                                               OrderItemExternalId__c,
                                               Product2.StockKeepingUnit 
                                               FROM OrderItem 
                                               WHERE OrderId =: orderIdInstance AND Type!='Delivery Charge']){
                                                   System.debug('orderItems SKU>>>'+orderItemInstance.Product2.StockKeepingUnit);
                                                   System.debug('jsonData.X_LINE_TBL.X_LINE_TBL_ITEM[count].ORDERED_ITEM)>>>'+productSkuVSJsonLineId.get(orderItemInstance.Product2.StockKeepingUnit));
                                                   if(productSkuVSJsonLineId.containsKey(orderItemInstance.Product2.StockKeepingUnit)){
                                                       orderItemInstance.OrderItemExternalId__c = productSkuVSJsonLineId.get(orderItemInstance.Product2.StockKeepingUnit);
                                                       orderItemList.add(orderItemInstance);                
                                                   }
                                               } 
            update orderItemList;
        }
        catch(Exception e){
            System.debug('Error in Process Order>>'+e.getLineNumber()+'>>>Message>>>'+e.getMessage());
        }  
    }
}