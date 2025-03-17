@isTest()
public class MedalliaIntegrationTest {
    public static testMethod void testOutboundMessageWithBasicAuth() {
        MedalliaIntegration.surveyPayload sp = new MedalliaIntegration.surveyPayload();
        sp.endpoint = 'https://instance.medallia.com/company.feed';
        sp.fieldSet = 'medalliaOutbound_createSurvey';
        sp.service = 'sfdc_test';
        sp.password = 'Medallia123';
        sp.QueryFilter=' WHERE ID IN :recordIds AND  Team_Persona_f__c in (\'Digital Media\',\'Social Media Case Manager\',\'CR Exec\',\'CR Frontline\',\'CR MSP\',\'PSS\',\'PSS Haier/Cafe\',\'CR eRelations\',\'SPSS\') AND  isParent__c =false  LIMIT 20000';
       // sp.db_cols='\'recordtype.developername\',\'owner.name\',\'gea_asset__r.In_Warranty__c\',\'Asset__r.Install_Date__c\',\'GEA_Asset__r.Install_Date__c\',\'GEA_Asset__r.Model_Number__c\',\'GEA_Asset__r.Serial_Number__c\',\'GEA_Asset__r.Product_Line__c\'';
        sp.recordid = null;
 
        
        Contact c = new Contact();
        c.FirstName = 'Con';
        c.LastName = 'tact';
        c.Email = Crypto.getRandomInteger()+'cont@contac.test.com.medalliadev';
        c.Title = 'test maker';
        insert c;
        
        Asset asset = new Asset();
        asset.In_Warranty__c = true;
        asset.Product_Line_Desc__c='IT TESTING ';
        asset.InstallDate=Date.parse('12/12/2019');
        asset.Model_Number__c='IM4A';
        asset.SerialNumber= '1245624';
        asset.Product_Line__c ='REFRIGERATOR - COMPACT';
        insert asset;
        
       
        Case cs = new Case();
        cs.Description='These are received damaged please replace';
        cs.Reason='Recall/Special Program';
        cs.Install_Date__c=null;
        cs.AssetId=asset.Id;
        cs.ContactId=c.Id; 
         insert cs;

        
        Case_Asset__c cs_asset = new Case_Asset__c();
        cs_asset.Install_Date__c=Date.parse('12/12/2019');
        cs_asset.Model_Number__c='IM4A';
        cs_asset.Serial_Number__c= '12133';
        cs_asset.Case__c=cs.id;
        cs_asset.Asset__c=asset.id;
        insert cs_asset;
        
      
        
        sp.recordid = String.valueOf(cs.Id);

        List<MedalliaIntegration.surveyPayload> splist = new List<MedalliaIntegration.surveyPayload>();
        splist.add(sp);
        MedalliaIntegration.sendToMedallia(splist);

    }
    public static testMethod void testOutboundMessageWithoutBasicAuth() {
        MedalliaIntegration.surveyPayload sp = new MedalliaIntegration.surveyPayload();
        sp.endpoint = 'https://instance.medallia.com/company.feed';
        sp.fieldSet = 'medalliaOutbound_createSurvey';
        sp.service = 'sfdc_test';
        
       // sp.db_cols='\'recordtype.developername\'';

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
        asset.Model_Number__c='JVM1400WW';
        asset.SerialNumber= '12133';
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
        cs_asset.Model_Number__c='JVM1400WW';
        cs_asset.Serial_Number__c= '12133';
        cs_asset.Case__c=cs.id;
        cs_asset.Asset__c=asset.id;
        insert cs_asset;
        
        
          sp.recordid = String.valueOf(cs.Id);


        List<MedalliaIntegration.surveyPayload> splist = new List<MedalliaIntegration.surveyPayload>();
        splist.add(sp);
        MedalliaIntegration.sendToMedallia(splist);

    }
    
    public static testMethod void testOutboundMessageNegative() {
        MedalliaIntegration.surveyPayload sp = new MedalliaIntegration.surveyPayload();
        sp.endpoint = 'https://instance.medallia.com/company.feed';
        sp.fieldSet = 'fail_medalliaOutbound_createSurvey';
        sp.service = 'sfdc_test';
       // sp.db_cols=null;
        sp.recordid = null;

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
        asset.SerialNumber= '767677';
        asset.Product_Line__c ='REFRIGERATOR - COMPACT';
        insert asset;
        
        Case cs = new Case();
        cs.Description='These are received damaged please replace';
        cs.Reason='Recall/Special Program';
        cs.GEA_Asset__c=String.valueOf(asset.Id);
        cs.ContactId=String.valueOf(c.Id);

        insert cs;
        
        Case_Asset__c cs_asset = new Case_Asset__c();
        cs_asset.Install_Date__c=Date.parse('12/12/2019');
        cs_asset.Model_Number__c='IM4A';
        cs_asset.Serial_Number__c= '767677';
        cs_asset.Case__c=cs.id;
        cs_asset.GEA_Asset__c=asset.id;
        insert cs_asset;
        
        
        sp.recordid = String.valueOf(cs.Id);


        List<MedalliaIntegration.surveyPayload> splist = new List<MedalliaIntegration.surveyPayload>();
        splist.add(sp);
        MedalliaIntegration.sendToMedallia(splist);

    }
}