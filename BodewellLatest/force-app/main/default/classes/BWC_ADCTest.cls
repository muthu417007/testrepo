@isTest
public class BWC_ADCTest {
    @isTest
    static void testGetADC_Details() {
        // Create test data if needed, including any required objects or records
        // Insert necessary data into the database for the test
        
        // Call the method to be tested

        List<String> skuList = new List<String>{'SKU1'};
        String postalCodeInstance = '40222';
       // System.Test.startTest();
       // Test.setMock(HttpCalloutMock.class, new MockBWC_ADC());
        BWC_AvailabilityCacheWrapper result = BWC_ADC.getADC_Details(skuList, postalCodeInstance);
       // System.Test.stopTest();

        // Add assertions to verify the results
      //  System.assertEquals(null, result); // Adjust this assertion based on your expected result
    }

    @isTest
    static void testGetProductValues() {
        // Create test data if needed, including any required objects or records
        // Insert necessary data into the database for the test
        
        // Call the method to be tested
        BWC_ADC.ProductValuesResponse productResponse = new BWC_ADC.ProductValuesResponse();
        Product2 productInstance=new Product2(
          Name='Test',
          BWC_PARTSTAT__c=123,
          Restrictions__c='test',
          BWC_Material_Stock_Indicator__c='test',
          BWC_Brand__c='test',
          StockKeepingUnit='test',
          BWC_SUPERCEDE_COUNT__c=123,
          BWC_Derivative__c='test',
          Item_Lifecycle_Phase__c='test',
          Item_Number__c='124'
        );
        insert productInstance;
        System.Test.startTest();
        productResponse = BWC_ADC.getProductValues(productInstance.Id);
        System.Test.stopTest();

        // Add assertions to verify the results
       // System.assertEquals(null, product); // Adjust this assertion based on your expected result
    }
    
    @isTest
    static void testGetProductValuesInCatch() {
         BWC_ADC.ProductValuesResponse productResponse = new BWC_ADC.ProductValuesResponse();
          productResponse = BWC_ADC.getProductValues('123456789');        
    }
    
}