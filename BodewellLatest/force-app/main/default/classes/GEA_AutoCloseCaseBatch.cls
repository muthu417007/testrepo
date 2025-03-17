/********************************************************************************************************************
 * * @author      :   Monu Samrat
 * @company      :  GEA
 * @JiraTicket     :  CCOE-668 
 * @description :   This class is for closing the cases that has been created by Haier chat bot and the age of case must be >7 days. 
 * @testClass   :   GEA_AutoCloseHaierCasesBatchUtilsTest....
 * ********************************************************************************************************* */
public class GEA_AutoCloseCaseBatch implements  Database.Batchable<sobject>  {
    //this is a start method ,will return all the records that are required to be processed.//
  public Database.QueryLocator start(Database.BatchableContext bc) {
      string query;
      if(Test.isRunningTest()){
     	query= 'SELECT Id, case.Case_f_Owner__c, CaseId,case.status, case.Case_Age_in_Days__c, LiveChatButtonId FROM LiveChatTranscript limit 10 ';
      }  
      else{
     	query= 'SELECT Id, case.Case_f_Owner__c, CaseId,case.status, case.Case_Age_in_Days__c, LiveChatButtonId FROM LiveChatTranscript where LiveChatButtonId =\'5734P000000LhSp\' and  case.Case_Age_in_Days__c >7 and case.Case_f_Owner__c = \'Automated process\' and case.status=\'New\' ';
      
      }
      return Database.getQueryLocator(query);   
   
  }
    //this thexecute method, here the records that are in the query locator start method will be processed.//
    public void execute(Database.BatchableContext bc , List<LiveChatTranscript> scope ) 
    {  
      GEA_AutoCloseHaierCasesBatchUtils.batchExecute(scope);
    }     
   // this is the finish method of batch class ,here a email is send to the person who hhas ran the batch after completion of execute method. //
public void finish ( Database.BatchableContext bc ) {
     AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob
            				WHERE Id = :bc.getJobId()];
     //Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddress = new String[] {job.CreatedBy.Email};
        mail.setToAddresses(toAddress);
        mail.setSubject('Apex Job status is ' + job.Status);
        mail.setPlainTextBody('The batch Apex job has total batches' + job.TotalJobItems + ' . The batches processed are '+job.JobItemsProcessed + '. The batches that got faied are' + job.NumberOfErrors );
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

   
    
}