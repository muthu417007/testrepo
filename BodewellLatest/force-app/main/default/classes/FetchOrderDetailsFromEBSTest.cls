/**
 * @description class : FetchOrderDetailsFromEBS
 * Created by : Santhosh Kanne
*/ 
@isTest
public class FetchOrderDetailsFromEBSTest {
	@isTest    
    Static void FetchOrderDetails_test(){
        List<String> payload=new List<String>{'{"ordernumber": "4006732344"}'};
        Test.startTest();
        List<String> resp=FetchOrderDetailsFromEBS.FetchOrderDetailsFromEBS(payload);
        Test.stopTest();
        System.assertNotEquals(null, resp,'response successfully returned');
    }

}