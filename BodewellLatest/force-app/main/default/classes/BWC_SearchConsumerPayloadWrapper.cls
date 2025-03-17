/**
* @author Abhishek
* @date 04/08/2023
* @description This class provides consumer details based on the consumer number.
*/
public class BWC_SearchConsumerPayloadWrapper {
    /**
* This method returns consumer details based on consumer number.
* @param consumerNumber - Consumer Number
* @return - BWC_SearchConsumerPayloadResponseWrapper
*/
    public static BWC_SearchConsumerPayloadResponseWrapper getConsumerDetail(String addressTypeInstance,String addressNameInstance){
        try{
            String consumerNumber;
            BWC_SearchConsumerPayloadResponseWrapper wrapperResponseData = new BWC_SearchConsumerPayloadResponseWrapper();
            List<User> userList = [SELECT Id,
                                   AccountId,
                                   Account.BWC_Consumer_Number__c
                                   FROM User 
                                   WHERE Id =:UserInfo.getUserId() 
                                   LIMIT 1];
            List<ContactPointAddress> contactPointAddressList = [SELECT Id,
                                                                 Name,
                                                                 BWC_Ship_To_Org_Id__c,
                                                                 BWC_Bill_To_Org_Id__c,
                                                                 BWC_Account_Number__c,
                                                                 Street, 
                                                                 City, 
                                                                 State, 
                                                                 PostalCode, 
                                                                 Country 
                                                                 FROM ContactPointAddress 
                                                                 WHERE IsDefault = True 
                                                                 AND AddressType =:addressTypeInstance
                                                                 AND ParentId =: userList[0].AccountId
                                                                 LIMIT 1];
            System.debug('contactPointAddressListINSearchConsumer???'+contactPointAddressList);
            if(!userList.isEmpty() && !String.isBlank(userList[0].Account.BWC_Consumer_Number__c)){          
                consumerNumber = userList[0].Account.BWC_Consumer_Number__c;
            }
            if(String.isBlank(consumerNumber)){
                consumerNumber = '';
            }
            Map<String, Object> jsonMap = new Map<String, Object>();
            jsonMap.put('P_INIT_MSG_LIST', '');
            Map<String, Object> customerSearchRecMap = new Map<String, Object>();
            customerSearchRecMap.put('ACCOUNT_NUMBER', consumerNumber);
            customerSearchRecMap.put('SITE_USE_CODE', '');
            customerSearchRecMap.put('ADDRESS1', '');
            customerSearchRecMap.put('POSTAL_CODE', '');
            customerSearchRecMap.put('PHONE_NUMBER', '');
            customerSearchRecMap.put('EMAIL_ADDRESS', '');
            jsonMap.put('P_CUSTOMER_SEARCH_REC', customerSearchRecMap);
            // Debugging information
            System.debug(JSON.serialize(jsonMap));
            String jsonData = JSON.serialize(jsonMap);
            String responseData = BWC_SearchConsumer.SearchConsumerAPI(jsonData);
            // Debugging information
            System.debug('responseData-->'+responseData);            
            BWC_SearchConsumerResponseWrapper responseWrapper = (BWC_SearchConsumerResponseWrapper) JSON.deserialize(responseData, BWC_SearchConsumerResponseWrapper.class);
            // Debugging information
            System.debug('P_HEADER_MSG-->'+responseWrapper.P_HEADER_MSG);
            if(responseWrapper.P_HEADER_MSG != null){
                String requestBodyInstance = CreateConsumerPayload.getConsumerCreatePayload(contactPointAddressList);
                String getCreateUserDetail = BWC_CreateConsumerAPI.CreateConsumerAPI(requestBodyInstance);
                wrapperResponseData.responseData = getCreateUserDetail;
                wrapperResponseData.isNull = true;
                System.debug('getCreateUserDetail-->'+getCreateUserDetail);
            }
            else{
                wrapperResponseData.isNull = false;
                
                AssignShipToBillToWrapper wrapperAssignAddressInstance = assignShipToBillTo(contactPointAddressList,jsonData,addressNameInstance);
                System.debug('wrapperAssignAddressInstance-->'+wrapperAssignAddressInstance);
                if(wrapperAssignAddressInstance.isAddressExists){
                    System.debug('inside wrapperAssignAddressInstance.isAddressExists');
                    //wrapperResponseData.billToOrgId = wrapperAssignAddressInstance.billToOrgId;
                    wrapperResponseData.shipToOrgId = wrapperAssignAddressInstance.shipToOrgId;
                }
                else{
                    System.debug('inside else wrapperAssignAddressInstance.isAddressExists');
                    BWC_UpdateOracleConsumerAddress.BWC_UpdateOracleConsumerWrapper wrapperDataShipping = new BWC_UpdateOracleConsumerAddress.BWC_UpdateOracleConsumerWrapper();
                    //BWC_UpdateOracleConsumerAddress.BWC_UpdateOracleConsumerWrapper wrapperDataBilling = new BWC_UpdateOracleConsumerAddress.BWC_UpdateOracleConsumerWrapper();
                    
                    wrapperDataShipping = BWC_UpdateOracleConsumerAddress.updateAddress(addressTypeInstance,addressNameInstance);
                    //wrapperDataBilling = BWC_UpdateOracleConsumerAddress.updateAddress('Billing','BILL_TO');
                    if(('S').equals(wrapperDataShipping.STATUS)){
                        wrapperAssignAddressInstance = assignShipToBillTo(contactPointAddressList,jsonData,addressNameInstance);
                        //wrapperResponseData.billToOrgId = wrapperAssignAddressInstance.billToOrgId;
                        wrapperResponseData.shipToOrgId = wrapperAssignAddressInstance.shipToOrgId;
                    }
                }
            }
            system.debug('wrapperResponseData-->'+wrapperResponseData);
            // Debugging information
            return wrapperResponseData;
        }
        catch(Exception e){
            System.debug('exception in BWC_SearchConsumerPayloadWrapper==>'+e.getMessage());
            // Debugging information
            System.debug('exception in BWC_SearchConsumerPayloadWrapper line number==>'+e.getLineNumber());
            return null;
        }
    }
    public static AssignShipToBillToWrapper assignShipToBillTo(List<ContactPointAddress> contactPointAddressList, String jsonData,String addressNameInstance){
        AssignShipToBillToWrapper assignShipToBillToWrapperInstance = new AssignShipToBillToWrapper();
        assignShipToBillToWrapperInstance.isAddressExists = false;
        String searchConsumerData = BWC_SearchConsumer.SearchConsumerAPI(jsonData);
        BWC_SearchConsumerResponseWrapper responseWrapperForShipAndBill = (BWC_SearchConsumerResponseWrapper) JSON.deserialize(searchConsumerData, BWC_SearchConsumerResponseWrapper.class);
        System.debug('searchConsumerData before replace->'+searchConsumerData);
        List<BWC_SearchConsumerResponseWrapper.CustomerDetailsItem> customerDtlsTabItems = responseWrapperForShipAndBill.P_OUT_CUSTOMER_DTLS_TAB.P_OUT_CUSTOMER_DTLS_TAB_ITEM;
        for(BWC_SearchConsumerResponseWrapper.CustomerDetailsItem customDetailsItem : customerDtlsTabItems){
            System.debug('inside loop upper');
            if((contactPointAddressList[0].City).equals(customDetailsItem.CITY) && (contactPointAddressList[0].State).equals(customDetailsItem.STATE) && (contactPointAddressList[0].PostalCode).equals(customDetailsItem.POSTAL_CODE)){
                System.debug('inside loop');
                if((addressNameInstance).equals(customDetailsItem.SITE_USE_CODE)){
                    System.debug('inside loop ship if');
                    assignShipToBillToWrapperInstance.shipToOrgId = customDetailsItem.SITE_USE_ID;
                    assignShipToBillToWrapperInstance.isAddressExists = true;
                }
                /*if(('BILL_TO').equals(customDetailsItem.SITE_USE_CODE)){
                    System.debug('inside loop bill if');
                    assignShipToBillToWrapperInstance.billToOrgId = customDetailsItem.SITE_USE_ID;
                }*/
                
            }
        }
        System.debug('assignShipToBillToWrapperInstance-->'+assignShipToBillToWrapperInstance);
        return assignShipToBillToWrapperInstance;
    }
    public class BWC_SearchConsumerPayloadResponseWrapper{
        public Boolean isNull;
        public String responseData;
        public BWC_SearchConsumerResponseWrapper searchConsumerData;
        public String shipToOrgId;
        //public String billToOrgId;
    }
    public class AssignShipToBillToWrapper{
        public Boolean isAddressExists;
        public String shipToOrgId;
        //public String billToOrgId;
    }
}