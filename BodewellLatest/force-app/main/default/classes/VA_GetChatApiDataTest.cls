/*
 * @description VA_GetChatApiDataTest test class for VA_GetChatApiData
 */
@isTest
public class VA_GetChatApiDataTest {
    @isTest
    static void getAnalyticsDataTest(){
        Test.startTest();
        String resp = VA_GetChatApiData.getAnalyticsResponse('no_cool','21','0','freezer','IM4A','LT123456','1234567890','21','32','test desc');
        Test.stopTest();
        system.assertNotEquals(null, resp,'response not null');
    }

}