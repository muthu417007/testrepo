@isTest(seeAllData=true)
public class MYA_ForgetPasswordTest {

    public static testMethod void forgetPassword1(){
      
        MYA_ForgetPassword.flowforget firstInput = new MYA_ForgetPassword.flowforget();
        firstInput.oldPass='time';
        firstInput.newPass='time34';
        firstInput.rePass='time3467';
        Test.startTest();
        MYA_ForgetPassword.getforgetPassword(
            new List<MYA_ForgetPassword.flowforget>{firstInput}
        );
        system.assertEquals(new List<String>{'Password Change is Successful'},MYA_ForgetPassword.getforgetPassword(
            new List<MYA_ForgetPassword.flowforget>{firstInput}
        ) );
        Test.stopTest();
    }
    
   public static testMethod void forgetPassword2(){
      
       Account acc= new Account(Name= 'Test Account');
        insert acc;
        Profile p = [select Id from profile where name='Default Customer Login User'];
        Contact cont = new Contact(LastName ='testCon',AccountId = acc.Id);
        insert cont;
         // Create a unique UserName
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';        
        User u1 = new User(
            Alias = 'standt',
            Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName=uniqueUserName,
            ContactId=cont.Id);
        insert u1;
       //system.debug('u'+u);
       system.runAs(u1){
        MYA_ForgetPassword.flowforget firstInput = new MYA_ForgetPassword.flowforget();

        Test.startTest();
        firstInput.oldPass='Test@123456';
        firstInput.newPass=null;
        firstInput.rePass=null;
        MYA_ForgetPassword.getforgetPassword(
            new List<MYA_ForgetPassword.flowforget>{firstInput}
        );
        system.assertEquals(new List<String>{'Password Change is Successful'},MYA_ForgetPassword.getforgetPassword(
            new List<MYA_ForgetPassword.flowforget>{firstInput}
        ) );
        Test.stopTest();
       }
    } 
   
}