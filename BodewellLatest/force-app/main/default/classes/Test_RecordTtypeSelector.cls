@isTest()
public class Test_RecordTtypeSelector {
     
    private static testmethod  void CreateContact(){
      
        List<Schema.RecordTypeInfo> recordTypeInfoList = Contact.SObjectType.getDescribe().getRecordTypeInfos(); 
        RecordTtypeSelector.getRecordTypeValues();
    }
}