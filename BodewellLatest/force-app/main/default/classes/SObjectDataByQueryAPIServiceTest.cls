/********************************************************************************************************************
 * * @author      :   Monu Samrat
 * @company      :  GEA
 * @JiraTicket     :  CCOE-509 
 * @description :   This created to test the apex class. 
 * @testClass   :   SObjectDataByQueryAPIServiceTest
 * ********************************************************************************************************* */
@isTest
public class SObjectDataByQueryAPIServiceTest { 
      @isTest static void doPostTest1() { 
         Case cs = new Case();
        cs.Description='Testingsss12234';
        cs.Reason='Recall/Special Program';
         insert cs;
         //system.debug('@@@@@@@@@'+ cs.id);
          string subject='subject';
          string caseNumber ='caseNumber' ;	 
    	  string criteria = 'id=\''+cs.id+'\'';
          Test.startTest();
         List<sObject> newClassCall = SObjectDataByQueryAPIService.doPost(new string[] {subject,caseNumber}, 'case',criteria,10);
        // system.debug('@@@@@@@@'+ newClassCall );
        Test.stopTest(); 
        system.assertNotEquals(null, newClassCall);
     } 
   
    }