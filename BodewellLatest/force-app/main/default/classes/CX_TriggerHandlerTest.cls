@isTest
public with sharing class CX_TriggerHandlerTest {
    public class DelegateClassTest extends CX_TriggerHandler.DelegateBase {}

    @IsTest
    static void DelegateClassTesting(){
        DelegateClassTest dct = new DelegateClassTest();
        dct.prepareBefore();
        dct.prepareAfter();
        dct.beforeInsert(new List<SObject>());
        dct.beforeUpdate(new Map<Id, sObject>(), new Map<Id, sObject>());
        dct.beforeDelete(new Map<Id, sObject>());
        dct.afterInsert(new Map<Id, sObject>());
        dct.afterUpdate(new Map<Id, sObject>(), new Map<Id, sObject>());
        dct.afterDelete(new Map<Id, sObject>());
        dct.afterUndelete(new Map<Id, sObject>());
        dct.finish();

        CX_TriggerHandler.allowTrigger(DelegateClassTest.class);
        CX_TriggerHandler.bypassTrigger(DelegateClassTest.class);
    }
}