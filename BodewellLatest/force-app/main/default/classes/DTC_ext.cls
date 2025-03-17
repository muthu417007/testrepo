public class DTC_ext{

    public DTC_Chat__c dtc {get;set;}
    public Boolean showForm {get;set;}
    

    public DTC_ext(ApexPages.StandardController stdController) {
        this.dtc= (DTC_Chat__c )stdController.getRecord();
        showForm = true;
    }

    public pageReference submitRecord() {
       insert dtc;
       showForm = false;
       return null;
    }
}