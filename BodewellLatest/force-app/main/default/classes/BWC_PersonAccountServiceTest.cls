@isTest 
public class BWC_PersonAccountServiceTest {
  
    static testMethod void createPersonAccountTest1() {
        BWC_PersonAccountService objPersonAccountService = new BWC_PersonAccountService();
        Account objPersonAccount;
        objPersonAccount = objPersonAccountService.createPersonAccount('TestFirstName','TestLastName','TestEmail@test.com', 'abc123', 'GEA', 'Google;Twitter', null);
    }
    
    static testMethod void createPersonAccountTest2() {
        
        PS_WebServiceUserInfoPasswordWrapper wrapInfoPassword = new PS_WebServiceUserInfoPasswordWrapper();
        wrapInfoPassword.mobile = '2143982657';
                
        BWC_PersonAccountService objPersonAccountService = new BWC_PersonAccountService();
        Account objPersonAccount;
        objPersonAccount = objPersonAccountService.createPersonAccount('','','TestEmail@test.com', 'abc123', 'GEA', 'Google;Twitter', wrapInfoPassword);
        
    }
    
    static testMethod void createPersonAccountWithWrapperTest() {
        CX_ContactCreationWrapper wrapContactCreation = new CX_ContactCreationWrapper();
        wrapContactCreation.firstName = 'Test';
        wrapContactCreation.lastName = 'Test';
        BWC_PersonAccountService objPersonAccountService = new BWC_PersonAccountService();
        Account objPersonAccount;
        objPersonAccount = objPersonAccountService.createPersonAccountWithWrapper(wrapContactCreation);
               
    }
}