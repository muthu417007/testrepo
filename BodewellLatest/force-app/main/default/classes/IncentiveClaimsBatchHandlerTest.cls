/**
 * @author         Niku Singh
 * @company        GEA
 * @created        03/29/2022
 * @description    Test Class for IncentiveClaimsBatchable, IncentiveClaimsBatchHandler, IncentiveClaimsScheduleDispatcher, IncentiveClaimsScheduler, IncentiveClaimTrigger, IncentiveClaim_TriggerHandler
 */
@isTest
public class IncentiveClaimsBatchHandlerTest {
    @testSetup static void setup(){
        Id contractRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Contract Direct').getRecordTypeId();
        
        UserRole ur = [Select id from UserRole where DeveloperName='Florida_Manager_Contract'];
        Profile p = [SELECT Id FROM Profile WHERE Name='HQ']; 
        Profile p2 = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u1 = new User(Alias = 'stand1t', Email='standarduser1@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = ur.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='standardTestuser1@testorg.com');
        insert u1;
        
        User u2 = new User(Alias = 'standt2', Email='standarduser2@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p2.Id, UserRoleId = ur.Id, ManagerId = u1.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='standardTestuser2@testorg.com');
        insert u2;
        system.runAs(u1){
            PS_AccountTriggerHandler.TriggerDisabled = true;
            Account testAccount = new Account(Name='TestAccount', Phone='6538264578', Doing_Business_As_DBA__c='TestAccount123', Channel__c='Retail', Oracle_Account_Number__c='213456', Website='test@parent.com', Brands_Allowed__c='GE;GE Profile Series;Hotpoint;Monogram;Haier;Café', recordtypeid=contractRecordTypeId);
        	insert testAccount;
            Incentive_claim__c incl1 = new Incentive_claim__c(Account_Name__c=testAccount.Id,
                                                        Project_Name__c='TestClass Project', 
                                                        Project_Account_cust_code__c='123987', 
                                                        Project_Location_City__c='Test City',
                                                        Project_Location_State__c='Test State', 
                                                        I_have_verified_the_account_has_billing__c='Yes',
                                                        Requestor_s_Region_Manager__c= u1.Id,
                                                        ASM_Receiving_Project_Billing__c = u1.Id,
                                                        Value__c = 84597,
                                                        Check_box_to_verify_I_reviewed_my_claim__c= True,
                                                        Award_Qualifier__c = 'GSB_$');
            insert incl1;
            Incentive_claim__c incl2 = new Incentive_claim__c(Account_Name__c=testAccount.Id,
                                                        Project_Name__c='TestClass Project2', 
                                                        Project_Account_cust_code__c='123985', 
                                                        Project_Location_City__c='Test City',
                                                        Project_Location_State__c='Test State', 
                                                        I_have_verified_the_account_has_billing__c='Yes',
                                                        Requestor_s_Region_Manager__c= u1.Id,
                                                        ASM_Receiving_Project_Billing__c = u1.Id,
                                                        Value__c = 84597,
                                                        Check_box_to_verify_I_reviewed_my_claim__c= True,
                                                        Award_Qualifier__c = 'GSB_$');
            insert incl2;
        }
    }
    
    @isTest
    static void testIncentiveClaimInsertion(){
        User u = [Select id,LastName from User where LastName='Testing2'];
        Incentive_claim__c ic1 = [Select id from Incentive_claim__c where Project_Name__c='TestClass Project'];
        Incentive_claim__c ic2 = [Select id,Name from Incentive_claim__c where Project_Name__c='TestClass Project2'];
        Test.startTest();
        System.assertEquals(u.LastName, 'Testing2', 'Name should Match');
        system.runAs(u){
            Approval.ProcessSubmitRequest req1 = 
            new Approval.ProcessSubmitRequest();
        	req1.setComments('Submitting request for approval.');
        	req1.setObjectId(ic1.id);
        
            // Submit on behalf of a specific submitter
            req1.setSubmitterId(u.Id); 
            
            // Submit the record to specific process and skip the criteria evaluation
            req1.setProcessDefinitionNameOrId('Incentive_claims_approval_V2');
            req1.setSkipEntryCriteria(true);
            
            // Submit the approval request for the Incentive Claim
            Approval.ProcessResult result = Approval.process(req1);
            
            Approval.ProcessSubmitRequest req2 = 
            new Approval.ProcessSubmitRequest();
        	req2.setComments('Submitting request for approval.');
        	req2.setObjectId(ic2.id);
        
            // Submit on behalf of a specific submitter
            req2.setSubmitterId(u.Id); 
            
            // Submit the record to specific process and skip the criteria evaluation
            req2.setProcessDefinitionNameOrId('Incentive_claims_approval_V2');
            req2.setSkipEntryCriteria(true);
            
            // Submit the approval request for the Incentive Claim
            Approval.ProcessResult result2 = Approval.process(req2);
            System.debug(Logginglevel.INFO,'result---'+result2);
            String cronEXP = '0 0 0 3 9 ? 2031';

            //WHEN
            String jobId = System.schedule('testIncentiveClaimsScheduledApex', CRONEXP,  new IncentiveClaimsScheduleDispatcher());
    
            //THEN
            //CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            
        }
        Test.stopTest();
    }
    @isTest
    static void testIncentiveClaimInsertion2(){
        Incentive_claim__c ic1 = [Select id,Name from Incentive_claim__c where Project_Name__c='TestClass Project'];
        Account testAccount = [Select Id,Name from Account where name='TestAccount'];
        User u1 = [Select id from User where LastName='Testing1'];
        test.startTest();
        System.assertEquals(testAccount.name, 'TestAccount', 'Name should Match');
        Incentive_claim__c incl2 = new Incentive_claim__c(Account_Name__c=testAccount.Id,
                                                        Project_Name__c='TestClass Project2', 
                                                        Project_Account_cust_code__c='123985', 
                                                        Project_Location_City__c='Test City',
                                                        Project_Location_State__c='Test State', 
                                                        I_have_verified_the_account_has_billing__c='Yes',
                                                        Requestor_s_Region_Manager__c= u1.Id,
                                                        ASM_Receiving_Project_Billing__c = u1.Id,
                                                        Value__c = 84597,
                                                        Check_box_to_verify_I_reviewed_my_claim__c= True,
                                                        Award_Qualifier__c = 'GSB_$');
            insert incl2;
        ic1.Project_Name__c='TestClass Project3';
        
        update ic1;
        delete ic1;
        test.stopTest();
    }

}