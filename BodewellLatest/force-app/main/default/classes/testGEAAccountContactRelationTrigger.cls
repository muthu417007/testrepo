@isTest
public class testGEAAccountContactRelationTrigger {
    
        static testMethod void testBulkInsert() {
    
            List<GEA_AccountContactRelation__c> crs = new List<GEA_AccountContactRelation__c>();
    
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
        

    
            // add 200 accounts to the list to be inserted
            for (Integer i=0;i<200;i++) {
    
                GEA_AccountContactRelation__c cr = new GEA_AccountContactRelation__c(
                    name='Ed Tjarks Test',
                    account__c='0014P00002ZEcDCQA1',
                    Contact__c = '0034P00002xnRXPQA2',
                    //LocationPersonID__c='EFT-TEST'+string.valueof(i),
                    CreatedById = u1.Id
                );
                crs.add(cr);
    
            }
    
            // Switch to the runtime context
            Test.startTest();  
    
            // run as a different user to test security and rights
            System.runAs(u) {
                insert crs;
            }
    
            // Switch back to the original context
            Test.stopTest();     
    
            // query for all contacts created
            for (GEA_AccountContactRelation__c cr2 : [Select Heroku_Ext_Id__c from GEA_AccountContactRelation__c Where CreatedById = :u1.Id])
                System.debug('GEA account contact relation ID: '+cr2.id+' Heroku Ext ID: '+cr2.Heroku_Ext_Id__c);
    
        }
}