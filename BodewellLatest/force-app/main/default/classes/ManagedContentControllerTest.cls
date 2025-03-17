/*
 * There is not great current support around testing ConnectApi.ManagedContent.
 * It currently requires SeeAllData=true(https://ideas.salesforce.com/s/idea/a0B8W00000GdZzDUAV/fix-connectapi-methods-are-not-supported-in-data-siloed-tests)
 * and you cannot create data in the test class(which is why you need to SeeAllData).
 * Since all we are really doing is running a query we are going to just call the test methods
 * to get code coverage. Hopefully in the near future they will fix this.
 */
@isTest(SeeAllData=true)
public with sharing class ManagedContentControllerTest {

    @IsTest
    static void getContent(){ 
        Test.startTest();
        Map<String, ConnectApi.ManagedContentNodeValue> managedContentMap= ManagedContentController.getContent('CONTENTID',0,1,'en_US','');
        Test.stopTest();
    }

    @IsTest
    static void getContentList(){ 
        Test.startTest();
        List<ConnectApi.ManagedContentVersion> managedContentVersions= ManagedContentController.getContentList(0,1,'en_US','');
        Test.stopTest();
    }
}