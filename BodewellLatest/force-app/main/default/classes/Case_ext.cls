public class Case_ext{

    private final Case c;

    public case_ext(ApexPages.StandardController stdController) {
        this.c= (Case)stdController.getRecord();
    }

    public pageReference caseDashboard() {
         PageReference p = new PageReference('/apex/caseDashboard?id=' + c.id);
        return p;
    }
}