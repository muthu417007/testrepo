@RestResource(urlMapping='/latest/analyticsReportResults')
global class AnalyticsReportResultsRestResource {    
    final static String baseUrl=URL.getSalesforceBaseUrl().toExternalForm();
    final static Map<integer,String> keyMap = new Map<integer,String>{1=>'Answers By Category',2=>'App Only Answers',3=>'Index Answers',4=>'Sibling Answers'};
        
    @HttpPost
    global static void doPost()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;  
        integer apiNumber=1;
        integer rowLimit=200;
        Map<String, Object> inputParamMap = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());        
        List<Object> filterList = (List<Object>)inputParamMap.get('filters');
        List<String> columnList;
        String filter=' WHERE PublishStatus=\'Online\' AND Knowledge__kav.Language=\'EN_US\' ';
        String accessString='';
        String dataCategoryString='';
        String keywordFilterString='';
        String filterAttribute;
        
        for(Object obj : filterList){            
            Map<String,Object> filterAttributeMap = (Map<String,Object>)obj;           
            if(filterAttributeMap.containsKey('operator')){
                List<Object> jsonList = (List<Object>)filterAttributeMap.get('values');
                if(String.valueOf(filterAttributeMap.get('name'))=='Access'){                    
                    for(Object o : jsonList){
                        accessString+=String.valueOf(o)+'__c';
                    }
                    
                }else if(String.valueOf(filterAttributeMap.get('name'))=='01I4P000001wZpx.DataCategorySelection.DataCategory.DeveloperName'){
                    for(Object o : jsonList){                       
                        dataCategoryString+=String.valueOf(o)+'__c';              
                    }
                }
            }else{                
                filterAttribute=String.valueOf(filterAttributeMap.get('name'));
                if(filterAttribute.toLowerCase()=='knowledge__kav.keywords__c'){
                    keywordFilterString=String.valueOf(filterAttributemap.get('values'));
                }
            }            
        }
        
        Set<String> keywordMatchIdSet = new Set<String>();
        Set<String> dcMatchIdSet = new Set<String>();        
        
        if(inputParamMap.containsKey('apiNumber'))
            apiNumber=(Integer)inputParamMap.get('apiNumber');
        if(inputParamMap.containsKey('limit'))
            rowLimit=(Integer)inputParamMap.get('limit');
        if(rowLimit>1000)
            rowLimit=1000;
        //query by keyword first
        if(String.isNotBlank(keywordFilterString)){
            String searchQuery = 'FIND {'+keywordFilterString+'} IN ALL FIELDS  RETURNING Knowledge__kav(Id '+filter+' ORDER BY Custom_Created_Date_f__c DESC)';            
            if(apiNumber==4){
				searchQuery+=' WITH DATA CATEGORY Service_Categories__c AT (NewFI_Mobile_Diagnostics__c)';            
            }
            System.debug('searchQuery_TEMP:'+ searchQuery);
            List<List<SObject>> searchList = Search.query(searchQuery);
            if(!searchList.isEmpty()){
                for(Knowledge__kav k : (List<Knowledge__kav>)searchList.get(0)){
                    keywordMatchIdSet.add(k.Id);
                }
            }
            //System.debug('keywordMatch:'+keywordMatchIdSet);
        }
        //since access and data category are in the same column and we want the column to have both values we query twice
        if(String.isNotBlank(dataCategoryString)){
            String soql = 'SELECT Id FROM Knowledge__kav '+filter; 
            if(!keywordMatchIdSet.isEmpty()){
                if(apiNumber==4){
                    soql+=' AND Parent_Article__r.Id IN :keywordMatchIdSet ';
                }else{
                	soql+=' AND Id IN :keywordMatchIdSet ';
                }
            }            
            soql+=' WITH DATA CATEGORY Service_Categories__c AT ('+dataCategoryString+') ';            
            soql+='ORDER BY Custom_Created_Date_f__c DESC LIMIT :rowLimit';
            for(Knowledge__kav k : Database.query(soql)){
                dcMatchIdSet.add(k.Id);
            }
            //System.debug('dcMatchIdSet:'+dcMatchIdSet);
        }
        
        boolean returnEmpty=false;
        if(String.isNotBlank(keywordFilterString) && keywordMatchIdSet.isEmpty())
            returnEmpty=true;
        if(String.isNotBlank(dataCategoryString) && dcMatchIdSet.isEmpty())
            returnEmpty=true;
        if(apiNumber==1){
            columnList = new List<String>{'Knowledge__kav.Id','Knowledge__kav.GE_Tag_URL__c','Knowledge__kav.Title','Knowledge__kav.Custom_Created_Date_f__c','Knowledge__kav.Answer_Type__c'};               
        }
        else if(apiNumber==2){
            columnList = new List<String>{'Knowledge__kav.Id','Knowledge__kav.Title','Knowledge__kav.Solution__c','Knowledge__kav.Attachment_Count__c','Knowledge__kav.Custom_Created_Date_f__c'};
        }
        else if(apiNumber==3){
            columnList = new List<String>{'Knowledge__kav.Id','Knowledge__kav.GE_Tag_URL__c','Knowledge__kav.Title','Knowledge__kav.Custom_Created_Date_f__c','Knowledge__kav.Answer_Type__c'};
        }
        else if(apiNumber==4){
            columnList = new List<String>{'Knowledge__kav.Parent_Article_Id__c','Knowledge__kav.Id','Knowledge__kav.Title',
                'Knowledge__kav.Parent_Article__r.Solution__c','Knowledge__kav.Solution__c','Knowledge__kav.Parent_Article__r.Custom_Created_Date_f__c',
                'Knowledge__kav.Custom_Created_Date_f__c','Knowledge__kav.Parent_Article__r.Answer_Type__c','Knowledge__kav.Answer_Type__c',
                'Attachment_Count__c','Knowledge__kav.Parent_Article__r.Attachment_Count__c'};        
        }
        else if(apiNumber==5||apiNumber==6){
            columnList = new List<String>{'Knowledge__kav.Id','Knowledge__kav.GE_Tag_URL__c','Knowledge__kav.Title','Knowledge__kav.Custom_Created_Date_f__c','Knowledge__kav.Answer_Type__c','Knowledge__kav.SystemModstamp'};  
        }
        String soql='SELECT '+String.join(columnList,',')+' FROM Knowledge__kav '+filter;
        if(!dcMatchIdSet.isEmpty() && !keywordMatchIdSet.isEmpty()){
            Set<String> bothMatch = new Set<String>();
            Set<String> allId = new Set<String>();
            allId.addAll(dcMatchIdSet);
            allId.addAll(keywordMatchIdSet);
            if(apiNumber==4){
                soql+=' AND Id IN :dcMatchIdSet AND Parent_Article__r.Id IN :keywordMatchIdSet';
            }else{
                for(String key : allId){
                    if(dcMatchIdSet.contains(key) && keywordMatchIdSet.contains(key)){
                        bothMatch.add(key);
                    }
                }
                soql+=' AND Id IN :bothMatch';
            }
        }else if(!keywordMatchIdSet.isEmpty()){
            soql+=' AND Id IN :keywordMatchIdSet';
        }
        else if(!dcMatchIdSet.isEmpty()){
            soql+=' AND Id IN :dcMatchIdSet';
        }
        if(!String.isBlank(accessString)){
            soql+=' WITH DATA CATEGORY Products_By_Brand__c AT ('+accessString+') ';
        }
        soql+=' LIMIT :rowLimit';
        
        List<Knowledge__kav> kList = new List<Knowledge__kav>();
        if(apiNumber==5){
            soql='SELECT Knowledge__kav.Id,Knowledge__kav.GE_Tag_URL__c,Knowledge__kav.Title,Knowledge__kav.Custom_Created_Date_f__c,Knowledge__kav.Answer_Type__c,Knowledge__kav.SystemModstamp FROM Knowledge__kav WHERE PublishStatus=\'Online\' AND Knowledge__kav.Language=\'EN_US\' WITH DATA CATEGORY Service_Categories__c AT (Service_Bulletin__c)  order by SystemModstamp desc LIMIT :rowLimit';
        }
        if(apiNumber==6){
            soql='SELECT Knowledge__kav.Id,Knowledge__kav.GE_Tag_URL__c,Knowledge__kav.Title,Knowledge__kav.Custom_Created_Date_f__c,Knowledge__kav.Answer_Type__c,Knowledge__kav.SystemModstamp FROM Knowledge__kav WHERE PublishStatus=\'Online\' AND Knowledge__kav.Language=\'EN_US\' WITH DATA CATEGORY Service_Categories__c AT (Training_Bulletin__c)  order by SystemModstamp desc LIMIT :rowLimit';
        }
        System.debug(soql);
        if(!returnEmpty)
        	kList = Database.query(soql);
        String jsonString='{"count":'+kList.size()+',"name":"'+keyMap.get(apiNumber)+'","columNames":[';
        jsonString+=JSON.serialize(columnList);
        jsonString+='],"rows":[';
       
        for(Knowledge__kav k : kList){
            jsonString+='[';
            if(apiNumber==1||apiNumber==3){
                jsonString+=JSON.serialize(k.Id)+','+JSON.serialize(k.GE_Tag_URL__c)+','+JSON.serialize(k.Title)+','+JSON.serialize(k.Custom_Created_Date_f__c)+','+JSON.serialize(k.Answer_Type__c);
            }else if(apiNumber==2){
                jsonString+=JSON.serialize(k.Id)+','+JSON.serialize(k.Title)+','+JSON.serialize(k.Solution__c)+','+JSON.serialize(k.Attachment_Count__c)+','+JSON.serialize(k.Custom_Created_Date_f__c);
            }else if(apiNumber==4){
                jsonString+=JSON.serialize(k.Parent_Article_Id__c)+','+JSON.serialize(k.Id)+','+JSON.serialize(k.Title)+','
                    +JSON.serialize(k.Parent_Article__r.Solution__c)+','+JSON.serialize(k.Solution__c)+','+JSON.serialize(k.Parent_Article__r.Custom_Created_Date_f__c)
                    +','+JSON.serialize(k.Custom_Created_Date_f__c)
                    +','+JSON.serialize(k.Parent_Article__r.Answer_Type__c)+','+JSON.serialize(k.Answer_Type__c)
                    +','+JSON.serialize(k.Attachment_Count__c)+','+JSON.serialize(k.Parent_Article__r.Attachment_Count__c);
            }
            else if(apiNumber==5||apiNumber==6){
                jsonString+=JSON.serialize(k.Id)+','+JSON.serialize(k.GE_Tag_URL__c)+','+JSON.serialize(k.Title)+','+JSON.serialize(k.Custom_Created_Date_f__c)+','+JSON.serialize(k.Answer_Type__c)+','+JSON.serialize(k.SystemModstamp);
            }
            jsonString+='],';
        }
        jsonString=jsonString.removeEnd(',');
        jsonString+=']}';
        System.debug('jsonString_output' + jsonString);
        res.responseBody = Blob.valueOf(jsonString);
    }
}