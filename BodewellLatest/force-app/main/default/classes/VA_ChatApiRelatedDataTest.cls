/*
 * @description VA_ChatApiRelatedDataTest test class for VA_ChatApiRelatedData
 */
@isTest
public class VA_ChatApiRelatedDataTest {
	@isTest
    static void insertVaAuditRecordTest(){
        
        VAChat_Details__c vaauditrec= new VAChat_Details__c();
        vaauditrec.ModelNo__c='IM4A';
        vaauditrec.SerialNo__c='LT123456';
        vaauditrec.Phone__c= '8096477190';
        Test.startTest();
        VAChat_Details__c resp= VA_ChatApiRelatedData.upsertVaChatDetail(vaauditrec);
        Test.stopTest();
        system.assertNotEquals(null, resp,'response not null');
    }
    /*static testmethod void insertVaCaseRecordTest(){
        
        Case caseRec= new Case();
        caseRec.Subject= 'VA Chat test record';
        caseRec.Case_Type__c = 'Parts';
        caseRec.First_Name__c= 'test';
        caseRec.Last_Name__c= 'record';
        Test.startTest();
        Case resp= VA_ValidateSerialNumber.upsertCaseRecord(caseRec);
        Test.stopTest();
    }*/
    @isTest
    static void checkSerialWarrantyTest(){
        
        Test.startTest();
        List < Virtual_Assistant_Metadata__mdt > serialRecords= VA_ChatApiRelatedData.checkSerialWarranty('LT123456');
        Test.stopTest();
        system.assertNotEquals(null, serialRecords,'response not null');
    }
    @isTest
    static void getProduct2Test(){
        Test.startTest();
        List<Product2> productRecord = VA_ChatApiRelatedData.getProduct2Record('IM4A');
        Test.stopTest();
        system.assertNotEquals(null, productRecord,'response not null');
    }
    @isTest
    static void getVaChatDetailTest(){
        
        Profile p = [select Id from profile where name='IT'];
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
            UserName=uniqueUserName
           );
        insert u1;
        VAChat_Details__c chatRecord = new VAChat_Details__c();
        chatRecord.ProblemCategory__c = 'no_cool';
        chatRecord.Phone__c = '1234567890';
        chatRecord.ApplianceType__c = 'freezer';
        chatRecord.ModelNo__c = 'IM4A';
        chatRecord.SerialNo__c = 'LT123456';
        chatRecord.Status__c = 'AB';
        chatRecord.Requested_by__c =u1.id;
        insert chatRecord;
        
        Test.startTest();
        String resp = VA_ChatApiRelatedData.getVaChatDetail('IM4A','LT123456',u1.Id);
        Test.stopTest();
        system.AssertNotEquals(null,resp,'response not null');
        
        String resp2 = VA_ChatApiRelatedData.getModelData('IM4A');
        system.assertNotEquals(null, resp2,'response not null');
        String resp3 = VA_ChatApiRelatedData.getSerialData('LT123456', 'IM4A', '1234567890');
        system.assertNotEquals(null, resp3,'response not null');
       
    }
    
    @isTest
    static void getFSSavewithPartsQueueIDTest(){
        
        Test.startTest();
        String res = VA_ChatApiRelatedData.getFSSavewithPartsQueueID('FSSWPSavewithParts');
        Test.stopTest();
        system.assertNotEquals(null, res,'response not null');
    }
}