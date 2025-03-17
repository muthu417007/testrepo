/**
* @author Abhishek Bisht
* @date 02/02/2024
* @description The purpose of this class is to update consumer address if it already contains a account.
* */
public class BWC_UpdateOracleConsumerAddress {
    /*
* @description The method returns the response of updating consumer address api
* @param 
* @return BWC_UpdateOracleConsumerWrapper
*/
    public static BWC_UpdateOracleConsumerWrapper updateAddress(String locationName,String locationType){
        String response;
        BWC_UpdateOracleConsumerWrapper wrapperResponse;
        final String fakeResponse = '{    "STATUS": "S",    "MESSAGE": "Column site_use_code must have a value.",    "LOCATION": {        "X_LOCATION_ID": "112756577",        "X_ADDR_VAL_STATUS": "",        "X_ADDR_WARN_MSG": "",        "X_RETURN_STATUS": "S",        "X_MSG_COUNT": "0",        "X_MSG_DATA": ""    },    "PARTY_SITE": {        "X_PARTY_SITE_ID": "114954222",        "X_PARTY_SITE_NUMBER": "114244285",        "X_RETURN_STATUS": "S",        "X_MSG_COUNT": "0",        "X_MSG_DATA": null    },    "CUSTOMER_ACCOUTN_SITE": {        "X_CUST_ACCT_SITE_ID": "113965260",        "X_RETURN_STATUS": "S",        "X_MSG_COUNT": "0",        "X_MSG_DATA": null    },    "CUSTOMER_SITE_USE_ID": {        "X_SITE_USE_ID": null,        "X_RETURN_STATUS": "E",        "X_MSG_COUNT": "1",        "X_MSG_DATA": "Column site_use_code must have a value."    }}';
        
        String jsonString = BWC_CreateUpdateOracleConsumerPayload.createConsumerUpdatePayload(locationName,locationType);
        System.debug('jsonString in BWC_UpdateOracleConsumerAddress->'+jsonString);
        
        if(!String.isBlank(jsonString)){
            response = test.isRunningTest() ? fakeResponse : utility.isSandbox ? RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_QA_Token','BWC_UpdateConsumer_QA',null,'POST',jsonString) : RequestMuleAPIData.getMuleAPIData('BWC_Production_MuleAuth','BWC_PROD_EBS_Token','BWC_PROD_UpdateConsumer',null,'POST',jsonString);
            wrapperResponse = (BWC_UpdateOracleConsumerWrapper)JSON.deserialize(response, BWC_UpdateOracleConsumerWrapper.class);
        }
        return wrapperResponse;
    }
    
    public class BWC_UpdateOracleConsumerWrapper{
        public String STATUS;
    }
}