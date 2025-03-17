@isTest 
private class UtilityAuth0New1_test{
    static testMethod void test_isSandbox() {
        Boolean isSandbox = UtilityAuth0New1.isSandbox;
    }
    
    
    static testMethod void test_truncate(){
        String nullResult = UtilityAuth0New1.truncate('GGG',1);
        //System.assertEquals('', nullResult.trim());
        
        String str2 = UtilityAuth0New1.truncate('ggggg',10);
        String str3 = UtilityAuth0New1.truncate('GGGGGG',3);
    }
    
     static testMethod void test_initCap(){

        String result = UtilityAuth0New1.initCap('change to cap');
        System.assertEquals('Change To Cap', result.trim());
    }
    
    static testMethod void test_impliedDecimal(){
        String nullResult = UtilityAuth0New1.impliedDecimal(null);
        System.assertEquals('', nullResult.trim());
        String result = UtilityAuth0New1.impliedDecimal(10.75);
        System.assertEquals('1075', result.trim());
    }

    static testMethod void test_findGeConsumerNumber(){
        String nullResult = UtilityAuth0New1.findGeConsumerNumber('','1');
        System.assertEquals('Error - No Asset Found', nullResult.trim());
        String str1 = UtilityAuth0New1.findGeConsumerNumber('0032g000006mF56AAE','a014P00001wlPw5QAE');
        String str2 = UtilityAuth0New1.findGeConsumerNumber('0032g000006mF56AAE','');
        String str3 = UtilityAuth0New1.findGeConsumerNumber('','a014P00001wlPw5QAE');
        String str4 = UtilityAuth0New1.findGeConsumerNumber('','');

    }
    static testMethod void test_FuncDateDurationDiff(){
        Long lngVal  = UtilityAuth0New1.FuncDateDurationDiff(datetime.now(),datetime.now());
    }
    static testMethod void test_getGraphQLToken(){
        Auth0TokenTimeout__c setting = new Auth0TokenTimeout__c();
        if(setting.id == null) {
            system.debug('NULL');
            setting.AppName__c = 'Auth0';
            setting.TimeoutMins__c = '900';
            setting.IsActive__c = true;
            insert setting;
            String result = UtilityAuth0New1.getGraphQLTokenAuth0New1();
            System.assertNotEquals(null, result);
        }
        else
        {
            system.debug('NOT NULL');
        }
        
    }
    
    static testMethod void test_getMFGNumber(){
        String result = UtilityAuth0New1.getMFGNumber('FFFFF');
    }
    
    static testMethod void test_getArchivedContacts(){
      searchPhoneResponse sr = UtilityAuth0New1.getArchivedContacts('1231234');
        Id testNew = UtilityAuth0New1.restoreContact(sr.data.HouseHoldByPhone[0]);
        
         searchPhoneResponse sr1 = UtilityAuth0New1.getArchivedContacts('GGGGGGGGGGGGG');
    }
    
    static testMethod void test_createSiebelAsset(){
      List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        List<Asset> assets = TestDataFactory.createAssets(3,accounts[0]);
        
        // Perform test
        Test.startTest();
        Contact c = [SELECT id from contact LIMIT 1];
        Case caseRec = TestDataFactory.createCase(c, assets[0]);
        UtilityAuth0New1.createSiebelAsset(assets[0].id, c.id);
        Test.stopTest();
    }
    
    static testMethod void test_addressVerify(){
        zoneDetailsResponse result = UtilityAuth0New1.addressVerify('32137');
        System.assertNotEquals(null, result);
    }
    static testMethod void test_searchIdResponse(){
        searchIdResponse result = UtilityAuth0New1.getById('32137');
        System.assertNotEquals(null, result);
    }
    static testMethod void test_restoreContactEmail(){
        StaticResource sr = [select id,body from StaticResource Where Name = 'searchEmailTestResponse'];
        String testBody = sr.body.toString();
      searchEmailResponse searchResultsEmail = searchEmailResponse.parse(testBody);
        
    ID result = UtilityAuth0New1.restoreContactEmail(searchResultsEmail.data.HouseHoldByEmail[0]);        //
        System.assertNotEquals(null, result);
    }
    
    
    
    
    
    static testMethod void test_CN1CustomerNumber(){
     //test CN1 callout
      contact c = new contact();
        c.lastName = 'New Person';
        c.firstName = 'Hello';
        account a = new account();
        a.BillingStreet = '6419 Shelber Viewer Driver ';
        a.BillingCity = 'MEMPHIS';
        a.BillingPostalCode = '38134';
        a.BillingState = 'TN';
        CN1Response test = UtilityAuth0New1.CN1CustomerNumber(c, '314000056', a);
        //{
         //   "ConsumerNo": "187616956",
         //   "AddressId": "01876169560001",
        //    "PhoneId": "01876169560001"
        //}
    }



        
        
   
}