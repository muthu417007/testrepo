//******************************************************************************************
// Author:       Yogesh Sharma
// Company:      TCS
// Created Date: 11/04/2023
//******************************************************************************************
//@description : Apex Class to test request for Carousel Slide Data
@isTest
private class RG_CarouselSlideDataControllerTest 
{
    //@description : Apex method to test request for Carousel Slide Data
    @isTest
    static void getCarouselSlidesTest() 
    {
        List<RG_Repair__mdt> carouselSlides = [SELECT Id, Label, Heading1__c, Heading2__c, 
                                                                Description__c, ImageUrl__c 
                                                                FROM RG_Repair__mdt 
                                               					WHERE Heading1__c != null
                                                                ORDER BY Label];
        List<RG_Repair__mdt> carouselSlidesTest = RG_CarouselSlideDataController.getCarouselSlides();
        System.assertEquals(carouselSlides.size(), carouselSlidesTest.size(),'Test Passed');
    }
}