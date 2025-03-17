@isTest
public class MYA_WebConsumerInfoController_Test {
    @testSetup
    static void dataSetup(){
        Account acc= new Account(Name= 'Test Account');
        insert acc;
        
        Contact cont = new Contact(LastName ='testCon',
                                   Email='standarduser@testorg.com',
                                   AccountId = acc.Id, Global_Customer_Id__c= '123456-1234-123');
        insert cont;
        
        WebConsumerInfo__c webConsInfoObj = new WebConsumerInfo__c();
      	webConsInfoObj.Model_number__c = 'TEST123';
       	webConsInfoObj.Serial_Number__c = 'SLTEST123';
        webConsInfoObj.Data_Source_Code__c = 'VT';
        insert webConsInfoObj; 
    }
	@isTest
    static void saveWebConsInfoTest1() {  
        Account acc = [select Id from Account LIMIT 1];
        Contact cont = [select Id from Contact LIMIT 1];
        Profile p = [select Id from profile where name='Default Customer Login User'];
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
        	MYA_WebConsumerInfoController.SaveAssetResponse response1 = MYA_WebConsumerInfoController.saveAssets('123TEST', '321SLTEST', '07/07/2022', 'VT', acc.Id, u1.ContactId, true);
        	MYA_WebConsumerInfoController.SaveAssetResponse response2 = MYA_WebConsumerInfoController.saveAssets('TEST321', '123SLTEST', '07/07/2022', 'TEST', acc.Id, u1.ContactId, true);
        	MYA_WebConsumerInfoController.SaveAssetResponse response3 = MYA_WebConsumerInfoController.saveAssets('TEST123', 'SLTEST123', '07/07/2022', 'VT', acc.Id, u1.ContactId, true);
        }
        Test.stopTest();
     }
}