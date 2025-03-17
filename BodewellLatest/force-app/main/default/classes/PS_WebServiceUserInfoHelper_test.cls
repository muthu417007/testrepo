@isTest 
public class PS_WebServiceUserInfoHelper_test {
    static testMethod void FuncinsertDummyAccountAndContactFirstNameLastNameEmail_test() {
        Contact objDummyContact;
        objDummyContact = PS_WebServiceUserInfoHelper.insertDummyAccountAndContact('TestFirstname','TestLastName','TestEmail@geappliances.com');
    }
    static testMethod void FuncinsertDummyAccountAndContactFirstNameLastNameEmailSourceProviderNull_test() {
        Contact objDummyContact;
        objDummyContact = PS_WebServiceUserInfoHelper.insertDummyAccountAndContact('TestFirstname','TestLastName','TestEmail@geappliances.com','TestSource','google',null);
    }
    //
}