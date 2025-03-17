@isTest(seeAllData=true)
public class BWC_OrderConfirmationControllerTest {
    
    
      
    @isTest
    static void createContactTest() { 

        Account acc= new Account(Name= 'Test Account');
        insert acc;
        Profile p = [select Id from profile where name='Default Customer Login User'];
        Contact cont = new Contact(LastName ='testCon',
                                   Email='standarduser@testorg.com',
                                   AccountId = acc.Id, Global_Customer_Id__c= '123456-1234-123');
        insert cont;
         // Create a unique UserName
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';        
        User u1 = new User(
            Alias = 'standt',
            Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName=uniqueUserName,
            ContactId=cont.Id);
        insert u1;
        
        Contact_Point__c ContactPointObj = new Contact_Point__c();
        ContactPointObj.Contact__c = u1.ContactId;
        ContactPointObj.Phone__c = '1122334455';
        ContactPointObj.MYA_Included__c = true;
        ContactPointObj.MYAISPrimary__c = false;
        insert ContactPointObj;
        
        Contact_Point__c ContactPointObj1 = new Contact_Point__c();
        ContactPointObj1.Contact__c = u1.ContactId;
        ContactPointObj1.Phone__c = '1122334456';
        ContactPointObj1.MYA_Included__c = true;
        ContactPointObj1.MYAISPrimary__c = false;
        insert ContactPointObj1;
        
        Contact_Point__c ContactPointObj2 = new Contact_Point__c();
        ContactPointObj2.Contact__c = u1.ContactId;
        ContactPointObj2.Phone__c = '1122334457';
        ContactPointObj2.MYA_Included__c = true;
        ContactPointObj2.MYAISPrimary__c = false;
        ContactPointObj2.MYA_IsDeleted__c = true;
        insert ContactPointObj2;
        
        Test.startTest();  
        
        System.runAs(u1) {
        	Contact_Point__c response1 = BWC_OrderConfirmationController.getContactPointByContactId(u1.ContactId);
         
        }
        
        Test.stopTest();
		   			
     }
    
    @isTest
    public static void getBodewellOrdersItemstest()
    {
          User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
         
          Account acc= new Account(Name= 'Test Account');
        insert acc;
        Pricebook2 pb = [
            SELECT Id
            FROM Pricebook2
            WHERE isStandard = true
            LIMIT 1
        ];
        Order order = new Order(
            AccountId = acc.Id,
            OrderReferenceNumber = 'BDC00654321',
            // SalesStoreId = cart.WebStoreId,
            // PoNumber = cart.PoNumber,
            // BillingStreet = cart.BillingStreet,
            // BillingCity = cart.BillingCity,
            // BillingState = cart.BillingState,
            // BillingPostalCode = cart.BillingPostalCode,
            // BillingCountry = cart.BillingCountry,
            // BillingLatitude = cart.BillingLatitude,
            // BillingLongitude = cart.BillingLongitude,
            Pricebook2Id = pb.Id,
            EffectiveDate = Date.today(),
            OrderedDate = Date.today(),
            Status = 'Draft'
        );
        insert(order);
        
       
        
        
        system.debug('order created ');
        OrderDeliveryMethod m = new OrderDeliveryMethod();
        m.Name = 'Test';
        insert m;
        OrderDeliveryGroup orderDeliveryGroup = new OrderDeliveryGroup(
            Description = 'cartDeliveryGroup.Description',
            DesiredDeliveryDate = Date.today(),
            DeliverToName = 'cartDeliveryGroup.DeliverToName',
            DeliveryInstructions = 'cartDeliveryGroup.ShippingInstructions',
            // DeliverToStreet = cartDeliveryGroup.DeliverToStreet,
            // DeliverToCity = cartDeliveryGroup.DeliverToCity,
            // DeliverToState = cartDeliveryGroup.DeliverToState,
            // DeliverToPostalCode = cartDeliveryGroup.DeliverToPostalCode,
            // DeliverToCountry = cartDeliveryGroup.DeliverToCountry,
            // DeliverToLatitude = cartDeliveryGroup.DeliverToLatitude,
            // DeliverToLongitude = cartDeliveryGroup.DeliverToLongitude,
            OrderDeliveryMethodId = m.Id,
            OrderId = order.Id
        );
        insert orderDeliveryGroup;
        system.debug('order delivery method');
        Product2 prod = new Product2(name = 'Test',Item_Number__c='Order12345');
        insert prod;
        /*Pricebook2 pb = new Pricebook2(
Name = 'Example Price Book',
Description = 'This is the Price Book description.',
IsActive = true,
IsStandard = true
);
insert pb;*/
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pb.Id,
            Product2Id = prod.Id,
            UnitPrice = 1,
            IsActive = true,
            UseStandardPrice = false
        );
        insert pbe;
        OrderItem orderItem = new OrderItem(
            Product2Id = prod.Id,
            // Type = orderItemType,
            Quantity = 1,
            ListPrice = 1,
            UnitPrice = 1,
            OrderId = order.Id,
            PricebookEntryId = pbe.Id,
            OrderDeliveryGroupId = orderDeliveryGroup.Id
            // TotalLineAmount = cartItem.TotalLineAmount
        );
        insert(orderItem);
        
        
        
