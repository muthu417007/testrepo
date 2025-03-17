public without sharing class SearchController {
    /*
    @AuraEnabled(cacheable=false)
    public static List<Contact> getContacts(String fName,String lName, String iEmail, String iPhone, String iStreet, String iZip){
      /
        List<contact> returnContacts = [select id,name,accountId,phone 
            from contact 
            where firstName =: fName 
            or email =: iEmail
            or phone =: iphone
            or (mailingstreet =: iStreet and mailingPostalCode =: iZip )
            limit 25]; 
      /  
        
        String qryString = 'SELECT  id,name,accountId,phone,email,mailingStreet,mailingPostalCode FROM Contact WHERE ID != NULL  ';
        if(fName != null && fName != '' ){
            qryString += 'AND firstName =:  fName ';    
        }
        if(lName != null && lName != ''){
            qryString += 'AND lastName =: lName ';    
        }
        if(iEmail != null && iEmail != ''){
            qryString += 'AND email =: iEmail ';    
        }
        if(iPhone != null && iPhone != ''){
            qryString += 'AND phone =: iPhone ';    
        }
        if(iStreet != null && iStreet != '' && iZip != null && iZip != ''){
            qryString += 'AND mailingstreet =: iStreet AND mailingPostalCode =: iZip ';    
        }
        qryString += ' ORDER BY lastName LIMIT 100 ';
        system.debug(qryString);
        system.debug(iStreet + ' ' + iZip);
        List<contact> returnContacts = Database.query(qryString);
        
        if(iStreet != null && iStreet != '' && iZip != null && iZip != ''){
            
           List<Account> sls = [SELECT id from account 
                                             WHERE Zip_Search__c =: iZip
                                             AND Street_Search__c = : iStreet];
            
            
            Set<ID> accountIds = new Set<ID>();
            for(Account s:sls){
                accountIds.add(s.id);
            }
            List<contact> locationContacts = [SELECT  id,name,accountId,phone,email,mailingStreet,mailingPostalCode 
                                              FROM Contact 
                                              WHERE accountID in: accountIds];
            for(contact c:locationContacts){
                returnContacts.add(c);  
            }
        }
        
        //List<contact> returnContacts = [select id,name,accountId from contact  limit 3]; 
        return  returnContacts;

    }
    
   // @AuraEnabled(cacheable=false)
   // public static List<DA_Contact__b> getArchivedContacts(String fName,String lName){
  //    String searchName = fName + ' ' +  lName;
  //    List<DA_Contact__b> returnContacts = [select id,S_Name__c,S_Name_Indexed__c,S_Phone_Indexed__c,S_Id_Indexed__c,s_phone__C,s_email__c
  //              from DA_Contact__b 
  //              where S_Name_Indexed__c =: searchName limit 50]; 
      
  //    return  returnContacts;
  //  }
    
   // @AuraEnabled(cacheable=false)
   // public static List<String> restoreContact(String index1,String index2, String index3){
      //Map<string,string> testrun = ceparc.DataArchivaDetailComponentController.unarchive('S_Name_Indexed__c = \'test archive\' and S_HomePhone_Indexed__c  = null and S_Id_Indexed__c = \'0036c00000ajgsuqar\'', 'Contact');
 
   //   String restoreString = 'S_Name_Indexed__c = \'' + index1 + '\' and S_Phone_Indexed__c  = \'' + index2 + '\' and S_Id_Indexed__c = \'' + index3 + '\'';
      
    //  System.debug('restoreString ' +restoreString );
   //   Map<string,string> restoreResult = ceparc.DataArchivaDetailComponentController.unarchive(restoreString, 'Contact');
      
   //   System.debug('restoreResult ' +restoreResult );
      // restore response   {SUCCESS=0036C00000AlCpRQAV}
      //{INFO=Schema sync submitted successfully! Please try again after some time.
      
       
        
    //  List<String> responseString = new List<String>();
      
   //   List<Contact> contactRec = [SELECT ID,ACCOUNTID FROM CONTACT WHERE ID =: restoreResult.get('SUCCESS')];
   //   IF(contactRec.size() != 0){
   //       responseString.add(contactRec[0].id);
   //       responseString.add(contactRec[0].accountId);
          //restore accountContactRelation
         //  ID contactID = index3.mid(0,15);
         //  createAccountContactRelation(contactID);
            
  //    }
  //      responseString.add(JSON.serialize(restoreResult));
  //      system.debug('responseString ' + responseString);
  //    return  responseString;
  //  }
    /*
    @future
    public static void createAccountContactRelation(String contactId){
        List<DA_AccountContactRelation__b> acr = [SELECT S_AccountId__c , S_ContactId_Indexed__c 
                                                     FROM DA_AccountContactRelation__b
                                                     WHERE S_ContactId_Indexed__c = :contactID];
        
          
            List<DA_AccountContactRelation__b> delacr = [SELECT S_ContactId_Indexed__c ,S_Id_Indexed__c
                                                      FROM DA_AccountContactRelation__b
                                                      WHERE S_ContactId_Indexed__c = :contactID];
        List<AccountContactRelation> insertRecs = new List<AccountContactRelation>();
            for(DA_AccountContactRelation__b a:acr){
               AccountContactRelation newRec = new AccountContactRelation();
                newRec.accountId = a.S_AccountId__c;
                newRec.ContactId = contactID; 
                insertRecs.add(newRec);
                //createAccountContactRelation(a.S_AccountId__c,contactID);
            }
            //try{
                //insert insertRecs;
               // Database.deleteImmediate(delacr);
   
            //}
            //catch (exception e){
                
            //}
        
        //AccountContactRelation newRec = new AccountContactRelation();
       // newRec.accountId = accountID;
        //newRec.ContactId = contactId; 
        //insert newRec;    
    }
    /
    @AuraEnabled(cacheable=false)
    public static List<String> createContact(String fName,String lName, String iEmail, String iPhone,
                                             String iStreet, String iZip,Boolean createCase){
        List<String> returnIds = new List<String>();
        // find/create household
        // TODO look at service locations to find household
        //List<Service_Location__c> sl = [SELECT ID,Account__c FROM Service_Location__c
        //                               WHERE Zip_Code__c =: iZip
        //                               AND AddressLine1__c = : iStreet];
        //List<Account> households = new List<Account>();
        //If(sl.size() == 1){
        //    households = [SELECT ID
         //                 FROM Account
         //                 WHERE id =: sl[0].Account__c];
                                                     
        //} else {
         //   households = [SELECT ID
          //             FROM Account
         //              WHERE phone =: iPhone 
         //              AND phone != null
         //             ];
        //}
        ///if(households.size() != 1){
         //   Account newHousehold = new Account();
         //   newHouseHold.name = lName + ' Household';
         //   insert newHouseHold;
         //   households.add(newHouseHold);
        //}
        
        //Contact newContact = new Contact();
        //newContact.firstName = fName;
        //newContact.LastName = lName;
        //newContact.accountID = households[0].id;
        //newContact.email = iEmail;
        //newContact.phone = iPhone;
        //newContact.MailingStreet = iStreet;
        //newContact.MailingPostalCode = iZip;
        //newContact.MailingState = 'KY';
        //newContact.MailingCity = 'Louisville';
        // try{
        //    insert newContact;
        //}catch(exception e){
        //    throw new AuraHandledException('Error creating contact: '
        //    + e.getMessage()); 
        //}
                                                
                                                
                
        // create account
        
        
        //if(sl.size() == 0){
        //    Service_Location__c newSl = new Service_Location__c();
         //   newSl.AddressLine1__c =  iStreet;
         //   newSl.Zip_Code__c = iZip;
         //   newSl.Account__c = households[0].id;
         //   newSl.state__c = 'KY';
         //   newSl.city__c = 'Louisville';
         //   insert newSl;
            
        //} else {
        //    sl[0].Account__c = households[0].id; 
         //   update sl[0];
        //}
        //update service location account lookup
      
        //create case if set
                                   
    
    // find/create service location
    // find/create asset
      //  returnIds.add(newContact.id);
     //   returnIds.add(households[0].id);
     //   if(createCase){
      //      Case newCase = new Case();
      //      newCase.contactId = newContact.id;
      //      insert newCase;
      //      returnIds.add(newCase.id);
      //  }  
      //  system.debug(returnIds);
       // return returnIds; 
       return null;   
    }
    
*/
}