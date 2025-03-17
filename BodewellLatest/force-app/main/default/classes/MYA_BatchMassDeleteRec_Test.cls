@isTest
public class MYA_BatchMassDeleteRec_Test {
     public static testMethod void MYA_deleteRecords(){
       string query = 'SELECT id FROM WebConsumerInfo__c where CreatedDate = Today';
       Test.startTest();
            MYA_BatchMassDeleteRec obj = new MYA_BatchMassDeleteRec(query);
            DataBase.executeBatch(obj,200); 
         Test.stopTest();
     }

}