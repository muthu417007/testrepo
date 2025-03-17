public class RecordTypecheck {
// Returns a List of the Names of all RecordTypes
// available to the running user for a given SOBject type
public static List<String> GetAvailableRecordTypeNamesForSObject(
    Schema.SObjectType objType
) {
    List<String> names = new List<String>();
    List<RecordTypeInfo> infos = objType.getDescribe().getRecordTypeInfos();
    // If there are 2 or more RecordTypes...
    if (infos.size() > 1) {
        for (RecordTypeInfo i : infos) {
            system.debug('i is:'+i);
           if (i.isAvailable() 
           // Ignore the Master Record Type, whose Id always ends with 'AAA'.
           // We check the Id because Name can change depending on the user's language.
            && !String.valueOf(i.getRecordTypeId()).endsWith('AAA'))
                names.add(i.getName());
        }
    } 
    // Otherwise there's just the Master record type,
    // so add it in, since it MUST always be available
    else names.add(infos[0].getName());
    return names;
}
}