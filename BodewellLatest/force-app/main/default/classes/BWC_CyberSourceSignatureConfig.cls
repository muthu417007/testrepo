public class BWC_CyberSourceSignatureConfig {    
    public String data {get;set;}
    public String signedData {get;set;}
    public decimal deliveryInstallationCharges {get;set;}
    public decimal tax{get;set;}
    public decimal totalAmount {get;set;}
    public boolean displayParam {get;set;}
    public boolean hasRequiredData {get;set;}
    
    public BWC_CyberSourceSignatureConfig(ApexPages.StandardController con){
        hasRequiredData=true;
        displayParam=true;
        tax=6;
        deliveryInstallationCharges=100;
        totalAmount=100;
        
    }
  private static final String SECRET_KEY = 'beb3e5da26d6454eba60c060b59d262f68a7b458389f445da623abf71d031051c77675b724da4fa28dcd48ec82a80cf5e1592b724bd348218a0b2d3ccfa350723e89e799685e4dd69e6371b4678b8394e37404483fde4a829842c2c68cec5d118bdd0a2caf8e477095b9cc9857f7bbea5af4667b71ba4d5d9938a2fe1edd0438';
  //private static final String SECRET_KEY = '68f1ac81adaa49b39153c839b12d0c467d157fd45c694355b75bf7617d2fce1a664760e56c7b4eb9889ca6eceb1b1860612fe510954341f4b08b9f542af1090332f661f1dfb343979ef3d0a97544dbd59f71476a5ae940f1b288150926d6e78b0e05f20751df4c7fb9002808a7b97a09a2e0889cc35748a2a6db7b97c6c41b57';
 
    
    public PageReference doBuild(){
        //getParametersValues();
        return null;
    }
    public PageReference setVisible(){
        displayParam=true;
        return null;
    }
    public Map<String,String> paramMap {
        get{
            Timezone tz = UserInfo.getTimeZone();
            //system.debug(tz.getOffset(System.now())/3600000*-1);
            if(paramMap==null){
                Map<string, string> dictionary = new Map<string, string>();
                dictionary.put('merchant_defined_data1', '3326250');
               // dictionary.put('merchant_defined_data1', concession.name.subString(2,concession.name.length()));
                dictionary.put('merchant_defined_data2', '100');
                dictionary.put('merchant_defined_data3', '120004835');
                dictionary.put('tax_amount', '12');
                dictionary.put('amount', '212');
                dictionary.put('transaction_uuid', getUUID());
                dictionary.put('unsigned_field_names', '');
                dictionary.put('signed_field_names', 'merchant_defined_data1,merchant_defined_data2,merchant_defined_data3,tax_amount,amount,transaction_uuid,unsigned_field_names,signed_field_names,signed_date_time,transaction_type,locale,currency,override_custom_receipt_page,reference_number,access_key,profile_id,merchant_defined_data4,bill_to_address_country,bill_to_address_line1,bill_to_forename,bill_to_address_postal_code,bill_to_address_state,bill_to_surname,bill_to_address_city,bill_to_email');
                //dictionary.put('signed_date_time', getUtcDateTime(System.now().addHours(5)));
                dictionary.put('signed_date_time', getUtcDateTime(System.now().addHours(tz.getOffset(System.now())/3600000*-1)));
                
                dictionary.put('transaction_type', 'authorization,create_payment_token');
                dictionary.put('locale', 'en');
                dictionary.put('currency', 'USD');
                dictionary.put('override_custom_receipt_page', '');
               // dictionary.put('override_custom_receipt_page', 'https://geapp--bwcommoob--c.sandbox.vf.force.com/apex/bwc_CyberSourceSign/Cybersource_Response');
               dictionary.put('override_custom_receipt_page', 'https://geapp--bwcommoob.sandbox.my.salesforce-sites.com/bcybersourceresponse');
                dictionary.put('reference_number', '120004835-1381'); //order source 1381
                dictionary.put('access_key', '65a22dd0363534bd9d2d5ea7074c3883');
                dictionary.put('profile_id', 'BB376E86-3806-4757-93F8-290F794A3CE7');
                //dictionary.put('merchant_defined_data4', '3326250');
                dictionary.put('merchant_defined_data4', 'TESTING VIA HOSTED CHECKOUT');
                dictionary.put('bill_to_address_country', 'US');
                dictionary.put('bill_to_address_line1',  '307 N HOURSEBORN PRKWY');
                dictionary.put('bill_to_forename',  'MOHAMMAD F');
                dictionary.put('bill_to_address_postal_code',  '40222');
                dictionary.put('bill_to_address_state', 'KY');
                dictionary.put('bill_to_surname', 'FEROZ');
                dictionary.put('bill_to_address_city', 'LOUISVILLE');
                //dictionary.put('bill_to_email', concession.Case__r.Contact.Email);
                dictionary.put('bill_to_email', '');
                data='';
                for(string key : dictionary.keyset())
                {
                    System.debug(key+'='+dictionary.get(key));
                    //data += EncodingUtil.urlEncode(key,'UTF-8')+'='+EncodingUtil.urlEncode(dictionary.get(key), 'UTF-8') + ',';
                    data += key+'='+dictionary.get(key)+',';
                }
                data=data.removeEnd(',');
                signedData='<input type="hidden" id="signature" name="signature" value="'+sign(data,SECRET_KEY)+'"/>';
                paramMap=dictionary;
            }
            return paramMap;
        }
        set;
    }
     public  String getParametersValues() {
        String result = '';
        
        for(String oKey : paramMap.keySet()) { 
            result += '<div>';
            result += '<input type="text" id="' + oKey + '" name="' + oKey + '" value="' + paramMap.get(oKey) + '"/>';
            result += '</div>';
        }
        return result;
    }
     @AuraEnabled(cacheable=true)
       public Map<string, string> getParametersValuesLWC() {
     
        return paramMap;
    }
      @AuraEnabled(cacheable=true)
       public String getSignature() {
      data='';
                for(string key : paramMap.keyset())
                {
                    System.debug(key+'='+paramMap.get(key));
                    //data += EncodingUtil.urlEncode(key,'UTF-8')+'='+EncodingUtil.urlEncode(dictionary.get(key), 'UTF-8') + ',';
                    data += key+'='+paramMap.get(key)+',';
                }
                data=data.removeEnd(',');
                 String result =sign(data,SECRET_KEY);
                      
        return result;
           
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
        String strUTCDateTime = dt.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        return strUTCDateTime;
  }
      
    
}