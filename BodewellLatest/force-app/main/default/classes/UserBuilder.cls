/**
 * description Datafactory / builder class for User object
 * Example usage
 *         User testUser = new UserBuilder()
 *            .setDefault()
 *           .setFirstName(UserBuilder.TEST_USER_FIRST_NAME)
 *            .setProfile(UserBuilder.PROFILE_NAME_SYSTEM_ADMINISTRATOR)
 *            .setRole(UserBuilder.ROLE_DEVELOPERNAME_CEO)
 *           .save();
 */
@IsTest
public with sharing class UserBuilder {
    public final static String PROFILE_NAME_STANDARD_USER = 'Standard User';
    public final static String PROFILE_NAME_SYSTEM_ADMINISTRATOR = 'System Administrator';
    public final static String ROLE_DEVELOPERNAME_CEO = 'CEO';
    public final static String TEST_USER_FIRST_NAME = 'Test User - ST';

    private static Map<String, Id> profileNameToIdMap;
    private static Map<String, Id> roleDeveloperNameToIdMap;

    /**
     * @description Get Standard Profile Id
     */
    public static Id getProfileId(String profileName) {
        if (profileNameToIdMap == null) {
            profileNameToIdMap = new Map<String, Id>();
            for (Profile p : [SELECT Id, Name FROM Profile WHERE UserType = 'Standard']) {
                profileNameToIdMap.put(p.Name, p.Id);
            }
        }
        return profileNameToIdMap.get(profileName);
    }

    /**
     * @description Get Role Id
     */
    public static Id getRoleId(String roleDeveloperName) {
        if (roleDeveloperNameToIdMap == null) {
            roleDeveloperNameToIdMap = new Map<String, Id>();
            for (UserRole role : [SELECT Id, DeveloperName FROM UserRole]) {
                roleDeveloperNameToIdMap.put(role.DeveloperName, role.Id);
            }
        }
        return roleDeveloperNameToIdMap.get(roleDeveloperName);
    }

    private User record;

    /**
     * @description Constructor, initilizes a new User
     */
    public UserBuilder() {
        record = new User();
    }

    /**
     * @description Set First Name
     */
    public UserBuilder setFirstName(String firstName) {
        record.FirstName = firstName;
        return this;
    }

    /**
     * @description Set Profile
     */
    public UserBuilder setProfile(String profileName) {
        record.ProfileId = getProfileId(profileName);
        return this;
    }

    /**
     * @description Set Role
     */
    public UserBuilder setRole(String roleDeveloperName) {
        record.UserRoleId = getRoleId(roleDeveloperName);
        return this;
    }

    /**
     * @description Assign Permission Set
     * Always run this method with
     * System.runAs(new User(Id = Userinfo.getUserId())) {}
     * otherwise a MIXED DML operation may occur
     */
    public static void assignPermissionSet(Id userId, String permissionSetApiName) {
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = :permissionSetApiName LIMIT 1];
        PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = userId);
        insert psa;
    }

    /**
     * @description Set User fields with static values
     */
    public UserBuilder setDefault() {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueOf(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
        Integer randomId = Integer.valueOf(Math.rint(Math.random() * 1000000));
        String uniqueName = orgId + dateString + randomId;

        record.FirstName = 'GEA';
        record.LastName = 'User';
        record.Email = uniqueName + '@test.org';
        record.Username = uniqueName + '@test' + orgId + '.org';
        record.EmailEncodingKey = 'ISO-8859-1';
        record.Alias = uniqueName.substring(18, 23);
        record.TimeZoneSidKey = 'America/Los_Angeles';
        record.LocaleSidKey = 'en_US';
        record.LanguageLocaleKey = 'en_US';
        return this;
    }

    public static String generateUserName(){
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueOf(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
        Integer randomId = Integer.valueOf(Math.rint(Math.random() * 1000000));
        String uniqueName = orgId + dateString + randomId;

        return uniqueName + '@test' + orgId + '.org';
    }

    /**
     * @description returns User record
     */
    public User build() {
        return record;
    }

    /**
     * @description inserts and returns User record
     */
    public User save() {
        insert record;
        return record;
    }

    public static User getUser() {
        User testUser = [SELECT Id FROM User WHERE FirstName = :TEST_USER_FIRST_NAME];
        return testUser;
    }
}