@isTest
public class testGEAAssetHerokuExtIDTrigger {  
    static testMethod void testBulkInsert() {
    
            List<Asset> assets = new List<Asset>();
    
            Profile p = [select id from profile where name='System Administrator'];
            // create a user to run the test as
            User u = new User(alias = 'eft92160', email='eft92160@eftemail.com',
                emailencodingkey='UTF-8', lastname='eft92160', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.Id, country='United States',
                timezonesidkey='America/Los_Angeles', username='eft92160@eftemail.com');
            insert u;
    
            Profile p1 = [select id from profile where name='Customer Care'];
            // create a user to own the contact
            User u1 = new User(alias = 'eft9216', email='eft9216@eftemail.com',
                emailencodingkey='UTF-8', lastname='eft9216', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p1.Id, country='United States',
                timezonesidkey='America/Los_Angeles', username='eft9216@eftemail.com');
            insert u1;
        

    
            // add 200 assets to the list to be inserted
            for (Integer i=0;i<200;i++) {
    
                Asset a = new Asset(
                    //account__c='0014P00002ZEcDCQA1',
                    AccountId='0014P00002ZEcDCQA1',
                    assetID__c='EFT-TEST'+string.valueof(i),
                    OwnerId = u1.Id
                );
                assets.add(a);
    
            }
    
            // Switch to the runtime context
            Test.startTest();  
    
            // run as a different user to test security and rights
            System.runAs(u) {
                insert assets;
                
                //retrieve the 200 assets and update the PersonID, then update the asset
                List <Asset> updast = new List<Asset>();
                integer i1 = 0;
                for (Asset asst : [Select Heroku_Ext_Id__c from Asset Where OwnerId = :u1.Id]){ 
                    Asset upda = new Asset();
                    upda.id = asst.id;
                    upda.assetID__c = string.valueof(i1);
                    i1++;
                    //system.debug('i1: '+i1);
                    updast.add(upda);
                }
                update(updast);
            }
    
            // Switch back to the original context
            Test.stopTest();     
    
            // query for all contacts created
            for (Asset asst1 : [Select Heroku_Ext_Id__c from Asset Where OwnerId = :u1.Id])
                System.debug('GEA Asset ID: '+asst1.id+' Heroku Ext ID: '+asst1.Heroku_Ext_Id__c);
    
        }
}