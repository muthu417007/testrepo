@IsTest
public with sharing class PS_SetCustomerIdPSessionIdBatchTest {

    private static final String DEFAULT_CUSTOMER_LOGIN_PROFILE = 'Default Customer Login User';
    private static final String SYSTEM_ADMIN_PROFILE = 'System Administrator';

    @IsTest
    public static void shouldSetCustomerSessionId_WhenNull() {
        System.debug(LoggingLevel.INFO, 'shouldSetCustomerSessionId_WhenNull BEGIN ' + System.now().time());

        //given
        final Integer TEST_AMOUNT = 200;
        String userName = 'pssetcustomeridtest';
        User adminUser = [SELECT Id FROM User WHERE Id = :System.UserInfo.getUserId() LIMIT 1];
        System.runAs(adminUser) {
            //Create portal account owner
            UserRole portalRole = [
                    SELECT Id
                    FROM UserRole
                    WHERE PortalType = 'None'
                    LIMIT 1
            ];
            Profile sysAdminProfile = [
                    SELECT Id
                    FROM Profile
                    WHERE Name = :SYSTEM_ADMIN_PROFILE
            ];
            String ownerUsername =
                    System.now().millisecond() +
                            Math.rint(Math.random() * 1000) +
                            'test86934@test.com';
               
        User portalAccountOwner = new User(
                UserRoleId = portalRole.Id,
                ProfileId = sysAdminProfile.Id,
                Username = ownerUsername,
                Alias = 'test1',
                Email = ownerUsername,
                EmailEncodingKey = 'UTF-8',
                FirstName = 'test1',
                LastName = 'test1',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago'
                );
                insert portalAccountOwner;
        
            //Create account
            Account portalAccount = new Account(
                    Name = userName +
                            'portal@' +
                            System.now().millisecond() +
                            'test5436.com',
                    OwnerId = portalAccountOwner.Id
            );
            insert portalAccount;
        
            //Create contact
            List<Contact> contacts = new List<Contact>();
            for (Integer i = 0; i < TEST_AMOUNT; i++) {
                contacts.add(
                        new Contact(
                                FirstName = 'test2',
                                LastName = userName + 'portalTest2',
                                AccountId = portalAccount.Id,
                                Job_Title__c = System.now().millisecond() + Math.rint(Math.random() * 1000) + userName + 'portal@test2.com',
                                Email = System.now().millisecond() + Math.rint(Math.random() * 1000) + userName + 'portal@test2.com'
                        )
                );
            }
            insert contacts;
        
            //Create user
            Profile portalProfile = [
                    SELECT Id
                    FROM Profile
                    WHERE Name = :DEFAULT_CUSTOMER_LOGIN_PROFILE
                    LIMIT 1
            ];
        
            List<User> users = new List<User>();
            for (Integer i = 0; i < TEST_AMOUNT; i++) {
                String portalUserName =
                        userName +
                                'portal' +
                                System.now().millisecond() +
                                Math.rint(Math.random() * 10000) + i +
                                '@test54677.com';
                users.add(
                        new User(
                                Username = portalUserName,
                                ContactId = contacts.get(i).Id,
                                ProfileId = portalProfile.Id,
                                Alias = 'test123',
                                Email = portalUserName,
                                EmailEncodingKey = 'UTF-8',
                                LastName = 'lastNameTest322',
                                Latitude = 10,
                                Longitude = 10,
                                CommunityNickname = 'test123' + i,
                                TimeZoneSidKey = 'Europe/London',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US'
                        )
                );
            }
            insert users;
        }

        List<User> users = new List<User>();
        for (User user : [
                SELECT Id
                FROM User
                WHERE IsPortalEnabled = TRUE AND LastName = 'lastNameTest322'
        ]) {
            user.Customer_IdP_Session_Id__c = null;
            users.add(user);
        }
        update users;

        //then
        Test.startTest();
        Database.executeBatch(new PS_SetCustomerIdPSessionIdBatch(), 400);
        Test.stopTest();

        System.assertEquals(
                TEST_AMOUNT,
                [
                        SELECT Id
                        FROM User
                        WHERE Customer_IdP_Session_Id__c != NULL AND IsPortalEnabled = TRUE AND LastName = 'lastNameTest322'
                ].size(),
                'Invalid number of users with new Customer IdP Session Id'
        );
    }
}