public class CaseLinksController {

    @AuraEnabled
	public static Case queryCase(String caseId)
	{
		Case c = [select Id, ContactId
                  from Case where Id=:caseId limit 1];
		return c;
	}
    
}