public class BWC_PersonAccountService {
    
    private static Customer_IdP_Configuration__mdt siteConfig = PS_GEAIdPCustomerConfigHelper.getSiteConfiguration();
    private static Id acctRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
    public Account createPersonAccount(String FirstName, String LastName, String email, String GlobalId, String RegistrationSource, String socialProvider, PS_WebServiceUserInfoPasswordWrapper additionalInfo ){
        
        system.debug('@@@@ in createPersonAccount');
        
        //Check for existing person account
         List<Account> accounts = [
                SELECT Id, FirstName, LastName, PersonEmail, Global_Customer_Id__pc,CreatedDate
                FROM Account
                WHERE PersonEmail = :email and RecordTypeId=: acctRecordTypeId //Added recordtype condition for CC0E - 655 
        ];
        system.debug('@@@@ accounts list : ' +accounts);
        
        Account acc;
        if (!accounts.isEmpty()) {
            system.debug('@@@@ inside if ');
            List<account> updateaccountList = new List<account> (); 
            acc = accounts[0];
            //Override with new values
            if (String.isNotBlank(firstName)) {
                acc.FirstName = firstName;
            }
            if (String.isNotBlank(lastName)) {
                acc.LastName = lastName;
            }
            if (String.isNotBlank(additionalInfo.mobile)) {
                acc.PersonMobilePhone = additionalInfo.mobile;
            }
            update acc;
            //Start - newly logic added to update new global contact id - JIRA CCOE-605
            updateaccountList.add(acc);
            if (String.isBlank(acc.Global_Customer_Id__pc))
            {
                PS_ContactTriggerHandlerHelper psContactTriggerHandlerHelper = new PS_ContactTriggerHandlerHelper(true);
                globalId = psContactTriggerHandlerHelper.setGlobalIdForPersonContact(globalId); 
            }
            update updateaccountList;
            return acc;
        
        } else {
            
            system.debug('@@@@ inside else ');
            Contact contact = (Contact) JSON.deserialize(siteConfig.Registration_Contact_Defaults__c, Contact.class );
                                  
            Account personAccount = new Account();
            if (String.isBlank(FirstName)) {
                FirstName = contact.FirstName;
            }
            if (String.isBlank(lastName)) {
                LastName = contact.LastName;
            }
            personAccount.firstName = FirstName;
            personAccount.LastName = LastName;
            personAccount.Email__c = email;
            personAccount.PersonEmail = email;
            personAccount.Global_Customer_Id__pc = GlobalId;
            personAccount.Global_Customer_Id__c = GlobalId;
            personAccount.RecordTypeID = acctRecordTypeId;
            if (String.isNotBlank(RegistrationSource)) {
                personAccount.Registration_Source__pc = RegistrationSource;
            }
            if (String.isNotBlank(socialProvider)) {
                socialProvider = socialProvider.toLowerCase();
                Set<String> contactSocialProviders =
                    String.isBlank(personAccount.Social_Provider__pc)
                    ? new Set<String>()
                    : new Set<String>(personAccount.Social_Provider__pc?.split(';'));
                contactSocialProviders.add(socialProvider);
                personAccount.Social_Provider__pc = String.join(new List<String>(contactSocialProviders), ';');
            }
            if (additionalInfo != null && String.isNotBlank(additionalInfo.mobile)) {
                personAccount.Phone = additionalInfo.mobile;
            }
            personAccount.DataSourceCode__pc = contact.DataSourceCode__c;
            system.debug(' #### personAccount::: '+personAccount);
            insert personAccount;
            return personAccount;
                
       }
           
    }            
       
        
    public Account createPersonAccountWithWrapper(CX_ContactCreationWrapper wrapper) {
        Id acctRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account personAccountWrap = new Account();
        personAccountWrap.FirstName = wrapper.firstName;
        personAccountWrap.LastName = wrapper.lastName;
        personAccountWrap.Email__c = wrapper.email;
        personAccountWrap.PersonEmail = wrapper.email;
        personAccountWrap.Phone = wrapper.phone;
        personAccountWrap.RecordTypeID = acctRecordTypeId;
        insert personAccountWrap;
        system.debug('@@@@ in createPersonAccountWithWrapper');
        return personAccountWrap;
    }
}