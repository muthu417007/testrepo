public class ContactCreate_ext{

    public Contact c;
    
    public contactCreate_ext(ApexPages.StandardController stdController) {
        this.c= (Contact)stdController.getRecord();
    }

    public pageReference redirectSearch(){
        PageReference p = new PageReference('/apex/contactSearch');
        return p;
    }
}