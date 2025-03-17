//******************************************************************************************
// Author:       Kanishtika Gupta
// Company:      TCS
// Created Date: 13/03/2023
//******************************************************************************************
//@description : Apex Class to test request for display all resourses on Resource Hub Page
public with sharing class RG_ViewAllResources {
    @AuraEnabled(cacheable=true)
    public static List<RG_Repair__mdt> getAllResources()
    {
        List<RG_Repair__mdt> allResources = New List<RG_Repair__mdt>();
        if(Schema.sObjectType.RG_Repair__mdt.fields.Id.isAccessible() &&
            Schema.sObjectType.RG_Repair__mdt.fields.Label.isAccessible() &&
            Schema.sObjectType.RG_Repair__mdt.fields.Redirection_Link__c.isAccessible() &&
            Schema.sObjectType.RG_Repair__mdt.fields.Resource_Image__c.isAccessible() &&
            Schema.sObjectType.RG_Repair__mdt.fields.Sequence_No__c.isAccessible() &&
            Schema.sObjectType.RG_Repair__mdt.fields.Resource_Name__c.isAccessible())
        {
            allResources = [SELECT Id, Label, Resource_Name__c,Sequence_No__c, Resource_Image__c,Redirection_Link__c 
                            FROM RG_Repair__mdt where Sequence_No__c != null Order By Sequence_No__c];
        }
        return allResources;
    }

}