@isTest 
private class Utility_test{
    static testMethod void test_isSandbox() {
        Boolean isSandbox = Utility.isSandbox;
    }
    
    
    static testMethod void test_truncate(){
        String nullResult = Utility.truncate('GGG',1);
        //System.assertEquals('', nullResult.trim());
        
        String str2 = Utility.truncate('ggggg',10);
        String str3 = Utility.truncate('GGGGGG',3);
    }
    
     static testMethod void test_initCap(){

        String result = Utility.initCap('change to cap');
        System.assertEquals('Change To Cap', result.trim());
    }
    
    static testMethod void test_impliedDecimal(){
        String nullResult = Utility.impliedDecimal(null);
        System.assertEquals('', nullResult.trim());
        String result = Utility.impliedDecimal(10.75);
        System.assertEquals('1075', result.trim());
    }
    //@isTest(SeeAllData=true)
    static testMethod void test_findGeConsumerNumber(){
        
        List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        List<Asset> assets = TestDataFactory.createAssets(1,accounts[0]);
        Test.startTest();
        Contact c = [SELECT id from contact LIMIT 1];
        Asset ast=[SELECT id from Asset LIMIT 1];
        String nullResult = Utility.findGeConsumerNumber('','1');
        System.assertEquals('Error - No Asset Found', nullResult.trim());
        String str0 = Utility.findGeConsumerNumber('0034P00002xKiCSQA0','a014P00001wlPw5QAE');
        String str1 = Utility.findGeConsumerNumber('0032g000006mF56AAE','a014P00001wlPw5QAE');
        String str2 = Utility.findGeConsumerNumber('0032g000006mF56AAE','');
        String str3 = Utility.findGeConsumerNumber('','a014P00001wlPw5QAE');
        String str4 = Utility.findGeConsumerNumber('','');
        String str5 = Utility.findGeConsumerNumber(c.id,ast.id);
        Test.stopTest();
        
        
    }
    static testMethod void test_FuncDateDurationDiff(){
        Long lngVal  = Utility.FuncDateDurationDiff(datetime.now(),datetime.now());
    }
    static testMethod void test_getGraphQLToken(){
        Auth0TokenTimeout__c setting = new Auth0TokenTimeout__c();
        if(setting.id == null) {
            system.debug('NULL');
            setting.AppName__c = 'Auth0';
            setting.TimeoutMins__c = '900';
            setting.IsActive__c = true;
            insert setting;
            String result = Utility.getGraphQLToken();
            System.assertNotEquals(null, result);
        }
        else
        {
            system.debug('NOT NULL');
        }
        
    }
    
    static testMethod void test_getGraphQLTokenHeroku(){
        Auth0TokenTimeout__c setting = new Auth0TokenTimeout__c();
        if(setting.id == null) {
            system.debug('NULL');
            setting.AppName__c = 'HerokuAuth';
            setting.TimeoutMins__c = '900';
            setting.IsActive__c = true;
            insert setting;
            String result = Utility.getGraphQLToken('Heroku');
            System.assertNotEquals(null, result);
        }
        else
        {
            system.debug('NOT NULL');
        }
        
    }
    
    static testMethod void test_getMFGNumber(){
        String result = Utility.getMFGNumber('FFFFF');
    }
    
    static testMethod void test_getArchivedContacts(){
      searchPhoneResponse sr = Utility.getArchivedContacts('1231234');
        Id testNew = Utility.restoreContact(sr.data.HouseHoldByPhone[0]);
        
         searchPhoneResponse sr1 = Utility.getArchivedContacts('GGGGGGGGGGGGG');
    }
    
    static testMethod void test_createSiebelAsset(){
      List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        List<Asset> assets = TestDataFactory.createAssets(3,accounts[0]);
        
        // Perform test
        Test.startTest();
        Contact c = [SELECT id from contact LIMIT 1];
        Case caseRec = TestDataFactory.createCase(c, assets[0]);
        Utility.createSiebelAsset(assets[0].id, c.id);
        Test.stopTest();
    }
    
    static testMethod void test_addressVerify(){
        zoneDetailsResponse result = utility.addressVerify('32137');
        System.assertNotEquals(null, result);
    }
    static testMethod void test_searchIdResponse(){
        searchIdResponse result = utility.getById('32137');
        System.assertNotEquals(null, result);
    }
    static testMethod void test_restoreContactEmail(){
        StaticResource sr = [select id,body from StaticResource Where Name = 'searchEmailTestResponse'];
        String testBody = sr.body.toString();
      searchEmailResponse searchResultsEmail = searchEmailResponse.parse(testBody);
        
    ID result = utility.restoreContactEmail(searchResultsEmail.data.HouseHoldByEmail[0]);        //
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
        CN1Response test = Utility.CN1CustomerNumber(c, '314000056', a);
        //{
         //   "ConsumerNo": "187616956",
         //   "AddressId": "01876169560001",
        //    "PhoneId": "01876169560001"
        //}
    }

    static testMethod void test_createSiebelAssetRealTime(){
        Utility.createSiebelAssetRealTime('a014P00001y437kQAA','0031F00000cuXGCQA2');
    }
    
    static testMethod void test_FuncTest(){
        Utility.FuncTest();
    }
        
        
   
}