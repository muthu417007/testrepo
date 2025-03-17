@isTest
public class BWC_ModifyDeliveryGroupTest {

    @isTest
    public static void updateCurrentDeliveryGroupTestCase1(){
        
        Product2 productInstance = new Product2(
            Name = 'Shipping Charge for this delivery method',
            Item_Number__c = '123',
            StockKeepingUnit = 'Item1'
        );
        insert productInstance;
        
        OrderDeliveryMethod orderDeliveryMethodRecord = new OrderDeliveryMethod();
        orderDeliveryMethodRecord.Name = 'Order Delivery Method 1';
        orderDeliveryMethodRecord.ProductId = productInstance.Id;
        insert orderDeliveryMethodRecord;
        
        Account testAccount = new Account(Name='TestAccount');
        insert testAccount;
        
        WebStore testWebStore = new WebStore(Name='TestWebStore');
        insert testWebStore;
        
        WebCart cart = new WebCart(Name='Cart', WebStoreId=testWebStore.Id, AccountId = testAccount.Id);
        insert cart;
        
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery 1',DeliveryMethodId = orderDeliveryMethodRecord.Id);
        insert cartDeliveryGroup;
        
        Test.StartTest();
        BWC_ModifyDeliveryGroup.updateCurrentDeliveryGroup();
        Test.StopTest();
    }
    
    @isTest
    public static void updateCurrentDeliveryGroupTestCase2(){
        Product2 productInstance = new Product2(
            Name = 'Shipping Charge for this delivery method',
            Item_Number__c = '123',
            StockKeepingUnit = 'Item1'
        );
        insert productInstance;
        
        Account testAccount = new Account(Name='TestAccount');
        insert testAccount;
        
        WebStore testWebStore = new WebStore(Name='TestWebStore');
        insert testWebStore;
        
        WebCart cart = new WebCart(Name='Cart', WebStoreId=testWebStore.Id, AccountId = testAccount.Id);
        insert cart;
        
        CartDeliveryGroup cartDeliveryGroup2 = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery 1');
        insert cartDeliveryGroup2;
        
        Test.StartTest();
        BWC_ModifyDeliveryGroup.updateCurrentDeliveryGroup();
        Test.StopTest();
    }
    
    @isTest
    public static void updateCurrentDeliveryGroupTestCaseCatch(){
        Account testAccount = new Account(Name='TestAccount');
        insert testAccount;
        
        WebStore testWebStore = new WebStore(Name='TestWebStore');
        insert testWebStore;
        
        WebCart cart = new WebCart(Name='Cart', WebStoreId=testWebStore.Id, AccountId = testAccount.Id);
        insert cart;
        
        CartDeliveryGroup cartDeliveryGroup2 = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery 1');
        insert cartDeliveryGroup2;
        
        Test.StartTest();
        BWC_ModifyDeliveryGroup.updateCurrentDeliveryGroup();
        Test.StopTest();
    }
}