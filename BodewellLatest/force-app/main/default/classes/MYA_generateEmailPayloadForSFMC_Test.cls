//******************************************************************************************
//Name : MYA_generateEmailPayloadForSFMC_Test 
//Requirement : To test MYA_generateEmailPayloadForSFMC.MYA_Utility_publishEmailPayloadForSFMC
//@description : Test Class
//EPIC/US/TASK : IDMSF-1173
//******************************************************************************************
//History
//	Version				Author					Date				Detail
//  1.0					Yogesh Sharma			07/11/2022			Initial
//******************************************************************************************
@isTest
private class MYA_generateEmailPayloadForSFMC_Test {
    @isTest
    static void MYA_generateEmailPayloadForSFMC_Test1(){
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Contact ownerCon = new COntact(LastName='Contact', AccountId = acc.Id);
        insert ownerCon;
        
        List<String> assetIds = new List<String>();
        Asset asset = new Asset(
        	OwnershipStartedOn__c=Date.Today(),
            OriginalEngineeringModelNumber__c='',
            ModelValidityFlag__c=true,
            Model_Number__c='',
            SerialNumber='',
            DataSourceCode__c='',
            OriginalModelNumber__c = '',
            ContactId = ownerCon.Id,
            AccountId = acc.Id
        );
        insert asset;
        assetIds.add(asset.Id);
        String assurantURL='https://model-spa-dsp.assurant.com/registration/?type=GEA';
        MYA_generateEmailPayloadForSFMC.MYA_Utility_publishEmailPayloadForSFMC(assetIds,assurantURL);
    }
    
    
    @isTest
    static void MYA_generateEmailPayloadForSFMC_Test2(){
        Account acc = new Account(
        					Name = 'Test Account',
            				BillingCity ='Test City',
            				BillingStreet = '123 Main Street',
            				BillingState='Test State',
            				BillingCountry='Test Country',
            				BillingPostalCode='12345'
        				);
        insert acc;
        
        Contact ownerCon = new COntact(
        	FirstName= '',
            LastName='Contact',
            Phone='1234567890',
            Email='test@test.com',
            AccountId = acc.id
        );
        insert ownerCon;
        
        List<String> assetIds = new List<String>();
        Asset asset = new Asset(
        	OwnershipStartedOn__c=Date.Today(),
            OriginalEngineeringModelNumber__c='E123',
            ModelValidityFlag__c=true,
            Model_Number__c='m1234',
            SerialNumber='s1234',
            DataSourceCode__c='d123',
            OriginalModelNumber__c = 'ABC123',
            ContactId = ownerCon.Id,
            AccountId = acc.Id
        );
        insert asset;
        assetIds.add(asset.Id);
        String assurantURL='https://model-spa-dsp.assurant.com/registration/?type=GEA';
        MYA_generateEmailPayloadForSFMC.MYA_Utility_publishEmailPayloadForSFMC(assetIds,assurantURL);
    }
    
    @isTest
    static void MYA_publishGuestEmailPayloadForSFMC_Test1(){        
        Prd_Reg_Event__e payload = new Prd_Reg_Event__e();
        payload.Email__c = 'test@test.com';
        payload.SessionID__c = 'test@test.com1234567890';
        payload.Payload__c = '{"transaction_data":{"ConsumerFirstName":"Raj","ConsumerLastName":"Akhil","ConsumerAddress1":"Jacumba Hot Springs, CA 91934","ConsumerAddress2":"","ConsumerPhone":"4234234234","City":"Jacumba Hot Springs","State":"AK","ZipCode":"69221","product":[{"ApplianceInstallDate":"2022-09-11","ManufacturingModel":"PEM31EFES","ModelValidityFlag":true,"MarketingModel":"PEM31EFES","ApplianceSerial":"GHT567567","InputModel":"PEM31EFES"}]},"send_single_options":{"suppression_info":"false"},"send_single_contact":{"email":"test@test.com"}}';
        MYA_generateEmailPayloadForSFMC.EmailPayloadInput input = new MYA_generateEmailPayloadForSFMC.EmailPayloadInput();
        input.Payload = payload;
        MYA_generateEmailPayloadForSFMC.MYA_Utility_publishGuestEmailPayloadForSFMC(input);
    }
    
    @isTest
    static void MYA_publishGuestEmailPayloadForSFMC_Test2(){        
        Prd_Reg_Event__e payload = new Prd_Reg_Event__e();
        payload.Email__c = Null;
        payload.SessionID__c = Null;
        payload.Payload__c = Null;
        MYA_generateEmailPayloadForSFMC.EmailPayloadInput input = new MYA_generateEmailPayloadForSFMC.EmailPayloadInput();
        input.Payload = payload;
        MYA_generateEmailPayloadForSFMC.MYA_Utility_publishGuestEmailPayloadForSFMC(input);
    }
}