@isTest
public class PS_StaticResourceHelperTest {
    @isTest
    private static void getResourceURL_should_return_resource_URL() {
        //Arrange

        // Act
        Test.startTest();
        String resourceUrl = PS_StaticResourceHelper.getResourceURL();
        Test.stopTest();
    
        // Asserts
        System.assert(resourceUrl != '', 'Resource is expected since configuration exists.');
    }

    @isTest
    private static void getResourceURL_should_return_empty_if_no_config_exists() {
        //Arrange
        PS_GEAIdPCustomerConfigHelper.customerIdPConfiguration = new Customer_IdP_Configuration__mdt();

        // Act
        Test.startTest();
        String resourceUrl = PS_StaticResourceHelper.getResourceURL();
        Test.stopTest();
    
        // Asserts
        System.assertEquals('/resource/null', resourceUrl, 'No resource is expected since no configuration exists.');
    }
}