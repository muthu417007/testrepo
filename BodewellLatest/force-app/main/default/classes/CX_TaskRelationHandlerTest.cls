/**
 * @author         Gunhan Gultekin
 * @company        PolSource
 * @created        17.06.2021
 * @description    CX_TaskRelation tests
 */
@IsTest(IsParallel = true)
public with sharing class CX_TaskRelationHandlerTest {
    private static final RecordTypeInfo CASE_GENERAL_RT =  Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('General');
    
    @IsTest
    static void updateOpenTaskCountTest(){
        Case testCase = new Case(Subject = 'Test', 
            RecordTypeId = CASE_GENERAL_RT.getRecordTypeId(),
            CX_RelatedOpenTaskCount__c = 0
        );
        insert testCase;

        Task testTask = new Task(Subject = 'Test Task',Status = 'Open', 
            WhatId = testCase.Id
        );
        Task testTask2 = new Task(Subject = 'Test Task',Status = 'Complete', 
            WhatId = testCase.Id
        );

        insert new List<Task>{testTask,testTask2};

        Test.startTest();
        
        CX_TaskRelationHandler.getInstance().updateOpenTaskCount(
            new List<Case>{testCase},
            new Set<Id>{testCase.Id}
        );
        
        Test.stopTest();
        
        System.debug(testCase.CX_RelatedOpenTaskCount__c);

        System.assertEquals(1, testCase.CX_RelatedOpenTaskCount__c);

    }
}