@IsTest
public with sharing class PS_RemoteAdminRegisterEmailWServiceTest {

    private static final String TEST_EMAIL = 'contact@email.com';
    private static final String DUMMY_ACCOUNT_NAME = 'Dummy Account Name';
    private static final String DUMMY_ACCOUNT_RECORD_TYPE = 'Location';
    private static final String DUMMY_CONTACT_LASTNAME = 'Dummy Contact Lastname';
    private static final String DUMMY_CONTACT_RECORD_TYPE = 'Consumer';
    private static final String TEST_GLOBAL_CUSTOMER_ID = '987654';

    @IsTest
    public static void shouldReturnExistingUser_WhenValidParam() {
        //given
        Contact contact = new Contact(
                LastName = 'lastname',
                Global_Customer_Id__c = TEST_GLOBAL_CUSTOMER_ID,
                Email = TEST_EMAIL
        );
        insert contact;

        //then
        Test.startTest();
        PS_RemoteAdminRegisterEmailWebService.EmailRegistrationResponse emailRegistrationResponse =
                PS_RemoteAdminRegisterEmailWebService.getUser(TEST_EMAIL);
        Test.stopTest();

        System.assertEquals(
                TEST_EMAIL,
                emailRegistrationResponse.email,
                'Invalid email value'
        );

        System.assertNotEquals(
                null,
                emailRegistrationResponse.globalId,
                'Invalid global Id value'
        );
    }

    @IsTest
    public static void shouldReturnNewUser_WhenValidParam() {
        //given
        Customer_IdP_Configuration__mdt customerIdPConfiguration = new Customer_IdP_Configuration__mdt(
                Registration_Account_Defaults__c = JSON.serialize(new Account(Name = DUMMY_ACCOUNT_NAME)),
                Registration_Account_RecordType__c = DUMMY_ACCOUNT_RECORD_TYPE,
                Registration_Contact_Defaults__c = JSON.serialize(new Contact(LastName = DUMMY_CONTACT_LASTNAME)),
                Registration_Contact_RecordType__c = DUMMY_CONTACT_RECORD_TYPE
        );

        //then
        Test.startTest();
        PS_GEAIdPCustomerConfigHelper.customerIdPConfiguration = customerIdPConfiguration;
        PS_RemoteAdminRegisterEmailWebService.EmailRegistrationResponse emailRegistrationResponse =
                PS_RemoteAdminRegisterEmailWebService.getUser(TEST_EMAIL);
        Test.stopTest();

        System.assertEquals(
                TEST_EMAIL,
                emailRegistrationResponse.email,
                'Invalid email value'
        );

        Account insertedAccount = [SELECT Name FROM Account].get(0);

        System.assertEquals(
                DUMMY_ACCOUNT_NAME,
                insertedAccount.Name,
                'Invalid inserted account name'
        );

        Contact insertedContact = [SELECT LastName,Email FROM Contact WHERE AccountId = :insertedAccount.Id LIMIT 1];

        System.assertEquals(
                DUMMY_CONTACT_LASTNAME,
                insertedContact.LastName,
                'Invalid contact lastname value'
        );

        System.assertEquals(
                TEST_EMAIL,
                insertedContact.Email,
                'Invalid email value'
        );
    }

    @IsTest
    public static void shouldThrowError_WhenInvalidParam() {
        //given
        Boolean exceptionThrown = false;
        //then
        Test.startTest();
        try {
            PS_RemoteAdminRegisterEmailWebService.getUser(null);
        } catch (Exception e) {
            exceptionThrown = e instanceof IllegalArgumentException;
        }
        Test.stopTest();

        System.assertEquals(
                true,
                exceptionThrown,
                'Exception should be thrown'
        );
    }
}