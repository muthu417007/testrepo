/********************************************************************************************************************
 * * @author      :   Monu Samrat
 * @company      :    GEA
 * @JiraTicket     :  CCOE-668 
 * @description :   This class is the utility class for batch. Here execute method logic for 'autoCloseCaseBatch' batch class is written.
					This class will close the cases that has been created by Haier chat bot and the age of case must be >7 days. 
 * @testClass   :   GEA_AutoCloseHaierCasesBatchUtilsTest
 * ********************************************************************************************************* */
    
public without sharing class GEA_AutoCloseHaierCasesBatchUtils {  
    // this method is for updating the case staus to close //
public static void batchExecute(List<LiveChatTranscript> scope){
	List<case> listToBeUpdated = new List<case>();
    set<id>idss=new set<id>();
                for(LiveChatTranscript lct: scope )
                {
					idss.add(lct.CaseId);
                }
    if(idss.size()>0)
    {
     list<case>cslst= [select id,status from case where id=:idss];
    	if(cslst.size()>0)
         {
   			   for(case cs:cslst )
                   {
                   cs.status='Closed' ;
                   listToBeUpdated.add(cs);
                   }
             
				    update listToBeUpdated;

             
         }
    }
}
}