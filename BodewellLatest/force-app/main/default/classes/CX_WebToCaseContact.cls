/**
 * @author         Gabriel Alves
 * @company        PolSource
 * @created        08.06.2021
 * @description    Class used to organize the Case trigger using the Trigger Handler pattern
 */
public with sharing class CX_WebToCaseContact {
    public CX_WebToCaseContact() {}

    // public void updateWebCase (List<Case> newCases) {
    //     List<String> emailAddresses = new List<String>();
    //     List<String> firstname = new List<String>();
    //     List<String> lastname = new List<String>();
    //     List<String> webToCaseOriginList = new List<String>();
    //     Set<Id> caseId = new Set<Id>();
    //     String CONTACTID,checkcase,ACCOUNTID,street,city,zip,state,country,AccName,searchKey,contfound,accfound,phone,statecode,casenum;
    //     Map<String,Contact> emailToContactMap = new Map<String,Contact>();
    //     for(WebToCaseOrigin__mdt wco: [SELECT DeveloperName FROM WebToCaseOrigin__mdt]) {              
    //         webToCaseOriginList.add(wco.DeveloperName);              
    //     }
    //     for(Case c : newCases) {
    //         if(c.Origin=='WebToCase' && c.Web_To_Case_Origin__c!=null) {
    //             String caseorigin=c.Web_To_Case_Origin__c;
    //             caseorigin=caseorigin.replace('.com','');
    //             System.debug('caseorigin=' + caseorigin);            
    //             if(c.ContactId==null && webToCaseOriginList.contains(caseorigin) ) {
    //                 caseId.add(c.Id);
    //                 emailAddresses.add(c.SuppliedEmail);
    //                 firstname.add(c.First_Name__c);
    //                 lastname.add(c.Last_Name__c);
    //                 if(c.Phone_Number__c!=NULL) {
    //                     phone=(c.Phone_Number__c).trim();
    //                     phone=phone.replace('(','');
    //                     phone=phone.replace(')','');
    //                     phone=phone.replace('-','');
    //                     phone=phone.replace(' ','');
    //                 }
    //                 casenum=c.caseNumber;            
    //                 checkcase='true';
    //                 city=c.City__c;
    //                 if(c.State__c!=null){                   
    //                     state=c.State__c;
    //                     System.debug('state1=' + state);
    //                     state=state.replace(' ','');
    //                     System.debug('state2=' + state);
    //                 }                
    //                 zip=c.Zip_Postal_Code__c;
    //                 country=c.Country__c ;
    //                 street=c.Street_Address__c;                
    //             }
    //         }
    //     }
    //     if(checkcase=='true') {
    //         List<StateCodeMap__mdt> lstMetaData= new List<StateCodeMap__mdt>();
    //         lstMetaData = [SELECT Code__c FROM StateCodeMap__mdt where DeveloperName=:state];
    //         if(lstMetaData.size()==1) {
    //             state=lstMetaData[0].Code__c;
    //             System.debug('state3=' + state);
    //         }
    //         List<Contact> listContactsemailphone = [Select Id,AccountId,Phone,Email,MailingStreet,MailingCity,MailingState, MailingPostalCode 
    //                                                 From Contact Where FirstName in: firstname AND 
    //                                                 LastName in: lastname AND Email in :emailAddresses AND 
    //                                                 (Phone =:phone and Phone<>NULL) ORDER BY CreatedDate DESC];
    //         System.debug('listContactsemailphone=' + listContactsemailphone);
    //         List<Contact> listContactsemail = [Select Id,AccountId,Phone,Email,MailingStreet,MailingCity,MailingState, MailingPostalCode
    //                                            From Contact Where FirstName in: firstname AND LastName in: lastname AND 
    //                                            Email in :emailAddresses ORDER BY CreatedDate DESC];
    //         System.debug('listContactsemail=' + listContactsemail);
    //         if(street!=NULL) {
    //             AccName= street + ' ' + city+ ' ' + state + ' ' + zip;
    //             System.debug('AccName=' + AccName);
    //         } 
    //         List<Account> listAccount = [Select Id,BillingStreet,BillingCity,BillingState,BillingPostalCode from Account where name=:AccName];
    //         System.debug('listAccount=' + listAccount);
    //         if(phone!=null && listContactsemailphone.size()>=1){ 
    //             {
    //                 if(street==null) {
    //                     CONTACTID=listContactsemailphone[0].Id;
    //                     ACCOUNTID=listContactsemailphone[0].AccountId;
    //                 } else{
    //                     System.debug('street '+street);
    //                     System.debug('city'+city);
    //                     for(Contact cc: listContactsemailphone){
    //                         if(cc.MailingStreet==street && cc.MailingCity==city &&cc.MailingState==state && cc.MailingPostalCode==zip){
    //                             CONTACTID=cc.Id;
    //                             ACCOUNTID=cc.AccountId;
    //                             contfound='false';
    //                         }
    //                     }
    //                     if(contfound!='false'){
    //                         System.debug('=Contact found but street not matching');
    //                         Account acc= new Account();
    //                         if(listAccount.size()==0){
    //                             acc.name = AccName;
    //                             acc.BillingStreet = street;
    //                             acc.BillingCity = city;
    //                             acc.BillingState = state;
    //                             acc.BillingPostalCode = zip;               
    //                             insert acc;
    //                             ACCOUNTID=acc.Id;
    //                             System.debug('Creating New contact and account with form details');
    //                         }else{
    //                             for(Account a: listAccount){
    //                                 if(a.BillingStreet==street && a.BillingCity==city && a.BillingState==state && a.BillingPostalCode==zip){
    //                                     ACCOUNTID=a.Id;
    //                                     accfound='true';
    //                                 }
    //                             }
    //                             if(accfound!='true'){
    //                                 acc.name = AccName;
    //                                 acc.BillingStreet = street;
    //                                 acc.BillingCity = city;
    //                                 acc.BillingState = state;
    //                                 acc.BillingPostalCode = zip;
    //                                 insert acc;
    //                                 ACCOUNTID=acc.Id;
    //                             }
    //                         }
    //                         System.debug('Creating New contact');
    //                         Contact cont = new Contact(FirstName= firstname[0],AccountId=ACCOUNTID,
    //                                                    LastName=lastname[0],
    //                                                    Email=emailAddresses[0],
    //                                                    Phone=phone,MailingCity=city,MailingState=state,
    //                                                    MailingPostalCode=zip,MailingCountry=country,MailingStreet=street);
    //                         insert cont;
    //                         System.debug('cont=' + cont);
    //                         CONTACTID=cont.Id;
    //                         System.debug('CONTACTID=' + CONTACTID);
    //                     }
    //                 }
    //             }   
    //         } else if(listContactsemail.size()>=1){
    //             System.debug('else if 1 loop');
    //             if(phone==null && street==null) {
    //                 CONTACTID=listContactsemail[0].Id;
    //                 ACCOUNTID=listContactsemail[0].AccountId;
    //             } else if(phone==null && street!=null){
    //                 for(Contact cc: listContactsemail) {
    //                     if(cc.MailingStreet==street && cc.MailingCity==city) {
    //                         CONTACTID=cc.Id;
    //                         ACCOUNTID=cc.AccountId;
    //                         contfound='true';
    //                     }
    //                 }
    //                 if(contfound!='true') {
    //                     System.debug('=Contact found but street not matching');
    //                     Account acc= new Account();
    //                     if(listAccount.size()==0) {                
    //                         acc.name = AccName;
    //                         acc.BillingStreet = street;
    //                         acc.BillingCity = city;
    //                         acc.BillingState = state;
    //                         acc.BillingPostalCode = zip;
    //                         insert acc;
    //                         ACCOUNTID=acc.Id;
    //                         System.debug('Creating New contact and account with form details');
    //                     } else {
    //                         for(Account a: listAccount) {
    //                             if(a.BillingStreet==street && a.BillingCity==city &&a.BillingState==state&&a.BillingPostalCode==zip) {
    //                                 ACCOUNTID=a.Id;
    //                                 accfound='true';
    //                             }
    //                         }
    //                         if(accfound!='true') {
    //                             acc.name = AccName;
    //                             acc.BillingStreet = street;
    //                             acc.BillingCity = city;
    //                             acc.BillingState = state;
    //                             acc.BillingPostalCode = zip;
    //                             insert acc;
    //                             ACCOUNTID=acc.Id;
    //                         }
    //                     }
    //                     System.debug('Creating New contact');
    //                     Contact cont = new Contact(FirstName= firstname[0],AccountId=ACCOUNTID,
    //                                                LastName=lastname[0],
    //                                                Email=emailAddresses[0],
    //                                                Phone=phone,MailingCity=city,MailingState=state,MailingPostalCode=zip,MailingCountry=country,MailingStreet=street);
    //                     insert cont;
    //                     System.debug('cont=' + cont);
    //                     CONTACTID=cont.Id;
    //                     System.debug('CONTACTID=' + CONTACTID);
    //                 }
    //             }
    //         } else  {
    //             //No match create contact
    //             System.debug('else loop');
    //             Account acc= new Account();
    //             if(listAccount.size()==0) {
    //                 System.debug('No Account Found');
    //                 if(street==NULL) {            
    //                     acc.name = 'NoAddress City ST 00000';
    //                     acc.BillingStreet = 'NoAddress';
    //                     acc.BillingCity = 'City';
    //                     acc.BillingState = 'ST';
    //                     acc.BillingPostalCode = '00000';
    //                     insert acc;
    //                     ACCOUNTID=acc.Id;
    //                     System.debug('Creating New contact and empty account');
    //                 } else{               
    //                     acc.name = AccName;
    //                     acc.BillingStreet = street;
    //                     acc.BillingCity = city;
    //                     acc.BillingState = state;
    //                     acc.BillingPostalCode = zip;
    //                     insert acc;
    //                     ACCOUNTID=acc.Id;
    //                     System.debug('Creating New contact and account with form details');
    //                 }
    //             } else {
    //                 System.debug('Account Found');
    //                 acc.Id=listAccount[0].Id;
    //                 ACCOUNTID=listAccount[0].Id;
    //             }
    //             System.debug('Creating New contact');
    //             Contact cont = new Contact(FirstName= firstname[0],AccountId=ACCOUNTID,
    //                                        LastName=lastname[0],
    //                                        Email=emailAddresses[0],
    //                                        Phone=phone,MailingCity=city,MailingState=state,MailingPostalCode=zip,
    //                                        MailingCountry=country,MailingStreet=street);
    //             insert cont;
    //             System.debug('cont=' + cont);
    //             CONTACTID=cont.Id;
    //             System.debug('CONTACTID=' + CONTACTID);
    //         }
    //         List<Case> cases = [SELECT Id From Case where Id IN :caseId];
    //         List<Case> caseUpdateList = new List<Case>();
    //         for(Case c: cases) {               
    //             c.ContactId=CONTACTID; 
    //             c.AccountId=ACCOUNTID;
    //             caseUpdateList.add(c);
    //         }
    //         System.debug('Updating case with contactID');
    //         update caseUpdateList;
    //         System.debug('CaseID' +caseId);
    //         System.debug('casenum' +casenum);
    //     }     
    // }
}