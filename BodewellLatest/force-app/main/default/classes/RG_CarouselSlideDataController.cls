//******************************************************************************************
// Author:       Yogesh Sharma
// Company:      TCS
// Created Date: 27/03/2023
//******************************************************************************************
//@description : Apex Class to handle request for Carousel Slide Data
public with sharing class RG_CarouselSlideDataController {
    //@description : Apex method to handle request for Carousel Slide Data
    @AuraEnabled(cacheable=true)
    public static List<RG_Repair__mdt> getCarouselSlides()
    {
        List<RG_Repair__mdt> carouselSlides = New List<RG_Repair__mdt>();
        if(Schema.sObjectType.RG_Repair__mdt.fields.Id.isAccessible() &&
            Schema.sObjectType.RG_Repair__mdt.fields.Label.isAccessible() &&
            Schema.sObjectType.RG_Repair__mdt.fields.Heading1__c.isAccessible() &&
            Schema.sObjectType.RG_Repair__mdt.fields.Heading2__c.isAccessible() &&
            Schema.sObjectType.RG_Repair__mdt.fields.Description__c.isAccessible() &&
            Schema.sObjectType.RG_Repair__mdt.fields.Contact_Number__c.isAccessible() &&
            Schema.sObjectType.RG_Repair__mdt.fields.ImageUrl__c.isAccessible())
        {
            carouselSlides = [SELECT Id, Label, Heading1__c, Heading2__c, Description__c, ImageUrl__c,Contact_Number__c 
                            FROM RG_Repair__mdt 
                            WHERE Heading1__c != null
                            ORDER BY Label];
        }
        return carouselSlides;   
    }
}