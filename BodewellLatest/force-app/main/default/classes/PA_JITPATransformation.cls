public class PA_JITPATransformation {
    
    Id acctRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Location').getRecordTypeId();
    Id personAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
    Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
    
    public void transformPersonAccount(Id UserId){
        
        List<Contact> listExistingContacts = new List<Contact>();
        List<Account> listNewBusinessAccounts = new List<Account>();
        String OriginalContactId;
        
        system.debug('@@@ JIT PA - UserId: ' +UserId);       
        //Get details of the existing User and Contact
        List<User> listExistingUsers = [SELECT Id, Name, UserName, FirstName, LastName, Country, Street, LanguageLocaleKey, LocaleSidKey,
                                        			TimeZoneSidKey, ProfileId,  Email, FederationIdentifier, CommunityNickname, Alias, 
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
        system.debug('@@@ JIT PA - listExistingContacts: ' +listExistingContacts);       
        //Use Contact details to create new Business Accounts
        listNewBusinessAccounts = createBusinessAccount(listExistingContacts);
		        
        //Disable the Existing Portal Users
        //disablePortalUser(listExistingUsers);
          disablePortalUser(UserId);
        
        //Associate Existing Contacts to New Business Accounts
         associateContactWithBusinessAccount(listNewBusinessAccounts);
        
        //Convert the Business Accounts to Person Accounts
        //convertBAtoPA(listNewBusinessAccounts);
        convertBAtoPA(OriginalContactId,personAccRecordTypeId);
        
        //Create New Portal Users
       // createNewPortalUser(listExistingUsers);
    }
    
    
    public List<Account> createBusinessAccount(List<Contact> listExistingContacts){
        
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
        system.debug('@@@ JIT PA - listNewAccounts: ' +listNewAccounts);
        return listNewAccounts;
        
    
    }
    
    public void associateContactWithBusinessAccount(List<Account> listNewBusinessAccounts){
        
        List<Contact> listAssociateContacts = new List<Contact>();
        
        for(Account acct : listNewBusinessAccounts){
            Contact cont = new Contact();
    		cont.Id = acct.PA_OriginalContactId__c;
            cont.AccountId = acct.Id;
           	listAssociateContacts.add(cont);
	    }
		update listAssociateContacts;
    }
    
    @future
    public static void disablePortalUser(Id UserId){
        
        List<User> listDisablePortalUsers = [select id, FirstName, FederationIdentifier, Email, Alias, CommunityNickname, IsPortalEnabled from User where id = :UserId];
		for(User usr : listDisablePortalUsers){
    		usr.FirstName = '_'+ usr.FirstName; 
            usr.FederationIdentifier = '_'+ usr.FederationIdentifier;
            usr.Email = '_'+ usr.Email;
            usr.Alias = '_'+ usr.Alias;
            usr.CommunityNickname = '_'+ usr.CommunityNickname;
           	usr.IsPortalEnabled = false;
    	}
		update listDisablePortalUsers;
    }
    
    @future
    public static void convertBAtoPA(String OriginalContactId, String personAccRecordTypeId){
        
        Account objConvertBAtoPA = [select id,RecordTypeId, PA_OriginalContactId__c from Account where PA_OriginalContactId__c = :OriginalContactId];
        objConvertBAtoPA.RecordTypeId = personAccRecordTypeId;
		update objConvertBAtoPA;
    }
   
    public void disablePortalUser(List<User> listExistingUsers){
        
        List<User> listDisablePortalUsers = new List<User>();
       
        for(User usr : listExistingUsers){
            User disableUser = new User();
            disableUser.Id = usr.Id;
			disableUser.FirstName = '_'+ usr.FirstName;            
            disableUser.FederationIdentifier = '_'+ usr.FederationIdentifier;
            disableUser.Email = '_'+ usr.Email;
            disableUser.Alias = '_'+ usr.Alias;
            disableUser.CommunityNickname = '_'+ usr.CommunityNickname;
           	disableUser.IsPortalEnabled = false;
            listDisablePortalUsers.add(disableUser);
        }  
        update listDisablePortalUsers;
    }
    
    public void convertBAtoPA(List<Account> listNewBusinessAccounts ){
        
        List<Account> listBAtoPA = new List<Account>();

		for(Account acc : listNewBusinessAccounts){
            Account personAccount = new Account();
    		personAccount.Id = acc.Id ;
            personAccount.RecordTypeId = personAccRecordTypeId;
            listBAtoPA.add(personAccount);
        }
		update listBAtoPA;
    }
    
    
    public void createNewPortalUser(List<User> listExistingUsers){
        
        List<User> listNewPortalUsers = new List<User>();
       
        for(User usr : listExistingUsers){
            User newUser = new User();
			newUser.FirstName = usr.FirstName; 
            newUser.LastName = usr.LastName;
            //newUser.Country = usr.Country;
            //newUser.Street = usr.Street;
            newUser.Username = usr.Username;
            newUser.Email = usr.Email;
            newUser.FederationIdentifier = usr.FederationIdentifier;
            newUser.Alias = usr.Alias;
            newUser.CommunityNickname = usr.CommunityNickname;
            newUser.LanguageLocaleKey = usr.LanguageLocaleKey;
            newUser.LocaleSidKey = usr.LocaleSidKey;
            newUser.TimeZoneSidKey = usr.TimeZoneSidKey;
            newUser.ProfileId = usr.ProfileId;
            newUser.ContactId = usr.ContactId;
            newUser.IsActive = usr.IsActive;
        	//newUser.IsPortalEnabled = true;

            listNewPortalUsers.add(newUser);
        }  
        insert listNewPortalUsers;
    }     
    

}