public class RecordLocking {
    
@InvocableMethod(label='Lock Damaged Location Application' description='Locks Damaged Location Application Record')
  public static void DLA_RecordLock(List<ID> ids) {
//   List<Damaged_Location_Application__c> DLAs = [SELECT ID FROM Damaged_Location_Application__c  WHERE Id in :ids];
//   Approval.LockResult[] lrList = Approval.lock(DLAs, false);
  }

}