public class CreateDummyAccount {
    public static Account FuncCreateDummyAccount()
    {
        ////////////////
        Account newAccount = new Account();
        newAccount.name = 'NoAddress City ST 00000';
        newAccount.BillingCity = 'City-G';
        newAccount.BillingState = 'ST';
        newAccount.BillingPostalCode = '00000';
        newAccount.RecordTypeId = '0124P0000015hYOQAY';
        insert newAccount;
        //////////////
        return newAccount;
    }
}