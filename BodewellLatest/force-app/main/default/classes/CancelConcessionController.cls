public class CancelConcessionController{
    Public Concession__c c{get;set;}
   

    public CancelConcessionController(ApexPages.StandardController stdController) {
        this.c= (Concession__c )stdController.getRecord();
        c = [SELECT id,Concession_Status__c
             FROM Concession__c 
             WHERE id =: c.id LIMIT 1]; 
    
    }

    public PageReference cancel() {
        List<Concession__c > concessions = [SELECT ID FROM Concession__c WHERE Id = :c.id];
        Approval.unLockResult[] unlockList = Approval.unlock(concessions , false);
        concessions[0].Concession_Status__c = 'Cancelled';
        update concessions[0];
        Approval.LockResult[] lockList = Approval.lock(concessions , false);

        PageReference p= new PageReference('/'+c.id);
        p.setRedirect(true);
        return p;  
    }
    
    
}