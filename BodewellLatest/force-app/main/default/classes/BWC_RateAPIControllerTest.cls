@isTest
public class BWC_RateAPIControllerTest {

    @TestSetup
    static void makeData(){
        Product2 testProductInstance = new Product2(
            Name = 'GXSL55R6363',
            ProductCode = 'GXSL55R',
            Item_Number__c = 'GXSL55R',
            StockKeepingUnit = 'GXSL55R6363',
            Inventory_Item_ID__c='12',
            BWC_Delivery_Type__c = 'sds',
            Is_Accessory__c = 'Yes'
        );
        insert testProductInstance;
    }

    @isTest
    public static void hitRateApiTest() {
        List<String> skuList = new List<String>();
        skuList.add([SELECT StockKeepingUnit FROM Product2 WHERE Name = 'GXSL55R6363' LIMIT 1][0].StockKeepingUnit);
        BWC_RateAPIController.hitRateApi(skuList,'40299');
    }
}