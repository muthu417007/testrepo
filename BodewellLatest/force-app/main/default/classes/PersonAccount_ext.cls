public class PersonAccount_ext{

    public Account acct;
    public Contact selectedContact;

    public PersonAccount_ext(ApexPages.StandardController stdController) {
        acct = (Account)stdController.getRecord();
        selectedContact = [Select id from Contact where AccountId = :acct.id limit 1];
    }
    
    public pageReference contactDashboard() {
        system.debug('in contactDashboard');
         PageReference p = new PageReference('/apex/contactDashboard?id=' + selectedContact.id);
        return p;
    }
}