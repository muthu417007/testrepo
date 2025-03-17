@isTest
public class ConnectedApplianceHelper_Test {
    
    static testMethod void test1() {
        Account a=new Account();
          a.Name='testName';
          a.BillingStreet='test street';
          a.BillingCity='test City';
          a.BillingState='OH';
          a.BillingPostalCode='12345';
          a.Country_Code__c='United States Of America';   
          insert a; 
        
        Asset ast=new Asset();
            ast.AccountId=a.Id;
            ast.Model_Number__c='PT916WMWW';
            ast.SerialNumber='SL87537HG6';
            ast.AssetNickname__c='testnick';
            ast.ModelValidityFlag__c=true;
            ast.MACAddress__c='D828C95C2442';
            insert ast;
        
        // Perform test
        Test.startTest();
        Contact c = [SELECT id from contact LIMIT 1];
        ConnectedApplianceResponse resp = ConnectedApplianceHelper.checkOnlineStatus(ast.MACAddress__c);
        ConnectedApplianceResponse testResponse = new ConnectedApplianceResponse();
        testResponse.presence = 'ONLINE';
        Test.stopTest();
    }
    }