/**
*@description : Class has been created to schedule Batch Apex for Record Deletion created for MYA project.
Name: Kanishtika Gupta
Copyright: @ 2022 GE Appliances
**********************************************
Req: 
Task :- IDMSF-1483
**********************************************
Purpose: Class has been created to schedule Batch Apex for Record Deletion created for MYA project.
**********************************************
History
---------------------------------------------
Version    Author    Date    Details
-------    -------    -------    -------
1.0      Kanishtika Gupta 04/08/2022   Created
**********************************************
**********************************************/
global class MYA_BatchMassDeleteRecSchedule implements Schedulable{
  global void execute(SchedulableContext sc)
    {
       List<MYA_Purge_Records_Batch__mdt> bList = [SELECT Id,Batch_Name__c,BatchSize__c,Query__c FROM MYA_Purge_Records_Batch__mdt/* where Active=True*/];
       //Add a checkbox Active
       //
       List<MYA_BatchMassDeleteRec> batchList = new List<MYA_BatchMassDeleteRec>();
        for (MYA_Purge_Records_Batch__mdt m : bList){
        	MYA_BatchMassDeleteRec b = new MYA_BatchMassDeleteRec(m.Query__c);
       		database.executebatch(b,(Integer)m.BatchSize__c);
            batchList.add(b);
    	}
        System.debug(batchList);
       
    }
}