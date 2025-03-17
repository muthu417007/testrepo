public  without sharing class BWC_OrderConfirmationController {
    
    
     //@description : Method is used for retrieving bodewell order items
     @AuraEnabled (Cacheable=true)
     public static Mya_OrderItems getBodewellOrderItems(string orderRefNumber)
    { 
        
       List<Mya_LineItems> myLineItemList = new list<Mya_LineItems>();
         Mya_OrderItems OI = New Mya_OrderItems();
        List<OrderItem> ordItems  = new List<OrderItem>();
        
        ordItems = [select id ,product2.BWC_Main_Image__c, product2.BWC_Product_Marketing_Description__c,product2.Base_Model__c,Product2.StockKeepingUnit,
                     order.Order_Number__c, order.CreatedDate ,order.OrderReferenceNumber
                      from OrderItem
                      where Order.OrderReferenceNumber= :orderRefNumber and type='Order Product'];
        system.debug('ordItems' +ordItems);
           for(OrderItem items : ordItems){
               system.debug('inside for');
                Mya_LineItems LineItem = new Mya_LineItems();
                LineItem.ShowLineItemFlag = true;
                if(LineItem.ShowLineItemFlag == true){
                     LineItem.LineItemURL = items.Product2.BWC_Main_Image__c;
                     LineItem.ProdDescription = items.product2.BWC_Product_Marketing_Description__c.toString();
                     LineItem.ItemModelNo = items.product2.Base_Model__c;
                    system.debug('LineItem' +LineItem.LineItemURL);
                     myLineItemList.add(LineItem);
                   }
            OI.LineItemList = myLineItemList;
                String domainUrl = Url.getOrgDomainUrl().getHost();
            MYA_Configuration__mdt details = MYA_MetaDataConfigHelper.getmyaConfigByDomain(domainUrl);    
            OI.FGOrderFlag = true;   
            OI.DeliveryInfoURL = details.DeliveryInfoURL__c;
            OI.RescheduleURL = details.RescheduleURL__c;
            OI.TrackMyOrderURL = details.TrackMyOrderURL__c;
            OI.OrderSubTotal = OI.OrderTotal - OI.OrderTax - OI.OrderShippingCharge - OI.OrderDeliveryCharge + OI.OrderDiscount;
           // OI.OrderSubTotalString = decToStr(OI.OrderSubTotal);
               system.debug('order line items' +   OI.LineItemList );
                }
        Return OI;

        }
    
   //For getting product service instalation
     @AuraEnabled(cacheable=false)
    public static BWC_Product_Service__c getProductServiceType(String cartItemId){
        try{        
        BWC_Product_Service__c prodService =  [Select id,Name,BWC_Service_Type__c,BWC_Service_Price__c  from BWC_Product_Service__c where Cart_Item__c=:cartItemId
                                               and BWC_Service_Type__c ='Installation' limit 1];
            return prodService;
        }
        catch(Exception e){
            System.debug('Exception Message==>'+e.getMessage());
            System.debug('Exception At line==>'+e.getLineNumber());
            return null;
        }
        
    } 
 
      	// For getting user contact point deatils
    @AuraEnabled(cacheable=false)
    public static Contact_Point__c getContactPointByContactId(String ContactId) {
        Boolean MyaIncluded = true;
        Boolean MyaDeleted = false;
       List<Contact_Point__c> Res = [SELECT Id, Contact__c, ContactType__c, Phone__c, Email__c, MYAISPrimary__c,CreatedDate  FROM Contact_Point__c WHERE Contact__c=:ContactId AND MYA_Included__c=:MyaIncluded AND MYA_IsDeleted__c=:MyaDeleted and MYAISPrimary__c=true ORDER BY CreatedDate DESC LIMIT 1];
if(!(res.size()>0))
{
           Res = [SELECT Id, Contact__c, ContactType__c, Phone__c, Email__c, MYAISPrimary__c,CreatedDate  FROM Contact_Point__c WHERE Contact__c=:ContactId AND MYA_Included__c=:MyaIncluded AND MYA_IsDeleted__c=:MyaDeleted  ORDER BY CreatedDate DESC LIMIT 1];

}
        return Res[0];
    } 
       
   @AuraEnabled (Cacheable=true)
    public static List<OrderItemSummary> getBodewellOrdersItems(string Id)
    {
        String recId=Id.trim();
        OrderSummary ordSummary= [select id ,OrderNumber from OrderSummary where OrderNumber =:recId];
        system.debug('ordSummary'+ordSummary);
        List<OrderItemSummary> ordItems = new List<OrderItemSummary>();
        ordItems = [SELECT id ,StockKeepingUnit ,cart_Item_Id__c,Quantity,product2.StockKeepingUnit, product2.Base_Model__c,product2.Description,product2.BWC_Product_Marketing_Description__c,product2.BWC_Service_Contracts__c,
                    product2.BWC_Main_Image__c ,Product2.BWC_Small_Appliance__c,TotalPrice ,OrderSummary.BWC_Cart_Id__c,OrderSummary.BillingPostalCode,OriginalOrderItem.BWC_Shipping_Method__c,product2.BWC_Delivery_Type__c,BWC_Original_Ship_Date__c,BWC_Pickup_Location__c
                    from OrderItemSummary 
                    where (OrderSummaryId = :ordSummary.Id) and type='Order Product'
                    ];
                     return ordItems;
    } 
    

     @AuraEnabled (Cacheable=true)
     public static List<OrderSummary> getBodewellOrderSummary(string UserId, integer ordCount,integer  noOfMonths)
    { 
        Date today = System.today();
        Date last_n_month = today.addMonths(-noOfMonths);
        List<OrderSummary > ordSummary = new List<OrderSummary>();
        ordSummary = [select id ,OriginalOrder.bwc_Order_Number__c, OrderedDate, OrderNumber, GrandTotalAmount, Status,OriginalOrder.OrderNumber,
                      BillingStreet,  BillingCity, BillingState, BillingPostalCode, BillToContact.Name
                       from OrderSummary 
                      where( AccountId IN (SELECT AccountId FROM User WHERE Id=: UserId))
                      AND (OrderedDate >= :last_n_month AND OrderedDate <=today )
                      ORDER BY CreatedDate DESC, LastModifiedDate DESC];
                      return ordSummary;
    }
    
     @AuraEnabled (Cacheable=true)
     public static List<OrderItem> getBodewellOrderSummaryItems(string orderRefNumber)
    { 
       System.debug('bodewellOrdersummary ITems');
        List<OrderItem> ordItems = new List<OrderItem>();
        ordItems = [select id ,cart_Item_Id__c,product2.BWC_Main_Image__c, product2.BWC_Product_Marketing_Description__c,product2.Base_Model__c,
                      TotalPrice,BWC_Original_Ship_Date__c,BWC_Shipping_Method__c,Product2.BWC_Delivery_Type__c,
                      product2.StockKeepingUnit,order.BillingPostalCode,order.Status
                     from OrderItem
                     where Order.OrderReferenceNumber= :orderRefNumber and type='Order Product'];
                     return ordItems;
    } 
    
   @AuraEnabled (Cacheable=true)
     public static List<OrderDeliveryGroupSummary> getOrderDeliveryGroupSummary(String orderSummaryId)
    { 
        system.debug('order delivery group summary');
        String recId=orderSummaryId.trim();
        OrderSummary ordSummary= [select id ,OrderNumber from OrderSummary where OriginalOrder.OrderReferenceNumber=:recId];
       
        List<OrderDeliveryGroupSummary> ordGrpSummary = new List<OrderDeliveryGroupSummary>();
        ordGrpSummary = [select id , DeliverToName, DeliverToStreet, DeliverToCity, DeliverToCountry, DeliverToState,DeliverToPostalCode,PhoneNumber
                      from OrderDeliveryGroupSummary 
                      where( OrderSummaryId = :ordSummary.Id)];
                      return ordGrpSummary;
    }
    
    @AuraEnabled (Cacheable=true)
     public static List<OrderPaymentSummary> getOrderDeliveryPaymentSummary(String orderSummaryId)
    { 
         system.debug('get order delivery payment summary');
        String recId=orderSummaryId.trim();
        //OriginalOrder.OrderReferenceNumber
        OrderSummary ordSummary = [select id, OrderNumber from OrderSummary where OriginalOrder.OrderReferenceNumber =:recId];
        String orderNumber = ordSummary.OrderNumber;
        List<OrderPaymentSummary> ordPaymentSummary = new List<OrderPaymentSummary>();
        ordPaymentSummary = [SELECT id,Method, OrderSummary.OriginalOrder.OrderReferenceNumber, OrderSummary.BillingStreet, OrderSummary.BillingCity,  
                             OrderSummary.BillingState, OrderSummary.BillingPostalCode ,OrderSummary.OrderNumber, ordersummary.OrderedDate ,OrderSummary.TotalAdjDistAMount,OrderSummary.BWC_Billing_Name__c,
                             OrderSummary.TotalAdjustedProductAmount,OrderSummary.TotalDeliveryAmount ,OrderSummary.BWC_Cart_Id__c, OrderSummary.TotalAdjustedDeliveryAmount ,OrderSummary.TotalTaxAmount ,OrderSummary.GrandTotalAmount
                             from OrderPaymentSummary 
                             where( OrderSummary.OrderNumber = :orderNumber)];
                      return ordPaymentSummary;
    }
    
     @AuraEnabled (Cacheable=true)
     public static  List<CardPaymentMethod> getOrderDeliveryPaymentSummaryStripe(String orderSummaryId)
    { 
        String recId=orderSummaryId.trim();
         OrderSummary ordSummary = [select id, OrderNumber from OrderSummary where OriginalOrder.OrderReferenceNumber =:recId];
         system.debug('get order delivery payment summary');
       // String recId=orderSummaryId.trim();
        // OrderSummary ordSummary = [select id, OrderNumber from OrderSummary where OrderNumber =:recId];
        String orderNumber = ordSummary.OrderNumber;
                                    List<CardPaymentMethod> cardPaymentMethodList = new List<CardPaymentMethod>();
      List<OrderPaymentSummary> ordPaymentSummary = new List<OrderPaymentSummary>();
        ordPaymentSummary = [SELECT id,Method, OrderSummary.BillingStreet, OrderSummary.BillingCity,  
                             OrderSummary.BillingState, OrderSummary.BillingPostalCode ,OrderSummary.OrderNumber, ordersummary.OrderedDate ,OrderSummary.TotalAdjDistAMount,OrderSummary.BWC_Billing_Name__c,
                             OrderSummary.TotalAdjustedProductAmount,OrderSummary.TotalDeliveryAmount ,OrderSummary.BWC_Cart_Id__c, OrderSummary.TotalAdjustedDeliveryAmount ,OrderSummary.TotalTaxAmount ,OrderSummary.GrandTotalAmount
                             from OrderPaymentSummary 
                             where( OrderSummary.OrderNumber = :orderNumber)];
          if(!test.isRunningTest()){
  
          List<PaymentAuthorization> paymentAuthorizationList = [SELECT Id,PaymentMethodId
                                                                       FROM PaymentAuthorization
                                                                       WHERE OrderPaymentSummaryId =:ordPaymentSummary[0].id];
                Set<Id> paymentMethodIds = new Set<Id>();
                for(PaymentAuthorization paymentAuth: paymentAuthorizationList){
                    paymentMethodIds.add(paymentAuth.PaymentMethodId);
                }

                cardPaymentMethodList = [SELECT Id,
                                         OPERATION__c,
                                         CONTEXT__c,
                                         CREDIT_CARD_APPROVAL_CODE__c,
                                         CREDIT_CARD_APPROVAL_DATE__c,
                                         CREDIT_CARD_CODE__c,
                                         CREDIT_CARD_EXPIRATION_DATE__c,
                                         CREDIT_CARD_HOLDER_NAME__c,
                                         CREDIT_CARD_NUMBER__c,
                                         PAYMENT_AMOUNT__c,
                                         PAYMENT_COLLECTION_EVENT__c,
                                         PAYMENT_NUMBER__c,
                                         ATTRIBUTE2__c,
                                         ATTRIBUTE3__c,
                                         ATTRIBUTE1__c,
                                         ATTRIBUTE4__c,
                                            ATTRIBUTE5__c,
                                         PAYMENT_TYPE_CODE__c,
                                         BWC_Payment_Provider__c
                                         FROM CardPaymentMethod
                                         WHERE Id IN :paymentMethodIds];
          }
        else
        {
               cardPaymentMethodList = [SELECT Id,
                                         OPERATION__c,
                                         CONTEXT__c,
                                         CREDIT_CARD_APPROVAL_CODE__c,
                                         CREDIT_CARD_APPROVAL_DATE__c,
                                         CREDIT_CARD_CODE__c,
                                         CREDIT_CARD_EXPIRATION_DATE__c,
                                         CREDIT_CARD_HOLDER_NAME__c,
                                         CREDIT_CARD_NUMBER__c,
                                         PAYMENT_AMOUNT__c,
                                         PAYMENT_COLLECTION_EVENT__c,
                                         PAYMENT_NUMBER__c,
                                         ATTRIBUTE2__c,
                                         ATTRIBUTE3__c,
                                         ATTRIBUTE1__c,
                                         ATTRIBUTE4__c,
                                            ATTRIBUTE5__c,
                                         PAYMENT_TYPE_CODE__c,
                                         BWC_Payment_Provider__c
                                         FROM CardPaymentMethod
                                        ];
        }
                      return cardPaymentMethodList;
    }
    
              
    
      @AuraEnabled(cacheable=true)
    public static String getCurrentCartId(string accountId){
        try{
        return [SELECT Id,accountId,createddate, status FROM Webcart where status ='Closed' and accountId=:accountId order by createddate Desc][0].Id;
        }catch(Exception e){
            System.debug('Exception Message==>'+e.getMessage());
            System.debug('Exception At line==>'+e.getLineNumber());
            return null;
        }
    }
}