public class Contact_ext{

    private final Contact c;

    public contact_ext(ApexPages.StandardController stdController) {
        this.c= (Contact)stdController.getRecord();
    }

    public pageReference contactDashboard() {
         PageReference p = new PageReference('/apex/contactDashboard?id=' + c.id);
        return p;
    }
}