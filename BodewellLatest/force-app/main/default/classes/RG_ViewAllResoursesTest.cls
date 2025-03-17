//******************************************************************************************
// Author:       Kanishtika Gupta
// Company:      TCS
// Created Date: 28/04/2023
//******************************************************************************************
//@description : Apex Class to test request for display all resourses on Resource Hub Page
@isTest
private class RG_ViewAllResoursesTest {
    //@description : Apex method to test request for All resources data
    @isTest
    static void getAllResourcesTest() 
    {
        List<RG_Repair__mdt> allresources = [SELECT Id, Label, Resource_Name__c,Sequence_No__c,
                                                         Resource_Image__c,Redirection_Link__c 
                                                         FROM RG_Repair__mdt where Sequence_No__c != null
                                                                ORDER BY Label];
        List<RG_Repair__mdt> resourcestest = RG_ViewAllResources.getAllResources();
        System.assertEquals(allresources.size(), resourcestest.size(),'Test Passed');
    }

}