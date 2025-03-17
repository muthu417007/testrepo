/**
* @author Abhishek Bisht
* @date 02/02/2024
* @description The purpose of this class is to create payload for consumer update address
* */
public class BWC_CreateUpdateOracleConsumerPayload {
    /**
* This method returns consumer update api payload
* @param 
* @return - String
*/
    public static String createConsumerUpdatePayload(String locationName,String locationType){ 
        String jsonString;
        List<User> userList = [SELECT Id,
                               AccountId,
                               Account.EBS_X_PARTY_ID__pc,
                               Account.EBS_X_CUST_ACCOUNT_ID__pc
                               FROM User 
                               WHERE Id =:UserInfo.getUserId() 
                               AND Account.EBS_X_PARTY_ID__pc != null
                               AND Account.EBS_X_CUST_ACCOUNT_ID__pc != null
                               AND AccountId != null
                               LIMIT 1];
        List<ContactPointAddress> conPointAddressList = new List<ContactPointAddress>();
        if(!userList.isEmpty()){
            conPointAddressList = [SELECT Id,
                                   Address,
                                   City,
                                   Street,
                                   PostalCode,
                                   State
                                   FROM ContactPointAddress
                                   WHERE IsDefault = true 
                                   AND AddressType = :locationName 
                                   AND ParentId =: userList[0].AccountId
                                   LIMIT 1];
        }
        
        if(!conPointAddressList.isEmpty()){
            
            JSONGenerator gen = JSON.createGenerator(true);
            
            gen.writeStartObject();
            gen.writeStringField('P_INIT_MSG_LIST', 'T');
            
            // Start writing P_LOCATION_REC
            gen.writeFieldName('P_LOCATION_REC');
            gen.writeStartObject();
            
            gen.writeStringField('LOCATION_ID', '');
            gen.writeStringField('ORIG_SYSTEM_REFERENCE', '');
            gen.writeStringField('ORIG_SYSTEM', '');
            gen.writeStringField('COUNTRY', 'US');
            gen.writeStringField('ADDRESS1', conPointAddressList[0].Street);
            gen.writeStringField('ADDRESS2', '');
            gen.writeStringField('ADDRESS3', '');
            gen.writeStringField('ADDRESS4', '');
            gen.writeStringField('CITY', conPointAddressList[0].City);
            gen.writeStringField('POSTAL_CODE', conPointAddressList[0].PostalCode);
            gen.writeStringField('STATE', conPointAddressList[0].State);
            
            gen.writeStringField('PROVINCE', '');
            gen.writeStringField('COUNTY', '');
            gen.writeStringField('ADDRESS_KEY', '');
            gen.writeStringField('ADDRESS_STYLE', '');
            gen.writeStringField('VALIDATED_FLAG', '');
            gen.writeStringField('ADDRESS_LINES_PHONETIC', '');
            gen.writeStringField('PO_BOX_NUMBER', '');
            gen.writeStringField('HOUSE_NUMBER', '');
            gen.writeStringField('STREET_SUFFIX', '');
            gen.writeStringField('STREET', '');
            gen.writeStringField('STREET_NUMBER', '');
            gen.writeStringField('FLOOR', '');
            gen.writeStringField('SUITE', '');
            gen.writeStringField('POSTAL_PLUS4_CODE', '');
            gen.writeStringField('POSITION', '');
            gen.writeStringField('LOCATION_DIRECTIONS', '');
            gen.writeStringField('ADDRESS_EFFECTIVE_DATE', '');
            gen.writeStringField('ADDRESS_EXPIRATION_DATE', '');
            gen.writeStringField('CLLI_CODE', '');
            gen.writeStringField('LANGUAGE', '');
            gen.writeStringField('SHORT_DESCRIPTION', '');
            gen.writeStringField('DESCRIPTION', locationType);
            
            // Write the nested GEOMETRY object
            gen.writeFieldName('GEOMETRY');
            gen.writeStartObject();
            gen.writeStringField('SDO_GTYPE', '');
            gen.writeStringField('SDO_SRID', '');
            
            // Write the nested SDO_POINT object
            gen.writeFieldName('SDO_POINT');
            gen.writeStartObject();
            gen.writeStringField('X', '');
            gen.writeStringField('Y', '');
            gen.writeStringField('Z', '');
            gen.writeEndObject(); // SDO_POINT
            
            gen.writeFieldName('SDO_ELEM_INFO');
            gen.writeStartObject();
            gen.writeStringField('SDO_ELEM_INFO_ITEM', '');
            gen.writeEndObject(); // SDO_ELEM_INFO
            
            gen.writeFieldName('SDO_ORDINATES');
            gen.writeStartObject();
            gen.writeStringField('SDO_ORDINATES_ITEM', '');
            gen.writeEndObject(); // SDO_ORDINATES
            
            gen.writeEndObject(); // GEOMETRY
            
            // Write the rest of the fields in P_LOCATION_REC
            gen.writeStringField('GEOMETRY_STATUS_CODE', '');
            
            // Write the rest of the fields in P_LOCATION_REC
            gen.writeStringField('LOC_HIERARCHY_ID', '');
            gen.writeStringField('SALES_TAX_GEOCODE', '');
            gen.writeStringField('SALES_TAX_INSIDE_CITY_LIMITS', '');
            gen.writeStringField('FA_LOCATION_ID', '');
            gen.writeStringField('CONTENT_SOURCE_TYPE', '');
            gen.writeStringField('ATTRIBUTE_CATEGORY', '');
            gen.writeStringField('ATTRIBUTE1', '');
            gen.writeStringField('ATTRIBUTE2', '');
            gen.writeStringField('ATTRIBUTE3', '');
            gen.writeStringField('ATTRIBUTE4', '');
            gen.writeStringField('ATTRIBUTE5', '');
            gen.writeStringField('ATTRIBUTE6', '');
            gen.writeStringField('ATTRIBUTE7', '');
            gen.writeStringField('ATTRIBUTE8', '');
            gen.writeStringField('ATTRIBUTE9', '');
            gen.writeStringField('ATTRIBUTE10', '');
            gen.writeStringField('ATTRIBUTE11', '');
            gen.writeStringField('ATTRIBUTE12', '');
            gen.writeStringField('ATTRIBUTE13', '');
            gen.writeStringField('ATTRIBUTE14', '');
            gen.writeStringField('ATTRIBUTE15', '');
            gen.writeStringField('ATTRIBUTE16', '');
            gen.writeStringField('ATTRIBUTE17', '');
            gen.writeStringField('ATTRIBUTE18', '');
            gen.writeStringField('ATTRIBUTE19', '');
            gen.writeStringField('ATTRIBUTE20', '');
            gen.writeStringField('TIMEZONE_ID', '');
            gen.writeStringField('CREATED_BY_MODULE', 'HZ_CPUI');
            gen.writeStringField('APPLICATION_ID', '');
            gen.writeStringField('ACTUAL_CONTENT_SOURCE', '');
            gen.writeStringField('DELIVERY_POINT_CODE', '');
            gen.writeStringField('PARTY_ID', userList[0].Account.EBS_X_PARTY_ID__pc);
            gen.writeStringField('CUST_ACCOUNT_ID', userList[0].Account.EBS_X_CUST_ACCOUNT_ID__pc);
            // End writing P_LOCATION_REC
            gen.writeEndObject();
            
            // End writing the main object
            gen.writeEndObject();
            
            jsonString = gen.getAsString();
        }
        System.debug('jsonString->'+jsonString);
        
        return jsonString;
        
    }
}