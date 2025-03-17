/**
*@description : Class has been created to call custom meta data for bulk record deletion created for MYA project.
Name: Kanishtika Gupta
Copyright: @ 2022 GE Appliances
**********************************************
Req: 
Task :- IDMSF-1483
**********************************************
Purpose: Class has been created to call custom meta data for bulk record deletion created for MYA project.
**********************************************
History
---------------------------------------------
Version    Author    Date    Details
-------    -------    -------    -------
1.0      Kanishtika Gupta 04/08/2022   Created
**********************************************
**********************************************/
global class MYA_BatchMassDeleteRec Implements Database.batchable<sobject> {
    String query ='';
    global MYA_BatchMassDeleteRec(String query){
        this.query = query;
    }
      global Database.QueryLocator start(Database.BatchableContext BC){
          return Database.getQueryLocator(query);
     }
     public  void execute(Database.BatchableContext BC,List<SObject> scope){
        //System.debug(scope);
        delete scope;
     }
    global void finish(Database.BatchableContext BC){
    }  
}