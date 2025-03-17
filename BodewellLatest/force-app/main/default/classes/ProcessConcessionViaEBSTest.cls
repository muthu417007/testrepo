/**
 * @description class : ProcessConcessionViaEBS
 * Created by : Santhosh Kanne
*/ 
@isTest
public class ProcessConcessionViaEBSTest {
    @isTest
    Static void ProcessConcession_test(){
        List<String> payload=new List<String>{'ListOfLineItems : { items }}'};
        Test.startTest();
        List<String> resp=ProcessConcessionViaEBS.ProcessConcessionViaEBS(payload);
        Test.stopTest();
        System.assertNotEquals(null, resp,'response successfully returned');
    }

}