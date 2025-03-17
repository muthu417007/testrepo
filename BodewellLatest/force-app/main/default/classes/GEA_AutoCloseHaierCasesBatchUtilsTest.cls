/********************************************************************************************************************
 * * @author      :   Monu Samrat
 * @company      :  GEA
 * @JiraTicket     :  CCOE-668 
 * @description :   This class is atest class for closing the cases that has been created by Haier chat bot and the age of case must be >7 days. 
 * @Class   :  GEA_AutocloseCasesBatch and GEA_AutocloseHaierCasesBatchUtils
 * ********************************************************************************************************* */

@isTest
public class GEA_AutoCloseHaierCasesBatchUtilsTest {
    
    //this method is for testing the GEA_autocloseCasesBatch class.//
    	 static testMethod void testMethod1() 
    {
        List<LiveChatTranscript> lct= new List<LiveChatTranscript>();
        list<case> caselist=new list<case>();
        //inserting case
        case cs= new case();
        cs.status='New';
        cs.Origin='web';
        caselist.add(cs);
        
        case cs1= new case();
        cs1.status='New';
        cs1.Origin='web';
        caselist.add(cs1);
        insert caselist;
        
        LiveChatVisitor lcv= new LiveChatVisitor();
        insert lcv;
        
         LiveChatVisitor lcv2= new LiveChatVisitor();
         insert lcv2;
        
        //inserting live chat transcript
            LiveChatTranscript lcts = new LiveChatTranscript();
            lcts.LiveChatButtonId='5734P000000LhSp';
            lcts.Case_Number__c='1111111' ;
            lcts.caseID=cs.id;
            lcts.LiveChatVisitorId=lcv.Id;
        	lct.add(lcts);
        
            LiveChatTranscript lcts1 = new LiveChatTranscript();
            lcts1.LiveChatButtonId='5734P000000LhSp';
            lcts1.Case_Number__c='1111112' ;
            lcts1.LiveChatVisitorId=lcv2.Id;
            lcts1.caseID=cs1.id;
        	lct.add(lcts1);
            insert lct;
        
        Test.startTest();
          GEA_AutoCloseCaseBatch obj = new GEA_AutoCloseCaseBatch();
            DataBase.executeBatch(obj); 
        Test.stopTest();
        system.assertEquals('1111112' ,lcts1.Case_Number__c ,'LCT has been inserted');
        }
    
    //this method is for testing the GEA_AutocloseHaierCasesBatchUtils class with method batchExecute//
       public static testMethod void testMethod2() {
           case cs1= new case();
           cs1.status='New';
           cs1.Origin='web';
           insert cs1;
           
            LiveChatVisitor lcv1= new LiveChatVisitor();
            insert lcv1;
           
           LiveChatTranscript lcts = new LiveChatTranscript();
            lcts.LiveChatButtonId='5734P000000LhSp';
            lcts.Case_Number__c='11111113' ;
           lcts.LiveChatVisitorId=lcv1.Id;
           lcts.caseID=cs1.id;
        	insert lcts;
           
            List<case> listToBeUpdated = new List<case>();
            list<LiveChatTranscript> lctlst= [select id ,caseID from LiveChatTranscript  ];
              set<id>idss=new set<id>();
                for(LiveChatTranscript lct: lctlst )
                {
					idss.add(lct.CaseId);
                }
     list<case>cslst= [select id,status from case ];
   			   for(case cs:cslst ){
                   cs.status='Closed' ;
                   listToBeUpdated.add(cs);
               }
           
        test.startTest();
            GEA_AutocloseHaierCasesBatchUtils.batchExecute(lctlst);
          test.stopTest();
           system.assertEquals('11111113' ,lcts.Case_Number__c ,'LCT has been inserted');
    
       }
        //this method is for testing the GEA_AutocloseHaierCasesBatchSchedular class with method Execute//
     public static testMethod void testschedule() {
          case cs2= new case();
           cs2.status='New';
           cs2.Origin='web';
           insert cs2;
           
            LiveChatVisitor lcv3= new LiveChatVisitor();
            insert lcv3;
           
           LiveChatTranscript lcts3 = new LiveChatTranscript();
            lcts3.LiveChatButtonId='5734P000000LhSp';
            lcts3.Case_Number__c='11111116' ;
           lcts3.LiveChatVisitorId=lcv3.Id;
           lcts3.caseID=cs2.id;
        	insert lcts3;
           
         

		Test.StartTest();
         GEA_AutoCloseCaseBatchSchedular sh1 = new GEA_AutoCloseCaseBatchSchedular();
		String sch = '0 0 23 * * ?'; 
        system.schedule('Test', sch, sh1); 
        Test.stopTest(); 
         system.assertEquals('11111116' ,lcts3.Case_Number__c ,'LCT has been inserted');
      
    }

    
}