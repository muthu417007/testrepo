@isTest
public class BWC_RelatedProductControllerTest {
    
    @isTest
    public static void productDetailsTest() {
        Product2 testProduct = new Product2(Name = 'Demo',BWC_Product_Marketing_Description__c = 'Dummy Product', BWC_Pairing_Models__c='ABC05LZQ1~ABC05LZQ2~ABC05LZW1', BWC_Optional_Charge__c='ABC05LZQ1~ABC05LZQ2~ABC05LZW1', BWC_Accessories__c='ABC05LZQ1~ABC05LZQ2~ABC05LZW1', BWC_MFG_SKU__c = 'ABC05LZQ1~ABC05LZQ2~ABC05LZW1', StockKeepingUnit = 'XYZ123', DisplayUrl = 'https://xyz.com', BWC_Exploded_Diagram_Images__c  = '', BWC_Main_Image__c = 'https://xyz.com', Item_Number__c = 'XYZ111', BWC_Exploded_Diagram_Available__c = true);
        insert testProduct;
        String postalCodeInstance = '40222';
        Test.startTest();
        BWC_RelatedProductController.productDetails(testProduct.Id, postalCodeInstance);
        Test.stopTest();
    }
    
}