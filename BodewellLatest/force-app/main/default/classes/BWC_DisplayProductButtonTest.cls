@isTest
public class BWC_DisplayProductButtonTest {
    @isTest
    static void testBwc_Available_Success() {
        
        // Create a test Product2 record
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            StockKeepingUnit = 'SKU1',
            Item_Number__c='123456',
            BWC_Exploded_Diagram_Parts__c = '{"Exploded Diagram Parts":{"sku":"PVS06BSPSS"}}',
            BWC_Delivery_Type__c = 'hd',
            Type = 'Base'
        );
        insert testProduct;

        Test.startTest();
        // Call the bwc_Available method with valid data
        Boolean result = BWC_DisplayProductButton.bwc_Available(testProduct.Id, '40222');
        Test.stopTest();
    }
    
     @isTest
    static void testBwc_Available_Success2() {
        
        // Create a test Product2 record
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            StockKeepingUnit = 'SKU2',
            Item_Number__c='123456',
            BWC_Exploded_Diagram_Parts__c = '{"Exploded Diagram Parts":{"sku":"PVS06BSPSS"}}',
            BWC_Delivery_Type__c = 'sps',
            Type = 'Base'
        );
        insert testProduct;

        Test.startTest();
        // Call the bwc_Available method with valid data
        Boolean result = BWC_DisplayProductButton.bwc_Available(testProduct.Id, '40222');
        Test.stopTest();
    }
    
     @isTest
    static void testBwc_In_Catch(){
        Test.startTest();
        Boolean result = BWC_DisplayProductButton.bwc_Available('1234', '12345');
        Test.stopTest();
    }

}