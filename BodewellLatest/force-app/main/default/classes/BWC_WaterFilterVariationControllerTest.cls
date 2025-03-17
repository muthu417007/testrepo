/**
* @author Shubhada
* @description This test class of BWC_WaterFilterVariationController
* */
@isTest(seeAllData=true)
public class BWC_WaterFilterVariationControllerTest {
    
    
    /*
* @description This method is used to cover getAccount, getProductDetails method
*/
    @isTest
    public static void waterFilterTest(){
        Account accountInstance = [SELECT Id FROM Account LIMIT 1];
        Product2 productInstance = [SELECT Id ,StockKeepingUnit FROM Product2 LIMIT 1];
        Network networkInstance = [SELECT Id FROM Network LIMIT 1];       
        test.startTest();
      
         //   BWC_WaterFilterVariationController.getAccount(user.Id);
            BWC_WaterFilterVariationController.getProductDetails(productInstance.StockKeepingUnit,accountInstance.Id,networkInstance.Id);
            //  BWC_WaterFilterVariationController.getProductPrice(communityId,prod.Id,con.AccountId);
       test.stopTest();
    }
    
        @isTest
    public static void getProductPriceTest(){
        Account accountInstance = [SELECT Id FROM Account LIMIT 1];
        Product2 productInstance = [SELECT Id FROM Product2 LIMIT 1];
        Network networkInstance = [SELECT Id FROM Network LIMIT 1];
        Test.startTest();
        BWC_WaterFilterVariationController.getProductPrice(networkInstance.Id,productInstance.Id,accountInstance.Id);
        Test.stopTest();
    }
    
        @isTest
    public static void getAccountId(){
        User user = [SELECT Id FROM user LIMIT 1];
           Test.startTest();
        BWC_WaterFilterVariationController.getAccount(user.Id);
        Test.stopTest();
    }
    
}