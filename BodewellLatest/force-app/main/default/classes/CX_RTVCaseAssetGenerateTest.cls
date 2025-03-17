/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        09.07.2021
 * @description    RTV Case Assets recommendation logic tests
 */
@IsTest
public with sharing class CX_RTVCaseAssetGenerateTest {
    @testSetup
    static void setup() {
        Case testCase = new Case(Subject = 'Test');
        insert testCase;

        Asset geaAsset = new Asset(Model_Number__c = 'AET05LY');
        insert geaAsset;

        Case_Asset__c caseAsset = new Case_Asset__c(Model_Number__c = 'AET05LY', Name = 'Test', Case__c = testCase.Id, Asset__c = geaAsset.Id);
        insert caseAsset;
    }

    @isTest
    static void recommendationTest() {
        Case testCase = [SELECT Id FROM Case];

        Test.startTest();
        List<List<Recommendation>> recommendations = CX_RTVCaseAssetGenerate.getRTVCaseAssetRecommendation(new List<String> { testCase.Id });
        Test.stopTest();

        System.assertEquals(1, recommendations.size());

        Recommendation recommendation = recommendations[0][0];

        System.assertEquals('RTV, Offer GWC Concession for asset AET05LY', recommendation.Description);
        System.assertEquals(testCase.Id, recommendation.CX_CaseId__c);
    }
}