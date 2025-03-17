@IsTest
public class PS_MeetCompReminder_Test {
    @testSetup 
    static void setup() {

        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(currentUser) {
            EmailTemplate[] emailTemplates = [SELECT htmlValue FROM EmailTemplate WHERE DeveloperName IN ('MC_Expiration_Notification_7_days', 'MC_Expiration_Notification_15_days', 'MC_Expiration_Notification_30_days')];
            for (EmailTemplate et : emailTemplates) {
                if (et.htmlValue == null) {
                    et.htmlValue = 
                        '<html><body><table><tr><th>Meet Comp Number</th><th>Account</th><th>GEA Model</th><th>Price</th><th>Current Eff Date</th><th>Current Term Date</th></tr>tabletoreplace</table></body></html>';
                }
            }
            update emailTemplates;
        }
        
        PS_MeetComp_TriggerHandler.TriggerDisabled =  true;
        Account acc1 = new Account(Name = 'Account 1', Meet_Comp_Eligibility__c = 'National');
        Account acc2 = new Account(Name = 'Account 2', Meet_Comp_Eligibility__c = 'National');
        insert new List<Account>{acc1, acc2};
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg246476578465.com');

        User u2 = new User(Alias = 'standt', Email='standarduser2@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2@testorg444555666.com');

        insert new List<User>{u, u2};

        Contact cnt = new Contact(
            FirstName='Joe',
            LastName='Smith',
            Phone='1231231231',
            AccountId=acc1.id);
        insert cnt;
                    
        Meet_Comp__c[] meetComps = new List<Meet_Comp__c>();
        
        for(integer i = 0; i < 100; i++) {
            Meet_Comp__c mc = new Meet_Comp__c(
                OwnerId = i == 40 ? u.Id : u2.Id,
                GEA_Individual_who_received_the_data__c = u.Id,
                Account__c = acc1.Id,
                Competitive_Inventory_Financing_pct__c = 5,
                Competitive_Invoice_Price__c = 5,
                Competitive_Other_Backside_pct__c = 5,
                Competitive_Price_Promotional_Diff__c = 5, 
                Competitive_Sales_Campaigns_Promos__c = 5,
                Competitive_Volume_Rebate_PIF__c =  5,
                Contact_Name__c = cnt.Id,
                Date_Competitive_Data_Received__c = Date.today().addDays(-3),
                Effective_Date__c = Date.today().addDays(3),
                GEA_Inventory_Financing__c = 5,
                GEA_Meet_Comp_Price__c = 5,
                GEA_Other_Backside__c = 5,
                GEA_Price_Promotional_Difference_PPD__c = 5,
                GEA_Sales_Campaigns_and_Promotions__c = 5,
                GEA_Volume_Rebate_PIF__c = 5,
                Termination_Date_of_Competitive_Data__c = Date.today().addDays(5),
                Termination_Date__c = Date.today().addDays(7)
            );
            meetComps.add(mc);
        }
        insert meetComps;
        PS_MC_Notification_Config__c notificationConfig = new PS_MC_Notification_Config__c(Name = 'test', Default_Notification_User__c = UserInfo.getUserId());
        insert notificationConfig;
    }
    
    static testmethod void execute_ShouldSendEmailsToMcOwners() { 
        //WHEN
        Test.startTest();
        PS_MeetCompReminder_Batch.emailsSent = new Set<String>();
        PS_MeetCompReminder_Batch mcReminder = new PS_MeetCompReminder_Batch();
        Database.executeBatch(mcReminder);
        Test.stopTest();
        
        //THEN
        System.AssertEquals(100, PS_MeetCompReminder_Batch.emailsSent.size(), 'Should send emails for 100 MC records');
        for(Meet_Comp__c mc : [SELECT OwnerId, Name FROM Meet_Comp__c]){
           System.AssertEquals(true, PS_MeetCompReminder_Batch.emailsSent.contains(mc.OwnerId + ':' + mc.Name),'Should send emails to MC Owners'); 
        }  
    }
    
    static testmethod void execute_ShouldSendEmailsToAccountOwners() { 
        //GIVEN
        User u = [SELECT isActive FROM USER WHERE Email = 'standarduser@testorg.com'];
        u.IsActive = false;
        update u;
        
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Account a = [SELECT Id FROM Account WHERE Name = 'Account 2'];
        Contact c = [SELECT accountId FROM Contact WHERE LastName = 'Smith'];
        c.accountId = a.Id;
        System.runAs(currentUser){
            update a;
        }
        
        //WHEN
        Test.startTest();
        PS_MeetCompReminder_Batch.emailsSent = new Set<String>();
        PS_MeetCompReminder_Batch mcReminder = new PS_MeetCompReminder_Batch();
        Database.executeBatch(mcReminder);
        Test.stopTest();
        
        //THEN
        System.AssertEquals(100, PS_MeetCompReminder_Batch.emailsSent.size());
        for(Meet_Comp__c mc : [SELECT Account__r.OwnerId, Name FROM Meet_Comp__c WHERE Owner.Email = 'standarduser@testorg.com']){
           System.AssertEquals(true, PS_MeetCompReminder_Batch.emailsSent.contains(mc.Account__r.OwnerId + ':' + mc.Name),
                              'Should send email to account owner if MC owner is not active'); 
        }
        for(Meet_Comp__c mc : [SELECT OwnerId, Name FROM Meet_Comp__c WHERE Owner.Email = 'standarduser2@testorg.com']){
           System.AssertEquals(true, PS_MeetCompReminder_Batch.emailsSent.contains(mc.OwnerId + ':' + mc.Name),
                              'Should send email to MC owner if active'); 
        } 
    }
    
    static testmethod void execute_ShouldSendEmailsToDefaultEmail() { 
        //GIVEN
        User userToDeactivate = [SELECT isActive FROM USER WHERE Email = 'standarduser@testorg.com'];
        Account acc = [SELECT OwnerId FROM Account WHERE Name = 'Account 1'];
        acc.OwnerId = userToDeactivate.Id;
        update acc;

        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(currentUser) {
            userToDeactivate.IsActive = false; 
            update userToDeactivate;   
        }
        
        //WHEN
        Test.startTest();
        PS_MeetCompReminder_Batch.emailsSent = new Set<String>();
        PS_MeetCompReminder_Batch mcReminder = new PS_MeetCompReminder_Batch();
        Database.executeBatch(mcReminder);
        Test.stopTest();
        
        //THEN
        System.AssertEquals(100, PS_MeetCompReminder_Batch.emailsSent.size());
        for(Meet_Comp__c mc : [SELECT Account__r.OwnerId, Name FROM Meet_Comp__c WHERE Owner.Email = 'standarduser@testorg.com']){
           System.AssertEquals(true, PS_MeetCompReminder_Batch.emailsSent.contains(UserInfo.getUserId() + ':' + mc.Name),
                              'If MC owner and account owner are not active, should send email to Default User'); 
        }
        for(Meet_Comp__c mc : [SELECT OwnerId, Name FROM Meet_Comp__c WHERE Owner.Email = 'standarduser2@testorg.com']){
           System.AssertEquals(true, PS_MeetCompReminder_Batch.emailsSent.contains(mc.OwnerId + ':' + mc.Name)); 
        } 
    }
}