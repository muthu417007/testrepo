@SuppressWarnings('PMD')

@isTest
public with sharing class BWC_TestDataFactory {
    private static final String SYSTEM_ADMIN_PROFILE = 'System Administrator';
    private static final String CUSTOMER_COMMUNITY_PROFILE = 'Bodewell Commerce D2C Login User%';
    private static final List<String> PERMISSION_SET_DEALER = new List<String>{ 'Buyer' };
    private static final String FINISHED_GOODS_BEVERAGES = 'ZFER';
    private static final String TEST_SKU = 'ABCD';
    @TestVisible
    private static final String PROD_NAME = 'Test Product';
    @TestVisible
    private static final String USER_FIRST_NAME_GEA = 'GEA';

    /**
    * @description  creats Account
    * @return       Account
    */
    public static Account createAccount() {
        Account account = new Account();
        account.BillingStreet = 'New York Street';
        account.BillingCity = 'New York';
        account.BillingCountry = 'USA';
        account.BillingPostalCode = '234324';

        account.ShippingStreet = 'Candata Street';
        account.ShippingCity = 'Canada';
        account.ShippingCountry = 'Canada';
        account.ShippingPostalCode = '32432';
        account.Name = 'Test Account';
        insert account;
        return account;
    }

    /**
    * @description  Use this if you need to modify some data on account before inserting it
    * @return       Account
    */
    public static Account returnAccount() {
        Account account = new Account(AccountNumber = '0500939572',
                Name = 'Arellano Williams',
                ShippingStreet = '11401 Peppergrass Trl',
                ShippingCountry = 'USA',
                ShippingCity = 'Argyle',
                ShippingState = 'Texas',
                ShippingPostalCode = '76226',
                Email__c = '' ,
                Phone = ''
        );
        return account;
    }

    /**
    * @description  creats contact
    * @param accId  Account ID
    * @return       Contact
    */
    public static Contact createContact(String accId) {
        Contact contact = new Contact(
                AccountId = accId,
                FirstName = 'CONA',
                LastName = 'Test',
                MailingCity = 'testMailingCity',
                MailingStreet = 'testMailingStreet',
                Email = 'cona@gmail.com',
                MailingPostalCode = '90210',
                Phone='7639475'
        );
        insert contact;
        return contact;
    }

    /**
    * @description  return contact
    * @param accId  accid
    * @return       Contact
    */
    public static Contact returnContact(String accId) {
        Contact contact = new Contact(
                AccountId = accId,
                FirstName = 'Arellano',
                LastName = 'Williams',
                Email = 'Arellano.Williams@gmail.com'
        );
        return contact;
    }

    /**
     * @description  create Account
     * @param doInsert boolean to decide dml
     * @param ownerId  owneriD of Account
     * @param accountName Accountname
     * @return  `Account` returns Account Instance
     */
    public static Account createAccount(Boolean doInsert, String ownerId, String accountName) {
        Account account = new Account();
        account.BillingStreet = 'New York Street';
        account.BillingCity = 'New York';
        account.BillingCountry = 'USA';
        account.BillingPostalCode = '234324';

        account.ShippingStreet = 'Candata Street';
        account.ShippingCity = 'Canada';
        account.ShippingCountry = 'Canada';
        account.ShippingPostalCode = '32432';
        account.Name = accountName;
        if (ownerId != null) {
            account.ownerId = ownerId;
        }
        if (doInsert) {
            insert account;
        }
        return account;
    }

    /**
     * @description  creats contact
     * @param doInsert to decide Dml
     * @param accId  Account ID for contact
     * @return `Contact` Contact terurns contact instance
     */
    public static Contact createContact(Boolean doInsert, String accId) {
        Contact contact = new Contact(
            AccountId = accId,
            FirstName = 'GEA',
            LastName = 'Test',
            MailingCity = 'testMailingCity',
            MailingStreet = 'testMailingStreet',
            Email = 'gea@gmail.com',
            MailingPostalCode = '90210'
        );
        if (doInsert) {
            insert contact;
        }
        return contact;
    }

    /**
     * @description
     * Test util method to create User
     * @param contactId The contact record Id
     * @return `User` record is returned
     */
    public static User createCommerceUser(Id contactId) {
        User communityUser;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            communityUser = createCommunityUserWithProfile(contactId);
        }
        return communityUser;
    }

    /**
     * @description
     * @param queryLimit the query limit for SOQL
     * @return  `List<User>` list users returned
     */
    public static List<User> getCommerceUser(Integer queryLimit) {
        Assert.areNotEqual(queryLimit, 0, 'parameter queryLimit must be higher than zero');
        return new List<User>(
            [
                SELECT Id, Name
                FROM User
                WHERE Profile.Name LIKE :CUSTOMER_COMMUNITY_PROFILE
                LIMIT :queryLimit
            ]
        );
    }

    /**
     * @description  return contact
     * @param contactId contact id
     * @return       Contact
     */

    private static User createCommunityUserWithProfile(Id contactId) {
        Id profileId = [SELECT Id FROM Profile WHERE Name LIKE :CUSTOMER_COMMUNITY_PROFILE LIMIT 1].Id;
        String organizationId = UserInfo.getOrganizationId();
        String uniqueName = organizationId + Integer.valueOf(Math.rint(Math.random() * 1000000));
        uniqueName = uniqueName.leftPad(15, '0');
        User communityUser = new User(
            firstname = USER_FIRST_NAME_GEA,
            lastName = 'TestUser',
            email = 'gea@gmail.com',
            Username = uniqueName + '@test' + organizationId + '.org',
            Alias = uniqueName.substring(9, 15),
            TimeZoneSidKey = 'America/Los_Angeles',
            IsActive = true,
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            ProfileId = profileId,
            ContactId = contactId
        );
        insert communityUser;

        // Assign b2b permissionsets - avoId permissionset group due to recalculation cpu time
        List<PermissionSet> commercePermissionsets = [
            SELECT Id, Name
            FROM PermissionSet
            WHERE Name IN :PERMISSION_SET_DEALER
        ];

        List<PermissionSetAssignment> psas = new List<PermissionSetAssignment>();
        for (PermissionSet ps : commercePermissionsets) {
            psas.add(new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = communityUser.Id));
        }
        insert psas;
        return communityUser;
    }

    /**
     * @description  Creats User
     */
    @future
    public static void returnSysAdminUser() {
        Id profileId = [SELECT Id FROM Profile WHERE Name = :SYSTEM_ADMIN_PROFILE LIMIT 1].Id;
        String organizationId = UserInfo.getOrganizationId();

        UserRole userRole;
        String roleId = '';

        if (UserInfo.getUserRoleId() == null) {
            userRole = new UserRole(Name = 'CEO', DeveloperName = 'CEO');
            insert userRole;
            roleId = userRole.Id;
        } else {
            roleId = UserInfo.getUserRoleId();
        }

        String uniqueName = organizationId + Integer.valueOf(Math.rint(Math.random() * 1000000));
        uniqueName = uniqueName.leftPad(15, '0');
        User sysAdmUser = new User(
            firstname = 'Arellano',
            lastName = 'Williams',
            email = 'Arellano.Williams@gmail.com',
            Username = uniqueName + '@test' + organizationId + '.org',
            Alias = uniqueName.substring(9, 15),
            TimeZoneSidKey = 'America/Los_Angeles',
            IsActive = true,
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            ProfileId = profileId,
            UserRoleId = roleId
        );
        insert sysAdmUser;
    }
}