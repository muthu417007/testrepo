public class PA_ODPATransformation {
    
    public static Id acctRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Location').getRecordTypeId();
    Public static Id personAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
    Public static Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
    Public Static String OriginalContactId;
    
    @InvocableMethod(label='Person Account Transformation')
    public static void transformPersonAccount(List<Id> UserId){
        
        List<Contact> listExistingContacts = new List<Contact>();
        List<Account> listNewBusinessAccounts = new List<Account>();
        //String OriginalContactId;
        
        system.debug('@@@@ JIT PA - UserId: ' +UserId);
        
        //Get details of the existing User and Contact
        List<User> listExistingUsers = [SELECT Id, Name, UserName, FirstName, LastName, Country, Street, LanguageLocaleKey, LocaleSidKey,
                                        			TimeZoneSidKey,EmailEncodingKey, ProfileId,  Email, FederationIdentifier, CommunityNickname, Alias, 
                                        			ContactId, IsActive, IsPortalEnabled, Contact.FirstName, Contact.LastName, Contact.OwnerId
                								FROM User
                									WHERE id = :UserId 
                                                        and IsPortalEnabled = true
                                   						and Contact.RecordTypeId=: contactRecordTypeId ];
        
       
        //Get details of the existing Contact
        for(User usr : listExistingUsers){
            Contact con = new Contact();
            con.Id = usr.ContactId;
            con.FirstName = usr.Contact.FirstName;
            con.LastName = usr.Contact.LastName;
            con.OwnerId = usr.Contact.OwnerId;
            OriginalContactId = usr.ContactId; 
            listExistingContacts.add(con);
        }
        
        User existingUserDetails = [SELECT Id, Name, UserName, FirstName, LastName, Country, Street, LanguageLocaleKey, LocaleSidKey,
                                        			TimeZoneSidKey,EmailEncodingKey, ProfileId,  Email, FederationIdentifier, CommunityNickname, Alias, 
                                        			ContactId, IsActive, IsPortalEnabled, Contact.FirstName, Contact.LastName, Contact.OwnerId
                								FROM User
                									WHERE id = :UserId 
                                                        and IsPortalEnabled = true
                                   						and Contact.RecordTypeId=: contactRecordTypeId ];
        
        
        
        //Use Contact details to create new Business Accounts
          listNewBusinessAccounts = createBusinessAccount(listExistingContacts);
		        
        //Disable the Existing Portal Users
          PA_DisablePortalUsers objDisablePortalUser = new PA_DisablePortalUsers(UserId[0]);
	      ID jobID1 = System.enqueueJob(objDisablePortalUser);
                        
        //Associate Existing Contacts to New Business Accounts
          associateContactWithBusinessAccount(listNewBusinessAccounts);
       
        //Convert the Business Accounts to Person Accounts
          PA_ConvertBAtoPA objConvertBAtoPA = new PA_ConvertBAtoPA(OriginalContactId, personAccRecordTypeId,existingUserDetails);
	      ID jobID2 = System.enqueueJob(objConvertBAtoPA);
        
        //Create New Portal Users
          //PA_CreatePortalUser objCreatePortalUser = new PA_CreatePortalUser(existingUserDetails);
	      //ID jobID3 = System.enqueueJob(objCreatePortalUser);
    }
    
    
    public static List<Account> createBusinessAccount(List<Contact> listExistingContacts){
        
        //Id acctRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Location').getRecordTypeId();
        List<Account> listNewAccounts = new List<Account>();
        
        for(Contact cont : listExistingContacts){
            Account acct = new Account();
    		acct.Name = cont.FirstName + ' ' + cont.LastName;
            //acct.BillingCountry = cont.Account.BillingCountry;
            //acct.Phone = cont.Phone;
            acct.PA_OriginalContactId__c = cont.Id;
            acct.OwnerId = cont.OwnerId;
            acct.RecordTypeId = acctRecordTypeId; 
         	listNewAccounts.add(acct);
	    }
	    insert listNewAccounts;
        system.debug('@@@@ JIT PA - listNewAccounts: ' +listNewAccounts);
        return listNewAccounts;
    }
    
    public static void associateContactWithBusinessAccount(List<Account> listNewBusinessAccounts){
        
        List<Contact> listAssociateContacts = new List<Contact>();
        
        for(Account acct : listNewBusinessAccounts){
            Contact cont = new Contact();
    		cont.Id = acct.PA_OriginalContactId__c;
            cont.AccountId = acct.Id;
           	listAssociateContacts.add(cont);
	    }
		update listAssociateContacts;
    }
    
    public static void disablePortalUser(Id UserId){
        
        system.debug('@@@@ JIT PA - inside DisableUser:Id: ' +UserId);
        
        List<User> listDisablePortalUsers = [select id, FirstName, FederationIdentifier, Email, Alias, CommunityNickname, IsPortalEnabled from User where id = :UserId];
		for(User usr : listDisablePortalUsers){
    		usr.FirstName = '_'+ usr.FirstName; 
            usr.FederationIdentifier = '_'+ usr.FederationIdentifier;
            usr.Email = '_'+ usr.Email;
            usr.Alias = '_'+ usr.Alias;
            usr.CommunityNickname = '_'+ usr.CommunityNickname;
           	//usr.IsPortalEnabled = false;
    	}
		update listDisablePortalUsers;
        
       // PA_ConvertBAtoPA objConvertBAtoPA = new PA_ConvertBAtoPA(OriginalContactId, personAccRecordTypeId);
	    //ID jobID = System.enqueueJob(objConvertBAtoPA);
    }
    
    
   /* public static void convertBAtoPA(List<Account> listNewBusinessAccounts, User existingUserDetails ){
        
        List<Account> listTransformBAtoPA =  [select id, RecordTypeId, IsCustomerPortal from Account where PA_OriginalContactId__c = :OriginalContactId];

		for(Account acc : listNewBusinessAccounts){
            Account personAccount = new Account();
    		personAccount.Id = acc.Id ;
            personAccount.RecordTypeId = personAccRecordTypeId;
            listBAtoPA.add(personAccount);
        }
		update listBAtoPA;
        
    }*/
    public static void convertBAtoPA(String OriginalContactId, ID personAccRecordTypeId, User existingUserDetails ){
        
        Account transformBAtoPA = new Account();
        
        Account objConvertBAtoPA = [select id, RecordTypeId, IsCustomerPortal from Account where PA_OriginalContactId__c = :OriginalContactId];
        if(objConvertBAtoPA.isCustomerPortal = true){
            objConvertBAtoPA.isCustomerPortal = false;
            system.debug('@@@@ JIT PA - isCustomerPortal: ' +objConvertBAtoPA.isCustomerPortal);
            update objConvertBAtoPA;
        }
        transformBAtoPA.Id = objConvertBAtoPA.Id;        
        transformBAtoPA.RecordTypeId = personAccRecordTypeId;
		update transformBAtoPA;
        
        //Create New Portal Users
        PA_CreatePortalUser objCreatePortalUser = new PA_CreatePortalUser(existingUserDetails);
	    ID jobID3 = System.enqueueJob(objCreatePortalUser);
    }
   
 
  
    
    public static void createNewPortalUser(User existingUserDetails){
        
            system.debug('@@@@ JIT PA - Inside createNewPortalUser: ' +existingUserDetails);
        
            User newUser = new User();
			newUser.FirstName = existingUserDetails.FirstName; 
            newUser.LastName = existingUserDetails.LastName;
            //newUser.Country = existingUserDetails.Country;
            //newUser.Street = existingUserDetails.Street;
            newUser.Username = existingUserDetails.Username;
            newUser.Email = existingUserDetails.Email;
            newUser.FederationIdentifier = existingUserDetails.FederationIdentifier;
            newUser.Alias = existingUserDetails.Alias;
            newUser.CommunityNickname = existingUserDetails.CommunityNickname;
            newUser.LanguageLocaleKey = existingUserDetails.LanguageLocaleKey;
            newUser.LocaleSidKey = existingUserDetails.LocaleSidKey;
        	newUser.EmailEncodingKey = existingUserDetails.EmailEncodingKey;
            newUser.TimeZoneSidKey = existingUserDetails.TimeZoneSidKey;
            newUser.ProfileId = existingUserDetails.ProfileId;
            newUser.ContactId = existingUserDetails.ContactId;
            newUser.IsActive = existingUserDetails.IsActive;
        	//newUser.IsPortalEnabled = true;

           insert newUser;
    }     
    

}