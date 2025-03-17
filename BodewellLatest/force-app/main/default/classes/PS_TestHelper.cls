@SuppressWarnings('sf:TestClassWithoutTestCases')
@IsTest
public without sharing class PS_TestHelper {

    @TestVisible
    private static final String DEFAULT_CUSTOMER_LOGIN_PROFILE = 'Default Customer Login User';
    private static final String SYSTEM_ADMIN_PROFILE = 'System Administrator';
    private static final String AIR_WATER_DISTRIBUTOR_ADMIN = 'Air and Water Distributor Admin';
    private static final String MINIMUM_ACCESS_PROFILE = 'Minimum Access - Salesforce';
    private static final String CUSTOMER_REMOTE_ADMIN_PERMISSION = 'Customer_IdP_Remote_Administrator';

    public static void createPortalUserWithAccount(String userName) {
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
            Contact contact = new Contact(
                    FirstName = 'test2',
                    LastName = userName + 'portalTest2',
                    AccountId = portalAccount.Id,
                    Job_Title__c = System.now().millisecond() + Math.rint(Math.random() * 1000) + userName + 'portal@test2.com',
                    Email = System.now().millisecond() + Math.rint(Math.random() * 1000) + userName + 'portal@test2.com'
            );
            insert contact;

            //Create user
            Profile portalProfile = [
                    SELECT Id
                    FROM Profile
                    WHERE Name = :DEFAULT_CUSTOMER_LOGIN_PROFILE
                    LIMIT 1
            ];

            String portalUserName =
                    userName +
                            'portal' +
                            System.now().millisecond() +
                            Math.rint(Math.random() * 1000) +
                            '@test54672.com';
            User portalUser = new User(
                    Username = portalUserName,
                    ContactId = contact.Id,
                    ProfileId = portalProfile.Id,
                    Alias = 'test123',
                    Email = portalUserName,
                    EmailEncodingKey = 'UTF-8',
                    LastName = 'lastNameTest332',
                    Latitude = 10,
                    Longitude = 10,
                    CommunityNickname = 'test12345',
                    TimeZoneSidKey = 'Europe/London',
                    LocaleSidKey = 'en_US',
                    LanguageLocaleKey = 'en_US',
                    PA_Transformed__c = true,
                    IsActive = TRUE
                
            );
            insert portalUser;

        }
    }
    
    /*
     * This method is created for testing the Air water login. 
     * */
    public static void createAirWaterUser(String userName) {
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
                            'AW_test86934@test.com';
            User portalAccountOwner = new User(
                    UserRoleId = portalRole.Id,
                    ProfileId = sysAdminProfile.Id,
                    Username = ownerUsername,
                    Alias = 'test1_AW',
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
                            'ANW_test5436.com',
                    OwnerId = portalAccountOwner.Id
            );
            insert portalAccount;

            
           List<RecordType> recType = [SELECT Id  FROM RecordType where SobjectType ='Contact' and developerName='Air_and_Water_Distributor' ];
            
            //Create contact
            Contact contact = new Contact(
                    FirstName = 'test2',
                    LastName = userName + 'portalTest2',
                    AccountId = portalAccount.Id,
                    Job_Title__c = System.now().millisecond() + Math.rint(Math.random() * 1000) + userName + 'portal@test2.com',
                    Email = 'Anw_'+System.now().millisecond() + Math.rint(Math.random() * 1000) + userName + 'portal@test2.com',
                	recordtypeid = recType[0].id
            );
            insert contact;

            //Create user
            Profile portalProfile = [
                    SELECT Id
                    FROM Profile
                    WHERE Name = :AIR_WATER_DISTRIBUTOR_ADMIN
                    LIMIT 1
            ];

            String portalUserName =
                    userName +
                            'portal_anw' +
                            System.now().millisecond() +
                            Math.rint(Math.random() * 1000) +
                            '@test54672.com';
            User portalUser = new User(
                    Username = portalUserName,
                    ContactId = contact.Id,
                    ProfileId = portalProfile.Id,
                    Alias = 'anw_test',
                    Email = portalUserName,
                    EmailEncodingKey = 'UTF-8',
                    LastName = 'lastNameTest332',
                    Latitude = 10,
                    Longitude = 10,
                    CommunityNickname = 'AW_test',
                    TimeZoneSidKey = 'Europe/London',
                    LocaleSidKey = 'en_US',
                    LanguageLocaleKey = 'en_US',
                    PA_Transformed__c = true,
                    IsActive = TRUE
                
                
            );
            insert portalUser;

        }
    }

    public static void createRemoteAdminUser(String userName) {
        User adminUser = [SELECT Id FROM User WHERE Id = :System.UserInfo.getUserId() LIMIT 1];

        System.runAs(adminUser) {
            UserRole adminRole = [
                    SELECT Id
                    FROM UserRole
                    WHERE PortalType = 'None'
                    LIMIT 1
            ];

            Profile minimumAccessProfile = [
                    SELECT Id
                    FROM Profile
                    WHERE Name = :MINIMUM_ACCESS_PROFILE
            ];

            String remoteAdminUsername =
                    userName +
                            'remoteAdmin' +
                            System.now().millisecond() +
                            Math.rint(Math.random() * 1000) +
                            '@test54673.com';
            User portalUser = new User(
                    Username = remoteAdminUsername,
                    ProfileId = minimumAccessProfile.Id,
                    UserRoleId = adminRole.Id,
                    Alias = 'test123',
                    Email = remoteAdminUsername,
                    EmailEncodingKey = 'UTF-8',
                    LastName = 'lastNameTest332',
                    Latitude = 10,
                    Longitude = 10,
                    CommunityNickname = 'test12' + Math.rint(Math.random() * 1000),
                    TimeZoneSidKey = 'Europe/London',
                    LocaleSidKey = 'en_US',
                    LanguageLocaleKey = 'en_US'
            );
            insert portalUser;

            PermissionSet customerRemoteAdminPermission = [
                    SELECT Id
                    FROM PermissionSet
                    WHERE Name = :CUSTOMER_REMOTE_ADMIN_PERMISSION
                    LIMIT 1
            ];

            insert new PermissionSetAssignment(
                    PermissionSetId = customerRemoteAdminPermission.Id,
                    AssigneeId = portalUser.Id
            );
        }
    }

    public static void createGuestUser(String userName) {
        User adminUser = [SELECT Id FROM User WHERE Id = :System.UserInfo.getUserId() LIMIT 1];

        System.runAs(adminUser) {
            Profile guestUserProfile = [
                    SELECT Id
                    FROM Profile
                    WHERE Name = :'Guest License User'
            ];

            String guestUsername =
                    userName +
                            'guestUser' +
                            System.now().millisecond() +
                            Math.rint(Math.random() * 1000) +
                            '@test54699.com';
            User guestUser = new User(
                    Username = guestUsername,
                    ProfileId = guestUserProfile.Id,
                    Alias = 'test123',
                    Email = guestUsername,
                    EmailEncodingKey = 'UTF-8',
                    LastName = 'lastNameTest332',
                    Latitude = 10,
                    Longitude = 10,
                    CommunityNickname = 'test12' + Math.rint(Math.random() * 1000),
                    TimeZoneSidKey = 'Europe/London',
                    LocaleSidKey = 'en_US',
                    LanguageLocaleKey = 'en_US'
            );
            insert guestUser;
        }
    }


    public static List<User> getCreatedPortalUser(String uniqueName) {
        String portalUserBaseName = '%' + uniqueName + 'portal%';
        return [
                SELECT Id,ContactId,Username,Customer_IdP_Session_Id__c,Contact.Global_Customer_Id__c,Email
                FROM User
                WHERE Username LIKE :portalUserBaseName
                ORDER BY FirstName ASC
        ];
    }
    
    public static List<User> getCreatedPortalUser_AirWaterUser(String uniqueName) {
        String portalUserBaseName = '%' + uniqueName + 'portal%';
        return [
                SELECT Id,ContactId,Username,Customer_IdP_Session_Id__c,Contact.Global_Customer_Id__c,Email
                FROM User
                WHERE Username LIKE :portalUserBaseName
                ORDER BY FirstName ASC
        ];
    }

    public static User getCreatedRemoteAdminUser(String uniqueName) {
        String portalUserBaseName = '%' + uniqueName + 'remoteAdmin%';
        return [
                SELECT Id,ContactId,Username,Email
                FROM User
                WHERE Username LIKE :portalUserBaseName
                LIMIT 1
        ];
    }

    public static User getCreatedGuestUser(String uniqueName) {
        String guestUserBaseName = '%' + uniqueName + 'guestUser%';
        return [
                SELECT Id,ContactId,Username,Email
                FROM User
                WHERE Username LIKE :guestUserBaseName
                LIMIT 1
        ];
    }

    public static Account getCreatedPortalAccount(String uniqueName) {
        String portalAccountBaseName = '%' + uniqueName + 'portal%';
        return [
                SELECT Id, Name
                FROM Account
                WHERE Name LIKE :portalAccountBaseName
                LIMIT 1
        ];
    }

    public static Contact getCreatedPortalContact(String uniqueName) {
        String portalContactBaseName = '%' + uniqueName + 'portal%';
        return [
                SELECT Id, Name
                FROM Contact
                WHERE Job_Title__c LIKE :portalContactBaseName
                LIMIT 1
        ];
    }
}