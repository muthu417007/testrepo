/**
*@description : Class has been created to update portal user flag true for all portal user created for MYA project.
Name: Kanishtika Gupta
Copyright: @ 2022 GE Appliances
**********************************************
Req: 
Task :- IDMSF-1634
**********************************************
Purpose: Class has been created to update portal user flag true for all portal user created for MYA project
**********************************************
History
---------------------------------------------
Version    Author    Date    Details
-------    -------    -------    -------
1.0      Kanishtika Gupta 21/09/2022   Created
**********************************************
**********************************************/
global class MYA_BatchPortalUserFlag Implements Database.batchable<sobject>,Database.stateful{
    public integer recordCount = 0;
    String query;
      public MYA_BatchPortalUserFlag() {
        if(Test.isRunningTest()){
         
              query = 'select id, name, profile.name, contact.name, contactId from user where profile.name=\'Default Customer Login User\' AND IsActive = true Limit 1';
        }
        else{
               query = 'select id, name, profile.name, contact.name, contactId from user where profile.name= \'Default Customer Login User\' AND IsActive = true';
        }
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
         return Database.getQueryLocator(query);
     }
     
     public  void execute(Database.BatchableContext BC,List<User> userdata){
         List<id> contactIdList = new List<id>();
         try{
             for(User u :userdata){
                 contactIdList.add(u.contactId);
             }
             List<Contact> conList = [select id, Is_Portal_User__c from Contact where Is_Portal_User__c=false and id in :contactIdList];
             for(Contact c :conList){
               c.Is_Portal_User__c = true;
             }
             Update conList;
             recordCount = recordCount + userdata.size();
         }
         catch(Exception e){
             MYA_ApplicationErrorLog.Mya_ExHandler(e, 'MYA_BatchPortalUserFlag', 'execute');
        }
     }
    global void finish(Database.BatchableContext bc){
        System.debug(LoggingLevel.WARN,'Total Record Processed ' +recordCount);
    }  
}