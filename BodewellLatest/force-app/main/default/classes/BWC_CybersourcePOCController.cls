public without sharing class BWC_CybersourcePOCController {

    private static final String SECRET_KEY = 'beb3e5da26d6454eba60c060b59d262f68a7b458389f445da623abf71d031051c77675b724da4fa28dcd48ec82a80cf5e1592b724bd348218a0b2d3ccfa350723e89e799685e4dd69e6371b4678b8394e37404483fde4a829842c2c68cec5d118bdd0a2caf8e477095b9cc9857f7bbea5af4667b71ba4d5d9938a2fe1edd0438';

    @AuraEnabled(cacheable=true)
    public static Map<String, String> getParameters() {
        Timezone tz = UserInfo.getTimeZone();
        Map<String, String> dictionary = new Map<String, String>();
        dictionary.put('merchant_defined_data1', '3326250');
        dictionary.put('merchant_defined_data2', '100');
        dictionary.put('merchant_defined_data3', '120004835');
        dictionary.put('tax_amount', '12');
        dictionary.put('amount', '212');
        dictionary.put('transaction_uuid', getUUID());
        dictionary.put('unsigned_field_names', '');
        dictionary.put('signed_field_names', 'merchant_defined_data1,merchant_defined_data2,merchant_defined_data3,tax_amount,amount,transaction_uuid,unsigned_field_names,signed_field_names,signed_date_time,transaction_type,locale,currency,override_custom_receipt_page,reference_number,access_key,profile_id,merchant_defined_data4,bill_to_address_country,bill_to_address_line1,bill_to_forename,bill_to_address_postal_code,bill_to_address_state,bill_to_surname,bill_to_address_city,bill_to_email');

        dictionary.put('signed_date_time', getUtcDateTime(System.now().addHours(tz.getOffset(System.now())/3600000*-1)));

        dictionary.put('transaction_type', 'authorization,create_payment_token');
        dictionary.put('locale', 'en');
        dictionary.put('currency', 'USD');
       // dictionary.put('override_custom_receipt_page', 'https://geapp--bwcommoob--c.sandbox.vf.force.com/apex/Cybersource_Response');
        dictionary.put('override_custom_receipt_page', 'https://geapp--bwcommoob.sandbox.my.salesforce-sites.com/bcybersourceresponse');
        dictionary.put('reference_number', '120004835-1382'); //order source 1382
        dictionary.put('access_key', '65a22dd0363534bd9d2d5ea7074c3883');
        dictionary.put('profile_id', 'BB376E86-3806-4757-93F8-290F794A3CE7');
        dictionary.put('merchant_defined_data4', 'TESTING VIA HOSTED CHECKOUT');
        dictionary.put('bill_to_address_country', 'US');
        dictionary.put('bill_to_address_line1',  '307 N HOURSEBORN PRKWY');
        dictionary.put('bill_to_forename',  'MOHAMMAD F');
        dictionary.put('bill_to_address_postal_code',  '40222');
        dictionary.put('bill_to_address_state', 'KY');
        dictionary.put('bill_to_surname', 'FEROZ');
        dictionary.put('bill_to_address_city', 'LOUISVILLE');
        dictionary.put('bill_to_email', '');
        String data = '';
        for(String key : dictionary.keyset()) {
            data += key + '=' + dictionary.get(key) + ',';
        }
        data = data.removeEnd(',');
        dictionary.put('signature', sign(data, SECRET_KEY));
        return dictionary;
    }

    private static String getUUID() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);        
        return guid;
    }

    private static String getUTCDateTime(DateTime dt) {
        String strUTCDateTime = dt.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        return strUTCDateTime;
    }

    private static String sign(String data, String secretKey){
        String result = EncodingUtil.base64Encode(Crypto.generateMac('hmacSHA256', Blob.valueOf(data), Blob.valueOf(secretKey)));
        return result;
    }
}