        order.Status = 'Activated';
        update order;
        ConnectApi.OrderSummaryInputRepresentation osir = new
            ConnectApi.OrderSummaryInputRepresentation();
        osir.orderId=order.Id; //replace this recordId with an appropriate value.
        osir.orderLifeCycleType='UNMANAGED';
        ConnectApi.OrderSummaryOutputRepresentation osor =
            ConnectApi.OrderSummaryCreation.createOrderSummary(osir);
        system.debug('osor==='+osor);
        OrderSummary ordSummary= [select id ,OrderNumber,OriginalOrder.OrderReferenceNumber from OrderSummary LIMIT 1];
        system.debug('ordSummary=='+ordSummary);
        WebStore webStore = new WebStore(Name='Bodewell Store');
        insert webStore;
        system.debug(webStore);
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=acc.Id, Status = 'Checkout');
        insert cart;
        
            CardPaymentMethod cmpInstance = new CardPaymentMethod(OPERATION__c='test',
                CONTEXT__c='82',
                CREDIT_CARD_APPROVAL_CODE__c='123',
                CREDIT_CARD_APPROVAL_DATE__c='123',
                CREDIT_CARD_CODE__c='1213',
                CREDIT_CARD_EXPIRATION_DATE__c='09-2029',
                CREDIT_CARD_HOLDER_NAME__c='test',
                CREDIT_CARD_NUMBER__c='567897654',
                PAYMENT_AMOUNT__c='344',
                PAYMENT_COLLECTION_EVENT__c='PREPAY',
                PAYMENT_NUMBER__c='1',
                ATTRIBUTE2__c='22',
                ATTRIBUTE3__c='324567',
                ATTRIBUTE1__c='dwfeerfe33',
                PAYMENT_TYPE_CODE__c='d12516',
                Status='Active',
                ProcessingMode='External'
              );
            //cmpInstance.CardPaymentMethodNumber = '123';
            
            insert cmpInstance;
        //SELECT Id, OrderSummaryId, PaymentMethodId, Type, FullName FROM OrderPaymentSummary
       
