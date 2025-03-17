/**
 * @description class : GetEBSWarehouseLocation
 * Created by : Santhosh Kanne
*/ 
@isTest
public class GetEBSWarehouseLocationTest {
    @isTest
    Static void GetWarehouseLocation_test(){
        List<String> payload=new List<String>{'{"zipcode": "40067"}'};
        Test.startTest();
        List<String> resp=GetEBSWarehouseLocation.GetEBSWarehouseLocation(payload);
        Test.stopTest();
        System.assertNotEquals(null, resp,'response successfully returned');
    }

}