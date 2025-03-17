@isTest
private class BWC_SearchConsumerResponseWrapperTest {

    @isTest
    static void testBWC_SearchConsumerResponseWrapper() {
        // Create test data
        BWC_SearchConsumerResponseWrapper.CustomerHeaderItem headerItem = new BWC_SearchConsumerResponseWrapper.CustomerHeaderItem();
        headerItem.PARTY_NAME = 'Test Name';
        // Add more test data initialization as needed

        BWC_SearchConsumerResponseWrapper.CustomerDetailsItem detailsItem = new BWC_SearchConsumerResponseWrapper.CustomerDetailsItem();
        detailsItem.SITE_USE_CODE = 'Test Code';
        // Add more test data initialization as needed

        BWC_SearchConsumerResponseWrapper wrapper = new BWC_SearchConsumerResponseWrapper();
        wrapper.P_HEADER_STATUS = 'Success';
        // Initialize other fields as needed
        wrapper.P_OUT_CUSTOMER_HDR_TAB = new BWC_SearchConsumerResponseWrapper.CustomerHeader();
        wrapper.P_OUT_CUSTOMER_HDR_TAB.P_OUT_CUSTOMER_HDR_TAB_ITEM = new List<BWC_SearchConsumerResponseWrapper.CustomerHeaderItem>{headerItem};
        wrapper.P_OUT_CUSTOMER_DTLS_TAB = new BWC_SearchConsumerResponseWrapper.CustomerDetails();
        wrapper.P_OUT_CUSTOMER_DTLS_TAB.P_OUT_CUSTOMER_DTLS_TAB_ITEM = new List<BWC_SearchConsumerResponseWrapper.CustomerDetailsItem>{detailsItem};

        // Perform test assertions
        System.assertEquals('Success', wrapper.P_HEADER_STATUS, 'Header status should be "Success"');
        // Add more assertions as needed
    }
}