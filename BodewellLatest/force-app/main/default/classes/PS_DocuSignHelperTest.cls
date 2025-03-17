@isTest
private class PS_DocuSignHelperTest {

    @isTest
    static void test_sendForSignatureMethodWithoutASMAndManagerSignaturesRequired () {

        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        Customer_Agreement__c agreement;

        System.runAs(dfsle.UserMock.createDocuSignSender()) {
            Id contractDistributorRTId = Account.getSObjectType().getDescribe().getRecordTypeInfosByName().get('Contract Distributor').getRecordTypeId();
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
            agreement = new Customer_Agreement__c(
                Account_Name__c = myAccount.Id,
                Contract_Distributor_Agreement_Selection__c = 'ABD Sales',
                Retail_Agreement_Selection__c = 'As-Is Retail',
                Agreement_Start_Date__c = Date.newInstance(2021, 1, 1),
                Agreement_Signer_Email__c = 'email@email.email'
            );
            insert agreement;
    
            Test.startTest();
    
            PS_DocuSignHelper.sendForSignature(new List<String>{agreement.Id});
    
            Test.stopTest();
        }
    }

    @isTest
    static void test_sendForSignatureMethodWithASMAndManagerSignaturesRequired () {

        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        Customer_Agreement__c agreement;

        System.runAs(dfsle.UserMock.createDocuSignSender()) {
            Id contractDistributorRTId = Account.getSObjectType().getDescribe().getRecordTypeInfosByName().get('Contract Distributor').getRecordTypeId();
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
            agreement = new Customer_Agreement__c(
                Account_Name__c = myAccount.Id,
                Contract_Distributor_Agreement_Selection__c = 'ABD Sales',
                Agreement_Start_Date__c = Date.newInstance(2021, 1, 1),
                Agreement_Signer_Email__c = 'email@email.email',
                Manager__c = UserInfo.getUserId()
            );
            insert agreement;
    
            Test.startTest();
    
            PS_DocuSignHelper.sendForSignature(new List<String>{agreement.Id});
    
            Test.stopTest();
        }
    }
}