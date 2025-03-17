/**
 * @author         Niku Singh
 * @company        GEA
 * @created        03/04/2022
 * @description    Test Class for WTBWebService
 */
@isTest
private class WTBWebServiceTest {
    @testSetup static void setup(){
        Id partyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Party').getRecordTypeId();
        Id retailRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail').getRecordTypeId();
        Id siteRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Account partyAccount = new Account(Name='TestParty', Party_Registry_ID__c='1234567', Party_Name__c='TestParty', recordtypeid=partyRecordTypeId);
        insert partyAccount;
        Account parentAccount = new Account(Name='TestParent', Status__c='A', Phone='6538264578', Doing_Business_As_DBA__c='TestParent123', Channel__c='Retail', Oracle_Account_Number__c='213456', Website='test@parent.com', Brands_Allowed__c='GE;GE Profile Series;Hotpoint;Monogram;Haier;Café', recordtypeid=retailRecordTypeId, parentid=partyAccount.Id);
        insert parentAccount;
        List<Account> siteAccounts = new List<Account>();
        for(integer i=0;i<5;i++){
            Account siteAccount = new Account(Name='TestSite'+i,parentid=parentAccount.Id, Oracle_Site_Reference_Id__c='432567'+i, ShippingStreet='TestStreet', ShippingState='CO', ShippingPostalCode='80260-4814', ShippingCity='Denver', ShippingCountry='US',Status__c='A',Purpose__c='WHERE TO BUY',recordtypeid=siteRecordTypeId, Channel__c='Retail');
            siteAccounts.add(siteAccount);
        }
        
        Account siteAccount1 = new Account(Name='TestSite1',parentid=parentAccount.Id, Phone='4444444444', Oracle_Site_Reference_Id__c='43256790', ShippingStreet='TestStreet', ShippingState='CO', ShippingPostalCode='80260-4814', ShippingCity='Denver', ShippingCountry='US',Status__c='A',Purpose__c='WHERE TO BUY',recordtypeid=siteRecordTypeId, Channel__c='Retail');
           siteAccounts.add(siteAccount1);
        insert siteAccounts;
        
    }
    
    @isTest //positive unit test for the REST API GET call
    static void testGetFirstSet1() {
        Account partyAcc = [Select id from Account where name='TestParty'];
        List<Party_Relationship__c> parRelatns = new List<Party_Relationship__c>();
        parRelatns.add(new Party_Relationship__c(Party__c=partyAcc.Id,Relationship_Type__c='Cafe Elite Group',Status__c='A'));
        parRelatns.add(new Party_Relationship__c(Party__c=partyAcc.Id,Relationship_Type__c='Premier EDV Group',Status__c='A'));
        parRelatns.add(new Party_Relationship__c(Party__c=partyAcc.Id,Relationship_Type__c='SDA Cafe Best Value Group',Status__c='A'));
        insert parRelatns;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        
        req.requestURI = '/services/apexrest/getSiteRecords?nextStartId=\'\'&recordsRetrieved=\'\'';
        
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        WTBWebservice.siteDetailsList();
        Test.stopTest();
    }
    @isTest
    static void testGetFirstSet2() {
        /*Account partyAcc = [Select id from Account where name='TestParty'];
        List<Party_Relationship__c> parRelatns = new List<Party_Relationship__c>();
        parRelatns.add(new Party_Relationship__c(Party__c=partyAcc.Id,Relationship_Type__c='Cafe Elite Group',Status__c='A'));
        parRelatns.add(new Party_Relationship__c(Party__c=partyAcc.Id,Relationship_Type__c='Premier EDV Group',Status__c='A'));
        parRelatns.add(new Party_Relationship__c(Party__c=partyAcc.Id,Relationship_Type__c='SDA Cafe Best Value Group',Status__c='A'));
        insert parRelatns;*/
        Account siteAcc = [Select id from account where name ='TestSite0' limit 1];
        system.debug('siteAcc>>>>'+siteAcc);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        
        req.requestURI = '/services/apexrest/getSiteRecords';
        req.addParameter('nextStartId', siteAcc.Id);
        req.addParameter('recordsRetrieved', '2000');
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        WTBWebservice.siteDetailsList();
        Test.stopTest();
    }

}