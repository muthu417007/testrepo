public without sharing class BWC_ShippingAndBillingAddressController {
    
    @AuraEnabled(cacheable=true)
    Public Static List<ContactPointAddress> bwc_getShippingAddress(String userId)
    {
        Id accountId = [Select AccountId from User where Id =:userId LIMIT 1][0].AccountId;
        
        List<ContactPointAddress> accountShippingAddresses=[SELECT Id,Name,AddressFirstName,AddressLastName ,BWC_Formatted_Address__c, Address, AddressType, Street, City, State, PostalCode, Country, IsDefault , ParentId FROM ContactPointAddress WHERE ParentId=:accountId and AddressType='Shipping' ORDER BY IsDefault DESC  ] ;
        return accountShippingAddresses;
    }
    @AuraEnabled
    Public Static sfdc_checkout.IntegrationStatus BWC_CallCheckoutIntrgration(String cartId)
    {
        //BWC_CheckAvailabilityController c = new BWC_CheckAvailabilityController();
        //c.startCartProcessAsync(null,cartId);
        //BWC_ShippingController shiObj = new BWC_ShippingController();
        // shiObj.startCartProcessAsync(null,cartId);
        BWC_TaxController taxObj = new BWC_TaxController();
       sfdc_checkout.IntegrationStatus returnStatus;
        
             if(!test.isRunningTest())
        {  
      returnStatus = taxObj.startCartProcessAsync(null,cartId);
        }
        //BWC_ShippingController shiObj = new BWC_ShippingController();
        //shiObj.startCartProcessAsync(null,cartId);
        return returnStatus;
    }
       @AuraEnabled
    public static ContactPointAddress getConsumerZipcode(
        String accountId
    ) {
        ContactPointAddress zipCodeInstance;
        if(accountId!=null) {
            List<ContactPointAddress> contactPointAddressInstance = [SELECT 
                                                                     PostalCode, State 
                                                                     FROM ContactPointAddress 
                                                                     WHERE ParentId =:accountId and IsDefault = true and addressType='Shipping'
                                                                     LIMIT 1];
            if(!contactPointAddressInstance.isEmpty()){
                zipCodeInstance = contactPointAddressInstance[0]; //'{"zipcode":"'+contactPointAddressInstance[0].PostalCode+'","state":"'+contactPointAddressInstance[0].State+'"}';
            }
            
        }
        return zipCodeInstance;
        
    }
    @AuraEnabled
    public static void updateCartStatus(String cartId){
        List<WebCart> cartList = [SELECT Id,
                                  Status
                                  FROM WebCart
                                  WHERE Id =: cartId
                                  LIMIT 1];
        if(cartList[0].Status != 'Checkout'){
            cartList[0].Status = 'Checkout';
            update cartList;
        }
    }
    
    @AuraEnabled(cacheable=true)
    Public Static ContactPointAddress bwc_getBillingAddressB(String accountId)
    {
        
        String accId=accountId.trim();
        ContactPointAddress accountShippingAddresses=[SELECT Id,BWC_Address_Line_2__c,AddressFirstName,BWC_IsVerified__c,BWC_Responsecode__c,BWC_HygieneAddressKey__c,AddressLastName,BWC_MelissaAddressKey__c,Name , Address, AddressType,BWC_Formatted_Address__c, Street, City, State, PostalCode, Country, IsDefault , ParentId FROM ContactPointAddress WHERE ParentId=:accId and AddressType='Shipping' and IsDefault=true  ORDER BY IsDefault DESC LIMIT 1  ] ;
        return accountShippingAddresses;
    }
    
    @AuraEnabled//(cacheable=true)
    Public Static String getCheckoutStatus(String cartId)
    {
        String cartIdNew=cartId.trim();
        
        String status=[SELECT Id,BWC_Checkout_Status__c FROM WebCart WHERE Id=:cartId LIMIT 1  ].BWC_Checkout_Status__c;
        return status;
    }
    @AuraEnabled
    Public Static WebCart updateCheckoutStatus(String cartId,String status)
    {
        
        
        WebCart cart=[SELECT Id,BWC_Checkout_Status__c FROM WebCart WHERE Id=:cartId LIMIT 1  ];
        cart.BWC_Checkout_Status__c=status;
        update cart;
        return cart;
    }
    
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
    
    //check validation    addressLine2 :this.AddressLine2,
    //  textMe:this.textMe,
    // referralCode: this.referralCode
    @AuraEnabled(cacheable=false)
    Public static AddressValidationWrapper Mya_AddressValidation(String firstName,String lastName,String Address,String City,String State,String Code,string addressType,String addressLine2,boolean textMe,String referralCode,String PhoneNumber)
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
        ContactPointAddress newAddress=new_AddAddress(response, firstName, lastName,addressType, addressLine2, textMe, referralCode, PhoneNumber);
        ContactPointAddress existingAddress= ext_AddAddress(response,firstName, lastName, Address, City, State, Code,addressType, addressLine2, textMe, referralCode, PhoneNumber);
        AddressValidationWrapper AVW=new AddressValidationWrapper();
        AVW.newAddress=newAddress;
        AVW.existingAddress=existingAddress;
        system.debug('response'+response.getBody());  
        return AVW;
        
    }
    
    
    
    public static ContactPointAddress ext_AddAddress(HttpResponse response1,String firstName,String lastName,String Address,String City,String State,String Code,string addressType,String addressLine2,boolean textMe,String referralCode,String PhoneNumber)
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
        Name2=+Address+' '+addressLine2+' '+City+' '+State+' '+Code;
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
        cpa.PostalCode=code;
        cpa.Name=firstName+' '+lastName;
        cpa.AddressFirstName=firstName;
        cpa.AddressLastName=lastName;
        cpa.BWC_Formatted_Address__c=Name2;
        cpa.IsDefault=true;
        cpa.BWC_Text_Me__c=textMe;
        cpa.BWC_Address_Line_2__c=addressLine2;
        cpa.BWC_Phone_Number__c=PhoneNumber;
        cpa.BWC_Referral_Code__c=referralCode;
        
        return cpa;
        
    }  
    public static ContactPointAddress new_AddAddress(HttpResponse response1,String firstName,String lastName,String addressType,String addressLine2,boolean textMe,String referralCode,String PhoneNumber)
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
        cpa.AddressFirstName=firstName;
        cpa.AddressLastName=lastName;
        cpa.BWC_Formatted_Address__c=Name2;
        cpa.IsDefault=true;
        cpa.BWC_Text_Me__c=textMe;
        cpa.BWC_Address_Line_2__c=addressLine2;
        cpa.BWC_Phone_Number__c=PhoneNumber;
        cpa.BWC_Referral_Code__c=referralCode;
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
    //create address
    @AuraEnabled(cacheable=false)
    Public static ContactPointAddress addAddress(String accountId,ContactPointAddress cpa)
    {  
        try
        {
            String accId=accountId.trim();
            if(cpa!=null)
            {
                if(cpa.AddressType=='Billing')
                {
                    Webcart cart=[SELECT Id, BillingStreet,BWC_Cart_Id__c, BillingCity, BillingState, BillingPostalCode,IsSecondary, BillingCountry, BillingAddress, AccountId, Status FROM WebCart where AccountId=:accId AND (status='Active' OR status='Checkout' ) and IsSecondary=false];
                    cart.BillingStreet=cpa.Street;
                    cart.BillingCity=cpa.City;
                    cart.BillingState=cpa.State;
                    cart.BillingPostalCode=cpa.PostalCode;
                    cart.BWC_Billing_Name__c=cpa.Name;
                 
                   cart.BWC_Cart_Id__c=cart.Id;
                    cart.BillingCountry=cpa.Country;
                    system.debug(cart);
                    update cart;
                    
                    
                } 
                if(cpa.AddressType=='Shipping')
                {
                    Webcart cart=[SELECT Id, BillingStreet,BWC_Cart_Id__c, BillingCity, BillingState, BillingPostalCode,IsSecondary, BillingCountry, BillingAddress, AccountId, Status FROM WebCart where AccountId=:accId AND (status='Active' OR status='Checkout' ) and IsSecondary=false];
                  CartDeliveryGroup cartGroup= [SELECT Id, Name, CartId, DeliveryMethodId, DeliverToFirstName, DeliverToLastName, DeliverToStreet, DeliverToName, DeliverToCity, DeliverToState, DeliverToPostalCode, DeliverToCountry
                    FROM CartDeliveryGroup
                   where cartId=:cart.Id];
                     system.debug('cartGroup=='+cartGroup);
                    cartGroup.DeliverToCity=cpa.City;
                    cartGroup.DeliverToFirstName=cpa.AddressFirstName;
                    cartGroup.DeliverToLastName=cpa.AddressLastName;
                 cartGroup.DeliverToName=cpa.AddressFirstName+' '+cpa.AddressLastName;

                    cartGroup.DeliverToState=cpa.State;
                    cartGroup.DeliverToCountry=cpa.Country;
                    cartGroup.DeliverToPostalCode=cpa.PostalCode;
                    cartGroup.DeliverToStreet=cpa.Street;
                 
                    update cartGroup;
                     system.debug('cartGroup=='+cartGroup);
                    system.debug('cartGroup=='+cartGroup);
                    
                    
                } 
                if(cpa.AddressType=='Shipping')
                { 
                    String conId=[select  id,accountId from Contact where accountId=:accId].Id;
                    Contact_Point__c createdContact=createContact(conId,cpa.BWC_Phone_Number__c,false);
                
                    List<ContactPointAddress> address=[SELECT Id, Name, ParentId,BWC_Text_Me__c, isDefault, AddressType, Street, City, State, PostalCode, Country, Address, AddressFirstName, AddressMiddleName, AddressLastName, PhoneNumber, BWC_IsVerified__c, BWC_MelissaAddressKey__c, BWC_HygieneAddressKey__c, BWC_Responsecode__c, BWC_Formatted_CPA_Name__c, BWC_Formatted_Address__c, BWC_Address_Line_2__c, BWC_Phone_Number__c,BWC_Referral_Code__c FROM ContactPointAddress where BWC_MelissaAddressKey__c=:cpa.BWC_MelissaAddressKey__c and AddressType='Shipping' and parentId=:accId  LIMIT 1];
                    if(address.size() == 0)
                    {
                        String SpacelessName = (cpa.BWC_Formatted_Address__c).replaceAll( '\\s+', '') + '%';
                        
                        address=[SELECT Id, Name, ParentId, isDefault,BWC_Text_Me__c, AddressType, Street, City, State, PostalCode, Country, Address, AddressFirstName, AddressMiddleName, AddressLastName, PhoneNumber, BWC_IsVerified__c, BWC_MelissaAddressKey__c, BWC_HygieneAddressKey__c, BWC_Responsecode__c, BWC_Formatted_CPA_Name__c, BWC_Formatted_Address__c, BWC_Address_Line_2__c, BWC_Phone_Number__c,BWC_Referral_Code__c FROM ContactPointAddress where BWC_Formatted_Address__c=:cpa.BWC_Formatted_Address__c and AddressType='Shipping' and BWC_Formatted_Address__c=:SpacelessName and parentId=:accId  LIMIT 1];
                    }
                    
                    
                    if(address.size()>0)  
                    {
                        
                        address[0].BWC_IsVerified__c=cpa.BWC_IsVerified__c;
                        address[0].Street= cpa.Street;
                        address[0].AddressType= cpa.AddressType;
                        address[0].BWC_MelissaAddressKey__c=cpa.BWC_MelissaAddressKey__c;
                        address[0].BWC_HygieneAddressKey__c=cpa.BWC_HygieneAddressKey__c;
                        address[0].State=cpa.State;
                        address[0].BWC_Responsecode__c=cpa.BWC_Responsecode__c;
                        address[0].City=cpa.City;
                        address[0].Country=cpa.Country;
                        address[0].PostalCode=cpa.PostalCode;
                        address[0].Name=cpa.Name;
                        
                        address[0].AddressFirstName=cpa.AddressFirstName;
                        address[0].AddressLastName=cpa.AddressLastName;
                        address[0].BWC_Formatted_Address__c=cpa.BWC_Formatted_Address__c;
                        address[0].IsDefault=cpa.IsDefault;
                        address[0].BWC_Text_Me__c=cpa.BWC_Text_Me__c;
                        address[0].BWC_Address_Line_2__c=cpa.BWC_Address_Line_2__c;
                        address[0].BWC_Phone_Number__c=cpa.BWC_Phone_Number__c;
                        address[0].BWC_Referral_Code__c=cpa.BWC_Referral_Code__c; 
                        update  address[0];
                        cpa=address[0];
                    }
                    else 
                    {
                        cpa.ParentId=accId;
                        cpa.isDefault=true;
                        insert cpa;  
                        
                    }
                    
                    
                }
                system.debug('cpa==='+cpa);
                if(cpa.AddressType=='Billing')
                {
                                        String conId=[select  id,accountId from Contact where accountId=:accId].Id;
                   // Contact_Point__c createdContact=createContact(conId,cpa.BWC_Phone_Number__c,false);
                
                    system.debug('before address==='+accountId);
                    List<ContactPointAddress> address=[SELECT Id, Name, ParentId,BWC_Text_Me__c, isDefault, AddressType, Street, City, State, PostalCode, Country, Address, AddressFirstName, AddressMiddleName, AddressLastName, PhoneNumber, BWC_IsVerified__c, BWC_MelissaAddressKey__c, BWC_HygieneAddressKey__c, BWC_Responsecode__c, BWC_Formatted_CPA_Name__c, BWC_Formatted_Address__c, BWC_Address_Line_2__c, BWC_Phone_Number__c,BWC_Referral_Code__c FROM ContactPointAddress where BWC_MelissaAddressKey__c=:cpa.BWC_MelissaAddressKey__c and AddressType='Billing'and parentId=:accId LIMIT 1];
                    
                    // List<ContactPointAddress> address=[SELECT Id, Name, ParentId,BWC_Text_Me__c, isDefault, AddressType, Street, City, State, PostalCode, Country, Address, AddressFirstName, AddressMiddleName, AddressLastName, PhoneNumber, BWC_IsVerified__c, BWC_MelissaAddressKey__c, BWC_HygieneAddressKey__c, BWC_Responsecode__c, BWC_Formatted_CPA_Name__c, BWC_Formatted_Address__c, BWC_Address_Line_2__c, BWC_Phone_Number__c,BWC_Referral_Code__c FROM ContactPointAddress where BWC_MelissaAddressKey__c=:cpa.BWC_MelissaAddressKey__c and AddressType='Billing' and parentId=:accountId  LIMIT 1];
                    system.debug('address==='+address);
                    if(address.size() == 0)
                    {
                        String SpacelessName = (cpa.BWC_Formatted_Address__c).replaceAll( '\\s+', '') + '%';
                        
                        address=[SELECT Id, Name, ParentId, isDefault,BWC_Text_Me__c, AddressType, Street, City, State, PostalCode, Country, Address, AddressFirstName, AddressMiddleName, AddressLastName, PhoneNumber, BWC_IsVerified__c, BWC_MelissaAddressKey__c, BWC_HygieneAddressKey__c, BWC_Responsecode__c, BWC_Formatted_CPA_Name__c, BWC_Formatted_Address__c, BWC_Address_Line_2__c, BWC_Phone_Number__c,BWC_Referral_Code__c FROM ContactPointAddress where BWC_Formatted_Address__c=:cpa.BWC_Formatted_Address__c and AddressType='Billing' and BWC_Formatted_Address__c=:SpacelessName  and parentId=:accId  LIMIT 1];
                    }
                    
                    
                    if(address.size()>0)  
                    {
                        
                        address[0].BWC_IsVerified__c=cpa.BWC_IsVerified__c;
                        address[0].Street= cpa.Street;
                        address[0].AddressType= cpa.AddressType;
                        address[0].BWC_MelissaAddressKey__c=cpa.BWC_MelissaAddressKey__c;
                        address[0].BWC_HygieneAddressKey__c=cpa.BWC_HygieneAddressKey__c;
                        address[0].State=cpa.State;
                        address[0].BWC_Responsecode__c=cpa.BWC_Responsecode__c;
                        address[0].City=cpa.City;
                        address[0].Country=cpa.Country;
                        address[0].PostalCode=cpa.PostalCode;
                        address[0].Name=cpa.Name;
                        address[0].BWC_Formatted_Address__c=cpa.BWC_Formatted_Address__c;
                        address[0].IsDefault=cpa.IsDefault;
                        address[0].BWC_Text_Me__c=cpa.BWC_Text_Me__c;
                        address[0].BWC_Address_Line_2__c=cpa.BWC_Address_Line_2__c;
                        address[0].BWC_Phone_Number__c=cpa.BWC_Phone_Number__c;
                        address[0].BWC_Referral_Code__c=cpa.BWC_Referral_Code__c; 
                        update  address[0];
                        cpa=address[0];
                    }
                    else 
                    {
                        ContactPointAddress newCPA = cpa.clone();
                        
                        newCPA.ParentId=accId;
                        newCPA.isDefault=true;
                        insert newCPA;                     
                    }
                    
                }
                
            }
            return cpa;
        }
        catch (Exception e) 
        {
            system.debug('Exception ===='+e.getMessage()+'   '+e.getLineNumber());
            return null;  
        }    
    }
    
    //select id, isDefault,isPrimary ,name from contactPointAddress where parentId='0018B00000OsSa9QAF' and addressType='Shipping'
    //create account(add address)
    @AuraEnabled(cacheable=false)
    Public static ContactPointAddress makeAddressDefault(String addressId,String phoneNumber)
    {  try
    {
        ContactPointAddress cpa=[ select id,parentId, isDefault,State,BWC_Phone_Number__c,isPrimary ,Country,City,PostalCode,Street,name,AddressType,AddressFirstName,AddressLastName from contactPointAddress where id=:addressId LIMIT 1];
        if(cpa.AddressType=='Shipping')
                {
                    Webcart cart=[SELECT Id, BillingStreet,BWC_Cart_Id__c, BillingCity, BillingState, BillingPostalCode,IsSecondary, BillingCountry, BillingAddress, AccountId, Status FROM WebCart where AccountId=:cpa.ParentId AND (status='Active' OR status='Checkout' ) and IsSecondary=false];
                  CartDeliveryGroup cartGroup= [SELECT Id, Name, CartId, DeliveryMethodId, DeliverToFirstName, DeliverToLastName, DeliverToStreet, DeliverToName, DeliverToCity, DeliverToState, DeliverToPostalCode, DeliverToCountry
                    FROM CartDeliveryGroup
                   where cartId=:cart.Id];
                     system.debug('cartGroup=='+cartGroup);
                    cartGroup.DeliverToCity=cpa.City;
                    cartGroup.DeliverToFirstName=cpa.AddressFirstName;
                    cartGroup.DeliverToLastName=cpa.AddressLastName;
                    cartGroup.DeliverToState=cpa.State;
                    cartGroup.DeliverToCountry=cpa.Country;
                    cartGroup.DeliverToPostalCode=cpa.PostalCode;
                    cartGroup.DeliverToStreet=cpa.Street;
                    update cartGroup;
                     system.debug('cartGroup=='+cartGroup);
                    system.debug('cartGroup=='+cartGroup);
  
                    
                } 
        if(cpa!=null)
        {
            
            cpa.isDefault=true;
            update cpa;
             String conId=[select  id,accountId from Contact where accountId=:cpa.parentId].Id;
            if(cpa.AddressType=='Shipping')
            {
         Contact_Point__c createdContact=createContact(conId,phoneNumber,false);
        }

        }
        return cpa;
    }
     catch (Exception e) 
     {
         
         return null;  
     }    
    }
    
    @AuraEnabled
    public static List<CartItem> updatecartItem(String expectedDeliveryDate,
                                                List<String> hdCartItems,
                                                String expectedpickupDeliveryDate,
                                                List<String> pickupcartItems,
                                                String shipType,
                                                List<String>shipcartItems,
                                                String shipFee,
                                                List<String> prodShippingList,
                                                String pickupLocation,List<String> sdsList) { 
                                                    BWC_Product_Service__c mdt=new BWC_Product_Service__c();
                                                    if(shipcartItems.size()>0)
                                                    {
                                              mdt=[SELECT Id, BWC_SKU__c,BWC_Service_Price__c , BWC_Cart_Id__c, BWC_Quantity__c, BWC_Member_Price__c, BWC_ZipCode__c, Product2Id__c, BWC_Order_Id__c, Cart_Item__c FROM BWC_Product_Service__c where Cart_Item__c=:shipcartItems[0]  LIMIT 1];

                                                    }
                                                    List<CartItem> CartItemList=new List<CartItem>();
                                            List<String> allids=new List<string>();
                                                    allids.addAll(hdCartItems);
                                                     allids.addAll(pickupcartItems);
                                                    allids.addAll(shipcartItems);
                                                     allids.addAll(prodShippingList);
                                                   List<CartItem> allitems= [SELECT Id,cart_Item_Id__c,cartId,Product2.stockKeepingUnit, BWC_Shipping_Method__c, BWC_Ship_Date__c,BWC_Original_Ship_Date__c,Product2.Is_Finished_Good__c,Product2.Is_Accessory__c,Product2.BWC_Is_Part__c FROM CartItem where ID IN:allids];
                                                        List<String> allSKUS=new List<string>();
                                                    for(CartItem item:allitems)
                                                    {
                                                        allSKUS.add(item.Product2.stockKeepingUnit);
                                                    }
                                                    Map<String,String> shipMethodMap=new Map<String,String>();
                                                    String accId=[select id, accountId from webcart where id=:allitems[0].cartId].accountId;
                                                     //  String accId=[Select id,BWC_Stripe_Customer_Id__c from account where id=:customerId].id;
        ContactpointAddress cpa=[SELECT Id,Name,AddressFirstName,AddressLastName ,BWC_Formatted_Address__c, Address, AddressType, Street, City, State, PostalCode, Country, IsDefault , ParentId FROM ContactPointAddress WHERE ParentId=:accId and AddressType='Shipping' and IsDefault=true limit 1];
        
                                            BWC_RateAPIController.ResponseWrapper shipmethods =BWC_RateAPIController.hitRateApi(allSKUS,cpa.PostalCode);
                                                    for(BWC_RateAPIController.ItemWrapper item :shipmethods.items)
                                                    {
                                                        List<BWC_RateAPIController.ValueWrapper> values=item.values;
                                                        if(values.size()==1)
                                                        {
                                                           shipMethodMap.put(item.item,values[0].shippingMethod); 
                                                        }
                                                        else
                                                        {
                                                            for(BWC_RateAPIController.ValueWrapper val:values)
                                                            {
                                                                if(mdt.BWC_Service_Price__c  ==Decimal.valueOf(val.shippingRate))
                                                        {
                                                            shipMethodMap.put(item.item,val.shippingMethod); 
                                                            
                                                        }
                                                        
                                                        
                                                            }
                                                               
                                                         
                                                        }
                                                        
                                                    }
                                                    //Hd List shipping method
                                                    for(CartItem ct:[SELECT Id,cart_Item_Id__c,Product2.stockKeepingUnit, BWC_Shipping_Method__c, BWC_Ship_Date__c,BWC_Original_Ship_Date__c,Product2.Is_Finished_Good__c,Product2.Is_Accessory__c,Product2.BWC_Is_Part__c FROM CartItem where ID IN:hdCartItems ])
                                                    {
                                                        if(!expectedDeliveryDate.contains('NaN'))
                                                        {
                                                             ct.BWC_Original_Ship_Date__c=expectedDeliveryDate; 
                                                        }
                                                      
                                                        ct.cart_Item_Id__c=ct.Id;
                                                        ct.BWC_Shipping_Method__c=shipMethodMap.get(ct.Product2.stockKeepingUnit);
                                                   /*     if(sdsList.size()>0)
                                                        {
                                                            if(ct.Product2.Is_Finished_Good__c=='Yes')
                                                            {
                                                                ct.BWC_Shipping_Method__c='SDS Delivery';
                                                            }
                                                        }
                                                        else
                                                        {
                                                            ct.BWC_Shipping_Method__c='Home Delivery';
                                                        }
                                                        */
                                                        
                                                        CartItemList.add(ct);
                                                    }
                                                    //SDS List shipping method
                                                    for(CartItem ct:[SELECT Id, cart_Item_Id__c,Product2.stockKeepingUnit,BWC_Shipping_Method__c, BWC_Ship_Date__c,BWC_Original_Ship_Date__c FROM CartItem where ID IN:sdsList ])
                                                    {
                                                        ct.cart_Item_Id__c=ct.Id;
                                                        
                                                         ct.BWC_Shipping_Method__c=shipMethodMap.get(ct.Product2.stockKeepingUnit);
                                                        
                                                        
                                                        CartItemList.add(ct);
                                                    }
                                                    //Will call List shipping method
                                                    for(CartItem ct:[SELECT Id,cart_Item_Id__c,Product2.stockKeepingUnit, BWC_Shipping_Method__c, BWC_Ship_Date__c,BWC_Original_Ship_Date__c,BWC_Pickup_Location__c FROM CartItem where ID IN:pickupcartItems ])
                                                    {
                                                        ct.cart_Item_Id__c=ct.Id;
                                                       
                                                          if(!expectedpickupDeliveryDate.contains('NaN'))
                                                        {
                                                             ct.BWC_Original_Ship_Date__c=expectedpickupDeliveryDate; 
                                                        }
                                                           ct.BWC_Shipping_Method__c=shipMethodMap.get(ct.Product2.stockKeepingUnit);

                                                        ct.BWC_Pickup_Location__c=pickupLocation;
                                                        CartItemList.add(ct);
                                                    }
                                                    //sps fee  List shipping method
                                                    for(CartItem ct:[SELECT Id,cart_Item_Id__c,Product2.stockKeepingUnit, BWC_Shipping_Method__c, BWC_Ship_Date__c,BWC_Original_Ship_Date__c FROM CartItem where ID IN:shipcartItems ])
                                                    {
                                                        ct.cart_Item_Id__c=ct.Id;
                                                        ct.BWC_Shipping_Method__c=shipMethodMap.get(ct.Product2.stockKeepingUnit);

                                                       
                                                        CartItemList.add(ct);
                                                    }
                                                    
                                                    //sps   List shipping method
                                                    for(CartItem ct:[SELECT Id,cart_Item_Id__c,product2.stockKeepingUnit, BWC_Shipping_Method__c, BWC_Ship_Date__c,BWC_Original_Ship_Date__c,Product2.Is_Finished_Good__c,Product2.Is_Accessory__c,Product2.BWC_Is_Part__c FROM CartItem where ID IN:prodShippingList ])
                                                    {
                                                        ct.cart_Item_Id__c=ct.Id;
                                                       ct.BWC_Shipping_Method__c=shipMethodMap.get(ct.Product2.stockKeepingUnit);

                                                        
                                                        CartItemList.add(ct);
                                                    }
                                                    
                                                    if(CartItemList.size()>0)
                                                    {
                                                        update CartItemList;
                                                    }
                                                    return CartItemList;
                                                    
                                                }
    
    
    
   	// For getting user contact point deatils
    @AuraEnabled(cacheable=false)
    public static Contact_Point__c getContactPointByContactId(String ContactId) {
        Boolean MyaIncluded = true;
        Boolean MyaDeleted = false;
       Contact_Point__c Res = [SELECT Id, Contact__c, ContactType__c, Phone__c, Email__c, MYAISPrimary__c  FROM Contact_Point__c WHERE Contact__c=:ContactId AND MYA_Included__c=:MyaIncluded AND MYA_IsDeleted__c=:MyaDeleted and MYAISPrimary__c=true ORDER BY CreatedDate LIMIT 1];
        return Res;
    } 
    
       // For Saving new contact
    @AuraEnabled(cacheable=false)
    public static Contact_Point__c createContact(String contactId, String phone, Boolean isPrimary ) {  
        Boolean myaIncluded = true;
        Boolean myaDeleted = true;
        Contact_Point__c response = new Contact_Point__c();        
        if(isPrimary == true) {
       		List<Contact_Point__c> cp = MYA_UserDetailsController.setPrimaryOnCreate(contactId);
        }
        List<Contact_Point__c> res = [SELECT Id, Contact__c, MYA_IsDeleted__c, MYAISPrimary__c FROM Contact_Point__c WHERE Phone__c=:phone AND Contact__c=:contactId AND MYA_Included__c=:myaIncluded AND MYA_IsDeleted__c=:myaDeleted];
        if (res.size() > 0) {
            Contact_Point__c con = res[0];
            con.MYA_IsDeleted__c = false;
            con.MYAISPrimary__c = isPrimary;
            update con;
            response = con;
        } else {
         	Contact_Point__c contact = new Contact_Point__c();
            contact.Contact__c = contactId;
            contact.Phone__c = phone;
            contact.MYA_Included__c = true;
            contact.MYAISPrimary__c = isPrimary;
            contact.DataSourceCode__c='Bodewell Commerce';
            contact.datasourcename__c='Bodewell Commerce';
            
            insert contact;
            response = contact;
        }
        return response;
    }  
}