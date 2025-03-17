@isTest
public with sharing class CX_KAVControllerExtensionTest {
    @IsTest
    static void saveTest(){
        Knowledge__kav kav = new Knowledge__kav(
            Title = 'Test title',
            Summary = 'Test summary',
            Keywords__c = 'Test keywords',
            UrlName = 'testurl'
        );

        ApexPages.StandardSetController setController = new ApexPages.StandardSetController(new List<Knowledge__kav>());

        CX_KAVControllerExtension controller = new CX_KAVControllerExtension(setController);
        controller.setKnowledge(kav);
        controller.save();
        
        List<Knowledge__kav> kavs = [SELECT Title FROM Knowledge__kav WHERE UrlName = 'testurl'];
        System.assertEquals('Test title', kavs[0].Title);
    }

    @IsTest
    static void saveTestException(){
        Knowledge__kav kav = new Knowledge__kav(
            Summary = 'Test summary',
            Keywords__c = 'Test keywords',
            UrlName = 'testurl'
        );

        ApexPages.StandardSetController setController = new ApexPages.StandardSetController(new List<Knowledge__kav>());

        CX_KAVControllerExtension controller = new CX_KAVControllerExtension(setController);
        controller.setKnowledge(kav);
        controller.save();
    }
}