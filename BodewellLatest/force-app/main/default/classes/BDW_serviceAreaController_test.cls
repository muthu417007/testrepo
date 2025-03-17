//******************************************************************************************
//Name : BDW_serviceAreaController_test
//Requirement : To test BDW_serviceAreaController_test
//******************************************************************************************
//History
//	Version				Author					Date				Detail
//  1.0					Yogesh Sharma			11/21/2022			Initial
//******************************************************************************************
//@description : To test BDW_serviceAreaController_test
@isTest
private class BDW_serviceAreaController_test 
{
    //@description : To test BDW_serviceAreaController.getServiceArea();
    @isTest
    static void getServiceArea_test()
    { 
        List<bw_ServiceLocation__mdt> c= [SELECT Id, Service_Area_Name__c, Service_Area_Number__c FROM bw_ServiceLocation__mdt];
        BDW_serviceAreaController.getServiceArea();
    }
    
    //@description : To test BDW_serviceAreaController.getRetailArea();
    @isTest
    static void getRetailArea_test()
    { 
        List<bw_RetailLocation__mdt> c= [SELECT Id, Retail_Area_Name__c, Retail_Area_Number__c, Retail_Area_AddresLine1__c, Retail_Area_AddresLine2__c, 
                                            Retail_Area_City__c, Retail_Area_State__c, Retail_Area_ZipCode__c 
                                            FROM bw_RetailLocation__mdt];
        BDW_serviceAreaController.getRetailArea();
    }
}