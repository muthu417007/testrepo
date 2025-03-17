public class RecordTtypeSelector {
     
    @AuraEnabled
    public string defaultRecordTypeId {get; set;}
    @AuraEnabled
    public Map<Id, String> contactRecordTypes {get; set;}
     
    @AuraEnabled       
    public static RecordTtypeSelector getRecordTypeValues(){
        RecordTtypeSelector obj = new RecordTtypeSelector();
        Map<Id, String> recordtypeMap = new Map<Id, String>();
        //Get all record types of Contact object
        List<Schema.RecordTypeInfo> recordTypeInfoList = Contact.SObjectType.getDescribe().getRecordTypeInfos();
        for(RecordTypeInfo info: recordTypeInfoList) {
            //Check record type is available for current user profile
            if(info.isAvailable()) {
                //Check master record type
                if(info.getName() != 'Master' && info.getName().trim() != ''){
                    recordtypeMap.put(info.getRecordTypeId(), info.getName());
                }
                //Get the default record type for current user profile
                if(info.isDefaultRecordTypeMapping()){
                    obj.defaultRecordTypeId = info.getRecordTypeId();
                }
            }
        }    
        obj.contactRecordTypes = recordtypeMap;
        return obj;
    }
}