/**
* @description created by : Santhosh Kanne
* Test class : OrdersData_test
*/
public without sharing class THD_MDO_OrdersData {
    /**
* @description return order service data.
* @param body
* @return orderlist lite response.
*/
    @AuraEnabled
    public static String ordersData(String body){
        String reqbody=body;
        String res;
        if(utility.isSandbox){
            res= RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','THD_MDO_Orders_Token','THD_MDO_OrdersData',null,'POST',reqbody);
        }
        else {
            res= RequestMuleAPIData.getMuleAPIData('Production_MuleAuth','Prod_Connected_Token','Prod_OrdersData',null,'POST',reqbody);
        }
        return res;
    }	
    /**
* @description return order detail  data.
* @param orderNumber
* @return orderdetail response with ordernumber as input.
*/
    @AuraEnabled
    public static String orderDetails(String orderNumber){
        String reqbody = '{"P_ORDER_NUMBER":'+integer.valueof(orderNumber)+'}';
        String res;
        if(utility.isSandbox){
            res= RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','THD_MDO_Orders_Token','THD_MDO_OrdersDetail',null,'POST',reqbody);
        }
        else {
            res= RequestMuleAPIData.getMuleAPIData('Production_MuleAuth','Prod_Connected_Token','Prod_OrderDetails',null,'POST',reqbody);
        }
        return res;
    }
    /**
* @description help links.
* @return Quick help links for orders console.
*/
    @AuraEnabled(cacheable=true)  
    public static List < THD_MDO_Orders_Help_Links__mdt > fetchQuickLinks() {  
        if(Schema.sObjectType.THD_MDO_Orders_Help_Links__mdt.isAccessible()){
            return [ SELECT Id, Name__c, Quick_Link__c FROM THD_MDO_Orders_Help_Links__mdt where IsHelpLink__c=true];
        }
        else {
            return new List<THD_MDO_Orders_Help_Links__mdt>();
        }
    }
    /**
* @description retrives Home depot endpoint from custom metadata.
* @return returns Home Depot Delivery Service Endpoint.
*/
    @AuraEnabled
    public static List<Map<Object,Object>> homeDepotNotes(){
        List<THD_MDO_Orders_Help_Links__mdt> ep;
        if(utility.isSandbox){
            ep= [ SELECT DeveloperName,Quick_Link__c FROM THD_MDO_Orders_Help_Links__mdt where IsHelpLink__c=false and DeveloperName!='Production_HomeDepotNotes'];  
        }
        else {
            ep= [ SELECT DeveloperName,Quick_Link__c FROM THD_MDO_Orders_Help_Links__mdt where IsHelpLink__c=false and DeveloperName!='Sandbox_HomeDepotNotes'];  
        }
        List<Map<Object,Object>> hdNotes=new List<Map<Object,Object>>();
        for(THD_MDO_Orders_Help_Links__mdt e:ep){
            Map<Object, Object> hdnote = new Map<Object, Object>{'Name' =>e.DeveloperName , 'Url' => e.Quick_Link__c};          
                hdNotes.add(hdnote);
        }
        return hdNotes;
    }        
}