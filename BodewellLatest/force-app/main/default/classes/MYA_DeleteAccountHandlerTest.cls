/**
 * @author         Akhil Raj
 * @company        TCS
 * @created        22.09.2022
 * @description    For user deactivation method test
 */
@isTest
public class MYA_DeleteAccountHandlerTest {
    //First test method
    public static testMethod void testDeleteUser1(){
        Account acc= new Account(Name= 'Test Account');
        insert acc;
        
        Account a=new Account();
          a.Name='testName';
          a.BillingStreet='test street';
          a.BillingCity='test City';
          a.BillingState='OH';
          a.BillingPostalCode='12345';
          a.Country_Code__c='United States Of America';   
         
     	insert a;
        
     	Account a1=new Account();
          a1.Name='Test STREET1 Test City1 AK 33333';
          a1.BillingStreet='test street1';
          a1.BillingCity='test City1';
          a1.BillingState='AK';
          a1.BillingPostalCode='33333';
          a1.Country_Code__c='United States Of America';   
     
       	insert a1;
        
        Profile p = [select Id from profile where name='Default Customer Login User'];
        Contact cont = new Contact(LastName ='testCon',
                                   Email='standarduser@testorg.com',
                                   AccountId = acc.Id, Global_Customer_Id__c= '123456-1234-123');
        insert cont;
         // Create a unique UserName
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';        
        User u1 = new User(
            Alias = 'standt',
            Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName=uniqueUserName,
            ContactId=cont.Id);
        insert u1;   
        
     	GEA_AccountContactRelation__c contactLoc=new GEA_AccountContactRelation__c();
           contactLoc.Name='testName';  
           contactLoc.Account__c=a.Id;
           contactLoc.Contact__c=u1.ContactId;
           contactLoc.MYA_Included__c=true;
           contactLoc.Nick_Name__c='testName';
           insert contactLoc; 
        
     	GEA_AccountContactRelation__c contactLoc1=new GEA_AccountContactRelation__c();
           contactLoc1.Name='testName1';  
           contactLoc1.Account__c=a1.Id;
           contactLoc1.Contact__c=u1.ContactId;
           contactLoc1.MYA_Included__c=true;
           contactLoc1.Nick_Name__c='testName';
           insert contactLoc1;
      
        Test.startTest();
        System.runAs(u1) {
        	MYA_DeleteAccountHandler.deactivate();
        }
        Test.stopTest();
    }
     //Second test method
    public static testMethod void testDeleteUser2(){
        Account acc= new Account(Name= 'Test Account');
        insert acc;
        
        Account a=new Account();
          a.Name='testName';
          a.BillingStreet='test street';
          a.BillingCity='test City';
          a.BillingState='OH';
          a.BillingPostalCode='12345';
          a.Country_Code__c='United States Of America';   
         
     	insert a;
        
     	Account a1=new Account();
          a1.Name='Test STREET1 Test City1 AK 33333';
          a1.BillingStreet='test street1';
          a1.BillingCity='test City1';
          a1.BillingState='AK';
          a1.BillingPostalCode='33333';
          a1.Country_Code__c='United States Of America';   
     
       	insert a1;
        
        Profile p = [select Id from profile where name='Default Customer Login User'];
        Contact cont = new Contact(LastName ='testCon',
                                   Email='standarduser@testorg.com',
                                   AccountId = acc.Id, Global_Customer_Id__c= '123456-1234-123');
        insert cont;
         // Create a unique UserName
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';        
        User u1 = new User(
            Alias = 'standt',
            Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName=uniqueUserName,
            ContactId=cont.Id);
        insert u1;   
        
     	GEA_AccountContactRelation__c contactLoc=new GEA_AccountContactRelation__c();
           contactLoc.Name='testName';  
           contactLoc.Account__c=a.Id;
           contactLoc.Contact__c=u1.ContactId;
           contactLoc.MYA_Included__c=true;
           contactLoc.Nick_Name__c='testName';
           insert contactLoc; 
        
     	GEA_AccountContactRelation__c contactLoc1=new GEA_AccountContactRelation__c();
           contactLoc1.Name='testName1';  
           contactLoc1.Account__c=a1.Id;
           contactLoc1.Contact__c=u1.ContactId;
           contactLoc1.MYA_Included__c=true;
           contactLoc1.Nick_Name__c='testName';
           insert contactLoc1;
      
        Test.startTest();
        System.runAs(u1) {
        	MYA_DeleteAccountHandler.deactivate();
        }
        Test.stopTest();
    }
}