//******************************************************************************************
//Name : Mya_MyOrderItems
//Requirement : To display Orders Data on My Orders and Order Details Page
//EPIC/US/TASK : IDMSF- 31, IDMSF- 37, IDMSF- 1032, IDMSF- 1033
//******************************************************************************************
//History
//  Version             Author                  Date                Detail
//  1.0                 Yogesh Sharma           07/11/2022          Initial
//  2.0                 Yogesh Sharma           17/01/2024          Updated.
//******************************************************************************************
//@description : Class to handle request for Orders Data.
public without sharing class Mya_MyOrderItems 
{
    //@description : Method is used for retrieving Orders Data
    //Input: String UserId
    //Return: List of Orders for an UserId (List<Mya_OrderItems>)
    @AuraEnabled (Cacheable=true)
    public static List<Mya_OrderItems> getOrderList(string UserId, integer ordCount)
    {
        List<Order> OrderNos = new List<Order>();
       
        Id PersonContactID;        
        if(UserId.substring(0,3) == '005'){
            system.debug('Order selected for: ' +UserId);
            
            OrderNos = [SELECT Id, OrderReferenceNumber, Order_Number__c, Guest_Flag__c, BWC_ORIG_SYS_DOCUMENT_REF__c,Status,
                        EffectiveDate, TotalAmount,GrandTotalAmount,RecordType.Name
                        FROM Order
                        WHERE (BillToContactId IN (SELECT ContactId FROM User WHERE Id=:UserId))
                        AND (Guest_Flag__c = false)
                        ORDER BY RecordType.Name, CreatedDate DESC, LastModifiedDate DESC];
        }
        else if(UserId.substring(0,3) == '003')
        {
            OrderNos = [SELECT Id, OrderReferenceNumber, Order_Number__c, Guest_Flag__c, 
                        EffectiveDate, TotalAmount,GrandTotalAmount, RecordType.Name
                        FROM Order
                        WHERE BillToContactId =: UserId 
                        ORDER BY RecordType.Name, CreatedDate DESC, LastModifiedDate DESC];                                    
        }
        else if(UserId.substring(0,3) == '001')
        {
            PersonContactID = [Select Id from Contact where AccountId = :UserId].id;
            
            OrderNos = [SELECT Id, OrderReferenceNumber, Order_Number__c, Guest_Flag__c, 
                        EffectiveDate, TotalAmount, GrandTotalAmount,RecordType.Name
                        FROM Order
                        WHERE (BillToContactId =: PersonContactId  
                               OR AccountId  = :userId)
                        ORDER BY RecordType.Name, CreatedDate DESC, LastModifiedDate DESC];
        }
        system.debug('Order Nos: '+OrderNos);  
        List<RecordType> RT = [SELECT Id, Name FROM RecordType WHERE Name IN ('FG Order','Parts Order','Concession Order') ORDER BY Name];
        String ConRecordTypId = RT[0].Id;
        String FGRecordTypId = RT[1].Id;
        String PARecordTypId = RT[2].Id;
        String OrderType;
        String Token = Mya_OrderDetailApiHelper.mya_ClientAuth();
        
        Set<String> Buf = New Set<String>();
        for(Order orderNo:OrderNos)
        {
            Buf.add(orderNo.Order_Number__c);
        }
        
        List<String> ClOrdNo = New List<String>();
        List<Contact> GLId = new List<Contact>();
        if(UserId.substring(0,3) == '005')
        {
            GLId = [SELECT Global_Customer_Id__c FROM Contact WHERE Id IN 
                    (SELECT ContactId FROM User WHERE Id=:UserId) LIMIT 1];
        }
        else if(UserId.substring(0,3) == '003')
        {
            GLId = [SELECT Global_Customer_Id__c FROM Contact WHERE Id =:UserId LIMIT 1];
        }
        else if(UserId.substring(0,3) == '001') 
        {
            GLId = [SELECT Global_Customer_Id__c FROM Contact WHERE Id =:PersonContactID and isPersonAccount = true LIMIT 1];
        }
        if(Test.isRunningTest() == false && GLId.size()>0)
        {
            List<c360_email__x> PId = [SELECT personid__c FROM c360_email__x 
                                       WHERE myamyaccountid__c =: GLId[0].Global_Customer_Id__c];
            
            List<String> PIds = New List<String>();
            for(c360_email__x EP : PId)
            {
                if(!PIds.contains(EP.personid__c))
                {
                    PIds.add(EP.personid__c); 
                }
            }
            if(!PIds.isEmpty())
            {
                List<c360_order__x> Ord360 = [SELECT Id, ordernumber__c, personid__c FROM c360_order__x 
                                              WHERE personid__c IN: PIds];
                for(c360_order__x EO:Ord360)
                {
                    ClOrdNo.add(EO.ordernumber__c);
                }   
            }                 
        }
        
        List<Order> OrdToAdd = New List<Order>();
        if(OrderNos.size()>0)
        {
            for(Order orderNo:OrderNos)
            {
                for(String EC:ClOrdNo)
                {
                    if(orderNo.Order_Number__c != EC && !(Buf.contains(EC)))
                    {
                        Buf.add(EC);
                        Order O = New Order();
                        O.RecordTypeId = PARecordTypId;
                        O.Order_Number__c = EC;
                        
                        OrdToAdd.add(O);
                    }
                }
            }
        }
        else
        {
            for(String EC:ClOrdNo)
            {
                Order O = New Order();
                O.RecordTypeId = PARecordTypId;
                O.Order_Number__c = EC;
                OrdToAdd.add(O);
            }
        }
        OrderNos.addAll(OrdToAdd);
        
        List<Mya_OrderItems> MyOrderItems = new List<Mya_OrderItems>();
        List<Order> orderToDisplay = new List<Order>();
        
        for(Integer i= ordCount;i<(ordCount+integer.valueOf(Label.mya_orderPaginationNo));i++)
        {
            if(i>=OrderNos.size())
            {
                break;
            }
            else
            {
                if(OrderNos[i].OrderReferenceNumber != null || OrderNos[i].Order_Number__c  != null)
                {
                    orderToDisplay.add(OrderNos[i]);
                }   
            }
        }
        for(Order orderNo:orderToDisplay)
        {
            if(orderNo.recordTypeId == FGRecordTypId)
            {
                OrderType = 'FG';
            }
            else if(orderNo.recordTypeId == PARecordTypId)
            {
                OrderType = 'Parts';
            }
            else if(orderNo.recordTypeId == ConRecordTypId)
            {
                OrderType = 'Concession';
            }
             
      
             if(orderNo.OrderReferenceNumber!=null && orderNo.OrderReferenceNumber.startsWith('BDC'))
             {
                OrderType = 'Bodewell';        
                 system.debug('bodewell orders');
             }
            if(OrderType == 'FG')
            {
                Mya_OrderItems EOI = new Mya_OrderItems();
                try 
                {
                    String Resp = Mya_OrderDetailApiHelper.mya_FetchOrderDetail(orderNo.OrderReferenceNumber,OrderType,Token);
                    if(Resp == 'Error')
                    {
                        system.debug('Error');
                        Token = Mya_OrderDetailApiHelper.mya_ClientAuth();
                        EOI = mya_OrderDetail(Resp, OrderType, orderNo.Id);
                        EOI.isCROrder = false;
                        //continue;
                    }
                    else if(Resp == 'Not Found')
                    {
                        system.debug('Not Found'+Resp);
                        EOI.OrderRefNumber = orderNo.OrderReferenceNumber;
                        EOI.OrderDate = orderNo.EffectiveDate;
                        EOI.OrderNumber = '-';
                        EOI.OrderStatus = 'Pending';
                        EOI.OrderTotalString = '-';
                        EOI.isCROrder = false;
                        //break;
                    }
                    else if(Resp != 'Error' && Resp != 'Not Found')
                    {
                        system.debug('mya_OrderDetail');
                        EOI = mya_OrderDetail(Resp, OrderType, orderNo.Id);
                        EOI.isCROrder = false;
                    }                    
                } 
                catch (Exception E) 
                {
                    
                }
                MyOrderItems.add(EOI);  
            }
            else if(OrderType == 'Parts')
            {
                Mya_OrderItems EOI = new Mya_OrderItems();
                try 
                {
                    String Resp = Mya_OrderDetailApiHelper.mya_FetchOrderDetail(orderNo.Order_Number__c,OrderType,Token);
                    if(Resp == 'Error')
                    {
                        Token = Mya_OrderDetailApiHelper.mya_ClientAuth();
                        EOI = mya_OrderDetail(Resp, OrderType, orderNo.Id);
                        EOI.isCROrder = false;
                        //continue;
                    }
                    else if(Resp == 'Not Found')
                    {
                        EOI.OrderNumber = orderNo.Order_Number__c;
                        EOI.OrderRefNumber = '-';
                        EOI.OrderDate = orderNo.EffectiveDate;
                        EOI.OrderStatus = 'Processing';
                        EOI.OrderTotalString = '-';
                        EOI.isCROrder = false;
                        //break;
                    }
                    else if(Resp != 'Error' && Resp != 'Not Found')
                    {
                        EOI = mya_OrderDetail(Resp, OrderType, orderNo.Id);
                        EOI.isCROrder = false;
                    }
                    
                } 
                catch (Exception E) 
                {
                    
                }
                MyOrderItems.add(EOI);  
            }
            else if(OrderType == 'Concession')
            {
                Mya_OrderItems EOI = new Mya_OrderItems();
                try 
                {
                    String Resp = Mya_OrderDetailApiHelper.mya_FetchOrderDetail(orderNo.Order_Number__c,OrderType,Token);
                    if(Resp == 'Error')
                    {
                        Token = Mya_OrderDetailApiHelper.mya_ClientAuth();
                        EOI = mya_OrderDetail(Resp, OrderType, orderNo.Id);
                        EOI.isCROrder = true;
                        //continue;
                    }
                    else if(Resp == 'Not Found')
                    {
                        EOI.OrderNumber = orderNo.Order_Number__c;
                        EOI.OrderRefNumber = '-';
                        EOI.OrderDate = orderNo.EffectiveDate;
                        EOI.OrderStatus = 'Processing';
                        EOI.OrderTotalString = '-';
                        EOI.isCROrder = true;
                        //break;
                    }
                    else if(Resp != 'Error' && Resp != 'Not Found')
                    {
                        EOI = mya_OrderDetail(Resp, OrderType, orderNo.Id);
                        EOI.isCROrder = true;
                    }
                    
                } 
                catch (Exception E) 
                {
                    
                }
                MyOrderItems.add(EOI);  
            }
            else if(OrderType == 'Bodewell'){
                system.debug('inside bodewell orders');
                Mya_OrderItems EOI = new Mya_OrderItems();
                try 
                {       
                    System.debug('bodewell orders');
                    EOI = BWC_OrderConfirmationController.getBodewellOrderItems(orderNo.OrderReferenceNumber);
                        EOI.OrderRefNumber = orderNo.OrderReferenceNumber;
                        EOI.OrderDate = orderNo.EffectiveDate;
                        EOI.OrderNumber = orderNo.Order_Number__c;
                        EOI.OrderStatus = orderNo.Status;
                        EOI.OrderStatusCompFlag = false;
                        EOI.OrderStatusPendFlag = false;
                        EOI.OrderStatusCancelFlag = false;
                        EOI.OrderTotalString = decToStr(orderNo.GrandTotalAmount);
                       
                             if(EOI.OrderStatus == 'Booked')
                               {
                               EOI.OrderStatus = 'Pending';     
                              EOI.OrderStatusPendFlag = true;        
                                }
                             else if(EOI.OrderStatus == 'closed')
                             {
                              EOI.OrderStatus = 'Complete';
                             EOI.OrderStatusPendFlag = true;  
                                 }
                             else if(EOI.OrderStatus == 'Cancelled')
                               {
                                   EOI.OrderStatus = 'Cancelled';
                                    EOI.OrderStatusCancelFlag = true;  
                                 } 
                            else if(EOI.OrderStatus == 'Entered' || EOI.OrderStatus == 'Activated')
                               {
                                   EOI.OrderStatus = 'Cancelled';
                                    EOI.OrderStatusCancelFlag = true;  
                                 }  
                     
                   
                    system.debug('EOI items'+EOI.OrderRefNumber +EOI.OrderDate  + EOI.OrderNumber +EOI.OrderStatus +EOI.OrderTotalString);
                   
                     String domainUrl = Url.getOrgDomainUrl().getHost();
            
                        
                   } 
                catch (Exception E) 
                {
                    
                }
                MyOrderItems.add(EOI);  
                
            }
                    
        }
        Return MyOrderItems;
    }
    
    
   
    //@description : Method is used for retrieving Orders Count
    //Input: String User Id
    //Return: Integer Order Count
    @AuraEnabled (Cacheable=true)
    Public static integer getOrderCount(string UserId)
    {
        List<Order> OrderNos = new List<Order>();
        Id PersonContactID;
        if(UserId.substring(0,3) == '005')
        {
            OrderNos = [SELECT RecordTypeId, Id, OrderReferenceNumber, Order_Number__c, Guest_Flag__c, EffectiveDate
                        FROM Order
                        WHERE (BillToContactId IN (SELECT ContactId FROM User WHERE Id=:UserId))
                        AND (Guest_Flag__c = false)
                        ORDER BY RecordTypeId];
        }
        else if(UserId.substring(0,3) == '003')
        {
            OrderNos = [SELECT RecordTypeId,Id, OrderReferenceNumber, Order_Number__c, EffectiveDate
                        FROM Order
                        WHERE BillToContactId =: UserId
                        ORDER BY RecordTypeId];
        }
        else if(UserId.substring(0,3) == '001')
        {
            PersonContactID = [Select Id from Contact where AccountId = :UserId].id;
            OrderNos = [SELECT Id,RecordTypeId, OrderReferenceNumber, Order_Number__c, EffectiveDate, TotalAmount
                        FROM Order
                        WHERE BillToContactId =: PersonContactId
                        ORDER BY RecordTypeId, CreatedDate DESC, LastModifiedDate DESC]; 
        }
        List<RecordType> RT = [SELECT Id, Name FROM RecordType WHERE Name IN ('FG Order','Parts Order') ORDER BY Name];
        String FGRecordTypId = RT[0].Id;
        String PARecordTypId = RT[1].Id;
        String OrderType;
        String Token = Mya_OrderDetailApiHelper.mya_ClientAuth();
        
        Set<String> Buf = New Set<String>();
        for(Order orderNo:OrderNos)
        {
            Buf.add(orderNo.Order_Number__c);
        }
        
        List<String> ClOrdNo = New List<String>();
        List<Contact> GLId = new List<Contact>();
        if(UserId.substring(0,3) == '005') {
            GLId = [SELECT Global_Customer_Id__c FROM Contact WHERE Id IN 
                    (SELECT ContactId FROM User WHERE Id=:UserId) LIMIT 1];
        } else if(UserId.substring(0,3) == '003') {
            GLId = [SELECT Global_Customer_Id__c FROM Contact WHERE Id =:UserId LIMIT 1];
        } else if(UserId.substring(0,3) == '001') {
            GLId = [SELECT Global_Customer_Id__c FROM Contact WHERE Id =:PersonContactID and isPersonAccount = true LIMIT 1];
        }
        
        if(Test.isRunningTest() == false && GLId.size()>0)
        {
            List<c360_email__x> PId = [SELECT personid__c FROM c360_email__x 
                                       WHERE myamyaccountid__c =: GLId[0].Global_Customer_Id__c];
            
            List<String> PIds = New List<String>();
            for(c360_email__x EP : PId)
            {
                if(!PIds.contains(EP.personid__c))
                {
                    PIds.add(EP.personid__c); 
                }
            }
            if(!PIds.isEmpty())
            {
                List<c360_order__x> Ord360 = [SELECT Id, ordernumber__c, personid__c FROM c360_order__x 
                                              WHERE personid__c IN: PIds];
                for(c360_order__x EO:Ord360)
                {
                    ClOrdNo.add(EO.ordernumber__c);
                }   
            }                 
        }
        
        List<Order> OrdToAdd = New List<Order>();
        if(OrderNos.size()>0)
        {
            for(Order orderNo:OrderNos)
            {
                for(String EC:ClOrdNo)
                {
                    if(orderNo.Order_Number__c != EC && !(Buf.contains(EC)))
                    {
                        Buf.add(EC);
                        Order O = New Order();
                        O.RecordTypeId = PARecordTypId;
                        O.Order_Number__c = EC;
                        
                        OrdToAdd.add(O);
                    }
                }
            }
        }
        else
        {
            for(String EC:ClOrdNo)
            {
                Order O = New Order();
                O.RecordTypeId = PARecordTypId;
                O.Order_Number__c = EC;
                OrdToAdd.add(O);
            }
        }
        OrderNos.addAll(OrdToAdd);
        return OrderNos.size();
    }
    
    
    //@description : Method is used for retrieving Orders Data
    //Input: String Order Reference No.
    //Return: Order Data for passed Order Reference No.
    @AuraEnabled (Cacheable=true)
    public static List<Mya_OrderItems> getOrderListRefNo(string OrderRefNo)
    {
        List<Mya_OrderItems> MyOrderItems = new List<Mya_OrderItems>();  
        List<String> orderNos = New List<String>{OrderRefNo};
            String OrderType = 'FG';
        String OrderId = 'OrderId';
        String Token = Mya_OrderDetailApiHelper.mya_ClientAuth();
        for(String orderNo:OrderNos)        
        {
            Mya_OrderItems EOI = mya_OrderDetail(Mya_OrderDetailApiHelper.mya_FetchOrderDetail(orderNo,OrderType,Token),OrderType,OrderId);
            MyOrderItems.add(EOI);            
        }
        Return MyOrderItems;
    }
    
    @AuraEnabled (Cacheable=true)
    public static List<Mya_OrderItems> getOrderListNo(string OrderRefNo)
    {
        List<Mya_OrderItems> MyOrderItems = new List<Mya_OrderItems>();  
        List<String> orderNos = New List<String>{OrderRefNo};
            String OrderType;
        if(OrderRefNo.isNumeric())
        {
            OrderType = 'Concession';
        }
        else
        {
            OrderType = 'FG';
        }
        String OrderId = 'OrderId';
        String Token = Mya_OrderDetailApiHelper.mya_ClientAuth();
        
        system.debug(OrderRefNo);
        
        for(String orderNo:OrderNos)        
        {
            Mya_OrderItems EOI = mya_OrderDetail(Mya_OrderDetailApiHelper.mya_FetchOrderDetail(orderNo,OrderType,Token),OrderType,OrderId);
            
            system.debug(EOI);
            
            MyOrderItems.add(EOI);            
        }
        Return MyOrderItems;
    }
    
    //@description : Method is used for Deserializing Orders API Data
    //Input: String JSON response from ORDER API
    //Return: Order Data for passed JSON response from ORDER API
    @AuraEnabled(cacheable=false)
    Public static Mya_OrderItems mya_OrderDetail(String JS, String OrderType, String OrderId)
    {
        String jsonData = JS;
        system.debug('inside myorders line no 381 ' +jsonData);
        Mya_Payload JD;
        List<Mya_Payload.P_OUT_LINE_TBL_ITEMS> lineTableItem  = new  List<Mya_Payload.P_OUT_LINE_TBL_ITEMS>();
        List<Mya_Payload.P_OUT_LINE_VAL_TBL_ITEMS> LineValueTableItem = new List<Mya_Payload.P_OUT_LINE_VAL_TBL_ITEMS>();  
        List<Mya_Payload.P_OUT_HEADER_PAYMENT_TBL_ITEMS> PaymentDetails = new List<Mya_Payload.P_OUT_HEADER_PAYMENT_TBL_ITEMS>();
        List<Mya_LineItems> myLineItemList = new list<Mya_LineItems>();
        Set<String> ShipSET = New Set<String>();
        
        //Deserializing JSON data Using Mya_Payload Wrapper Class
        JD = (Mya_Payload) JSON.deserialize(jsonData, Mya_Payload.class);
        
        lineTableItem = JD.P_OUT_LINE_TBL.P_OUT_LINE_TBL_ITEMS;
        LineValueTableItem = JD.P_OUT_LINE_VAL_TBL.P_OUT_LINE_VAL_TBL_ITEMS;
        PaymentDetails = JD.P_OUT_HEADER_PAYMENT_TBL.P_OUT_HEADER_PAYMENT_TBL_ITEMS;
        system.debug('lineTableItem line 395' +lineTableItem);
        system.debug('lineTableItem line 395' +LineValueTableItem);
        system.debug('lineTableItem line 395' +PaymentDetails);
        
        //Population of a Parts Order Data
        Mya_OrderItems OI = New Mya_OrderItems();
        if(OrderType == 'Parts')
        {
            OI.FGOrderFlag = false;
            OI.OrderDate = Date.valueOf(JD.P_OUT_HEADER_REC.ORDERED_DATE);
            OI.ShipZip = JD.P_OUT_HEADER_VAL_REC.SHIP_TO_ZIP.substring(0,5);
            OI.RequestDate = Date.valueOf(JD.P_OUT_HEADER_REC.REQUEST_DATE);
            OI.OrderNumber = JD.P_OUT_HEADER_REC.ORDER_NUMBER;
            
            if(JD.P_OUT_HEADER_REC.ORIG_SYS_DOCUMENT_REF != null)
            {
                OI.OrderRefNumber = JD.P_OUT_HEADER_REC.ORIG_SYS_DOCUMENT_REF;
            }
            else 
            {
                OI.OrderRefNumber = 'N/A';
            }
            //Order Status-HeaderStatus
            OI.OrderStatusCompFlag = false;
            OI.OrderStatusPendFlag = false;
            OI.OrderStatusCancelFlag = false;
            if(JD.P_OUT_HEADER_REC.FLOW_STATUS_CODE == 'booked')
            {
                OI.OrderStatus = 'Pending';     
                OI.OrderStatusPendFlag = true;        
            }
            else if(JD.P_OUT_HEADER_REC.FLOW_STATUS_CODE == 'closed')
            {
                OI.OrderStatus = 'Complete';
                OI.OrderStatusCompFlag = true;  
            }
            else if(JD.P_OUT_HEADER_REC.FLOW_STATUS_CODE == 'Cancelled')
            {
                OI.OrderStatus = 'Cancelled';
                OI.OrderStatusCancelFlag = true;  
            }
            
            //Show Return
            OI.ShowReturn = true;
            if((OI.RequestDate.addDays(90) <= date.today()) && OI.OrderStatus =='Complete')
            {
                OI.ShowReturn = false;
            }
            
            String domainUrl = Url.getOrgDomainUrl().getHost();
            MYA_Configuration__mdt details = MYA_MetaDataConfigHelper.getmyaConfigByDomain(domainUrl);    
            OI.PartsReturnURL = details.ReturnBaseURL__c 
                + '/store/order/selectreturns?'
                + 'order_number=' 
                + OI.OrderNumber 
                + '&delivery_zip_code=' 
                + JD.P_OUT_HEADER_VAL_REC.SHIP_TO_ZIP.substring(0,5);
            OI.PartsStatusURL = details.PartsOrderStatus__c
                + '/store/order/viewreceipt?order=' 
                + OI.OrderNumber
                + '&zip='
                + JD.P_OUT_HEADER_VAL_REC.SHIP_TO_ZIP.substring(0,5);
            
            for(Mya_Payload.P_OUT_LINE_TBL_ITEMS A:lineTableItem)
            {
                Mya_LineItems LineItem = new Mya_LineItems();
                //Line Item Display Flag
                LineItem.ShowLineItemFlag = false;
                LineItem.ItemModelNo = A.ORDERED_ITEM;
                
                LineItem.StandInstallFlag = false;
                if(A.ORDERED_ITEM.containsIgnoreCase('install'))
                {
                    LineItem.StandInstallFlag = true;
                }
                
                if(A.SHIPPING_INTERFACED_FLAG == 'Y')
                {
                    LineItem.ShowLineItemFlag = true;
                }
                
                
                //Product Image and Description for Every LineItem
                if(LineItem.ShowLineItemFlag == true)
                {
                    try 
                    {
                        MYA_EndecaApiHandler.EndecaResponseDetails data = MYA_EndecaApiHandler.MYA_EndecaResponseDetails(A.ORDERED_ITEM);
                        MYA_EndecaApiHandler.EndecaResponse prdInfo = data.ProductInfo;
                        String url1=prdInfo.defaultImageUrl;
                        if(url1 != null)
                        {
                            //LineItem.LineItemURL = url1+'&Variant=Thumbnail';
                            LineItem.LineItemURL = url1.left(url1.lastIndexOf('/'))+'/w_192,h_200'+url1.right(url1.length()-url1.lastIndexOf('/')); // changed as part of SPR-146 Salsify-endeca transisiton project changes
                        }   
                        LineItem.ProdDescription = prdInfo.ProductDescription.toString();
                    } 
                    catch (Exception Ex) 
                    {
                    }
                }
                LineItem.ItemImageFlag = false;
                if(LineItem.LineItemURL != null)
                {
                    LineItem.ItemImageFlag = true;
                }
                myLineItemList.add(LineItem);
            }
            OI.LineItemList = myLineItemList;
            
            for(Mya_Payload.P_OUT_HEADER_PAYMENT_TBL_ITEMS EP: PaymentDetails)
            {
                if(EP.PAYMENT_AMOUNT != null)
                {
                    OI.OrderTotal = OI.OrderTotal + decimal.valueOf(EP.PAYMENT_AMOUNT);
                }
            }
            OI.OrderTotalString = decToStr(OI.OrderTotal);
        }
        //Population of a FG Order Data
        else if(OrderType == 'FG' || OrderType == 'Concession')
        {
            OI.OrderDate = Date.valueOf(JD.P_OUT_HEADER_REC.ORDERED_DATE);
            OI.CustPhone = JD.P_OUT_HEADER_REC.ATTRIBUTE8;
            OI.CustEmail = JD.P_OUT_HEADER_REC.ATTRIBUTE2;
            OI.CustName = JD.P_OUT_HEADER_VAL_REC.SOLD_TO_ORG;
            OI.ShippingMethod = JD.P_OUT_HEADER_VAL_REC.SHIPPING_METHOD;
            OI.RequestDate = Date.valueOf(JD.P_OUT_HEADER_REC.REQUEST_DATE);
            OI.ShipZip = JD.P_OUT_HEADER_VAL_REC.SHIP_TO_ZIP.substring(0,5);
            OI.MixedShipFlag = false;
            OI.IsOrderAwaitingShippingFlag = false;
            OI.IsOrderAwaitingReturnFlag = false;
            OI.OrderId = OrderId;
            system.debug('Population of a FG Order Data' +OI.OrderDate + OI.OrderId );
            
            if(JD.P_OUT_HEADER_REC.ORDER_NUMBER != null)
            {
                OI.OrderNumber = JD.P_OUT_HEADER_REC.ORDER_NUMBER;
            }
            else 
            {
                OI.OrderNumber = 'N/A';
            }
            OI.OrderRefNumber = JD.P_OUT_HEADER_REC.ORIG_SYS_DOCUMENT_REF;
            
            
            //FG Order Flag
            OI.FGOrderFlag = true;
            system.debug('OI.FGOrderFlag' +OI.FGOrderFlag);
            
            //TotalValue
            /*if(JD.P_OUT_HEADER_REC.PAYMENT_AMOUNT != null)
{
OI.OrderTotal = decimal.valueOf(JD.P_OUT_HEADER_REC.PAYMENT_AMOUNT);
}*/
            
            if(OrderType == 'Concession')
            {
                OI.OrderTotalString = '0';
                OI.isCROrder = true;
            }
            else if(OrderType == 'FG')
            {
                for(Mya_Payload.P_OUT_HEADER_PAYMENT_TBL_ITEMS EP: PaymentDetails)
                {
                    if(EP.PAYMENT_AMOUNT != null)
                    {
                        OI.OrderTotal = OI.OrderTotal + decimal.valueOf(EP.PAYMENT_AMOUNT);
                    }
                }
                OI.OrderTotalString = decToStr(OI.OrderTotal);
            }
            system.debug('OI.OrderTotalString' +OI.OrderTotalString);
            
            
            //Ship Address
            if((JD.P_OUT_HEADER_VAL_REC.SHIP_TO_ADDRESS1 != null) && (JD.P_OUT_HEADER_VAL_REC.SHIP_TO_ADDRESS1 != 'null'))
            {
                OI.ShipAddLine1 = JD.P_OUT_HEADER_VAL_REC.SHIP_TO_ADDRESS1;
            }
            if((JD.P_OUT_HEADER_VAL_REC.SHIP_TO_ADDRESS2 != null) && (JD.P_OUT_HEADER_VAL_REC.SHIP_TO_ADDRESS2 != 'null'))
            {
                OI.ShipAddLine1 = OI.ShipAddLine1 + ' ' + JD.P_OUT_HEADER_VAL_REC.SHIP_TO_ADDRESS2;
            }
            if((JD.P_OUT_HEADER_VAL_REC.SHIP_TO_ADDRESS3 != null) && (JD.P_OUT_HEADER_VAL_REC.SHIP_TO_ADDRESS3 != 'null'))
            {
                OI.ShipAddLine1 = OI.ShipAddLine1 + ' ' + JD.P_OUT_HEADER_VAL_REC.SHIP_TO_ADDRESS3;
            }
            if((JD.P_OUT_HEADER_VAL_REC.SHIP_TO_ADDRESS4 != null) && (JD.P_OUT_HEADER_VAL_REC.SHIP_TO_ADDRESS4 != 'null'))
            {
                OI.ShipAddLine1 = OI.ShipAddLine1 + ' ' + JD.P_OUT_HEADER_VAL_REC.SHIP_TO_ADDRESS4;
            }
            
            OI.ShipAddLine2 = JD.P_OUT_HEADER_VAL_REC.SHIP_TO_CITY + ', ' +
                JD.P_OUT_HEADER_VAL_REC.SHIP_TO_STATE + ', ' +
                JD.P_OUT_HEADER_VAL_REC.SHIP_TO_ZIP.substring(0,5);
            system.debug('OI.ShipAddLine2' +OI.ShipAddLine2);
            //Bill Address
            if((JD.P_OUT_HEADER_VAL_REC.INVOICE_TO_ADDRESS1 != null) && (JD.P_OUT_HEADER_VAL_REC.INVOICE_TO_ADDRESS1 != 'null'))
            {
                OI.BillAddLine1 = JD.P_OUT_HEADER_VAL_REC.INVOICE_TO_ADDRESS1;
            }
            if((JD.P_OUT_HEADER_VAL_REC.INVOICE_TO_ADDRESS2 != null) && (JD.P_OUT_HEADER_VAL_REC.INVOICE_TO_ADDRESS2 != 'null'))
            {
                OI.BillAddLine1 = OI.BillAddLine1 + ' ' + JD.P_OUT_HEADER_VAL_REC.INVOICE_TO_ADDRESS2;
            }
            if((JD.P_OUT_HEADER_VAL_REC.INVOICE_TO_ADDRESS3 != null) && (JD.P_OUT_HEADER_VAL_REC.INVOICE_TO_ADDRESS3 != 'null'))
            {
                OI.BillAddLine1 = OI.BillAddLine1 + ' ' + JD.P_OUT_HEADER_VAL_REC.INVOICE_TO_ADDRESS3;
            }
            if((JD.P_OUT_HEADER_VAL_REC.INVOICE_TO_ADDRESS4 != null) && (JD.P_OUT_HEADER_VAL_REC.INVOICE_TO_ADDRESS4 != 'null'))
            {
                OI.BillAddLine1 = OI.BillAddLine1 + ' ' + JD.P_OUT_HEADER_VAL_REC.INVOICE_TO_ADDRESS4;
            }
            
            OI.BillAddLine2 = JD.P_OUT_HEADER_VAL_REC.INVOICE_TO_CITY + ', ' +
                JD.P_OUT_HEADER_VAL_REC.INVOICE_TO_STATE + ', ' +
                JD.P_OUT_HEADER_VAL_REC.INVOICE_TO_ZIP.substring(0,5);
            system.debug('OI.BillAddLine2' +OI.BillAddLine2); 
            
            //Population of Every LineItem in an Order
            for(Mya_Payload.P_OUT_LINE_TBL_ITEMS A:lineTableItem)
            {
                Mya_LineItems LineItem = new Mya_LineItems();
                LineItem.ItemModelNo = A.ORDERED_ITEM;
                LineItem.SourceType = A.SOURCE_TYPE_CODE;
                LineItem.RequestDate = Date.valueOf(A.REQUEST_DATE);
                LineItem.ItemQuantity = integer.valueOf(A.ORDERED_QUANTITY);
                
                LineItem.StandInstallFlag = false;
                if(A.ORDERED_ITEM.containsIgnoreCase('install'))
                {
                    LineItem.StandInstallFlag = true;
                }
                system.debug('LineItem.StandInstallFlag' +LineItem.StandInstallFlag);
                //Line Item Selling Price, Actual Price and Line Item Discount Flag
                LineItem.ItemUnitPrice = (integer.valueOf(A.ORDERED_QUANTITY))*(decimal.valueOf(A.UNIT_SELLING_PRICE_PER_PQTY));
                LineItem.ItemUnitPriceString = decToStr(LineItem.ItemUnitPrice);
                LineItem.ItemActualUnitPrice = (integer.valueOf(A.ORDERED_QUANTITY))*(decimal.valueOf(A.UNIT_LIST_PRICE_PER_PQTY));
                OI.OrderDiscount = OI.OrderDiscount + (LineItem.ItemActualUnitPrice - LineItem.ItemUnitPrice);
                OI.OrderDiscountString = decToStr(OI.OrderDiscount);
                LineItem.ItemDiscountFlag = false;
                if(LineItem.ItemUnitPrice < LineItem.ItemActualUnitPrice)
                {
                    LineItem.ItemDiscountFlag = true;
                }
                system.debug('LineItem.ItemDiscountFlag' +LineItem.ItemDiscountFlag);
                LineItem.ItemOrderType = A.LINE_CATEGORY_CODE;
                LineItem.LineItemStatus = A.FORM_FLOW_STATUS_CODE;
                
                if(A.SCHEDULE_ARRIVAL_DATE != null)
                {
                    LineItem.ItemArrivalDate = Date.valueOf(A.SCHEDULE_ARRIVAL_DATE);
                }
                
                OI.OrderType = A.LINE_CATEGORY_CODE;
                
                system.debug('OI.OrderType' +OI.OrderType);
                
                //Line Item Display Flag Order Detail Page
                LineItem.ShowLineItemFlagDetail = false;
                if(LineItem.ItemUnitPrice != 0)
                {
                    //Order Delivery Charge
                    if(A.ORDERED_ITEM != null && A.ORDERED_ITEM.containsIgnoreCase('home delivery'))
                    {
                        OI.OrderDeliveryCharge = decimal.valueOf(A.UNIT_LIST_PRICE);
                        OI.OrderDeliveryChargeFlag = true;
                        OI.OrderDeliveryChargeString = decToStr(OI.OrderDeliveryCharge);
                    }
                    
                    //Order Shipping Charge
                    else if(A.ORDERED_ITEM != null && A.ORDERED_ITEM.containsIgnoreCase('small package delivery'))
                    {
                        OI.OrderShippingCharge = decimal.valueOf(A.UNIT_LIST_PRICE);
                        OI.OrderShippingChargeString = decToStr(OI.OrderShippingCharge);
                    }
                    else 
                    {
                        LineItem.ShowLineItemFlagDetail = true;
                    }
                }
                else if(A.ATTRIBUTE1 != null)
                {
                    LineItem.ShowLineItemFlagDetail = true;
                }
                
                // Line Item Shipping Method
                Map<string,string> lineShip = new Map<string,string>();    
                for(integer counter = 0; counter<LineValueTableItem.size(); Counter++)
                {
                    lineShip.put(lineTableItem[counter].LINE_NUMBER,LineValueTableItem[counter].SHIPPING_METHOD);
                }
                LineItem.ItemShipMethod = lineShip.get(A.LINE_NUMBER);
                
                //Shipping Method Flags - 'Home Delivery' and 'Fedex'
                LineItem.ShipHomDelFlag = false;
                LineItem.ShipFedexFlag = false;
                ShipSET.add(LineItem.ItemShipMethod);
                if(LineItem.ItemShipMethod != null && (LineItem.ItemShipMethod.contains('Home Delivery') || LineItem.ItemShipMethod.contains('SDS Delivery')) && LineItem.ShipHomDelFlag == false)
                {
                    LineItem.ShipHomDelFlag = true;
                }
                if(LineItem.ItemShipMethod != null && LineItem.ItemShipMethod.contains('FedEx') && LineItem.ShipHomDelFlag == false)
                {
                    LineItem.ShipFedexFlag = true;
                }
                
                //List of Serial Numbers
                List<String> Serials = New List<String>();
                if(A.FROM_SERIAL_NUMBER.FROM_SERIAL_NUMBER_ITEMS != null)
                {
                    for(Mya_Payload.FROM_SERIAL_NUMBER_ITEMS ES:A.FROM_SERIAL_NUMBER.FROM_SERIAL_NUMBER_ITEMS)
                    {
                        if(ES!= null)
                        {
                            Serials.add(ES.FM_SERIAL_NUMBER); 
                        }
                    }
                }
                LineItem.LineItemSerialList = Serials;
                
                //TaxValue of an Order
                if(A.TAX_VALUE != null)
                {
                    LineItem.ItemTax = decimal.valueOf(A.TAX_VALUE);
                    OI.OrderTax = OI.OrderTax + decimal.valueOf(A.TAX_VALUE);
                    OI.OrderTaxString = decToStr(OI.OrderTax);
                }
                
                //Product Image and Description for Every LineItem
                if(LineItem.ShowLineItemFlagDetail == true)
                {
                    try 
                    {
                        MYA_EndecaApiHandler.EndecaResponseDetails data = MYA_EndecaApiHandler.MYA_EndecaResponseDetails(A.ORDERED_ITEM);
                        MYA_EndecaApiHandler.EndecaResponse prdInfo = data.ProductInfo;
                        String url1=prdInfo.defaultImageUrl;
                        if(url1 != null)
                        {
                            //LineItem.LineItemURL = url1+'&Variant=Thumbnail';
                            LineItem.LineItemURL = url1.left(url1.lastIndexOf('/'))+'/w_192,h_200'+url1.right(url1.length()-url1.lastIndexOf('/')); // changed as part of SPR-146 Salsify-endeca transisiton project changes; 
                            
                        }                    
                        LineItem.ProdDescription = prdInfo.ProductDescription.toString();
                    } 
                    catch (Exception Ex) 
                    {
                    }
                }
                
                //Line Item Display Flag
                LineItem.ShowLineItemFlag = false;
                if(A.SHIPPING_INTERFACED_FLAG == 'Y' || LineItem.LineItemURL != null)
                {
                    LineItem.ShowLineItemFlag = true;
                    OI.OrderShipDate = Date.valueOf(A.SCHEDULE_SHIP_DATE);
                }
                
                //Order Awaiting Return Flag
                if(LineItem.ShowLineItemFlag == true && OI.IsOrderAwaitingReturnFlag == false && LineItem.LineItemStatus == 'Awaiting Return')
                {
                    OI.IsOrderAwaitingReturnFlag = true;
                }
                
                //Order Awaiting Shipping Flag
                if(LineItem.ShowLineItemFlag == true && OI.IsOrderAwaitingShippingFlag == false && LineItem.LineItemStatus == 'Awaiting Shipping')
                {
                    OI.IsOrderAwaitingShippingFlag = true;
                }
                
                LineItem.ItemImageFlag = false;
                if(LineItem.LineItemURL != null)
                {
                    LineItem.ItemImageFlag = true;
                }
                
                // Service Code Changes Start - I
                // Line Item Service Flag
                LineItem.isServiceFlag =  false;
                for(Mya_Payload.P_OUT_LINE_VAL_TBL_ITEMS ELI:LineValueTableItem)
                {
                    if(ELI.ITEM_RELATIONSHIP_TYPE_DSP == 'Related' && (LineValueTableItem.indexOf(ELI) + 1) == integer.valueOf(A.LINE_NUMBER))
                    {
                        LineItem.isServiceFlag =  true;
                        LineItem.serviceRelatedToLineItem = ELI.ORIGINAL_ORDERED_ITEM;
                        if(A.ORDERED_ITEM.containsIgnoreCase('1-YEAR CONSUMER IN HOME SERVICE PLAN') ||
                           A.ORDERED_ITEM.containsIgnoreCase('1-YEAR NO CHARGE CONSUMER SERVICE PLAN'))
                        {
                            LineItem.ProdDescription = '1 Year Bodewell Care℠ Protection Plan';
                        }
                        else if(A.ORDERED_ITEM.containsIgnoreCase('2-YEAR CONSUMER IN HOME SERVICE PLAN') ||
                                A.ORDERED_ITEM.containsIgnoreCase('2-YEAR NO CHARGE CONSUMER SERVICE PLAN'))
                        {
                            LineItem.ProdDescription = '2 Year Bodewell Care℠ Protection Plan';
                        }
                        else if(A.ORDERED_ITEM.containsIgnoreCase('4-YEAR CONSUMER IN HOME SERVICE PLAN') ||
                                A.ORDERED_ITEM.containsIgnoreCase('4-YEAR NO CHARGE CONSUMER SERVICE PLAN'))
                        {
                            LineItem.ProdDescription = '4 Year Bodewell Care℠ Protection Plan';
                        }
                        //LineItem.ProdDescription = LineItem.serviceText;
                    }
                }
                // Service Code Changes Start End - I
                myLineItemList.add(LineItem);
            }
            // Service Code Changes Start - II
            Map<String,Mya_LineItems> serviceLineItem  = new  Map<String,Mya_LineItems>();
            List<Mya_LineItems> finalLineItems = new List<Mya_LineItems>();
            
            for(Mya_LineItems li:myLineItemList)
            {
                if(li.serviceRelatedToLineItem != null){
                    serviceLineItem.put(li.serviceRelatedToLineItem,li);
                }
            }
            
            for(Mya_LineItems lis:myLineItemList)
            {
                if(lis.serviceRelatedToLineItem == null)
                {
                    finalLineItems.add(lis);
                    if(serviceLineItem.containsKey(lis.ItemModelNo))
                    {
                        Mya_LineItems newLineItem = serviceLineItem.get(lis.ItemModelNo);
                        newLineItem.ItemArrivalDate = lis.ItemArrivalDate;
                        finalLineItems.add(newLineItem);
                        //finalLineItems.add(serviceLineItem.get(lis.ItemModelNo));
                    }  
                }   
            }
            myLineItemList.clear();
            myLineItemList.addAll(finalLineItems);
            // Service Code Changes End - II
            
            // Order Discount Flag
            OI.OrdDiscFlag = false;
            if(OI.OrderDiscount != 0)
            {
                OI.OrdDiscFlag = true;
            }
            
            // Mixed Shipping Method Flag
            if(ShipSET.contains('Home Delivery') && (ShipSET.contains('FedEx') || ShipSET.contains('FedEx Ground')))
            {
                OI.MixedShipFlag = true;
            }
            OI.LineItemList = myLineItemList;
            
            //Order Status of an Order
            List<String> StatusBuffer = new List<String>();
            Integer CancelCount = 0;
            Integer CompCount = 0;
            OI.OrderStatusCompFlag = false;
            OI.OrderStatusPendFlag = false;
            OI.OrderStatusCancelFlag = false;
            for(Mya_LineItems EST:myLineItemList)
            {
                String ES = EST.LineItemStatus;
                if(ES == 'Booked' || ES =='Supply Eligible' || ES =='Internal Req Requested' ||
                   ES =='Awaiting Shipping' || ES =='Awaiting Return' || ES =='Awaiting Receipt' ||
                   ES =='Shipped' || ES =='Picked')
                {
                    StatusBuffer.add('Pending');
                }
                else if(ES == 'Cancelled')
                {
                    StatusBuffer.add('Cancelled');
                    CancelCount += 1;
                }
                else if(ES == 'Closed' || ES =='Awaiting Fulfillment' || ES =='Returned')
                {
                    StatusBuffer.add('Complete');
                    CompCount += 1;
                }
            }
            if(StatusBuffer.contains('Pending'))
            {
                OI.OrderStatus='Pending';
                OI.OrderStatusPendFlag = true;
            }
            else if(StatusBuffer.size() == CompCount)
            {
                OI.OrderStatus='Complete';
                OI.OrderStatusCompFlag = true;
            }
            else if(StatusBuffer.contains('Cancelled'))
            {
                OI.OrderStatus='Cancelled';
                OI.OrderStatusCancelFlag = true;
            }
            
            //Home Delivery Shipping Method Flag
            OI.ShipMetHomDelFlag = false;
            if(JD.P_OUT_HEADER_VAL_REC.SHIPPING_METHOD == 'Home Delivery')
            {
                OI.ShipMetHomDelFlag = true;
            }
            
            //Text Track Flag
            OI.TextTrackFlag = false;
            if(OI.RequestDate > Date.today().AddDays(1))
            {
                OI.TextTrackFlag = true;
            }
            
            //Show Reschedule Link
            OI.ShowReschedule = false;
            if(OI.RequestDate > Date.today().AddDays(1) && OI.OrderStatus =='Pending' && OI.OrderType == 'ORDER')
            {
                OI.ShowReschedule = true;
            }
            
            //Show Track My Order
            OI.ShowTrackMyOrder = false;
            if(OI.RequestDate == Date.today() && OI.OrderStatus=='Pending' && (OI.OrderType == 'ORDER' || OI.OrderType == 'WORK ORDER'))
            {
                OI.ShowTrackMyOrder = true;
            }
            
            //BackOrder Flag
            OI.BackOrderFlag = false;
            List<Mya_Payload.P_HOLD_HEADER_LEVEL_INFO_TAB_ITEMS> HoldDet = New List<Mya_Payload.P_HOLD_HEADER_LEVEL_INFO_TAB_ITEMS>();
            if(JD.P_HOLD_HEADER_LEVEL_INFO_TAB.P_HOLD_HEADER_LEVEL_INFO_TAB_ITEMS != null)
            {
                HoldDet = JD.P_HOLD_HEADER_LEVEL_INFO_TAB.P_HOLD_HEADER_LEVEL_INFO_TAB_ITEMS;
                for(Mya_Payload.P_HOLD_HEADER_LEVEL_INFO_TAB_ITEMS ED: HoldDet)
                {
                    if(ED.HOLD_NAME =='GEA Store Backorder' && OI.BackOrderFlag == false)
                    {
                        OI.BackOrderFlag = true;
                    }
                }
            }
            
            String domainUrl = Url.getOrgDomainUrl().getHost();
            MYA_Configuration__mdt details = MYA_MetaDataConfigHelper.getmyaConfigByDomain(domainUrl);    
            OI.DeliveryInfoURL = details.DeliveryInfoURL__c;
            OI.RescheduleURL = details.RescheduleURL__c;
            OI.TrackMyOrderURL = details.TrackMyOrderURL__c;
            OI.OrderSubTotal = OI.OrderTotal - OI.OrderTax - OI.OrderShippingCharge - OI.OrderDeliveryCharge + OI.OrderDiscount;
            OI.OrderSubTotalString = decToStr(OI.OrderSubTotal);
        }
        Return OI;
    }
    public static string decToStr(decimal amt)
    {
        string amount = string.valueOf(amt);
        if(amt!=0 && amount.contains('.'))
        {
            integer dPos = amount.indexOf('.');
            if(amount.length() - dPos < 3)
            {
                amount = amount + '0';
            }
        }
        else if (amt==0 || amt == null)
        {
            amount = '0';
        }
        return amount;
    }
    
    @AuraEnabled(cacheable = true)
    public static OrderSummary getOrderSummaryDetails(String orderNumber){
        OrderSummary orderSummaryInstance = [SELECT Id
                                            FROM OrderSummary
                                            WHERE OriginalOrder.Order_Number__c =:orderNumber
                                            LIMIT 1];
        return orderSummaryInstance;
    }
}