@istest
public class BWC_AvailabilityCacheWrapperTest {
        @isTest
    static void testGetCacheAvailabilityParse() {
        String json='hello';
        Test.startTest();
       BWC_AvailabilityCacheWrapper response= BWC_AvailabilityCacheWrapper.parse(json);
          Test.stopTest();
        List<BWC_AvailabilityCacheWrapper.availabilityDetails> response1=response.availabilityDetails;
    String  msg=response.errorMessage;
    String  msg1=response.errorStatus;
        Integer requestedDateQuantity= response1[0].requestedDateQuantity;
       String shipDate= response1[0].shipDate;
        String requestedShipDate= response1[0].requestedShipDate;
          String message= response1[0].message;
                Integer errorCode= response1[0].errorCode;

        
        /*   String errorStatusNew=((BWC_AvailabilityCacheWrapper) System.JSON.deserialize(json, BWC_AvailabilityCacheWrapper.class)).errorStatus;
          String errorMessageNew=((BWC_AvailabilityCacheWrapper) System.JSON.deserialize(json, BWC_AvailabilityCacheWrapper.class)).errorMessage;
        List<BWC_AvailabilityCacheWrapper.availabilityDetails> listDetails=((BWC_AvailabilityCacheWrapper) System.JSON.deserialize(json, BWC_AvailabilityCacheWrapper.class)).availabilityDetails;
      
        */
    }

}