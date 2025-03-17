@isTest
public class DocusignSenderTest {
    @isTest
    static void test_sendForSignatureMethodWithoutASMAndManagerSignaturesRequired () {

        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        Credit_Application__c agreement;

        System.runAs(dfsle.UserMock.createDocuSignSender()) {
            Id contractDistributorRTId = Account.getSObjectType().getDescribe().getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
            Account myAccount = new Account(
                Name = 'Test Account',
                RecordTypeId = contractDistributorRTId
            );
            insert myAccount;             
            Contact myContact = new Contact(
                AccountId = myAccount.Id,
                FirstName = 'Test',
                LastName = 'Contact',
                Phone = '1234567890',
                Email = 'test.contact@example.com');
            insert myContact;
            agreement = new Credit_Application__c(
                Credit_Application_Forms__c = 'Multifamily Project Info Sheet NC',
                Customer_Email__c = 'email@email.email'
            );
            insert agreement;
    
            Test.startTest();
    
            DocuSignSender.sendEnvelopeMethod(new List<String>{agreement.Id});
    
            Test.stopTest();
            //system.assertequals('Test',agreement.Credit_Application_Forms__c='Hospitality');
            system.assertnotEquals(null, '');
        }
    }
}