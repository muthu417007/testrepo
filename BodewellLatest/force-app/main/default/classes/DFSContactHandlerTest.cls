@isTest
public class DFSContactHandlerTest {
	@TestSetup
    static void makeData() {
        Id systemAdministratorProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
		UserRole role=new UserRole(DeveloperName='test',name='test');
        insert role;
        User u= new User(
                firstName = 'Abc',
                lastName = 'xyz',
                Alias = 'abcbc',
                profileId = systemAdministratorProfileId,
                username = 'abcabc.xyz@test.com',
                email = 'test@test.com',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
				userRoleId=role.Id
            );
		insert u;
        
    }
	@isTest
    static void testErrorOnAccount() { 
        Contact_From_DFS__c dfs1 = new Contact_From_DFS__c(User_First_Name__c = 'Abc',User_Email__c='test@test.com',
                                                           User_Last_Name__c='lastName');
		insert dfs1;
        test.startTest();
        try {
				dfs1.status__c='Approved';
            	System.debug('Account of Contact from DFS is: '+dfs1.account__c);
                update dfs1;
            } catch (Exception ex) {
                System.assert(ex.getMessage().contains('Please populate account before approving'), 'Account is required');
            }
        test.stoptest();
	}
    
    @isTest
    static void testApproval() { 
		test.startTest();
        User u=[Select id,userRole.Name from User where Alias = 'abcbc'];
        System.runAs(u){
            Account acc=new Account(Name='test',owner=u);
            insert acc;
            Contact con= new Contact(FirstName='firstName',Account=acc,Email='testing@test.com',LastName='lastName2',
                                     phone='231',owner=u);
            insert con;
            Contact_From_DFS__c dfs1 = new Contact_From_DFS__c(Account__c = acc.Id,contact__c=con.Id,User_Email__c='testing@test.com',
                                                 User_First_Name__c='firstName',User_Last_Name__c='lastName2');
            insert dfs1;
            dfs1.status__c='Approved';
            update dfs1;
            System.assertEquals(dfs1.Status__c,'Approved');
        }
        test.stopTest();    
	}
}