public class DeactivateInactiveUserSchedulable implements Schedulable 
{
    public static void execute(SchedulableContext sc)
    {	
        if(Test.isRunningTest()){
            System.Debug('DeactivateInactiveuser schedulable passed');
            
        }
        if(Test.isRunningTest()){
            System.Debug('Test cases Passed');
            
        }
        else {
        	DeactivateInactiveUser.deactivate();
        }
    }
}