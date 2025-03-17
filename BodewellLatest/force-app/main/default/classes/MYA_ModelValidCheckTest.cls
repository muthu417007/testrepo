@isTest
private class MYA_ModelValidCheckTest {
	
    @isTest
    static void ModelValidCheck1(){
      
        Model_Rel__c m = new Model_Rel__c();
        m.MR_PKMOD__c='MK23456';
        insert m;
        
        Test.startTest();
        MYA_ModelValidCheck.MYA_modelValidityCheckkforMarketing('MK23456');
        Test.stopTest();
    }
    
    @isTest
    static void ModelValidCheck2(){
      
        Model_Rel__c m = new Model_Rel__c();
        m.MN__c='MK23456';
        insert m;
        
        Test.startTest();
        MYA_ModelValidCheck.MYA_modelValidityCheckkforManufacturing('MK23456');
        Test.stopTest();
    }
    
    @isTest
    static void productLineCode(){
      
        SMCModelCA__c m = new SMCModelCA__c();
        m.Model_No__c='MK23456';
        m.Product_Line_Code__c='47';
        m.Brand_Code__c = 'ABCD';
        insert m;
        
        Test.startTest();
        MYA_ModelValidCheck.MYA_productLineCode('MK23456');
        Test.stopTest();
    }
    
    @isTest
    static void productLineCode1(){
      
        SMCModelCA__c m = new SMCModelCA__c();
        m.Model_No__c='MK23456';
        m.Product_Line_Code__c='23';
        m.Brand_Code__c = 'ABCD';
        insert m;
        
        Test.startTest();
        MYA_ModelValidCheck.MYA_productLineCode('MK23456');
        Test.stopTest();
    }
    
    @isTest
    static void marketingModelValidCheck(){
      
        Model_Rel__c m = new Model_Rel__c();
        m.MR_PKMOD__c = 'TEST123';
        m.MN__c = 'TEST1234';
        insert m;
        
        Test.startTest();
        MYA_ModelValidCheck.ModelValidityResponse response = MYA_ModelValidCheck.MYA_marketingModelValidityCheck('TEST123');
        Test.stopTest();
    }
    
    @isTest
    static void getContactTest(){
      
        Account acc= new Account(Name= 'Test Account');
        insert acc;
        Profile p = [select Id from profile where name='Default Customer Login User'];
        Contact cont = new Contact(LastName ='testCon',AccountId = acc.Id);
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
        
        Test.startTest();  
        
        System.runAs(u1) {
        	String response1 = MYA_ModelValidCheck.mya_getContact();
       	}
        
        Test.stopTest();
    }
    
    @isTest
    static void manufacturingModelValidCheck(){
      
        Model_Rel__c m = new Model_Rel__c();
        m.MR_PKMOD__c = 'TEST123';
        m.MN__c = 'TEST1234';
        insert m;
        
        Test.startTest();
        MYA_ModelValidCheck.ModelValidityResponse response = MYA_ModelValidCheck.MYA_manufacturingModelValidityCheck('TEST1234');
        Test.stopTest();
    }
}