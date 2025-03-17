@isTest(seeAllData = true)
public class BWC_utilsTest {
    @isTest
    public static void getUserAccountIDtestMethod(){
        Test.startTest();
        BWC_utils.getUserAccountID();
        Test.stopTest();
    }
    @isTest
    public static void getUserAccountIDtestMethod2(){
        Test.startTest();
        BWC_utils.resolveSortParam('test');
        Test.stopTest();
    }
}