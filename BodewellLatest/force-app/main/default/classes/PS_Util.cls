public class PS_Util {
	public static Map<String, Id> buildMapOfRecordTypes(String passedSobjectType) {
		Map<String, Id> returnMap = new Map<String, Id>();
		for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = :passedSobjectType]) {
			returnMap.put(rt.DeveloperName, rt.Id);
		}
		return returnMap;
	}
}