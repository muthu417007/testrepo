/**
 * @description class : THD_MDO_OrdersData
 * Created by : Santhosh Kanne
*/ 
@isTest
public class OrdersData_Test {
    static testmethod void testOrders(){
        String payload='{"P_ORDER_NUMBER":"65050495"}';
		String res=THD_MDO_OrdersData.ordersData(payload);
        System.assertNotEquals(null, res,'success');
    }
    static testmethod void testOrderDetail(){
        String payload='65050495';
		String res=THD_MDO_OrdersData.orderDetails(payload);
        System.assertNotEquals(null, res,'success');        
    }
    static testmethod void testFetchLinks(){
        List <THD_MDO_Orders_Help_Links__mdt> res=THD_MDO_OrdersData.fetchQuickLinks();
        System.assertNotEquals(null, res,'success');        
    }
    static testmethod void testHomeDepotLinks(){
        List<Map<Object,Object>> res=THD_MDO_OrdersData.homeDepotNotes();
        System.assertNotEquals(null, res,'success');        
    }    
}