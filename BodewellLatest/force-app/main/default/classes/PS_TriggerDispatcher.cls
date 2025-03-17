public class PS_TriggerDispatcher {

    public static void run(PS_ITriggerHandler handler) {

        if (handler.IsDisabled()){
            return;
        }

        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                handler.beforeInsert(Trigger.New);
            }
            if (Trigger.isUpdate) {
                handler.beforeUpdate(Trigger.newMap, Trigger.OldMap);
            }
            
            if (Trigger.isDelete) {
                handler.beforeDelete(Trigger.oldMap);
            }
        }

        if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                handler.afterInsert(Trigger.New);
            }
            if (Trigger.isUpdate) {
                handler.afterUpdate(Trigger.newMap, Trigger.OldMap);
            }
            if (Trigger.isDelete) {
                handler.afterDelete(Trigger.oldMap);
            }
        }
    }
}