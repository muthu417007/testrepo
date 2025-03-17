/**
 * Author:        Karlo Lorenzana
 * Company:       GE Appliances
 * Zone:          North America
 * Description:   
 * Test Class:    CX_TriggerHandlerTest
 * History
 * 2021.05.18     Karlo Lorenzana     initial implementation
**/
public with sharing class CX_TriggerHandler {

	private CX_TriggerHandler() {}
    /**
     * Author:        Karlo Lorenzana
     * Company:       GE Appliances
     * Zone:          North America
     * Description:   Interface
     * History
     * 2021.05.18     Karlo Lorenzana     initial implementation
     */
    public interface Delegate {
        void prepareBefore();
        void prepareAfter();

        void beforeInsert(List<sObject> objList);
        void beforeUpdate(Map<Id, sObject> oldMap, Map<Id, sObject> newMap);
        void beforeDelete(Map<Id, sObject> newMap);

        void afterInsert(Map<Id, sObject> newMap);
        void afterUpdate(Map<Id, sObject> oldMap, Map<Id, sObject> newMap);
        void afterDelete(Map<Id, sObject> oldMap);
        void afterUndelete(Map<Id, sObject> newMap);

        void finish();
    }


    /**
     * Author:        Karlo Lorenzana
     * Company:       GE Appliances
     * Zone:          North America
     * Description:   DEFAULT DELEGATE INTERFACE IMPLEMENTATION
     * History
     * 2021.05.18     Karlo Lorenzana     initial implementation
     */
    public abstract class DelegateBase implements Delegate {

        /** Implementation requires the method to have no logic  */
        public virtual void prepareBefore() {}
        /** Implementation requires the method to have no logic  */
        public virtual void prepareAfter() {}

        /** Implementation requires the method to have no logic  */
        public virtual void beforeInsert(List<sObject> objList) {system.debug('@@@ isnide trigger objList ' +objList);}
        /** Implementation requires the method to have no logic  */
        public virtual void beforeUpdate(Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {}
        /** Implementation requires the method to have no logic  */
        public virtual void beforeDelete(Map<Id, sObject> newMap) {}

        /** Implementation requires the method to have no logic  */
        public virtual void afterInsert(Map<Id, sObject> newMap) {}
        /** Implementation requires the method to have no logic  */
        public virtual void afterUpdate(Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {}
        /** Implementation requires the method to have no logic  */
        public virtual void afterDelete(Map<Id, sObject> oldMap) {}
        /** Implementation requires the method to have no logic  */
        public virtual void afterUndelete(Map<Id, sObject> newMap) {}

        /** Implementation requires the method to have no logic  */
        public virtual void finish() {}

        /**
         * validateRun validate Run
         */
        protected virtual void validateRun() {
            if (!Trigger.isExecuting) {
                throw new TriggerHandlerException('Trigger handler class cannot be called outside of trigger execution');
            }
        }
    }


    /**
     * execute execution method
     * @param  d delegate
     */
    public static void execute(Delegate d) {
        if (toBeBypassedSet.contains(String.valueOf(d).split(':')[0])) {
            return;
        }

        if (Trigger.isBefore) {
            d.prepareBefore();

            if (Trigger.isInsert) {
                d.beforeInsert(Trigger.new);
            } else if (Trigger.isUpdate) {
                d.beforeUpdate(Trigger.oldMap, Trigger.newMap);
            } else if (Trigger.isDelete) {
                d.beforeDelete(Trigger.oldMap);
            }
        } else {
            d.prepareAfter();

            if (Trigger.isInsert) {
                d.afterInsert(Trigger.newMap);
            } else if (Trigger.isUpdate) {
                d.afterUpdate(Trigger.oldMap, Trigger.newMap);
            } else if (Trigger.isDelete) {
                d.afterDelete(Trigger.oldMap);
            } else if (Trigger.isUndelete) {
                d.afterUndelete(Trigger.newMap);
            }
        }

        d.finish();
    }


    //================================================================================
    // BYPASS TRIGGER LOGIC
    //================================================================================
    private static Set<String> toBeBypassedSet = new Set<String>();

    /**
     * bypassTrigger bypass trigger
     * @param  triggerHandlerClass trigger Handler class
     */
    public static void bypassTrigger(System.Type triggerHandlerClass) {
        toBeBypassedSet.add(triggerHandlerClass.getName());
    }

    /**
     * allowTrigger allow trigger
     * @param  triggerHandlerClass trigger handler class
     */
    public static void allowTrigger(System.Type triggerHandlerClass) {
        toBeBypassedSet.remove(triggerHandlerClass.getName());
    }

    /**
     * Author:        Karlo Lorenzana
     * Company:       GE Appliances
     * Zone:          North America
     * Description:   Trigger Handler Exception
     * History
     * 2021.05.18     Karlo Lorenzana     initial implementation
     */
    public class TriggerHandlerException extends Exception {}
}