@isTest
public class TestcontactinformationHerokuExtIDTrigger {
    
    static testMethod void testBulkInsert() {

        List<contact> contacts = new List<contact>();

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

        // add 200 contacts to the list to be inserted
        for (Integer i=0;i<200;i++) {

            Contact c = new Contact(
                FirstName = 'Test',
                LastName = 'Contact EFT',
                OwnerId = u1.Id
            );
            contacts.add(c);

        }

        // Switch to the runtime context
        Test.startTest();  

        // run as a different user to test security and rights
        System.runAs(u) {
            insert contacts;
            
            //retrieve the 200 contacts and update the contact Id, PersonDetailId and store Contact Information record
            List <Contact_Information__c> updContactinfo1 = new List<Contact_Information__c>();
        	integer i1 = 0;
        	for (Contact cont : [Select id from Contact Where OwnerId = :u1.Id]){ 
                contact_information__c updci = new contact_information__c();
                updci.contact__c = cont.id;
                updci.PersonDetailId__c = string.valueof(i1);
                updci.CreatedById=u.id;
                i1++;
                //system.debug('i1: '+i1+' contact Id: '+updci.contact__c+' persondetailid: '+updci.PersonDetailID__c);
                updcontactinfo1.add(updci);
        	}
        	insert(updcontactinfo1);
        }

        // Switch back to the original context
        Test.stopTest();     

        // query for all contact information records created
        for (Contact_Information__c cont : [Select Id, PersonDetailId__c, Heroku_Ext_Id__c from Contact_Information__c Where CreatedById = :u.Id])
            System.debug('PersonDetailId'+cont.PersonDetailid__c+' Heroku Ext ID: '+cont.Heroku_Ext_Id__c);

    }
    
}