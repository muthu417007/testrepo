public without sharing class bwc_OrderCreationBatchPayload {
    
    public static JSONGenerator getJson(List<Order> orderIdInstance){
        //Payload variables
        String customerNumber;
        Boolean isHD;
        Boolean isSDS;
        Boolean isHomeDelivery = false;
        Boolean isPart = false;
        String requestedDateInHeader;
        String deliveryChargeType = 'Delivery Charge';
        String chargeType = 'Charge';
        Integer cartItemCount = 0;
        Integer paymentNumberCount = 1;
        
        Map<String,Integer> inventoryTypeVsLineSeqMap = new Map<String,Integer>();
        Map<String,List<Integer>> inventoryTypeVsSeqNumList = new Map<String,List<Integer>>();
        Decimal totalPaymentAmount = 0;
        List<CardPaymentMethod> cardPaymentMethodList = new List<CardPaymentMethod>();
        
        List<OrderItem> orderItemInstance = [SELECT Id, 
                                             Quantity, 
                                             ListPrice, 
                                             UnitPrice,
                                             TotalPrice, 
                                             TotalLineAmount,
                                             Product2.Inventory_Item_ID__c,
                                             Product2.BWC_Delivery_Type__c,
                                             Product2.Is_Accessory__c,
                                             Product2.Is_Finished_Good__c,
                                             Product2.Name,
                                             Order.OrderNumber, 
                                             OrderId,
                                             Product2.StockKeepingUnit,
                                             BWC_Shipping_Method__c,
                                             Order.CreatedbyId,
                                             BWC_Original_Ship_Date__c,
                                             CreatedBy.Email
                                             FROM OrderItem
                                             WHERE OrderId IN : orderIdInstance
                                             AND Type != : deliveryChargeType];
        Id userIdInstance;
        if(!test.isRunningTest()){
            userIdInstance = orderItemInstance[0].Order.CreatedbyId;
            OrderPaymentSummary opsInstance = [SELECT Id,
                                               PaymentMethodId
                                               FROM OrderPaymentSummary
                                               WHERE OrderSummary.OriginalOrderId IN:orderIdInstance 
                                               LIMIT 1];
            List<PaymentAuthorization> paymentAuthorizationList = [SELECT Id,PaymentMethodId
                                                                   FROM PaymentAuthorization
                                                                   WHERE OrderPaymentSummaryId =:opsInstance.Id
                                                                   AND CreatedbyId = : orderIdInstance[0].CreatedbyId];
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
                                     PAYMENT_TYPE_CODE__c,
                                     BWC_Payment_Provider__c
                                     FROM CardPaymentMethod
                                     WHERE Id IN :paymentMethodIds];
            for(CardPaymentMethod cmpInstance:cardPaymentMethodList){
                totalPaymentAmount += Decimal.ValueOf(cmpInstance.PAYMENT_AMOUNT__c);                    
            }
            System.debug('totalPaymentAmount-->'+totalPaymentAmount);
        }
        else{
            userIdInstance = [SELECT Id,
                              AccountId,
                              Account.EBS_X_ACCOUNT_NUMBER__pc 
                              FROM User 
                              WHERE Alias = 'testuser' 
                              LIMIT 1][0].Id;
            cardPaymentMethodList=[SELECT Id,
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
                                   PAYMENT_TYPE_CODE__c,
                                   BWC_Payment_Provider__c
                                   FROM CardPaymentMethod 
                                   LIMIT 1];
        }
        WebCart webcartInstance = [SELECT Id 
                                   FROM WebCart 
                                   WHERE CreatedbyId = :orderIdInstance[0].CreatedbyId 
                                   AND PaymentMethodId  =: cardPaymentMethodList[0].Id];
        List<CartItem> cartItemList = [SELECT Id,
                                       sku,
                                       Quantity,
                                       Product2.Item_Type__c,
                                       Product2.BWC_Is_Part__c,
                                       Product2.BWC_Delivery_Type__c,
                                       Product2.Is_Accessory__c,
                                       Product2.StockKeepingUnit,
                                       Product2.Is_Finished_Good__c,
                                       BWC_Shipping_Method__c,
                                       BWC_Original_Ship_Date__c
                                       FROM CartItem 
                                       WHERE cartId =: webcartInstance.Id
                                       AND Type != :chargeType];
        for(CartItem cartItemRecord : cartItemList){
            cartItemCount++;
            if(cartItemRecord.Product2.BWC_Is_Part__c){
                isPart = true;
            }
            if(cartItemRecord.Product2.BWC_Delivery_Type__c == 'sds' && cartItemRecord.Product2.BWC_Delivery_Type__c != 'Will Call'){
                isSDS = true;
            }
            if(cartItemRecord.Product2.BWC_Delivery_Type__c == 'hd' && cartItemRecord.Product2.BWC_Delivery_Type__c != 'Will Call'){
                isHD = true;
                if(cartItemRecord.BWC_Original_Ship_Date__c != null && cartItemRecord.BWC_Original_Ship_Date__c != 'NaN-NaN-NaN'){
                    requestedDateInHeader = DateTime.newInstance(Date.valueOf(cartItemRecord.BWC_Original_Ship_Date__c), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd\'T\'HH:mm:ss');
                }
            }
            else if(cartItemRecord.BWC_Shipping_Method__c == 'Will Call' && isHD != true && cartItemRecord.BWC_Original_Ship_Date__c != null && cartItemRecord.BWC_Original_Ship_Date__c != 'NaN-NaN-NaN'){
                requestedDateInHeader = DateTime.newInstance(Date.valueOf(cartItemRecord.BWC_Original_Ship_Date__c), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd\'T\'HH:mm:ss');
            }
        }
        List<BWC_Product_Service__c> productServiceList = [SELECT Id,
                                                           Name,
                                                           BWC_Quantity__c,
                                                           BWC_Service_Price__c,
                                                           BWC_SKU__c,
                                                           BWC_Member_Price__c,
                                                           Cart_Item__r.BWC_Shipping_Method__c,
                                                           Cart_Item__r.Product2.BWC_Delivery_Type__c,
                                                           Cart_Item__r.Product2.Is_Accessory__c,
                                                           Cart_Item__r.Product2.StockKeepingUnit
                                                           FROM BWC_Product_Service__c
                                                           WHERE Cart_Item__c IN :cartItemList];
        customerNumber = orderIdInstance[0].Account.BWC_Consumer_Number__c != null ? orderIdInstance[0].Account.BWC_Consumer_Number__c : '1234';
        
        JSONGenerator gen = JSON.createGenerator(true);          
        gen.writeStartObject(); // Start of main object
        gen.writeStringField('RESPONSIBILITY', 'GEOM_SETUP _US_APL');
        gen.writeStringField('RESP_APPLICATION', 'GEONT');
        gen.writeStringField('SECURITY_GROUP', 'STANDARD');
        gen.writeStringField('NLS_LANGUAGE', 'AMERICAN');
        gen.writeNumberField('ORG_ID', 82);
        gen.writeFieldName('P_HEADER_REC');
        gen.writeStartObject();
        gen.writeStringField('ATTRIBUTE7',String.valueOf(totalPaymentAmount)); // total amount of the order
        gen.writeStringField('ATTRIBUTE2', orderItemInstance[0].CreatedBy.Email);
        //new changes 
        gen.writeStringField('ATTRIBUTE10', 'YES');
        gen.writeStringField('ATTRIBUTE12', 'YES');
        gen.writeStringField('ATTRIBUTE9', 'YES');
        gen.writeNumberField('ATTRIBUTE8', Decimal.valueOf(orderIdInstance[0].BillingPhoneNumber));
        gen.writeStringField('PAYMENT_AMOUNT', String.valueOf(totalPaymentAmount)); // total amount of the order
        gen.writeStringField('SHIPPING_INSTRUCTIONS', '');
        
        
        //new changes
        gen.writeStringField('BOOKED_FLAG', 'Y');
        gen.writeStringField('CUST_PO_NUMBER', orderItemInstance[0].CreatedBy.Email);
        gen.writeStringField('INVOICE_TO_ORG_ID', orderIdInstance[0].BWC_Bill_To_Org_Id__c);
        Datetime GMTDate = DateTime.now();
        String strConvertedDate = GMTDate.format('yyyy-MM-dd\'T\'HH:mm:ss');
        gen.writeStringField('ORDERED_DATE', strConvertedDate);
        
        // new changes start at 22/09/2023
        gen.writeStringField('ATTRIBUTE1', 'Bodewell Commerce');
        String origSysDocumentRef='BDC'+orderItemInstance[0].Order.OrderNumber;
        gen.writeStringField('ORIG_SYS_DOCUMENT_REF', origSysDocumentRef);
        if(isPart){
            gen.writeStringField('ATTRIBUTE15', 'CONSUMER ORDER');
        }
        
        //new changes end at 22/09/2023            
        gen.writeNumberField('ORG_ID', 82);
        Datetime GMTDate2 = DateTime.now();
        String strRequestDate = GMTDate2.format('yyyy-MM-dd\'T\'HH:mm:ss');
        if(requestedDateInHeader != null){
            gen.writeStringField('REQUEST_DATE', requestedDateInHeader);// date from cartitem
        }
        else{
            gen.writeStringField('REQUEST_DATE', strRequestDate);
        }
        gen.writeNumberField('SHIP_TO_ORG_ID', Integer.valueOf(orderIdInstance[0].BWC_Ship_To_Org_Id__c));
        gen.writeStringField('OPERATION', 'CREATE');
        
        gen.writeEndObject();
        //NEW CHANGE
        gen.writeFieldName('P_OLD_HEADER_REC');
        gen.writeStartObject();
        gen.writeStringField('CREATION_DATE', strRequestDate); // current date
        if(requestedDateInHeader != null){
            gen.writeStringField('REQUEST_DATE', requestedDateInHeader);// date from cartitem
        }
        else{
            gen.writeStringField('REQUEST_DATE', strRequestDate);
        }
        gen.writeEndObject();
        //NEW CHANGE
        gen.writeFieldName('P_HEADER_VAL_REC');
        gen.writeStartObject();
        gen.writeStringField('ORDER_SOURCE', 'Bodewell Commerce');//as discussed with Feroz this field will be Bodewell Commerce 
        gen.writeStringField('ORDER_TYPE', 'Standard Sales');//check
        gen.writeStringField('PAYMENT_TERM', 'Prepayment');
        gen.writeStringField('PRICE_LIST', 'APPLIANCES - GEA STORE - OWNER CHANNEL'); // It is changed
        gen.writeStringField('CUSTOMER_NUMBER', customerNumber);
        gen.writeStringField('SHIPPING_METHOD', OrderBodyCreater.getHeaderShippingMethod(cartItemList));
        gen.writeStringField('FREIGHT_TERMS', 'To Be Determined');
        gen.writeEndObject();
        
        // new change
        gen.writeFieldName('P_OLD_LINE_VAL_TBL');
        gen.writeStartObject();   
        gen.writeFieldName('P_LINE_VAL_TBL_ITEM');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('SHIP_TO_ZIP', orderIdInstance[0].ShippingPostalCode);
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject();
        
        // new change
        //new payment change start
        gen.writeFieldName('P_HEADER_PAYMENT_VAL_TBL');
        gen.writeStartObject();
        gen.writeFieldName('P_HEADER_PAYMENT_VAL_TBL_ITEM');
        gen.writeStartArray();
        for(CardPaymentMethod cmpInstance:cardPaymentMethodList){
            gen.writeStartObject();
            if(('Stripe').equals(cmpInstance.BWC_Payment_Provider__c)){
                gen.writeStringField('RECEIPT_METHOD', 'Stripe Credit Card');
                gen.writeStringField('PAYMENT_TYPE_CODE', 'CREDIT_CARD');
            }
            else{
                gen.writeStringField('RECEIPT_METHOD', 'Credit Card Receipts(N)');
            }
            // gen.writeNumberField('PAYMENT_PERCENTAGE', 100);
            gen.writeEndObject();
        }
        gen.writeEndArray();
        gen.writeEndObject();
        //new payment change end
        gen.writeFieldName('P_HEADER_PAYMENT_TBL');
        gen.writeStartObject();
        gen.writeFieldName('P_HEADER_PAYMENT_TBL_ITEM');
        gen.writeStartArray();
        for(CardPaymentMethod cmpInstance:cardPaymentMethodList){
            gen.writeStartObject();
            //new payment change start
            gen.writeStringField('ATTRIBUTE3', cmpInstance.ATTRIBUTE3__c);
            gen.writeStringField('CREDIT_CARD_CODE', cmpInstance.CREDIT_CARD_CODE__c);
            gen.writeStringField('ATTRIBUTE2', cmpInstance.ATTRIBUTE2__c);
            
            // NEW changes start at 22/09/2023
            gen.writeStringField('ATTRIBUTE1', cmpInstance.ATTRIBUTE1__c);
            // In dev this PAYMENT_AMOUNT field is string which is working but in qa it is working as a number field
            gen.writeStringField('PAYMENT_AMOUNT', cmpInstance.PAYMENT_AMOUNT__c);
            // NEW changes end at 22/09/2023
            
            gen.writeNumberField('PAYMENT_NUMBER', paymentNumberCount);
            // gen.writeStringField('ATTRIBUTE1', cmpInstance.ATTRIBUTE1__c);
            gen.writeStringField('CREDIT_CARD_APPROVAL_CODE', cmpInstance.CREDIT_CARD_APPROVAL_CODE__c);
            gen.writeStringField('CREDIT_CARD_APPROVAL_DATE', cmpInstance.CREDIT_CARD_APPROVAL_DATE__c);
            gen.writeStringField('CREDIT_CARD_NUMBER', cmpInstance.CREDIT_CARD_NUMBER__c);
            gen.writeStringField('PAYMENT_COLLECTION_EVENT', cmpInstance.PAYMENT_COLLECTION_EVENT__c);
            String dateExpiration = cmpInstance.CREDIT_CARD_EXPIRATION_DATE__c;
            Date convertedDate;
            List<String> dateParts = dateExpiration.split('-');
            String formattedDate; 
            if (dateParts.size() == 2) {
                Integer year = Integer.valueOf(dateParts[1]);
                Integer month = Integer.valueOf(dateParts[0]);
                formattedDate = year + '-' + String.valueOf(month).leftPad(2, '0') + '-30';
            }
            gen.writeStringField('CREDIT_CARD_EXPIRATION_DATE', formattedDate);
            
            //new payment change end
            
            gen.writeNumberField('CONTEXT', 82);                
            //new payment change start
            gen.writeStringField('CREDIT_CARD_HOLDER_NAME', cmpInstance.CREDIT_CARD_HOLDER_NAME__c);
            //gen.writeStringField('CREDIT_CARD_HOLDER_NAME', 'ABHISHEK BISHT VISA 1111');
            gen.writeStringField('OPERATION', cmpInstance.OPERATION__c);
            gen.writeStringField('PAYMENT_TYPE_CODE', cmpInstance.PAYMENT_TYPE_CODE__c);
            //new payment change end
            gen.writeEndObject();
            paymentNumberCount++;
        }
        gen.writeEndArray();
        gen.writeEndObject();
        gen.writeFieldName('P_LINE_TBL');
        gen.writeStartObject();
        gen.writeFieldName('P_LINE_TBL_ITEM');
        gen.writeStartArray();
        
        Integer countInstance = 1;
        Boolean oversizedFlag = false;
        for(OrderItem ordItm : orderItemInstance){   
            if(ordItm.Product2.BWC_Delivery_Type__c == 'sds' &&  ordItm.BWC_Shipping_Method__c != 'Will Call'){
                oversizedFlag = true;
            }
            if(!inventoryTypeVsSeqNumList.containsKey(ordItm.Product2.StockKeepingUnit)){
                inventoryTypeVsSeqNumList.put(ordItm.Product2.StockKeepingUnit,new List<Integer>{countInstance});
            }
            else{
                inventoryTypeVsSeqNumList.get(ordItm.Product2.StockKeepingUnit).add(countInstance);
            }
            inventoryTypeVsLineSeqMap.put(ordItm.Product2.StockKeepingUnit,countInstance);
            gen.writeStartObject();
            gen.writeNumberField('LINE_SEQ_NO',countInstance);
            gen.writeStringField('CUST_PO_NUMBER',ordItm.CreatedBy.Email);// this field contains length issue, due to high length it won't work
            gen.writeNumberField('ORDERED_QUANTITY', ordItm.Quantity);
            gen.writeNumberField('ORG_ID', 82);
            if(ordItm.BWC_Shipping_Method__c == 'Home Delivery' || ordItm.BWC_Shipping_Method__c == 'SDS Delivery'){
                gen.writeStringField('SHIP_SET','1');
            }
            gen.writeNumberField('UNIT_LIST_PRICE', ordItm.UnitPrice);
            gen.writeNumberField('UNIT_SELLING_PRICE', ordItm.UnitPrice);
            gen.writeStringField('OPERATION', 'CREATE');
            gen.writeNumberField('CUSTOMER_ITEM_NET_PRICE', ordItm.UnitPrice); // unit price of the order Item
            gen.writeStringField('CALCULATE_PRICE_FLAG', 'N');
            gen.writeStringField('INVENTORY_ITEM', ordItm.Product2.StockKeepingUnit);
            if(ordItm.BWC_Original_Ship_Date__c != null && ordItm.BWC_Original_Ship_Date__c != 'NaN-NaN-NaN'){
                Date inputDate = Date.valueOf(ordItm.BWC_Original_Ship_Date__c);
                DateTime dateTimeformat = DateTime.newInstance(inputDate, Time.newInstance(0, 0, 0, 0));
                String formattedDateString = dateTimeformat.format('yyyy-MM-dd\'T\'HH:mm:ss');
                gen.writeStringField('REQUEST_DATE', formattedDateString);
            }
            
            gen.writeEndObject(); 
            countInstance++;
        }
        //need to insert oversized product
        if(oversizedFlag == true){
            if(!inventoryTypeVsSeqNumList.containsKey('DELIVERY OVERSIZE')){
                inventoryTypeVsSeqNumList.put('DELIVERY OVERSIZE',new List<Integer>{countInstance});
            }
            else{
                inventoryTypeVsSeqNumList.get('DELIVERY OVERSIZE').add(countInstance);
            }
            inventoryTypeVsLineSeqMap.put('DELIVERY OVERSIZE',countInstance);
            gen.writeStartObject();
            gen.writeNumberField('LINE_SEQ_NO',countInstance);
            gen.writeStringField('CUST_PO_NUMBER',orderItemInstance[0].CreatedBy.Email);// this field contains length issue, due to high length it won't work
            
            gen.writeStringField('SHIP_SET','1');
            
            gen.writeNumberField('ORDERED_QUANTITY', 1);
            gen.writeNumberField('ORG_ID', 82);
            gen.writeNumberField('UNIT_LIST_PRICE', 150);
            gen.writeNumberField('UNIT_SELLING_PRICE', 150);
            
            gen.writeStringField('ITEM_RELATIONSHIP_TYPE_DSP', 'Service');
            
            gen.writeStringField('OPERATION', 'CREATE');
            gen.writeNumberField('CUSTOMER_ITEM_NET_PRICE', 150); // unit price of the order Item
            gen.writeStringField('CALCULATE_PRICE_FLAG', 'N');
            gen.writeStringField('INVENTORY_ITEM', 'DELIVERY OVERSIZE');
            gen.writeEndObject(); 
            countInstance++;
        }
        //need to insert oversized product
        
        // for installation product
        for(BWC_Product_Service__c productServiceRecord : productServiceList){
            if(!inventoryTypeVsSeqNumList.containsKey(productServiceRecord.BWC_SKU__c)){
                inventoryTypeVsSeqNumList.put(productServiceRecord.BWC_SKU__c,new List<Integer>{countInstance});
            }
            else{
                inventoryTypeVsSeqNumList.get(productServiceRecord.BWC_SKU__c).add(countInstance);
            }
            inventoryTypeVsLineSeqMap.put(productServiceRecord.BWC_SKU__c,countInstance);
            if(productServiceRecord.BWC_SKU__c == 'HOME DELIVERY' && isHomeDelivery==true){
                continue;
            }
            else{
                if(productServiceRecord.BWC_SKU__c == 'HOME DELIVERY'){
                    isHomeDelivery = true;
                }
                gen.writeStartObject();
                gen.writeNumberField('LINE_SEQ_NO',countInstance);
                gen.writeStringField('CUST_PO_NUMBER', orderItemInstance[0].CreatedBy.Email);
                gen.writeNumberField('ORDERED_QUANTITY', productServiceRecord.BWC_Quantity__c);
                gen.writeNumberField('ORG_ID', 82);
                
                if(productServiceRecord.Cart_Item__r.BWC_Shipping_Method__c == 'Home Delivery' || productServiceRecord.Cart_Item__r.BWC_Shipping_Method__c == 'SDS Delivery'){
                    gen.writeStringField('SHIP_SET','1');
                }
                Decimal unitPrice = (productServiceRecord.BWC_Service_Price__c)/(productServiceRecord.BWC_Quantity__c);
                gen.writeNumberField('UNIT_LIST_PRICE', unitPrice);
                gen.writeNumberField('UNIT_SELLING_PRICE', unitPrice);
                
                gen.writeStringField('ITEM_RELATIONSHIP_TYPE_DSP', 'Service');
                gen.writeStringField('ORIGINAL_ORDERED_ITEM', productServiceRecord.Cart_Item__r.Product2.StockKeepingUnit);
                
                gen.writeStringField('OPERATION', 'CREATE');
                gen.writeNumberField('CUSTOMER_ITEM_NET_PRICE', unitPrice);
                gen.writeStringField('CALCULATE_PRICE_FLAG', 'N');
                gen.writeStringField('INVENTORY_ITEM', productServiceRecord.BWC_SKU__c);
                gen.writeEndObject(); 
                countInstance++;
            }                
        }
        // for installation product
        gen.writeEndArray();
        gen.writeEndObject();
        gen.writeFieldName('P_LINE_VAL_TBL');
        gen.writeStartObject();
        gen.writeFieldName('P_LINE_VAL_TBL_ITEM');
        gen.writeStartArray();
        for(CartItem cartItemRecord : cartItemList){
            
            gen.writeStartObject();
            gen.writeStringField('INVENTORY_ITEM', cartItemRecord.Product2.StockKeepingUnit);
            gen.writeNumberField('LINE_SEQ_NO',inventoryTypeVsSeqNumList.get(cartItemRecord.Product2.StockKeepingUnit)[0]);
            inventoryTypeVsSeqNumList.get(cartItemRecord.Product2.StockKeepingUnit).remove(0);
            if(isSDS == true){
                if(cartItemRecord.Product2.BWC_Delivery_Type__c == 'sps' && cartItemRecord.Product2.Is_Accessory__c == 'No' || cartItemRecord.Product2.BWC_Delivery_Type__c == 'sps fee'){
                    gen.writeStringField('SHIPPING_METHOD',cartItemRecord.BWC_Shipping_Method__c);
                }
                else if(cartItemRecord.BWC_Shipping_Method__c != 'Will Call'){
                    gen.writeStringField('SHIPPING_METHOD','SDS Delivery');
                }
                else{
                    gen.writeStringField('SHIPPING_METHOD',cartItemRecord.BWC_Shipping_Method__c); // it will also cover for sps fee
                }
            }
            else if(isHD == true){
                if(cartItemRecord.Product2.BWC_Delivery_Type__c == 'sps' && cartItemRecord.Product2.Is_Accessory__c == 'No' || cartItemRecord.Product2.BWC_Delivery_Type__c == 'sps fee'){
                    gen.writeStringField('SHIPPING_METHOD',cartItemRecord.BWC_Shipping_Method__c);
                }
                else if(cartItemRecord.BWC_Shipping_Method__c != 'Will Call'){
                    gen.writeStringField('SHIPPING_METHOD','Home Delivery');
                }
                else{
                    gen.writeStringField('SHIPPING_METHOD',cartItemRecord.BWC_Shipping_Method__c); // it will also cover for sps fee
                }
            }
            else{
                gen.writeStringField('SHIPPING_METHOD',cartItemRecord.BWC_Shipping_Method__c);
            }
            gen.writeEndObject();
        }
        
        //need to insert oversized product
        if(oversizedFlag == true){
            gen.writeStartObject();
            gen.writeNumberField('LINE_SEQ_NO',inventoryTypeVsSeqNumList.get('DELIVERY OVERSIZE')[0]);
            inventoryTypeVsSeqNumList.get('DELIVERY OVERSIZE').remove(0);
            gen.writeStringField('INVENTORY_ITEM', 'DELIVERY OVERSIZE');
            gen.writeStringField('SHIPPING_METHOD','SDS Delivery');
            gen.writeEndObject();
        }
        //need to insert oversized product
        isHomeDelivery = false;
        // for installation product
        for(BWC_Product_Service__c productServiceRecord : productServiceList){
            System.debug('Service SKU 2--->'+productServiceRecord.BWC_SKU__c);
            if(productServiceRecord.BWC_SKU__c == 'HOME DELIVERY' && isHomeDelivery == true){
                continue;
            }
            else if(productServiceRecord.BWC_SKU__c == 'HOME DELIVERY' && isHomeDelivery != true){
                isHomeDelivery = true;
            }
            gen.writeStartObject();
            gen.writeNumberField('LINE_SEQ_NO',inventoryTypeVsSeqNumList.get(productServiceRecord.BWC_SKU__c)[0]);
            inventoryTypeVsSeqNumList.get(productServiceRecord.BWC_SKU__c).remove(0);
            if(productServiceRecord.Cart_Item__r.Product2.BWC_Delivery_Type__c == 'sps fee'){
                gen.writeStringField('INVENTORY_ITEM', 'PARTS - SHIPPING CHARGE');
            }
            else{
                gen.writeStringField('INVENTORY_ITEM', productServiceRecord.BWC_SKU__c);
            }
            
            if(isSDS == true){
                if(productServiceRecord.Cart_Item__r.Product2.BWC_Delivery_Type__c == 'sps' && productServiceRecord.Cart_Item__r.Product2.Is_Accessory__c == 'No'){
                    System.debug('sps type in SDS For Service-->');
                    gen.writeStringField('SHIPPING_METHOD',productServiceRecord.Cart_Item__r.BWC_Shipping_Method__c);
                }
                else if(productServiceRecord.Cart_Item__r.BWC_Shipping_Method__c != 'Will Call'){
                    System.debug('SDS Delivery Type');
                    gen.writeStringField('SHIPPING_METHOD','SDS Delivery');
                }
                else{
                    System.debug('Else of sds');
                    gen.writeStringField('SHIPPING_METHOD',productServiceRecord.Cart_Item__r.BWC_Shipping_Method__c); // it will also cover for sps fee
                }
            }
            else if(isHD == true){
                if(productServiceRecord.Cart_Item__r.Product2.BWC_Delivery_Type__c == 'sps' && productServiceRecord.Cart_Item__r.Product2.Is_Accessory__c == 'No' ){
                    gen.writeStringField('SHIPPING_METHOD',productServiceRecord.Cart_Item__r.BWC_Shipping_Method__c);
                }
                else if(productServiceRecord.Cart_Item__r.BWC_Shipping_Method__c != 'Will Call'){
                    gen.writeStringField('SHIPPING_METHOD','Home Delivery');
                }
                else{
                    gen.writeStringField('SHIPPING_METHOD',productServiceRecord.Cart_Item__r.BWC_Shipping_Method__c); // it will also cover for sps fee
                }
            }
            else{
                gen.writeStringField('SHIPPING_METHOD',productServiceRecord.Cart_Item__r.BWC_Shipping_Method__c	);
            }
            gen.writeEndObject();
        }
        // for installation product
        gen.writeEndArray();
        gen.writeEndObject();
        gen.writeEndObject(); // End of.close();
        return gen;
    }
}