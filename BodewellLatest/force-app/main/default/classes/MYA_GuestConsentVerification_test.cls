/**
*@description - Test Class for class MYA_GuestConsentVerification
Name: Baishali Das
Copyright: @ 2022 GE Appliances
**********************************************
Req: 
EPIC: IDMSF-962
**********************************************
Purpose: For storing consent information
**********************************************
History
---------------------------------------------
Version    Author    Date    Details
-------    -------    -------    -------
1.0      Baishali Das 28/07/2022   Created
**********************************************
**********************************************/

@isTest 
public class MYA_GuestConsentVerification_test {

@isTest
    static void mya_CreateUser_test()
    { 
    
    PS_WebServiceUserInfoHelper userInfoHelper = new PS_WebServiceUserInfoHelper(); 
     PS_WebServiceUserInfoHelper.testAppName='test';
         
     Profile pr = [select Id from profile where name='System Administrator'];
     Profile p = [select Id from profile where name='Default Customer Login User'];
   //  User usr=[select Id,Name,ContactId from user where profileid=:p.Id Limit 1];
     
     MYA_GuestConsentVerification gc=new MYA_GuestConsentVerification();
     gc.getGuestUserVerification();
     
     
    
    
     User us=[select Id,Name,ContactId,FirstName,LastName,Username,MobilePhone,IsActive,
                            LanguageLocaleKey,ServerRegion__c,IsPortalEnabled,Email,
                            Contact.Global_Customer_Id__c,Customer_IdP_Session_Id__c,
                            Latitude,Longitude,Account.BillingStreet,Account.BillingCity,
                            Account.BillingState,Account.BillingPostalCode,Account.BillingCountry,
                            Is_User_Verified_Manual__c from user where profileid=:pr.Id Limit 1];
     
      System.assert(us!=null);   
     
    }
    }