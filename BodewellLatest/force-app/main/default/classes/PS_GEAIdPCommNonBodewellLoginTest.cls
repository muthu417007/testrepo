@isTest
public class PS_GEAIdPCommNonBodewellLoginTest {
    private static final String CLASS_NAME = PS_GEAIdPCommLoginCtrlTest.class.getName().substring(0, 15);
    private static final String TEST_PASSWORD = 'TestPassword123';
     @isTest
     Public static void testnonBodewellLogin()
     {
         Test.StartTest();
         account acc= new account (FirstName='Test1', LastName='Account1',Email__c='Testemail1@bodewell.com');
        insert acc;
        system.debug('testest Insered acc data - ' + acc);
        String accid=acc.Id;
        system.debug('testest accid - ' + accid);
        
        try
        {  
        PS_TestHelper.createAirWaterUser(CLASS_NAME);
        User portalUser = PS_TestHelper.getCreatedPortalUser_AirWaterUser(CLASS_NAME).get(0);
       	system.debug('testest portalUser - ' + portalUser);
        System.setPassword(portalUser.Id, TEST_PASSWORD);
        User u = [SELECT ID FROM USer WHERE Id = : portalUser.Id];
        LoginHistory u2 = [SELECT Id,LoginUrl,UserId FROM LoginHistory where  (NOT LoginUrl LIKE '%bodewell%') limit 1];
        User u3 = [SELECT ID from User where Id=:u2.UserId] ;
        PS_GEAIdPCommNonBodewellLogin.nonBodewellLogin(u3.Id,'https://geapp--bwcommoob.sandbox.my.site.com/bodewellCommerce/login', u3);
        }
        catch(Exception e)
        {
            system.debug('testest Exception in test class - ' + e.getMessage());
        }
         Test.stoptest();
     }

}