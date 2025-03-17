@isTest
public class BWC_geolocateZipcodeControllerTest {

    @isTest
    static void testGetZipcode() {
     String latlng='abc,abc';
        
        Test.setMock(HttpCalloutMock.class, new BWC_ZipcodeMockGenerator());
        
        String result =BWC_geolocateZipcodeController.getZipcodeByLatLong(latlng);
        
        System.assertEquals('{"example":"test"}', result);
        
         }

         @isTest
    static void testGetAddress() {
     String latlng='0000';
        
        Test.setMock(HttpCalloutMock.class, new BWC_ZipcodeMockGenerator());
        
        String result =BWC_geolocateZipcodeController.getAddress(latlng);
        
        System.assertEquals('{"example":"test"}', result);
        
         }


         @isTest
         static void testUpdateUser() {
   // Create a test user

   Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

   User testUser = new User(

ProfileId = profile.Id,

       Username = 'testbodewell123@example.com',

       Email = 'testbodewell123@example.com',
Lastname='userbodewell',
       Alias = 'testuser',

       TimeZoneSidKey = 'America/Los_Angeles',

       LocaleSidKey = 'en_US',

       EmailEncodingKey = 'UTF-8',

       LanguageLocaleKey = 'en_US'

   );

   insert testUser;

User user=BWC_geolocateZipcodeController.updateUserZipcode(testUser.Id,'412726');
system.assertEquals('412726',user.BWC_Current_Location_ZipCode__c);
         }
}