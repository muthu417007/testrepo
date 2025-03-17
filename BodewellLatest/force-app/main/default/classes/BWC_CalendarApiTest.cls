@isTest
public class BWC_CalendarApiTest {
    @TestSetup
    static void makeData(){
        Product2 testProduct = new Product2(Name = 'Test Product', BWC_Delivery_Type__c = 'hd',Item_Number__c='2479953-83-703495831');
        insert testProduct;
        Product2 testProduct2 = new Product2(Name = 'Test Product2', BWC_Delivery_Type__c = 'sds',Item_Number__c='24799-83-7034931');
        insert testProduct2;
        Product2 testProduct3 = new Product2(Name = 'Test Product3', BWC_Delivery_Type__c = 'sps fee',Item_Number__c='24753-83-70495831');
        insert testProduct3;
        Product2 testProduct4 = new Product2(Name = 'Test Product4',Item_Number__c='253-3-703495831');
        insert testProduct4;
    }
    @isTest
    public static void testBWC_CalendarApiMethod() {
        
    Product2 testProduct=[Select Id from Product2 where Name='Test Product' limit 1]; 
        String postalCodeInstance = '12345';
        String productIdInstance = testProduct.Id;
        String result = BWC_CalendarApi.BWC_CalendarApiMethod(postalCodeInstance, productIdInstance);
        // System.assertEquals('', result);

    }
    @isTest
    public static void testBWC_CalendarApiMethod2() {
        
    Product2 testProduct=[Select Id from Product2 where Name='Test Product2' limit 1]; 
        String postalCodeInstance = '12345';
        String productIdInstance = testProduct.Id;
        String result = BWC_CalendarApi.BWC_CalendarApiMethod(postalCodeInstance, productIdInstance);
        // System.assertEquals('', result);

    }
    @isTest
    public static void testBWC_CalendarApiMethod3() {
        
    Product2 testProduct=[Select Id from Product2 where Name='Test Product3' limit 1]; 
        String postalCodeInstance = '12345';
        String productIdInstance = testProduct.Id;
        String result = BWC_CalendarApi.BWC_CalendarApiMethod(postalCodeInstance, productIdInstance);
        // System.assertEquals('', result);

    }
    @isTest
    public static void testBWC_CalendarApiMethod4() {
        
    Product2 testProduct=[Select Id from Product2 where Name='Test Product4' limit 1]; 
        String postalCodeInstance = '12345';
        String productIdInstance = testProduct.Id;
        String result = BWC_CalendarApi.BWC_CalendarApiMethod(postalCodeInstance, productIdInstance);
        // System.assertEquals('', result);

    }
    
    @isTest
    public static void testBWC_CalendarApiMethod_In_Catch() {
         
        String postalCodeInstance = '12345';
        String productIdInstance = '12345';
        String result = BWC_CalendarApi.BWC_CalendarApiMethod(postalCodeInstance, productIdInstance);
        // System.assertEquals('', result);

    }
    
    @isTest
    public static void getEstimatedDateForSmallApplianceTest(){
        Test.startTest();
        String result = BWC_CalendarApi.getEstimatedDateForSmallAppliance(new List<String>{'SKU'},'40222','FG');
        Test.stopTest();
    }
}