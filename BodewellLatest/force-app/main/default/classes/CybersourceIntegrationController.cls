public class CybersourceIntegrationController 
{
    
    private static final String SECRET_KEY = 'a778beb4ab324b68ab736eb91b658c05d1537aecd3144c02a0c279c2b2d0a9b26073b5fbc8a14b2da66add58e23957fecade3783307745f187c1677c1a7656f84261ac52fbe24a34bd97c7d7ff4916a7b3226b743aa8461b8f17bd8559494a6b6576b88e112146b6b59df1951067c4e08e2fe28f07054801bf67d19bc6f7451f'; //OSC PROD KEY

    @AuraEnabled
  public static Contact queryContact(String conId)
  {
    Contact c = [select Id, firstName, lastName, mailingStreet, mailingCity, mailingState, MailingPostalCode
                     from Contact where Id=:conId limit 1];
        system.debug('*** '+c);
    return c;
  }
    
    // Pass in the endpoint to be used using the string url
    // Map<String, Object>
  @AuraEnabled
  public static void MakeCallout() 
    {
        String url = 'https://secureacceptance.cybersource.com/pay';
    // Instantiate a new http object
    Http h = new Http();
 
    // Instantiate a new HTTP request, specify the method (POST) as well as the endpoint
    HttpRequest req = new HttpRequest();
    req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
    req.setMethod('POST');
    String payload = '';
        String guid = getUUID();
        System.debug(guid);
        Map<string, string> dictionary = new Map<string, string>();
       dictionary.put('merchant_defined_data1', '3326250');
        dictionary.put('merchant_defined_data2', '3.17');
        dictionary.put('merchant_defined_data3', '190401-002636');
        dictionary.put('tax_amount', '0.17');
        dictionary.put('amount', '3.17');
        dictionary.put('transaction_uuid', guid);
        dictionary.put('unsigned_field_names', '');
        dictionary.put('signed_field_names', 'merchant_defined_data1,override_custom_receipt_page,merchant_defined_data2,merchant_defined_data3,tax_amount,amount,transaction_uuid,unsigned_field_names,signed_field_names,signed_date_time,transaction_type,locale,currency,reference_number,access_key,profile_id,merchant_defined_data4,bill_to_address_country,bill_to_address_line1,bill_to_forename,bill_to_address_postal_code,bill_to_address_state,bill_to_surname,bill_to_address_city,bill_to_email');
        dictionary.put('signed_date_time', getUtcDateTime(System.now()));
        dictionary.put('transaction_type', 'sale,create_payment_token');
        dictionary.put('locale', 'en');
        dictionary.put('currency', 'USD');
        dictionary.put('override_custom_receipt_page', '');
        //dictionary.put('override_custom_receipt_page', 'https://geappliances.custhelp.com/app/Cybersource_Response');
        dictionary.put('reference_number', '190401-002636');
        dictionary.put('access_key', '8e474e3fd8ec3a069e4d9a2f624bd4ac');
        dictionary.put('profile_id', '1691B5CA-B0A1-4C96-AD77-457F4B7F5F05');
        dictionary.put('merchant_defined_data4', '3326250');
        dictionary.put('bill_to_address_country', 'US');
        dictionary.put('bill_to_address_line1', 'Ge Appliances ');
        dictionary.put('bill_to_forename', 'Gowsic');
        dictionary.put('bill_to_address_postal_code', '33606');
        dictionary.put('bill_to_address_state', 'FL');
        dictionary.put('bill_to_surname', 'S');
        dictionary.put('bill_to_address_city', 'TAMPA');
        dictionary.put('bill_to_email', 'gowsic.s@geappliances.com');
        for(string key : dictionary.keyset())
        {
            payload += EncodingUtil.urlEncode(key,'UTF-8')+'='+EncodingUtil.urlEncode(dictionary.get(key), 'UTF-8') + '&';
        }
        payload.removeEnd('&');
        System.debug('payloadBefore:'+payload);
        payload=sign(payload,SECRET_KEY);
        
        System.debug('url:'+url);
        System.debug('payload:'+payload);
        
        req.setEndpoint(url);
        req.setBody(payload);
    // Send the request, and return a response
    if(!test.isRunningTest()){
            HttpResponse res = h.send(req);
            System.debug('response:--> ' + res.getBody());
        } 
  }
    @AuraEnabled
  public static String getBody() 
    {          
    String payload = '';
        String guid = getUUID();
        System.debug(guid);
        Map<string, string> dictionary = new Map<string, string>();
        dictionary.put('merchant_defined_data1', '3326250');
        dictionary.put('merchant_defined_data2', '3.17');
        dictionary.put('merchant_defined_data3', '190401-002636');
        dictionary.put('tax_amount', '0.17');
        dictionary.put('amount', '3.17');
        dictionary.put('transaction_uuid', guid);
        dictionary.put('unsigned_field_names', '');
        dictionary.put('signed_field_names', 'merchant_defined_data1,override_custom_receipt_page,merchant_defined_data2,merchant_defined_data3,tax_amount,amount,transaction_uuid,unsigned_field_names,signed_field_names,signed_date_time,transaction_type,locale,currency,reference_number,access_key,profile_id,merchant_defined_data4,bill_to_address_country,bill_to_address_line1,bill_to_forename,bill_to_address_postal_code,bill_to_address_state,bill_to_surname,bill_to_address_city,bill_to_email');
        dictionary.put('signed_date_time', getUtcDateTime(System.now()));
        dictionary.put('transaction_type', 'sale,create_payment_token');
        dictionary.put('locale', 'en');
        dictionary.put('currency', 'USD');
        dictionary.put('override_custom_receipt_page', '');
        //dictionary.put('override_custom_receipt_page', 'https://geappliances.custhelp.com/app/Cybersource_Response');
        dictionary.put('reference_number', '190401-002636');
        dictionary.put('access_key', '8e474e3fd8ec3a069e4d9a2f624bd4ac');
        dictionary.put('profile_id', '1691B5CA-B0A1-4C96-AD77-457F4B7F5F05');
        dictionary.put('merchant_defined_data4', '3326250');
        dictionary.put('bill_to_address_country', 'US');
        dictionary.put('bill_to_address_line1', 'Ge Appliances ');
        dictionary.put('bill_to_forename', 'Gowsic');
        dictionary.put('bill_to_address_postal_code', '33606');
        dictionary.put('bill_to_address_state', 'FL');
        dictionary.put('bill_to_surname', 'S');
        dictionary.put('bill_to_address_city', 'TAMPA');
        dictionary.put('bill_to_email', 'gowsic.s@geappliances.com');
        for(string key : dictionary.keyset())
        {
            System.debug(key+'='+dictionary.get(key));
            //payload += EncodingUtil.urlEncode(key,'UTF-8')+'='+EncodingUtil.urlEncode(dictionary.get(key), 'UTF-8') + '&';
            payload += key+'='+dictionary.get(key)+'&';
        }
        payload.removeEnd('&');        
        System.debug('payloadBefore:'+payload);
        payload=sign(payload,SECRET_KEY);
        
        return payload;
  }
    private static String sign(String data, String secretKey){
        String result = EncodingUtil.base64Encode(Crypto.generateMac('hmacSHA256', Blob.valueOf(data), Blob.valueOf(secretKey)));
        return result;
    }
    private static String getUUID()
  {        
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);        
        return guid;
    }
    private static String getUTCDateTime(DateTime dt){
        DateTime oUTSDateTime = System.now().addHours(4);
        String strUTCDateTime = oUTSDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        return strUTCDateTime;
  }
    @AuraEnabled
  public static void sign(String postData)
    {
        Map<string, string> dictionary = new Map<string, string>();
        dictionary.put('merchant_defined_data1', '3219863');
        dictionary.put('merchant_defined_data2', '115.18');
        dictionary.put('merchant_defined_data3', '190410-000041');
        dictionary.put('tax_amount', '5.18');
        dictionary.put('amount', '115.18');
        dictionary.put('transaction_uuid', 'a5db1e80-5578-4c6a-b1f7-3f6a5a42c417');
        dictionary.put('unsigned_field_names', '');
        dictionary.put('signed_field_names', 'merchant_defined_data1%2coverride_custom_receipt_page%2cmerchant_defined_data2%2cmerchant_defined_data3%2ctax_amount%2camount%2ctransaction_uuid%2cunsigned_field_names%2csigned_field_names%2csigned_date_time%2ctransaction_type%2clocale%2ccurrency%2creference_number%2caccess_key%2cprofile_id%2cmerchant_defined_data4%2cbill_to_address_country%2cbill_to_address_line1%2cbill_to_forename%2cbill_to_address_postal_code%2cbill_to_address_state%2cbill_to_surname%2cbill_to_address_city%2cbill_to_email');
        dictionary.put('signed_date_time', '2019-09-09T12:15:35Z');
        dictionary.put('transaction_type', 'sale,create_payment_token');
        dictionary.put('locale', 'en');
        dictionary.put('currency', 'USD');
        dictionary.put('override_custom_receipt_page', '');
        //dictionary.put('override_custom_receipt_page', 'https%3a%2f%2fgeappliances.custhelp.com%2fapp%2fCybersource_Response');
        dictionary.put('reference_number', '190410-000041');
        dictionary.put('access_key', '8e474e3fd8ec3a069e4d9a2f624bd4ac');
        dictionary.put('profile_id', '1691B5CA-B0A1-4C96-AD77-457F4B7F5F05');
        dictionary.put('merchant_defined_data4', '3219863');
        dictionary.put('bill_to_address_country', 'US');
        dictionary.put('bill_to_address_line1', 'Test+Street');
        dictionary.put('bill_to_forename', 'Gowsic');
        dictionary.put('bill_to_address_postal_code', '96701');
        dictionary.put('bill_to_address_state', 'HI');
        dictionary.put('bill_to_surname', 'S');
        dictionary.put('bill_to_address_city', 'AIEA');
        dictionary.put('bill_to_email', '');
        
        postData = '';
           
        for(string key : dictionary.keyset())
        {
            postData += EncodingUtil.urlEncode(key, 'UTF-8') + '='
                + EncodingUtil.urlEncode(dictionary.get(key), 'UTF-8') + '&';
        }
        
        Blob signatureBlob = crypto.generateMac('hmacSHA256',Blob.valueOf(postData), Blob.valueOf(SECRET_KEY));
        //String signature = EncodingUtil.base64Encode(signatureBlob);
        String signature = EncodingUtil.convertToHex(signatureBlob);
        
        system.debug(signature);
    }
    
    // Converts a base64 string into a list of integers representing the encoded bytes
    public static List<Integer> B64ToBytes (String sIn) 
    {
        Map<Integer,Integer> base64 = new Map<Integer,Integer>{65=>0,66=>1,67=>2,68=>3,69=>4,70=>5,71=>6,72=>7,73=>8,74=>9,75=>10,76=>11,77=>12,78=>13,79=>14,80=>15,81=>16,82=>17,83=>18,84=>19,85=>20,86=>21,87=>22,88=>23,89=>24,90=>25,97=>26,98=>27,99=>28,100=>29,101=>30,102=>31,103=>32,104=>33,105=>34,106=>35,107=>36,108=>37,109=>38,110=>39,111=>40,112=>41,113=>42,114=>43,115=>44,116=>45,117=>46,118=>47,119=>48,120=>49,121=>50,122=>51,48=>52,49=>53,50=>54,51=>55,52=>56,53=>57,54=>58,55=>59,56=>60,57=>61,43=>62,47=>63};

        List<Integer> lstOut = new List<Integer>();
        if ( sIn == null || sIn == '' ) return lstOut;
        
        sIn += '='.repeat( 4 - Math.mod( sIn.length(), 4) );

        for ( Integer idx=0; idx < sIn.length(); idx += 4 ) {
            if ( base64.get(sIn.charAt(idx+1)) != null ) lstOut.add( (base64.get(sIn.charAt(idx)) << 2) | (base64.get(sIn.charAt(idx+1)) >>> 4) );
            if ( base64.get(sIn.charAt(idx+2)) != null ) lstOut.add( ((base64.get(sIn.charAt(idx+1)) & 15)<<4) | (base64.get(sIn.charAt(idx+2)) >>> 2) );
            if ( base64.get(sIn.charAt(idx+3)) != null ) lstOut.add( ((base64.get(sIn.charAt(idx+2)) & 3)<<6) | base64.get(sIn.charAt(idx+3)) );
        }

        System.Debug('B64ToBytes: [' + sIn + '] = ' + lstOut);
        return lstOut;
    }//B64ToBytes

    public static List<Integer> BlobToBytes (Blob input) 
    {
        return B64ToBytes( EncodingUtil.base64Encode(input) );
    }//BlobToBytes
    
}