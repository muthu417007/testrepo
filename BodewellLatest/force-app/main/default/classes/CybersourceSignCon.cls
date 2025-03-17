public class CybersourceSignCon {    
    public String data {get;set;}
    public String signedData {get;set;}
    public decimal deliveryInstallationCharges {get;set;}
    public decimal tax{get;set;}
    public decimal totalAmount {get;set;}
    public boolean displayParam {get;set;}
    public Concession__c concession {get;set;}
    public boolean hasRequiredData {get;set;}
    
    public CyberSourceSignCon(ApexPages.StandardController con){
        hasRequiredData=true;
        concession = [SELECT Id,name,Case__c,Case__r.CaseNumber,Case__r.Contact.Email,Case__r.Contact.FirstName,Case__r.Contact.LastName,
                                    Concession_Location__r.BillingStreet,Concession_Location__r.BillingCity,
                                    Concession_Location__r.BillingPostalCode,Concession_Location__r.BillingState
                                    FROM Concession__c 
                                    WHERE Id=:con.getId()];        
        if(concession.Case__c==null || concession.Case__r.Contact==null || concession.Concession_Location__c==null || 
           //String.isBlank(concession.Case__r.Contact.Email)||
          String.isBlank(concession.Case__r.Contact.FirstName) || String.isBlank(concession.Case__r.Contact.LastName)
          ||String.isBlank(concession.Concession_Location__r.BillingCity)||String.isBlank(concession.Concession_Location__r.BillingPostalCode)||String.isBlank(concession.Concession_Location__r.BillingState)
          ||String.isBlank(concession.Concession_Location__r.BillingStreet)){
            hasRequiredData=false;
        }
        displayParam=false;
        tax=0;
    }
  private static final String SECRET_KEY = 'a778beb4ab324b68ab736eb91b658c05d1537aecd3144c02a0c279c2b2d0a9b26073b5fbc8a14b2da66add58e23957fecade3783307745f187c1677c1a7656f84261ac52fbe24a34bd97c7d7ff4916a7b3226b743aa8461b8f17bd8559494a6b6576b88e112146b6b59df1951067c4e08e2fe28f07054801bf67d19bc6f7451f'; //OSC PROD KEY
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
                //dictionary.put('merchant_defined_data1', '3326250');
                dictionary.put('merchant_defined_data1', concession.name.subString(2,concession.name.length()));
                dictionary.put('merchant_defined_data2', String.valueOf(deliveryInstallationCharges==null?0:deliveryInstallationCharges));
                dictionary.put('merchant_defined_data3', concession.Case__r.CaseNumber);
                dictionary.put('tax_amount', String.valueOf(tax==null?0:tax));
                dictionary.put('amount', String.valueOf(totalAmount==null?0:totalAmount));
                dictionary.put('transaction_uuid', getUUID());
                dictionary.put('unsigned_field_names', '');
                dictionary.put('signed_field_names', 'merchant_defined_data1,merchant_defined_data2,merchant_defined_data3,tax_amount,amount,transaction_uuid,unsigned_field_names,signed_field_names,signed_date_time,transaction_type,locale,currency,override_custom_receipt_page,reference_number,access_key,profile_id,merchant_defined_data4,bill_to_address_country,bill_to_address_line1,bill_to_forename,bill_to_address_postal_code,bill_to_address_state,bill_to_surname,bill_to_address_city,bill_to_email');
                //dictionary.put('signed_date_time', getUtcDateTime(System.now().addHours(5)));
                dictionary.put('signed_date_time', getUtcDateTime(System.now().addHours(tz.getOffset(System.now())/3600000*-1)));
                
                dictionary.put('transaction_type', 'sale,create_payment_token');
                dictionary.put('locale', 'en');
                dictionary.put('currency', 'USD');
                dictionary.put('override_custom_receipt_page', '');
                //dictionary.put('override_custom_receipt_page', 'https://geappliances.custhelp.com/app/Cybersource_Response');
                dictionary.put('reference_number', concession.Case__r.CaseNumber);
                dictionary.put('access_key', '8e474e3fd8ec3a069e4d9a2f624bd4ac');
                dictionary.put('profile_id', '1691B5CA-B0A1-4C96-AD77-457F4B7F5F05');
                //dictionary.put('merchant_defined_data4', '3326250');
                dictionary.put('merchant_defined_data4', concession.name.subString(2,concession.name.length()));
                dictionary.put('bill_to_address_country', 'US');
                dictionary.put('bill_to_address_line1',  concession.Concession_Location__r.BillingStreet);
                dictionary.put('bill_to_forename',  concession.Case__r.Contact.FirstName);
                dictionary.put('bill_to_address_postal_code',  concession.Concession_Location__r.BillingPostalCode);
                dictionary.put('bill_to_address_state', concession.Concession_Location__r.BillingState);
                dictionary.put('bill_to_surname', concession.Case__r.Contact.LastName);
                dictionary.put('bill_to_address_city', concession.Concession_Location__r.BillingCity);
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
     public String getParametersValues() {
        String result = '';
        
        for(String oKey : paramMap.keySet()) { 
            result += '<div>';
            result += '<input type="text" id="' + oKey + '" name="' + oKey + '" value="' + paramMap.get(oKey) + '"/>';
            result += '</div>';
        }
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