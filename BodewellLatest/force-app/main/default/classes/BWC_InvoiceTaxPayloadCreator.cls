/**
* @author Abhishek
* @date 04/08/2023
* @description This class is used to genrate the tax sabrix payload
*/
public class BWC_InvoiceTaxPayloadCreator {
    /*
* @description This method is used to create payload with dynamic values
* @param cartItemList - This method is allow list of cartitems which is present in the current checkout transaction
* @return String
*/
    public static String getInvoiceTaxPayload(List<CartItem> cartItemList,BWC_SearchConsumerPayloadWrapper.BWC_SearchConsumerPayloadResponseWrapper responseWrapper){
        try{
            String customerName;
            Boolean oversizedFlag = false;
            Boolean isHomeDelivery = false;
            List<ContactPointAddress> shippingAddressList = new List<ContactPointAddress>();
            Map<String, Object> userDetailMap = new Map<String, Object>();
            Map<String,Map<String,String>> displayNameVsAddress = new Map<String,Map<String,String>>();
            
            if(responseWrapper.responseData != null){
                userDetailMap = (Map<String, Object>) JSON.deserializeUntyped(responseWrapper.responseData);
                System.debug('In Taxpayload userDetailMap-->'+userDetailMap);
            }
            
            List<BWC_Product_Service__c> productServiceList = [SELECT Id,
                                                               Name,
                                                               BWC_Quantity__c,
                                                               BWC_Service_Price__c,
                                                               BWC_SKU__c,
                                                               BWC_Member_Price__c,
                                                               Cart_Item__r.BWC_Shipping_Method__c,
                                                               Cart_Item__r.Product2.BWC_Delivery_Type__c,
                                                               Cart_Item__r.Product2.Is_Accessory__c,
                                                               Cart_Item__r.Product2.ProductCode
                                                               FROM BWC_Product_Service__c
                                                               WHERE Cart_Item__c IN :cartItemList];
            
            List<User> userList = [SELECT Id,
                                   Contact.Name,
                                   Account.BWC_Consumer_Number__c,
                                   AccountId
                                   FROM USER 
                                   WHERE Id =: UserInfo.getUserId()];
            
            if(!test.isRunningTest()){
                shippingAddressList = [SELECT Id,
                                       BWC_Account_Number__c,
                                       PostalCode, 
                                       City,
                                       Country,
                                       State,
                                       Street
                                       FROM ContactPointAddress 
                                       WHERE ParentId =: userList[0].AccountId 
                                       AND AddressType = 'Shipping'
                                       AND IsDefault = true];
                
                if(!userDetailMap.IsEmpty() || (String)userDetailMap.get('X_ACCOUNT_NUMBER')!=null){
                    customerName = (String)userDetailMap.get('X_ACCOUNT_NUMBER');
                }
                else if(userList[0].Account.BWC_Consumer_Number__c!=null){
                    customerName = userList[0].Account.BWC_Consumer_Number__c;
                }
                else{
                    customerName = '';
                }
            }
            else{
                shippingAddressList = [SELECT Id,
                                       PostalCode, 
                                       City,
                                       Country,
                                       State,
                                       Street
                                       FROM ContactPointAddress 
                                       WHERE AddressType = 'Shipping' AND IsDefault=true];
                customerName='';
            }
            
            
            // new changes start at 27/09/2023
            
            final String ZIP_SERVICE_API_RESPONSE = '{ "zipcode": "12345",  "has_home_delivery": true,  "has_small_package": true,  "has_sds_delivery": true,  "is_will_call": true,  "has_will_call": true,  "sds_ap_zone": "SDS_ZONE",  "hd_ap_zone": "HD_ZONE",  "mt_ap_zone": "MT_ZONE",  "agents": [    {      "zipcode": "12345",      "address": "123 Main St",      "method": "Delivery",      "agent_id": "001",      "phone": "555-1234",      "city": "Cityville",      "name": "Agent HD",      "state": "CA",      "display_name": "HD",      "v_code": "V123",      "loc_type": "Home"    },    {      "zipcode": "12345",      "address": "456 Oak St",      "method": "Delivery",      "agent_id": "002",      "phone": "555-5678",      "city": "Townsville",      "name": "Agent SDS",      "state": "CA",      "display_name": "SDS",      "v_code": "V456",      "loc_type": "Business"    },    {      "zipcode": "12345",      "address": "789 Pine St",      "method": "Delivery",      "agent_id": "003",      "phone": "555-9876",      "city": "Villageton",      "name": "Agent SPS",      "state": "CA",      "display_name": "SPS",      "v_code": "V789",      "loc_type": "Residential"    },    {      "zipcode": "12345",      "address": "987 Elm St",      "method": "Will Call",      "agent_id": "004",      "phone": "555-4321",      "city": "Willville",      "name": "Agent Will Call",      "state": "CA",      "display_name": "Will Call",      "v_code": "V987",      "loc_type": "Office"    }  ]}';
            String payload = '{"zipcode": "'+shippingAddressList[0].PostalCode+'"}';
            String resp;
            if(!test.isRunningTest()){
                if(utility.isSandbox){
                    resp= RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_QA_Token','Bwc_ZipServiceAPI',null,'POST',payload);
                }
                else{
                    resp= RequestMuleAPIData.getMuleAPIData('BWC_Production_MuleAuth','BWC_PROD_EBS_Token','BWC_PROD_ZipServiceAPI',null,'POST',payload);
                }
            }
            else{
                resp=ZIP_SERVICE_API_RESPONSE;
            }
            
            BWC_AgentResponseWrapper agentWrapperResponse = (BWC_AgentResponseWrapper)JSON.deserialize(resp, BWC_AgentResponseWrapper.class);
            List<BWC_AgentResponseWrapper.Wrapper> agents = agentWrapperResponse.agents;
            
            for(BWC_AgentResponseWrapper.Wrapper agent : agents){
                Map<String,String> addressNameVsAddressValues = new Map<String,String>();
                addressNameVsAddressValues.put('city',agent.city);
                addressNameVsAddressValues.put('state',agent.state);
                addressNameVsAddressValues.put('postcode',agent.zipcode);
                displayNameVsAddress.put(agent.display_name,addressNameVsAddressValues);
            }
            
            // new changes end at 27/09/2023
            Datetime GMTDate = DateTime.now();
            String strConvertedDate = GMTDate.format('yyyyMMdd');
            
            if(!shippingAddressList.IsEmpty()){
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeStringField('COMPANY_ROLE', 'S');
                gen.writeStringField('CURRENCY_CODE', 'USD');
                gen.writeStringField('INVOICE_DATE', strConvertedDate); //Today's date
                gen.writeStringField('CUSTOMER_NUMBER', customerName); //Consumer number
                gen.writeStringField('INVOICE_NUMBER', 'Document-1');
                gen.writeFieldName('LINES');
                gen.writeStartArray();
                Integer count = 1;
                
                for(CartItem cartItemInstance : cartItemList){
                    if(cartItemInstance.Product2.BWC_Delivery_Type__c == 'sds'){
                        oversizedFlag = true;
                    }
                    gen.writeStartObject();
                    
                    gen.writeStringField('LINE_NUMBER', String.valueOf(count)); //This is unique count field for the payload specific 
                    gen.writeStringField('LINE_ID', String.valueOf(count)); //This is unique count field for the payload specific
                    gen.writeStringField('GROSS_AMOUNT', String.valueOf(cartItemInstance.TotalPriceAfterAllAdjustments));
                    if(cartItemInstance.Product2.ProductCode != null){
                        gen.writeStringField('PRODUCT_CODE', cartItemInstance.Product2.ProductCode);
                    }
                    else{
                        gen.writeStringField('PRODUCT_CODE', '52141501');
                    }
                    gen.writeStringField('TRANSACTION_TYPE', 'GS');
                    Map<String,String> getAddressNameVsAddressValue = new Map<String,String>();
                    if(cartItemInstance.Product2.BWC_Delivery_Type__c == 'hd' && agentWrapperResponse.has_home_delivery == true){
                        getAddressNameVsAddressValue = displayNameVsAddress.get('HD');
                    }
                    else if(cartItemInstance.Product2.BWC_Delivery_Type__c == 'sds' && agentWrapperResponse.has_sds_delivery == true){
                        getAddressNameVsAddressValue = displayNameVsAddress.get('SDS');
                    }
                    else if((cartItemInstance.Product2.BWC_Delivery_Type__c == 'sps fee'|| cartItemInstance.Product2.BWC_Delivery_Type__c == 'sps') && agentWrapperResponse.has_small_package == true){
                        getAddressNameVsAddressValue = displayNameVsAddress.get('SPS');
                    }
                    else if(agentWrapperResponse.has_will_call){
                        getAddressNameVsAddressValue = displayNameVsAddress.get('Will Call');
                    }
                    
                    if(!getAddressNameVsAddressValue.isEmpty()){
                        gen.writeStringField('SHIP_FROM_CITY', getAddressNameVsAddressValue.get('city'));
                        gen.writeStringField('SHIP_FROM_STATE', getAddressNameVsAddressValue.get('state'));
                        gen.writeStringField('SHIP_FROM_COUNTRY', 'US');
                        gen.writeStringField('SHIP_FROM_POSTCODE', getAddressNameVsAddressValue.get('postcode'));
                    }
                    else{
                        gen.writeStringField('SHIP_FROM_CITY', shippingAddressList[0].City);
                        gen.writeStringField('SHIP_FROM_STATE', shippingAddressList[0].State);
                        gen.writeStringField('SHIP_FROM_COUNTRY', 'US');
                        gen.writeStringField('SHIP_FROM_POSTCODE', shippingAddressList[0].PostalCode);
                    }
                    gen.writeStringField('SHIP_TO_CITY', shippingAddressList[0].City); 
                    gen.writeStringField('SHIP_TO_STATE', shippingAddressList[0].State);
                    gen.writeStringField('SHIP_TO_COUNTRY', 'US');
                    gen.writeStringField('SHIP_TO_POSTCODE', shippingAddressList[0].PostalCode); 
                    gen.writeStringField('PART_NUMBER', cartItemInstance.sku);
                    gen.writeEndObject();
                    count++;
                }
                /*if(oversizedFlag){
                    gen.writeStartObject();
                    gen.writeStringField('LINE_NUMBER', String.valueOf(count)); //This is unique count field for the payload specific 
                    gen.writeStringField('LINE_ID', String.valueOf(count)); //This is unique count field for the payload specific
                    gen.writeStringField('GROSS_AMOUNT', '150');
                    gen.writeStringField('PRODUCT_CODE', System.Label.BWC_ProductCode); // Need to change this
                    gen.writeStringField('TRANSACTION_TYPE', 'GS');
                    
                    Map<String,String> getAddressNameVsAddressValue = new Map<String,String>();
                    
                    if(agentWrapperResponse.has_sds_delivery){
                        getAddressNameVsAddressValue = displayNameVsAddress.get('SDS');
                    }
                    else{
                        getAddressNameVsAddressValue = displayNameVsAddress.get('Will Call');
                    }
                    
                    if(!getAddressNameVsAddressValue.isEmpty()){
                        gen.writeStringField('SHIP_FROM_CITY', getAddressNameVsAddressValue.get('city'));
                        gen.writeStringField('SHIP_FROM_STATE', getAddressNameVsAddressValue.get('state'));
                        gen.writeStringField('SHIP_FROM_COUNTRY', 'US');
                        gen.writeStringField('SHIP_FROM_POSTCODE', getAddressNameVsAddressValue.get('postcode'));
                    }
                    else{
                        gen.writeStringField('SHIP_FROM_CITY', shippingAddressList[0].City);
                        gen.writeStringField('SHIP_FROM_STATE', shippingAddressList[0].State);
                        gen.writeStringField('SHIP_FROM_COUNTRY', 'US');
                        gen.writeStringField('SHIP_FROM_POSTCODE', shippingAddressList[0].PostalCode);
                    }
                    gen.writeStringField('SHIP_TO_CITY', shippingAddressList[0].City);
                    gen.writeStringField('SHIP_TO_STATE', shippingAddressList[0].State);
                    gen.writeStringField('SHIP_TO_COUNTRY', 'US');
                    gen.writeStringField('SHIP_TO_POSTCODE', shippingAddressList[0].PostalCode);
                    gen.writeStringField('PART_NUMBER', 'DELIVERY OVERSIZE');
                    gen.writeEndObject();
                    count++;
                }*/
                for(BWC_Product_Service__c productServiceRecord : productServiceList){
                    if(productServiceRecord.BWC_SKU__c == 'HOME DELIVERY'){
                        if(isHomeDelivery){
                            continue;
                        }
                        else{
                            isHomeDelivery = true;
                        }
                    }
                    gen.writeStartObject();
                    gen.writeStringField('LINE_NUMBER', String.valueOf(count)); //This is unique count field for the payload specific 
                    gen.writeStringField('LINE_ID', String.valueOf(count)); //This is unique count field for the payload specific
                    gen.writeStringField('GROSS_AMOUNT', String.ValueOf(productServiceRecord.BWC_Service_Price__c));
                    if(productServiceRecord.BWC_SKU__c == 'HOME DELIVERY'){
                        gen.writeStringField('PRODUCT_CODE', '78121603');
                    }
                    else if(productServiceRecord.BWC_SKU__c == 'FREESTANDING INSTALL'){
                        gen.writeStringField('PRODUCT_CODE', '52141500');
                    }
                    else{
                        gen.writeStringField('PRODUCT_CODE', System.Label.BWC_ProductCode);
                    }
                    gen.writeStringField('TRANSACTION_TYPE', 'GS');
                    
                    Map<String,String> getAddressNameVsAddressValue = new Map<String,String>();
                    if(productServiceRecord.Cart_Item__r.Product2.BWC_Delivery_Type__c == 'hd' && agentWrapperResponse.has_home_delivery == true){
                        getAddressNameVsAddressValue = displayNameVsAddress.get('HD');
                    }
                    else if(productServiceRecord.Cart_Item__r.Product2.BWC_Delivery_Type__c == 'sds' && agentWrapperResponse.has_sds_delivery == true){
                        getAddressNameVsAddressValue = displayNameVsAddress.get('SDS');
                    }
                    else if((productServiceRecord.Cart_Item__r.Product2.BWC_Delivery_Type__c == 'sps fee'||productServiceRecord.Cart_Item__r.Product2.BWC_Delivery_Type__c == 'sps') && agentWrapperResponse.has_small_package == true){
                        getAddressNameVsAddressValue = displayNameVsAddress.get('SPS');
                    }
                    else if(agentWrapperResponse.has_will_call){
                        getAddressNameVsAddressValue = displayNameVsAddress.get('Will Call');
                    }
                    
                    if(!getAddressNameVsAddressValue.isEmpty()){
                        gen.writeStringField('SHIP_FROM_CITY', getAddressNameVsAddressValue.get('city'));
                        gen.writeStringField('SHIP_FROM_STATE', getAddressNameVsAddressValue.get('state'));
                        gen.writeStringField('SHIP_FROM_COUNTRY', 'US');
                        gen.writeStringField('SHIP_FROM_POSTCODE', getAddressNameVsAddressValue.get('postcode'));
                    }
                    else{
                        gen.writeStringField('SHIP_FROM_CITY', shippingAddressList[0].City);
                        gen.writeStringField('SHIP_FROM_STATE', shippingAddressList[0].State);
                        gen.writeStringField('SHIP_FROM_COUNTRY', 'US');
                        gen.writeStringField('SHIP_FROM_POSTCODE', shippingAddressList[0].PostalCode);
                    }
                    gen.writeStringField('SHIP_TO_CITY', shippingAddressList[0].City);
                    gen.writeStringField('SHIP_TO_STATE', shippingAddressList[0].State);
                    gen.writeStringField('SHIP_TO_COUNTRY', 'US');
                    gen.writeStringField('SHIP_TO_POSTCODE', shippingAddressList[0].PostalCode);
                    gen.writeStringField('PART_NUMBER', productServiceRecord.BWC_SKU__c);
                    gen.writeEndObject();
                    count++;
                }
                gen.writeEndArray();
                gen.writeEndObject();
                String jsonString = gen.getAsString();
                System.debug('jsonString-->'+jsonString);
                return jsonString;
            }
            else{
                return null;
            }
        }
        catch(Exception e){
            System.debug('exception message in BWC_InvoiceTaxPayloadCreator-->'+e.getMessage());
            System.debug('exception line number in BWC_InvoiceTaxPayloadCreator-->'+e.getLineNumber());
            return null;
        } 
    }
    
}