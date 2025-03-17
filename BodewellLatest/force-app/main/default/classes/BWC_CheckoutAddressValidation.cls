public class BWC_CheckoutAddressValidation {
    public String Name;
    public String Status;
        
        //Get token details for mellisa address validation api 
        @AuraEnabled(cacheable=false)     
        public static String mya_AddValidation()
        {     
         	String domainUrl = Url.getOrgDomainUrl().getHost();
            MYA_Configuration__mdt details=MYA_MetaDataConfigHelper.getmyaConfigByDomain(domainUrl);
           
        	String postBodyToken = '{"client_id":"' + details.Token_Client_Id__c + 
            	'","client_secret":"' + details.Token_Client_Secret__c + 
                '","audience":"' + details.Token_Audience__c + '","grant_type":"client_credentials"}';
        
        	Http httpCall = new Http();
        	HttpRequest request = new HttpRequest();
        	request.setMethod('POST');
        	request.setEndpoint(details.Token_EndPoint_URL__c);
        	request.setHeader('Content-Type', 'application/json');
        	request.setBody(postBodyToken);
        	request.setTimeout(60000);
        	HttpResponse response; 
        	response = httpCall.send(request);      
        	GEAoAuthResponse  resp;
        	resp = GEAoAuthResponse.parse(response.getBody());
        	String Token=resp.access_token;
        	return Token;
        }
    
        //check validation
        @AuraEnabled(cacheable=false)
        Public static AddressValidationWrapper Mya_AddressValidation(String firstName,String lastName,String Address,String City,String State,String Code,string addressType)
        {
         
        	String token=mya_AddValidation();          
        	String Address1=Address;
        	String City1=City;
        	String State1=State;
        	String ZipCode=Code; 
     
        	String UserId=userinfo.getUserId();
        	    
            
        	list<User> Cons=[select Id,ContactId from User where Id=:UserId];
        	User Con=Cons[0];
        	System.debug(Con.ContactId);    
            
            String domainUrl = Url.getOrgDomainUrl().getHost();
            MYA_Configuration__mdt details=MYA_MetaDataConfigHelper.getmyaConfigByDomain(domainUrl);
            
        	String AuthToken = 'Bearer ' +token;
        
        	string url= 'ADDRESS_LINE1='+EncodingUtil.urlEncode(Address1, 'UTF-8')+'&CITY='+EncodingUtil.urlEncode(City1, 'UTF-8')+'&STATE='+EncodingUtil.urlEncode(State1, 'UTF-8')+'&POSTALCODE='+EncodingUtil.urlEncode(ZipCode, 'UTF-8');

        	Http httpCall = new Http();
        	HttpRequest request = new HttpRequest();
        	request.setMethod('GET');
        	request.setEndpoint(details.Mellisa_EndPoint_URL__c + url);
        	request.setHeader('Content-Type','application/json');
        	request.setHeader('Client_id',details.Mellisa_Client_Id__c);
        	request.setHeader('Client_secret',details.Mellisa_Client_Secret__c);
        	request.setHeader('Authorization',AuthToken);    
        
        	request.setTimeout(60000);
        	HttpResponse response ;
        
        	response = httpCall.send(request); 
            ContactPointAddress newAddress=new_AddAddress(response, firstName, lastName,addressType);
             ContactPointAddress existingAddress= ext_AddAddress(response,firstName, lastName, Address, City, State, Code,addressType);
            AddressValidationWrapper AVW=new AddressValidationWrapper();
            AVW.newAddress=newAddress;
            AVW.existingAddress=existingAddress;
               system.debug('response'+response.getBody());  
            return AVW;
      
        }
    
    
    
     public static ContactPointAddress ext_AddAddress(HttpResponse response1,String firstName,String lastName,String Address,String City,String State,String Code,string addressType)
         {   
       
            String Name;
              String Name2;
        	String Account_Id;              
        	
            boolean IsValid=false;
           
        	Mya_AddValidationResponse res; 
        	res = Mya_AddValidationResponse.parse(response1.getBody());
        	String result=res.RESULTS;
        	List<String> ResponseCodes = result.split(',');
        	             
        	if(ResponseCodes.contains('AS01'))
        	{ 
             	IsValid=true;
        	}
        	String Code1;
        	if(res.POSTALCODE.length()>5)
        	{
           		Code1=res.POSTALCODE.substring(0,5); 
        	}
        	else{
          		Code1=res.POSTALCODE;     
        	}
              
        
        	Name=firstName+' '+lastName+' '+Address+' '+City+' '+State+' '+Code1;
             	Name2=+Address+' '+City+' '+State+' '+Code1;
            String FullZipName = firstName+' '+lastName+' '+Address+' '+City+' '+State+' '+Code1;
            String SpacelessName = Name.replaceAll( '\\s+', '') + '%';
            String MelisaKey = res.MELISSA_ADDRESS_KEY;
         
            ContactPointAddress cpa=new ContactPointAddress();
             cpa.BWC_IsVerified__c=IsValid;
             cpa.Street=Address;
             cpa.AddressType=addressType;
             cpa.BWC_MelissaAddressKey__c=res.MELISSA_ADDRESS_KEY;
             cpa.BWC_HygieneAddressKey__c=res.ADDRESS_KEY;
             cpa.State=State;
             cpa.BWC_Responsecode__c=res.RESULTS;
             cpa.City=City;
             cpa.Country=res.COUNTRY;
             cpa.PostalCode=Code1;
             cpa.Name=firstName+' '+lastName;
         cpa.BWC_Formatted_Address__c=Name2;
             cpa.IsDefault=true;
             
        return cpa;
        
       }  
      public static ContactPointAddress new_AddAddress(HttpResponse response1,String firstName,String lastName,String addressType)
         {   
       
            String Name;
               String Name2;
        	String Account_Id;              
        	
            boolean IsValid=false;
           
        	Mya_AddValidationResponse res; 
        	res = Mya_AddValidationResponse.parse(response1.getBody());
        	String result=res.RESULTS;
        	List<String> ResponseCodes = result.split(',');
        	             
        	if(ResponseCodes.contains('AS01'))
        	{ 
             	IsValid=true;
        	}
        	String Code1;
        	if(res.POSTALCODE.length()>5)
        	{
           		Code1=res.POSTALCODE.substring(0,5); 
        	}
        	else{
          		Code1=res.POSTALCODE;     
        	}
              
        
        	Name=firstName+' '+lastName+' '+res.ADDRESS_LINE1+' '+res.CITY+' '+res.STATE+' '+Code1;
             	Name2=res.ADDRESS_LINE1+' '+res.CITY+' '+res.STATE+' '+Code1;
            String FullZipName = firstName+' '+lastName+' '+res.ADDRESS_LINE1+' '+res.CITY+' '+res.STATE+' '+res.POSTALCODE;
            String SpacelessName = Name.replaceAll( '\\s+', '') + '%';
            String MelisaKey = res.MELISSA_ADDRESS_KEY;
         
            ContactPointAddress cpa=new ContactPointAddress();
             cpa.BWC_IsVerified__c=IsValid;
             cpa.Street=res.ADDRESS_LINE1;
            cpa.AddressType=addressType;
             cpa.BWC_MelissaAddressKey__c=res.MELISSA_ADDRESS_KEY;
             cpa.BWC_HygieneAddressKey__c=res.ADDRESS_KEY;
             cpa.State=res.STATE;
             cpa.BWC_Responsecode__c=res.RESULTS;
             cpa.City=res.CITY;
             cpa.Country=res.COUNTRY;
             cpa.PostalCode=Code1;
          cpa.Name=firstName+' '+lastName;
             cpa.BWC_Formatted_Address__c=Name2;
               cpa.IsDefault=true;
        return cpa;
        
       }  
        public class AddressValidationWrapper {
        @auraenabled
        public ContactPointAddress newAddress;
          @auraenabled
        public ContactPointAddress existingAddress;
        public  AddressValidationWrapper()
        {
           ContactPointAddress newAddress=new ContactPointAddress();
         ContactPointAddress existingAddress=new ContactPointAddress();
        }
        
    }
       //create account(add address)
        @AuraEnabled(cacheable=false)
        Public static ContactPointAddress addAddress(String accountId,ContactPointAddress cpa)
        {  try
            {
            if(cpa!=null)
            {
                cpa.ParentId=accountId;
                insert cpa;
            }
                return cpa;
            }
       catch (Exception e) 
        {
          
           return null;  
        }    
        }
 
         
    
}