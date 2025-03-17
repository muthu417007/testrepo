public class CreateConsumerPayload {
    public static String getConsumerCreatePayload(List<ContactPointAddress> shippingAddressInstance) {
        try {
            String jsonString = '';
            String shippingCity = '';
            String shippingStreet = '';
            String shippingState = '';
            String shippingPostalCode = '';
            String shippingCountry = '';
            
            /*String billingCity = '';
            String billingStreet = '';
            String billingState = '';
            String billingPostalCode = '';
            String billingCountry = '';*/
            User userInnsatance = [SELECT Id,
                                   Name,
                                   FirstName,
                                   LastName,
                                   AccountId
                                   FROM User 
                                   WHERE Id =: userinfo.getuserid() 
                                   LIMIT 1];
            
            
            if(!shippingAddressInstance.IsEmpty()){
                shippingCity = shippingAddressInstance[0].City;
                shippingStreet = shippingAddressInstance[0].Street;
                shippingState = shippingAddressInstance[0].State;
                shippingPostalCode = shippingAddressInstance[0].PostalCode;
                shippingCountry = shippingAddressInstance[0].Country;
            }
            
            /* List<ContactPointAddress> billingAddressInstance = [SELECT Id, 
                                                                Street, 
                                                                City, 
                                                                State, 
                                                                PostalCode, 
                                                                Country 
                                                                FROM ContactPointAddress 
                                                                WHERE AddressType = 'Billing' 
                                                                AND isDefault = true
                                                                AND ParentId = :userInnsatance.AccountId
                                                                LIMIT 1];

           if(!billingAddressInstance.isEmpty()){
                billingCity = billingAddressInstance[0].City;
                billingStreet = billingAddressInstance[0].Street;
                billingState = billingAddressInstance[0].State;
                billingPostalCode = billingAddressInstance[0].PostalCode;
                billingCountry = billingAddressInstance[0].Country;
            }*/
            
            
            
            JSONGenerator jsGen = JSON.createGenerator(true);
            jsGen.writeStartObject();
            jsGen.writeStringField('P_INIT_MSG_LIST', 'T');
            jsGen.writeStringField('ORG_ID', '82'); 
            jsGen.writeStringField('P_CUSTOMER_TYPE', 'PERSON');
            
            jsGen.writeFieldName('P_CUST_ACCOUNT_REC');
            jsGen.writeStartObject();
            jsGen.writeStringField('CUSTOMER_CLASS_CODE', 'EXT');
            jsGen.writeStringField('ACCOUNT_NAME', userInnsatance.Name);
            jsGen.writeStringField('CREATED_BY_MODULE', 'HZ_CPUI');
            jsGen.writeEndObject();
            
            jsGen.writeFieldName('P_PARTY_REC');
            jsGen.writeStartObject();
            
            jsGen.writeEndObject(); 
            
            jsGen.writeFieldName('P_PERSON_REC');
            jsGen.writeStartObject();
            jsGen.writeStringField('PERSON_FIRST_NAME', userInnsatance.FirstName);
            jsGen.writeStringField('PERSON_MIDDLE_NAME', '');
            jsGen.writeStringField('PERSON_LAST_NAME', userInnsatance.LastName);
            
            jsGen.writeFieldName('PARTY_REC');
            jsGen.writeStartObject();
            
            jsGen.writeEndObject();
            jsGen.writeEndObject(); 
            
            jsGen.writeFieldName('P_SHIP_LOCATION_REC');
            jsGen.writeStartObject();
            jsGen.writeStringField('COUNTRY', 'US');
            jsGen.writeStringField('ADDRESS1', shippingStreet);
            jsGen.writeStringField('ADDRESS2', '');
            jsGen.writeStringField('ADDRESS3', '');
            jsGen.writeStringField('ADDRESS4', '');
            jsGen.writeStringField('CITY', shippingCity);
            jsGen.writeStringField('POSTAL_CODE', shippingPostalCode);
            jsGen.writeStringField('STATE', shippingState);
            jsGen.writeStringField('PROVINCE', '');
            jsGen.writeStringField('COUNTY', '');
            
            jsGen.writeFieldName('GEOMETRY');
            jsGen.writeStartObject();
            
            jsGen.writeFieldName('SDO_POINT');
            jsGen.writeStartObject();
            
            jsGen.writeEndObject();
            jsGen.writeFieldName('SDO_ELEM_INFO');
            jsGen.writeStartObject();
            
            jsGen.writeEndObject();
            jsGen.writeFieldName('SDO_ORDINATES');
            jsGen.writeStartObject();
            
            jsGen.writeEndObject();
            jsGen.writeEndObject();
            
            jsGen.writeEndObject(); 
            /*if(!billingAddressInstance.isEmpty()){
                jsGen.writeFieldName('P_BILL_LOCATION_REC');
                jsGen.writeStartObject();
                jsGen.writeStringField('COUNTRY', 'US');
                jsGen.writeStringField('ADDRESS1',  billingStreet);
                jsGen.writeStringField('ADDRESS2', '');
                jsGen.writeStringField('ADDRESS3', '');
                jsGen.writeStringField('ADDRESS4', '');
                jsGen.writeStringField('CITY',  billingCity);
                jsGen.writeStringField('POSTAL_CODE',  billingPostalCode);
                jsGen.writeStringField('STATE',  billingState);
                jsGen.writeStringField('PROVINCE', '');
                jsGen.writeStringField('COUNTY', '');
                
                jsGen.writeFieldName('GEOMETRY');
                jsGen.writeStartObject();
                
                jsGen.writeFieldName('SDO_POINT');
                jsGen.writeStartObject();
                
                jsGen.writeEndObject();
                jsGen.writeFieldName('SDO_ELEM_INFO');
                jsGen.writeStartObject();
                
                jsGen.writeEndObject();
                jsGen.writeFieldName('SDO_ORDINATES');
                jsGen.writeStartObject();
                
                jsGen.writeEndObject();
                jsGen.writeEndObject();
                
                jsGen.writeEndObject(); 
            }*/
            jsGen.writeFieldName('P_SOLD_LOCATION_REC');
            jsGen.writeStartObject();
            jsGen.writeStringField('COUNTRY', 'US');
            jsGen.writeStringField('ADDRESS1', '117522 Providence Street');
            jsGen.writeStringField('ADDRESS2', '');
            jsGen.writeStringField('ADDRESS3', '');
            jsGen.writeStringField('ADDRESS4', '');
            jsGen.writeStringField('CITY', 'Baldwin Park');
            jsGen.writeStringField('POSTAL_CODE', '91706');
            jsGen.writeStringField('STATE', 'CA');
            jsGen.writeStringField('PROVINCE', '');
            jsGen.writeStringField('COUNTY', '');
            
            jsGen.writeFieldName('GEOMETRY');
            jsGen.writeStartObject();
            
            jsGen.writeFieldName('SDO_POINT');
            jsGen.writeStartObject();
            
            jsGen.writeEndObject();
            jsGen.writeFieldName('SDO_ELEM_INFO');
            jsGen.writeStartObject();
            
            jsGen.writeEndObject();
            jsGen.writeFieldName('SDO_ORDINATES');
            jsGen.writeStartObject();
            
            jsGen.writeEndObject();
            jsGen.writeEndObject(); 
            
            jsGen.writeEndObject(); 
            
            jsGen.writeFieldName('P_CONTACT_POINT_REC');
            jsGen.writeStartObject();
            jsGen.writeStringField('CONTACT_POINT_PURPOSE', 'BUSINESS');
            jsGen.writeStringField('CONTACT_POINT_TYPE', 'PHONE');
            jsGen.writeStringField('CREATED_BY_MODULE', 'HZ_CPUI');
            jsGen.writeStringField('ORIG_SYSTEM_REFERENCE', '');
            jsGen.writeStringField('OWNER_TABLE_NAME', 'HZ_PARTIES');
            jsGen.writeEndObject();
            
            jsGen.writeFieldName('P_EMAIL_REC');
            jsGen.writeStartObject();
            jsGen.writeStringField('EMAIL_ADDRESS', UserInfo.getUserEmail());
            jsGen.writeStringField('EMAIL_FORMAT', '');
            jsGen.writeEndObject();
            
            /*     jsGen.writeFieldName('P_PHONE_REC');
jsGen.writeStartObject();
jsGen.writeNumberField('PHONE_AREA_CODE', 40); 
jsGen.writeStringField('PHONE_LINE_TYPE', 'GEN');
jsGen.writeStringField('PHONE_NUMBER', '9920072301');
jsGen.writeEndObject();
*/
            
            jsGen.writeFieldName('P_SHIP_CUST_ACCT_SITE_REC');
            jsGen.writeStartObject();
            jsGen.writeNumberField('ORG_ID', 82); 
            jsGen.writeEndObject();
            
            jsGen.writeFieldName('P_SHIP_CUST_SITE_USE_REC');
            jsGen.writeStartObject();
            jsGen.writeNumberField('ORG_ID', 82); 
            jsGen.writeStringField('SITE_USE_CODE', 'SHIP_TO');
            jsGen.writeEndObject();
            
            jsGen.writeFieldName('P_SOLD_CUST_ACCT_SITE_REC');
            jsGen.writeStartObject();
            jsGen.writeNumberField('ORG_ID', 82); 
            jsGen.writeEndObject();
            
            jsGen.writeFieldName('P_BILL_CUST_SITE_USE_REC');
            jsGen.writeStartObject();
            jsGen.writeNumberField('ORG_ID', 82); 
            jsGen.writeStringField('SITE_USE_CODE', 'BILL_TO');
            jsGen.writeEndObject();
            
            jsGen.writeEndObject();
            jsonString = jsGen.getAsString();
            System.debug('jsonString-->'+jsonString);
            return jsonString;
        } 
        catch (Exception e) {
            System.debug('An error occurred: ' + e.getMessage());
            return null;
        }
    }
}