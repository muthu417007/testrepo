@isTest
public with sharing class CreateAssetsControllerTest {

    @isTest
    static void attachFilesToGEAAssetTest(){

        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Test';
        contentVersion.PathOnClient = 'Test.jpg';
        contentVersion.VersionData = Blob.valueOf('Test Content');
        contentVersion.IsMajorVersion = true;
        insert contentVersion;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1];

        Asset geaAsset = new Asset();
        geaAsset.Model_Number__c = 'TESTMN';
        geaAsset.SerialNumber ='TESTSN';
        geaAsset.BrandName__c = 'TESTBN';
        geaAsset.DataSourceCode__c ='TESTDSC';
        //geaAsset.Is_Created_By_Quick_Action__c = true;
        insert geaAsset;

        Test.startTest();
            System.assertNotEquals(0, documents.size());
            CreateAssetsController.attachFilesToGEAAsset(geaAsset.Id, new List<Id>{documents.get(0).Id});
        Test.stopTest();

        ContentDocumentLink cdLink = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: geaAsset.Id LIMIT 1];
        System.assertNotEquals(null, cdLink);
        System.assertEquals(documents.get(0).Id, cdLink.ContentDocumentId);
    }

    @isTest
    static void getTextFromPictureOCRTest(){
        List<String> ocrText = new List<String>();

        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'TestImage',
            PathOnClient = 'TestImage.jpg',
            VersionData = Blob.valueOf('Test Image Data'),
            IsMajorVersion = true
        );
        insert contentVersionInsert;

        Id documentId = [SELECT Id FROM ContentDocument].get(0).Id;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new OCRCalloutMock());
            ocrText = CreateAssetsController.getTextFromPictureOCR(documentId);
        Test.stopTest();

        List<ContentDocument> documents = [SELECT Id FROM ContentDocument];
        System.assertEquals(ocrText.size(), 1);
        System.assertEquals(ocrText.get(0), 'JGB700SEJSS');
    }

    @isTest
    static void OCRResponseTest(){
        String responseBodyMock = '{"object":"predictresponse","probabilities":[{"probability":0.37609568,"label":"JGB700SEJSS","boundingBox":{"minX":25,"minY":0,"maxX":188,"maxY":98},"attributes":{"tag":"x","pageNumber":"1"}}],"task":"text"}';
        EinsteinOCRResponse plateRespone = EinsteinOCRResponse.parse(responseBodyMock);
        for(EinsteinOCRResponse.Probability prob : plateRespone.probabilities){
            System.assertNotEquals(null,prob.label);
            System.assertNotEquals(null,prob.boundingBox);
            System.assertNotEquals(null,prob.boundingBox.minX);
            System.assertNotEquals(null,prob.boundingBox.minY);
            System.assertNotEquals(null,prob.boundingBox.maxX);
            System.assertNotEquals(null,prob.boundingBox.maxY);
            System.assertNotEquals(null,prob.attributes);
            System.assertNotEquals(null,prob.attributes.tag);
        }
        System.assertNotEquals(null,plateRespone.task);
        System.assertNotEquals(null,plateRespone.task);
    }

    @isTest
    static void testGettingBrandsList(){
        System.assertNotEquals(0,CreateAssetsController.getBrandValuesIntoList().size());
    }
}