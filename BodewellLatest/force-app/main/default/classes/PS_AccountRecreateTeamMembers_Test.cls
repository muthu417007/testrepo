@isTest
private class PS_AccountRecreateTeamMembers_Test {

    static testMethod void beforeUpdate_queryAndThenRecreateAccountTeam () {
        
        Profile prof = [select Id from profile where name LIKE '%System Administrator%'];
        List<User> users = new List<User>();
        for (Integer i = 0; i < 5; i++) {
            users.add(new User(
                firstName = 'Abc' + i,
                lastName = 'xyz' + i,
                Alias = 'abcb' + i,
                profileId = prof.Id,
                username = 'abcabc' + i + '.xyz@test.com',
                email = 'test' + i + '@test.com',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'
            ));
        }
        insert users;

        System.runAs(users[1]) {
            PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = 'B2B_Sales_Update_Account_Name'];
            PermissionSetAssignment psa1 = new PermissionSetAssignment(
                PermissionSetId = permSet.Id,
                AssigneeId = UserInfo.getUserId()
            );
            insert psa1;
            PermissionSetAssignment psa2 = new PermissionSetAssignment(
                PermissionSetId = permSet.Id,
                AssigneeId = users[0].Id
            );
            insert psa2;
        }

        Account account;
        System.runAs(users[0]) {
            account = new Account(Name = 'Account 1');
            insert account;
            List<AccountTeamMember> members = new List<AccountTeamMember>();
            for (Integer i = 2; i < 5; i++) {
                members.add(new AccountTeamMember(
                    AccountAccessLevel = 'Edit',
                    AccountId = account.Id,
                    UserId = users[i].Id
                ));
            }
            insert members;
        }

        users[3].IsActive = false;
        update users[3];
        
        Test.startTest();

        System.assertEquals(3, [SELECT count() FROM AccountTeamMember WHERE AccountId = :account.Id]);

        account.OwnerId = users[1].Id;
        System.runAs(users[0]) {
            update account;
        }

        System.assertEquals(0, [SELECT count() FROM AccountTeamMember WHERE AccountId = :account.Id]);

        Test.stopTest();

        //System.assertEquals(3, [SELECT count() FROM AccountTeamMember WHERE AccountId = :account.Id]);
    }

    static testMethod void beforeUpdate_queryAndThenRecreateAccountTeamWithOwnerOfMeetComps () {
        
        Profile prof = [select Id from profile where name LIKE '%System Administrator%'];
        List<User> users = new List<User>();
        for (Integer i = 0; i < 5; i++) {
            users.add(new User(
                firstName = 'Abc' + i,
                lastName = 'xyz' + i,
                Alias = 'abcb' + i,
                profileId = prof.Id,
                username = 'abcabc' + i + '.xyz@test.com',
                email = 'test' + i + '@test.com',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'
            ));
        }
        insert users;

        System.runAs(users[1]) {
            PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = 'B2B_Sales_Update_Account_Name'];
            PermissionSetAssignment psa1 = new PermissionSetAssignment(
                PermissionSetId = permSet.Id,
                AssigneeId = UserInfo.getUserId()
            );
            insert psa1;
            PermissionSetAssignment psa2 = new PermissionSetAssignment(
                PermissionSetId = permSet.Id,
                AssigneeId = users[0].Id
            );
            insert psa2;
        }

        Account account;
        System.runAs(users[0]) {
            account = new Account(Name = 'Account 1', Meet_Comp_Eligibility__c = 'National');
            insert account;
            List<AccountTeamMember> members = new List<AccountTeamMember>();
            for (Integer i = 2; i < 5; i++) {
                members.add(new AccountTeamMember(
                    AccountAccessLevel = 'Edit',
                    AccountId = account.Id,
                    UserId = users[i].Id
                ));
            }
            insert members;
            Contact cnt = new Contact(
                FirstName = 'Joe',
                LastName = 'Smith',
                Phone = '4155551212',
                AccountId = account.id);
            insert cnt;
            insert new Meet_Comp__c(
                GEA_Individual_who_received_the_data__c = userInfo.getUserId(),
                Account__c = account.Id,
                Competitive_Inventory_Financing_pct__c = 5,
                Competitive_Invoice_Price__c = 5,
                Competitive_Other_Backside_pct__c = 5,
                Competitive_Price_Promotional_Diff__c = 5,
                Competitive_Sales_Campaigns_Promos__c = 5,
                Competitive_Volume_Rebate_PIF__c =  5,
                Contact_Name__c = cnt.Id,
                Date_Competitive_Data_Received__c = Date.today().addDays(-3),
                GEA_Inventory_Financing__c = 5,
                GEA_Meet_Comp_Price__c = 5,
                GEA_Other_Backside__c = 5,
                GEA_Price_Promotional_Difference_PPD__c = 5,
                GEA_Sales_Campaigns_and_Promotions__c = 5,
                GEA_Volume_Rebate_PIF__c = 5
            );
        }
        
        Test.startTest();

        System.assertEquals(3, [SELECT count() FROM AccountTeamMember WHERE AccountId = :account.Id]);

        account.OwnerId = users[1].Id;
        System.runAs(users[0]) {
            update account;
        }

        System.assertEquals(0, [SELECT count() FROM AccountTeamMember WHERE AccountId = :account.Id]);

        Test.stopTest();

        //System.assertEquals(3, [SELECT count() FROM AccountTeamMember WHERE AccountId = :account.Id]);
    }
}