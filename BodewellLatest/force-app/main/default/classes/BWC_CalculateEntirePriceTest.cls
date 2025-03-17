@isTest
public class BWC_CalculateEntirePriceTest {
    @TestSetup
    public static void testRecordSetup(){
        Product2 testProductInstance = new Product2(
            Name = 'test',
            ProductCode = '124',
            Item_Number__c = '123',
            StockKeepingUnit = 'Item1',
            Inventory_Item_ID__c='12',
            BWC_Delivery_Type__c = 'sds'
        );
        insert testProductInstance;
        Product2 testProductInstance2 = new Product2(
            Name = 'test1',
            ProductCode = '1242',
            Item_Number__c = '1234',
            StockKeepingUnit = 'Item2',
            Inventory_Item_ID__c='11',
            BWC_Delivery_Type__c = 'hd'
        );
        insert testProductInstance2;
        
        Account testAccount = new Account(Name = 'Test1');
        insert testAccount;
        WebStore testWebStore = new WebStore(Name='Bodewell Store');
        insert testWebStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=testWebStore.Id, AccountId=testAccount.Id);
        insert cart;
        
        CartDeliveryGroup cartDeliveryGroupInstance=new CartDeliveryGroup(Name='Default Delivery',CartId=cart.Id);
        insert cartDeliveryGroupInstance;
        
        CartItem cartItemInstance=new CartItem(Name=testProductInstance.Name,Product2Id=testProductInstance.Id,CartId=cart.Id,CartDeliveryGroupId=cartDeliveryGroupInstance.Id);
        insert cartItemInstance;
        
        BWC_Product_Service__c productServiceInstance = new BWC_Product_Service__c(Name='Test',BWC_SKU__c='HOME DELIVERY',BWC_Service_Price__c = 99, Cart_Item__c =cartItemInstance.Id);
        insert productServiceInstance;
        
        CartItem cartItemInstance2=new CartItem(Name=testProductInstance2.Name,Product2Id=testProductInstance2.Id,CartId=cart.Id,CartDeliveryGroupId=cartDeliveryGroupInstance.Id);
        insert cartItemInstance2;
        
        BWC_Product_Service__c productServiceInstance2 = new BWC_Product_Service__c(Name='Test2',BWC_SKU__c='HOME DELIVERY',BWC_Service_Price__c = 99, Cart_Item__c =cartItemInstance2.Id);
        insert productServiceInstance2;
        
        BWC_Product_Service__c productServiceInstance3 = new BWC_Product_Service__c(Name='Test3',BWC_SKU__c='FREESTANDING INSTALL',BWC_Service_Price__c = 25, Cart_Item__c =cartItemInstance2.Id);
        insert productServiceInstance3;
    }
    
    @isTest
    public static void calculateTotalAmountTest(){
        WebCart cart=[Select Id from WebCart limit 1];
        Double totalAmount = BWC_CalculateEntirePrice.calculateTotalAmount(cart.Id);
        
    }
}