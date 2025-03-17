/********************************************************************************************************************
 * * @author      :   Monu Samrat
 * @company      :  GEA
 * @JiraTicket     :  CCOE-668 
 * @description :   This class will help in scheduling the batch....... 
 * @testClass   :   GEA_AutoCloseCaseBatchSchedularTest
 * ********************************************************************************************************* */


public class GEA_AutoCloseCaseBatchSchedular implements Schedulable {
    // This method will schedule the batch class.
    public void execute(SchedulableContext sc) {
        
    GEA_AutoCloseCaseBatch b = new GEA_AutoCloseCaseBatch(); 
        database.executebatch(b);

    }


}