//       OrderPaymentSummary ordPaymentSummary=[SELECT id,Method from OrderPaymentSummary where( OrderSummaryId=:ordSummary.Id)];
           PaymentAuthorization pay=new PaymentAuthorization();
             // pay.OrderPaymentSummaryId=ordPaymentSummary.id;
              pay.PaymentMethodId=cmpInstance.Id;
              pay.Status='Processed';
          //    pay.Type='Capture';
              pay.ProcessingMode='External';
             // String amt=[SELECT Id, PAYMENT_AMOUNT__c FROM CardPaymentMethod where id=:s].PAYMENT_AMOUNT__c;
              pay.Amount=Decimal.valueOf('20');
            // insert pay;
        test.startTest();
        List<OrderItemSummary> listSummary= BWC_OrderConfirmationController.getBodewellOrdersItems(order.OrderReferenceNumber);
        List<OrderDeliveryGroupSummary> delSummary= BWC_OrderConfirmationController.getOrderDeliveryGroupSummary(order.OrderReferenceNumber);
        List<OrderPaymentSummary> paymentSummary=BWC_OrderConfirmationController.getOrderDeliveryPaymentSummary(order.OrderReferenceNumber); 
                List<CardPaymentMethod> paymentSummary1=BWC_OrderConfirmationController.getOrderDeliveryPaymentSummaryStripe(order.OrderReferenceNumber); 

          List<OrderSummary> orderSummary=BWC_OrderConfirmationController.getBodewellOrderSummary(thisUser.Id,1,1); 
        List<OrderItem> orderItems=BWC_OrderConfirmationController.getBodewellOrderSummaryItems(order.OrderReferenceNumber); 
        
        
        String cartId= BWC_OrderConfirmationController.getCurrentCartId(acc.Id);
        BWC_Product_Service__c prodSer = BWC_OrderConfirmationController.getProductServiceType(cartId);
        
            test.stoptest();
        
    }
    
     @isTest
    static void Mya_MyOrderItems_bodewellOrders()
    {
        Account acc= new Account(Name= 'Test Account Bodewell');
        insert acc;
        Profile p = [select Id from profile where name='Bodewell Commerce D2C Login User'];
        RecordType FG = [SELECT Id, Name FROM RecordType WHERE Name='FG Order'];
        
        Contact cont = new Contact(LastName ='testConbodewell',AccountId = acc.Id);
        insert cont;
        system.debug('contact created succesfully');
       
         // Create a unique UserName
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';        
        User u1 = new User(
            Alias = 'standt',
            Email='standarduserbodewell@testorg.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName=uniqueUserName,
            ContactId=cont.Id);
        insert u1;

Pricebook2 pb = [
            SELECT Id
            FROM Pricebook2
            WHERE isStandard = true
            LIMIT 1
        ];
            
         Contract contr = new Contract (AccountId = acc.Id, Status= 'Draft');
        insert contr;
        Product2 prod = new Product2(name = 'Test',Item_Number__c='Order12345');
        prod.BWC_Product_Marketing_Description__c = 'GE Profile™ Series ENERGY STAR';
        prod.Base_Model__c = 'PFE28KY';
         insert prod;
        
         PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pb.Id,
            Product2Id = prod.Id,
            UnitPrice = 1,
            IsActive = true,
            UseStandardPrice = false
        );
        insert pbe;
        
          System.debug('Product inserted successfully');
        
         Order odr1 = new order ();
        odr1.OrderReferenceNumber = 'BDC00654321';
        odr1.Order_Number__c = '00654321';
        // od1.RecordTypeId = FG.Id;
        odr1.BillToContactId = U1.ContactId;
        odr1.EffectiveDate = date.today()-2;
        odr1.AccountId = acc.id; 
        odr1.Status= 'Booked';
        odr1.ContractId = contr.Id;
        odr1.Pricebook2Id = pb.Id;
        insert odr1;
       
        
        System.debug('ORder created succesfully');
      System.debug('Test Order' + odr1.Order_Number__c);
        
         OrderItem orderItem = new OrderItem(
            Product2Id = prod.Id,
            Quantity = 1,
            ListPrice = 1,
            UnitPrice = 1,
              PricebookEntryId = pbe.Id,
            OrderId = odr1.Id,
             Type = 'Order Product'
        );
        insert(orderItem);
       Order OrderNos;
          system.debug('orders created succesfully');
        
          OrderNos =[SELECT Id, OrderReferenceNumber, Order_Number__c, Guest_Flag__c, BWC_ORIG_SYS_DOCUMENT_REF__c,Status,
                        EffectiveDate, TotalAmount, RecordType.Name
                        FROM Order 
                         where
                        OrderReferenceNumber like 'BDC%' limit 1];
        
        System.debug('OrderNos ' + OrderNos);
        Test.startTest();  
        System.runAs(u1) 
        {    
           
      Mya_OrderItems MyOrderItemsBodewellOrderItems= BWC_OrderConfirmationController.getBodewellOrderItems(odr1.OrderReferenceNumber); 
            
        }
        Test.stopTest();

     }                        
    
}