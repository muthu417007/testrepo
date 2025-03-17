public with sharing class SUCaseCreateController{
    @AuraEnabled
    public static Map<String, String> FetchFields(String GlobalAction){
        final ApexPages.StandardController stdController;
        List<QuickAction.DescribeLayoutItem> fieldList = new List<QuickAction.DescribeLayoutItem>();
        Map<String, String> finalString = new Map<String, String>();
        QuickAction.DescribeQuickActionResult[] results = QuickAction.describeQuickActions(new String[]{ GlobalAction });
        User user = [Select FirstName, LastName, Email from user where Id=: UserInfo.getUserId() limit 1];
        for (QuickAction.DescribeQuickActionResult res : results) {
            for (QuickAction.DescribeLayoutRow row : res.getLayout().getLayoutRows()) {
                for (QuickAction.DescribeLayoutItem col : row.getLayoutItems()) {
                    if (!col.placeholder)
                        fieldList.add(col);                         
                }
            }
         
            finalString.put('defaultValues', JSON.serialize(res.getDefaultValues()));
        }
        finalString.put('fieldList',JSON.serialize(fieldList));
        finalString.put('fieldInfo',JSON.serialize(user));
        return finalString;
    }
    
    @AuraEnabled
    public static String SaveCase(String GlobalAction, Case suCase, List < String > fileIds){
        QuickAction.QuickActionRequest req = new QuickAction.QuickActionRequest();
        req.quickActionName = GlobalAction;
        req.record = suCase;
        QuickAction.QuickActionResult res = QuickAction.performQuickAction(req);
        String recordID = res.getIds()[0];
        Case cc = [select CaseNumber from Case where Id =:recordID];
        if ((fileIds != null && !fileIds.isEmpty())) {
            List < ContentDocumentLink > cdl = new List < ContentDocumentLink > ();
            for (String docId: fileIds) {
                cdl.add(new ContentDocumentLink(contentDocumentID = docId, LinkedEntityId = recordID, ShareType = 'v'));
            }
            insert cdl;
        }
        Map<string, string> details =new Map<string, string>();
        details.put('recordID',recordID);
        details.put('caseNumber',cc.CaseNumber);
        String CaseDetails = JSON.serialize(details);
        return CaseDetails;
    }
}