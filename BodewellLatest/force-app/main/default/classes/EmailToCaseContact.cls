public class EmailToCaseContact {
    private static boolean run = true;
    public static boolean runOnce(){
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }
    Set<Id> caseId = new Set<Id>();
    List<String> emailAddresses = new List<String>();
    String checkcase,EmailFromName;
    String contactId,AcctId,strFirstName,strLastName;
    public void updatecase(List<case> caseList)
    {
        for(Case c : caseList) {
            if(c.Origin=='Email' && c.SuppliedEmail!=null && c.ContactId==null && c.SuppliedName!=null && c.SuppliedEmail!='')
            {
                System.debug('Case Number' + c.caseNumber);
                caseId.add(c.Id);
                emailAddresses.add(c.SuppliedEmail);
                EmailFromName=c.SuppliedName;
                checkcase='true';
                
            }
        }
        if(checkcase=='true')
        {
            List<Contact> listContactsemail = [Select Id,AccountId,CreatedDate From Contact Where email in: emailAddresses Order By CreatedDate DESC];
            List<Case> listContactcase = [select ContactId,AccountId from Case where SuppliedEmail in: emailAddresses and ContactEmail in: emailAddresses and Status!='Closed' order by CreatedDate];
            if(listContactsemail.size()==1)
            {
                System.debug('1 contact found.Tie the contact to case');
                contactId=listContactsemail[0].Id;
                AcctId=listContactsemail[0].AccountId; 
                
            }
            else if(listContactsemail.size()>1 && listContactcase.size()==0)
            {
                contactId=listContactsemail[0].Id;
                AcctId=listContactsemail[0].AccountId; 
            }
            else if(listContactsemail.size()>1 && listContactcase.size() >= 1){
                System.debug('Count>1. So check for which contact to tie to case');
                contactId = listContactcase[0].ContactId;
                AcctId = listContactcase[0].AccountId;
                
            }
            List<Case> cases = [SELECT Id From Case where Id IN :caseId];
            List<Case> caseUpdateList = new List<Case>();
            for(Case c: cases)
            {  
                c.ContactId=contactId; 
                c.AccountId=AcctId;
                caseUpdateList.add(c);
            }
            System.debug('Updating case with contactID and accountID');
            update caseUpdateList;
            System.debug('CaseID' +caseId);
            
        }
        
    }
}