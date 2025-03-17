/**
 * @author         Niku Singh
 * @company        GEA
 * @created        03/27/2022
 * @description    Batch class to get the pending ProcessWorkItem records and send email
 */
global class IncentiveClaimsBatchable implements Database.Batchable<SObject>, Database.Stateful{
    Set<Id> pendingIncntvClaims = new Set<Id>(); // Set to hold all the pending ProcessWorkItems that are pending for more than 3 days for Region Managers approval.
    String processDefnatnId;
    public IncentiveClaimsBatchable(String pdId){ //Constructor to get processDefinitionId as argument.
        processDefnatnId = pdId; // Process Definition Id for Incentive Claim Approval Process.
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator(
            'Select Id,targetobjectid from processinstance where processdefinitionId =: processDefnatnId and status = \'pending\'');
    }

    global void execute(Database.BatchableContext bc, List<ProcessInstance> scope) {
        pendingIncntvClaims.addAll(IncentiveClaimsBatchHandler.sendEscalationEmails(scope));
    }

    global void finish(Database.BatchableContext bc) {
        //AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
            //FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        if(!pendingIncntvClaims.isEmpty()){
            String baseUrl = System.Url.getOrgDomainUrl().toExternalForm();
            String emailSubject = Email_Attribute__mdt.getInstance(System.Label.Incentive_Claim_Developer_Name).subject__c;
            String emailbody = Email_Attribute__mdt.getInstance(System.Label.Incentive_Claim_Developer_Name).Email_Body__c+'<br />';
            String[] toAddresses = (Email_Attribute__mdt.getInstance(System.Label.Incentive_Claim_Developer_Name).toAddresses__c).split(',');// IncentiveCompensationBigHatApprovers@geappliances.com
                        
            for(Id pic: pendingIncntvClaims){
                Emailbody = Emailbody+baseUrl+'/'+pic+'<br />';
            }
            SFDCUtil.sendHTMLEmail(toAddresses, emailSubject, null, null, null, Emailbody);
        }

    }

}