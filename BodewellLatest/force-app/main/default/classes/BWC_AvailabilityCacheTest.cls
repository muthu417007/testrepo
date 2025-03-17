/**
* @author 
* @date 05/09/2023
* @description This test class is for BWC_AvailabilityCache Class
*/
@isTest
public class BWC_AvailabilityCacheTest {

    @isTest
    static void testGetCacheAvailability() {
        List<String> skuList = new List<String>{'SKU1', 'SKU2'};
        
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        BWC_AvailabilityCacheWrapper result = BWC_AvailabilityCache.getcacheAvailabilty(skuList,'413726');
        
        System.assertNotEquals(null, result);
        
         }
}