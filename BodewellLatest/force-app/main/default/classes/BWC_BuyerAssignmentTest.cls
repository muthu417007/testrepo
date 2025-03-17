@isTest
public class BWC_BuyerAssignmentTest {
    private static final String CLASS_NAME = PS_GEAIdPCommLoginCtrlTest.class.getName().substring(0, 15);
    private static final String TEST_PASSWORD = 'TestPassword123';
     @isTest
    static  void testAssignBuyerGroup()
    {
        try
        {
        account acc= new account (FirstName='Test', LastName='Account',Email__c='Testemail@bodewell.com');
        insert acc;
		BuyerGroup BG = new BuyerGroup(Name='Registered_Owner_Account', Description='Buyer Group for Non - Members');
     	insert BG;
        Account accdata=[select Id From Account where Email__c='Testemail@bodewell.com'];
        String accid=accdata.Id;
        test.startTest();
        BWC_BuyerAssignment.insertBuyerGroup(accid);
        test.stopTest();
        }
        catch(Exception e)
        {
            system.debug('testtest exception at Line number - ' + e.getLineNumber() + ' testest Exception in test class - ' + e.getMessage());
        }

	}
    @isTest
    static  void assignBodewellPermissionNoBuyerGrp()
    {
        account acc= new account (FirstName='Test1', LastName='Account1',Email__c='Testemail1@bodewell.com');
        insert acc;
        String accid=acc.Id;
        
        try
        {
            
        test.startTest();
        PS_TestHelper.createAirWaterUser(CLASS_NAME);
        User portalUser = PS_TestHelper.getCreatedPortalUser(CLASS_NAME).get(0);
        System.setPassword(portalUser.Id, TEST_PASSWORD);
        User u = [SELECT ID FROM USer WHERE Id = : portalUser.Id];
        test.stopTest();
        
        BWC_AssignBodewellCommercePermissions.MakeAsBuyerEnabled(accid, u.Id);
        }
        catch(Exception e)
        {
            system.debug('testtest exception at Line number - ' + e.getLineNumber() + ' testest Exception in test class - ' + e.getMessage());
        }

	}
    
    @isTest
    static  void assignBodewellPermissionHasBuyerGrp()
    {
        account acc= new account (FirstName='Test', LastName='Account',Email__c='Testemail2@bodewell.com');
        insert acc;
        Account accdata=[select Id From Account where Email__c='Testemail2@bodewell.com'];
        String accid=acc.Id;
        
        account acc2= new account (FirstName='Test', LastName='Account',Email__c='Testemail3@bodewell.com');
        insert acc2;
        String accid2=acc2.Id;
        BuyerAccount buyerAccount = new BuyerAccount();
        buyerAccount.Name = 'Test Buyer Account1';
        buyerAccount.IsActive = true;
        buyerAccount.BuyerId = accid2;
        insert buyerAccount;
        
        account acc3= new account (FirstName='Test', LastName='Account',Email__c='Testemail4@bodewell.com');
        insert acc3;
        String accid3=acc3.Id;
        BuyerAccount buyerAccount2 = new BuyerAccount();
        buyerAccount2.Name = 'Test Buyer Account2';
        buyerAccount2.IsActive = true;
        buyerAccount2.BuyerId = accid3;
        insert buyerAccount2;
        
		BuyerGroup BG1 = new BuyerGroup(Name='Registered_Owner_Account1', Description='Buyer Group for Non - Members1');
     	insert BG1;

        BuyerGroup BG2 = new BuyerGroup(Name='Registered_Owner_Account2', Description='Buyer Group for Non - Members2');
     	insert BG2;
        
        BuyerGroupMember BGM1 = new BuyerGroupMember(BuyerId = accid2, BuyerGroupId = BG1.Id );
     	insert BGM1;
        
        BuyerGroupMember BGM2 = new BuyerGroupMember(BuyerId = accid3, BuyerGroupId = BG2.Id );
     	insert BGM2;

        try
        {
            
        test.startTest();
        PS_TestHelper.createAirWaterUser('test');
        User portalUser = PS_TestHelper.getCreatedPortalUser('test').get(0);
        System.setPassword(portalUser.Id, TEST_PASSWORD);
        User u = [SELECT ID FROM USer WHERE Id = : portalUser.Id];
        test.stopTest();
        
        BWC_AssignBodewellCommercePermissions.MakeAsBuyerEnabled(accid2, u.Id);
        
        }
        catch(Exception e)
        {
            system.debug('testtest exception at Line number - ' + e.getLineNumber() + ' testest Exception in test class - ' + e.getMessage());
        }

	}
}