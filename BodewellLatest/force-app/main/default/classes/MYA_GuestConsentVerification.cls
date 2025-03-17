/**
*@description
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
1.0      Baishali Das 16/06/2022   Created
**********************************************
**********************************************/


public with sharing class MYA_GuestConsentVerification {

@TestVisible private static final String GLOBAL_ID_PARAM = 'globalId';
@TestVisible private static final String EMAIL_PARAM = 'email';

  private static Customer_IdP_Configuration__mdt siteConfig =
            PS_GEAIdPCustomerConfigHelper.getSiteConfiguration();
         
  @AuraEnabled(Cacheable=false)       
  public void getGuestUserVerification(){  
  
          PS_WebServiceUserInfoHelper userInfoHelper = new PS_WebServiceUserInfoHelper(); 
          
          
       List<User> users = new List<User>();
       users = [SELECT FirstName,LastName,Username,MobilePhone,Name,IsActive,
                            LanguageLocaleKey,ServerRegion__c,IsPortalEnabled,Email,
                            Contact.Global_Customer_Id__c,Customer_IdP_Session_Id__c,
                            Latitude,Longitude,Account.BillingStreet,Account.BillingCity,
                            Account.BillingState,Account.BillingPostalCode,Account.BillingCountry,
                            Is_User_Verified_Manual__c,Account.dealer_id__C,CX_Profile_Name__c FROM User
                    WHERE id= :UserInfo.getUserId()
                    AND IsActive = TRUE
                    LIMIT 1
            ];
        User currentUser = users.get(0);      
       PS_WebServiceUserInfoExtWrapper userInfoExtWrapper =
                userInfoHelper.getUserInfoWrapper(
                        currentUser,
                        true,
                        true
                ); 
                              
                System.debug(LoggingLevel.WARN,'Test :' +userInfoExtWrapper);
                System.debug(LoggingLevel.WARN,'Test user :' +currentUser);
            
         PS_WebServiceUserInfoHelper.insertMissingAuthorizationFormConsents(currentUser,userInfoExtWrapper); 
         }        
   
   
}