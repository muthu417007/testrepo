public without sharing class SearchInVFController {
    public list <User> usr {get;set;}
   // public list <User> usr4 {get;set;}
    public String searchKey {get;set;}
    public String searchKey4 {get;set;}
    public Integer countTotalRecords{get;set;}
    public SearchInVFController( ) {
        usr = new list<user>();
        countTotalRecords = [SELECT count() FROM user];
        system.debug('@@@@@users '+countTotalRecords);
    }
    public void searchUser(){
        if( (searchKey != null && searchKey!='')){string searchquery='SELECT FirstName,LastName,Name,Email,FederationIdentifier,IsActive,ProfileId,SSO_ID__c,Username, Profile.UserLicense.Name FROM User where Email like  \'%' + String.escapeSingleQuotes(searchKey) + '%\'  and Name like  \'%' + String.escapeSingleQuotes(searchKey4) + '%\' LIMIT 999'; usr= Database.query(searchquery);
            system.debug('@@@@@@@@@usrlst'+ usr);
        }
      else if(searchKey4!= null && searchKey4!=''){ string searchquery='SELECT FirstName,LastName,Name,Email,FederationIdentifier,IsActive,ProfileId,SSO_ID__c,Username, Profile.UserLicense.Name FROM User where  Name like  \'%' + String.escapeSingleQuotes(searchKey4) + '%\'  LIMIT 999'; usr= Database.query(searchquery);
            system.debug('@@@@@@@@@usrlst'+ usr);
        }
    }
        
      public void clear() {
          if(usr.size()>0)  { usr.clear();    }
          
       //else if(usr4.size()>0)
       // { usr4.clear(); }
      //  if((usr.size()>0)){ usr.clear(); }
           //  PageReference srcPage = ApexPages.currentPage();
       // srcPage.setRedirect(false);
       // return srcPage;
      } 
}