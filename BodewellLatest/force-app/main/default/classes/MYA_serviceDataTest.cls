@isTest
public class MYA_serviceDataTest {

    public static testMethod void MYA_accountDetail(){
        string user1 = UserInfo.getUserId();
        List<User> userName =[Select Id, FirstName,LastName,MiddleName from User where Id=:user1]; 
        Contact con = new Contact();
        con.FirstName = userName[0].FirstName;
        con.MiddleName = userName[0].MiddleName;
        con.LastName = userName[0].LastName;
        insert con;
        
        Service__c s = new Service__c();
        s.MYA_Service_Status__c='R';
        s.Contact__c=con.id;
        s.Service_Date__c = system.today().addDays(-2);
        insert s;
        Test.startTest();
        MYA_serviceData.MYA_getAccountProduct();
        Test.stopTest();
    }
    public static testMethod void MYA_accountDetail1(){
        string user1 = UserInfo.getUserId();
        List<User> userName =[Select Id, FirstName,LastName,MiddleName from User where Id=:user1]; 
        Contact con = new Contact();
        con.FirstName = userName[0].FirstName;
        con.MiddleName = userName[0].MiddleName;
        con.LastName = userName[0].LastName;
        insert con;
        
        Service__c s = new Service__c();
        s.MYA_Service_Status__c='R';
        s.Contact__c=con.id;
        s.Service_Date__c = system.today().addDays(-2);
        insert s;
        
        GEA_Asset__c a = new GEA_Asset__c();
        a.OriginalModelNumber__c = 'AB1234';
        a.Serial_Number__c = 'SR1234';

        
        Test.startTest();
        mya_serviceData.MYA_getAccountProduct1();
        Test.stopTest();
    }
    public static testMethod void MYA_accountDetail2(){
        string user1 = UserInfo.getUserId();
        List<User> userName =[Select Id, FirstName,LastName,MiddleName from User where Id=:user1]; 
        Contact con = new Contact();
        con.FirstName = userName[0].FirstName;
        con.MiddleName = userName[0].MiddleName;
        con.LastName = userName[0].LastName;
        insert con;
        
        Test.startTest();
        mya_serviceData.MYA_getAccountProductC360();
        Test.stopTest();
    }
}