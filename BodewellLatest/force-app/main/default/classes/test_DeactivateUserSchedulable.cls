@isTest
public class test_DeactivateUserSchedulable {

    @isTest public static void testFunc() {
        Test.startTest();
        SchedulableContext sc = null;
     	DeactivateInactiveUserSchedulable.execute(sc);
        Test.stopTest();
    }
}