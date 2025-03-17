@isTest()
public class MedalliaIntegrationBulkTriggerTest {
    public static testMethod void testOutboundMessageWithBasicAuth() {
        MedalliaIntegrationBulkTrigger.surveyPayload sp = new MedalliaIntegrationBulkTrigger.surveyPayload();
        sp.endpoint = 'https://instance.medallia.com/company.feed';
        sp.fieldSet = 'medalliaOutbound_createSurvey_Case_Asset';
        sp.service = 'sfdc_test';
        sp.password = 'Medallia123';
        sp.QueryFilter = 'Case__r.Team_Persona_f__c in (\'Digital Media\',\'Social Media Case Manager\',\'CR Exec\',\'CR Frontline\',\'CR MSP\',\'PSS\',\'PSS Haier/Cafe\') and Case__r.ClosedDate >= 2020-03-04T00:00:00Z and Case__r.ClosedDate <= 2020-03-18T00:00:00Z';
       // sp.db_cols='\'recordtype.developername\',\'owner.name\',\'gea_asset__r.In_Warranty__c\',\'GEA_Asset__r.Install_Date__c\',\'GEA_Asset__r.Install_Date__c\',\'GEA_Asset__r.Model_Number__c\',\'GEA_Asset__r.Serial_Number__c\',\'GEA_Asset__r.Product_Line__c\'';
        sp.casesToSurvey = null;
 
        List<Case> caseList = new List<Case>();
        
        Contact c = new Contact();
        c.FirstName = 'Con';
        c.LastName = 'tact';
        c.Email = Crypto.getRandomInteger()+'cont@contac.test.com.medalliadev';
        c.Title = 'test maker';
        insert c;
        
        
        Asset asset = new Asset();
        asset.In_Warranty__c = true;
        asset.Product_Line_Desc__c='IT TESTING PLEASE IGNORE';
        asset.InstallDate=Date.parse('12/12/2019');
        asset.Model_Number__c='IM4A';
        asset.SerialNumber= '4535348785';
        asset.Product_Line__c ='REFRIGERATOR - COMPACT';
        insert asset;
        
        Case cs = new Case();
        cs.Description='These are received damaged please replace';
        cs.Reason='Recall/Special Program';
        cs.AssetId=asset.Id;
        cs.ContactId=c.Id; 
         insert cs;

        
        caseList.add(cs);
        
        Case_Asset__c cs_asset = new Case_Asset__c();
        cs_asset.Install_Date__c=Date.parse('12/12/2019');
        cs_asset.Model_Number__c='IM4A';
        cs_asset.Serial_Number__c= '767677';
 		cs_asset.Case__c=cs.id;
        cs_asset.Asset__c=asset.id;
        insert cs_asset;
        
        sp.casesToSurvey = caseList;

        List<MedalliaIntegrationBulkTrigger.surveyPayload> splist = new List<MedalliaIntegrationBulkTrigger.surveyPayload>();
        splist.add(sp);
        MedalliaIntegrationBulkTrigger.sendToMedallia(splist);

    }
    public static testMethod void testOutboundMessageWithoutBasicAuth() {
        MedalliaIntegrationBulkTrigger.surveyPayload sp = new MedalliaIntegrationBulkTrigger.surveyPayload();
        sp.endpoint = 'https://instance.medallia.com/company.feed';
        sp.fieldSet = 'medalliaOutbound_createSurvey_Case_Asset';
        sp.service = 'sfdc_test';
         sp.QueryFilter = null;
       // sp.db_cols='\'recordtype.developername\'';
       // 
         sp.casesToSurvey = null;
 
        List<Case> caseList = new List<Case>();

       Contact c = new Contact();
        c.FirstName = 'Con';
        c.LastName = 'tact';
        c.Email = Crypto.getRandomInteger()+'cont@contac.test.com.medalliadev';
        c.Title = 'test maker';
        insert c;
        
        Asset asset = new Asset();
        asset.In_Warranty__c = true;
        asset.Product_Line_Desc__c='IT TESTING PLEASE IGNORE';
        asset.InstallDate=Date.parse('12/12/2019');
        asset.Model_Number__c='IM4A';
        asset.SerialNumber= '453537845';
        asset.Product_Line__c ='REFRIGERATOR - COMPACT';
        insert asset;
        
        Case cs = new Case();
        cs.Description='These are received damaged please replace';
        cs.Reason='Recall/Special Program';
        cs.AssetId=String.valueOf(asset.Id);
        cs.ContactId=String.valueOf(c.Id);

        insert cs;

          caseList.add(cs);
        
         Case_Asset__c cs_asset = new Case_Asset__c();
        cs_asset.Install_Date__c=Date.parse('12/12/2019');
        cs_asset.Model_Number__c='IM4A';
        cs_asset.Serial_Number__c= '767677';
 		cs_asset.Case__c=cs.id;
        cs_asset.Asset__c=asset.id;
        insert cs_asset;
        
        sp.casesToSurvey = caseList;


         List<MedalliaIntegrationBulkTrigger.surveyPayload> splist = new List<MedalliaIntegrationBulkTrigger.surveyPayload>();
        splist.add(sp);
        MedalliaIntegrationBulkTrigger.sendToMedallia(splist);

    }
    
    public static testMethod void testOutboundMessageNegative() {
        MedalliaIntegrationBulkTrigger.surveyPayload sp = new MedalliaIntegrationBulkTrigger.surveyPayload();
        sp.endpoint = 'https://instance.medallia.com/company.feed';
        sp.fieldSet = 'fail_medalliaOutbound_createSurvey';
        sp.service = 'sfdc_test';
       // sp.db_cols=null;
       // sp.recordid = null;

        Contact c = new Contact();
        c.FirstName = 'Con';
        c.LastName = 'tact';
        c.Email = Crypto.getRandomInteger()+'cont@contac.test.com.medalliadev';
        c.Title = 'test maker';
        insert c;
        
        Asset asset = new Asset();
        asset.In_Warranty__c = true;
        asset.Product_Line_Desc__c='IT TESTING PLEASE IGNORE';
        asset.InstallDate=Date.parse('12/12/2019');
        asset.Model_Number__c='IM4A';
        asset.SerialNumber= '45359898345';
        asset.Product_Line__c ='REFRIGERATOR - COMPACT';
        insert asset;
        
        Case cs = new Case();
        cs.Description='These are received damaged please replace';
        cs.Reason='Recall/Special Program';
        cs.AssetId=String.valueOf(asset.Id);
        cs.ContactId=String.valueOf(c.Id);

        insert cs;

         Case_Asset__c cs_asset = new Case_Asset__c();
        cs_asset.Install_Date__c=Date.parse('12/12/2019');
        cs_asset.Model_Number__c='IM4A';
        cs_asset.Serial_Number__c= '767677';
 		cs_asset.Case__c=cs.id;
        cs_asset.Asset__c=asset.id;
        insert cs_asset;
        
       //sp.recordid = String.valueOf(cs.Id);


        List<MedalliaIntegrationBulkTrigger.surveyPayload> splist = new List<MedalliaIntegrationBulkTrigger.surveyPayload>();
        splist.add(sp);
        MedalliaIntegrationBulkTrigger.sendToMedallia(splist);

    }
}