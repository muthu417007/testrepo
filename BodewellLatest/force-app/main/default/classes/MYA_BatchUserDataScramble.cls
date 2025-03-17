/**
 * @author         Akhil Raj
 * @company        TCS
 * @created        22.09.2022
 * @description    For scramble user data after deactivation
 */
global class MYA_BatchUserDataScramble Implements Database.batchable<sobject>,Database.stateful{
    public integer recordCount = 0;
    // Start 
    global Database.QueryLocator start(Database.BatchableContext bc){
          return Database.getQueryLocator([SELECT Id FROM User WHERE profile.name='Default Customer Login User' AND LastModifiedDate >= TODAY AND IsActive =:false LIMIT 10]);
     }
    // Execute 
     public  void execute(Database.BatchableContext bc,List<User> userdata){
         for(User u :userdata){
             UserManagement.obfuscateUser(u.Id);
         }
     }
     // Finish 
     global void finish(Database.BatchableContext bc){
        System.debug(LoggingLevel.WARN, 'Total Record Processed ' +recordCount);
     }  
}