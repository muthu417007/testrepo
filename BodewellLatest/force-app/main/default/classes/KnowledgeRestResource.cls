@RestResource(urlMapping='/knowledge/*')
global class KnowledgeRestResource 
{
    final static String psOnline='Online';
    //PublishStatus=:psOnline AND 
    final static String baseUrl=URL.getSalesforceBaseUrl().toExternalForm();
    @HttpGet
    global static void doGet()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        System.debug(req.requestURI);
        Map<String,String> tokensMap = getTokens(req);
        //1
        Pattern knowledgePattern = Pattern.compile('\\/knowledge[/]?');
        Matcher match = knowledgePattern.matcher(req.requestURI);
        res.addHeader('Content-Type', 'application/json');
        if(match.matches()){
            System.debug('knowledgePattern');
            res.responseBody = Blob.valueOf(JSON.serialize(getKnowledge(req)));
        }
        //2
        Pattern knowledgeIdPattern = Pattern.compile('(\\/knowledge\\/(?:[a-z][a-z]*[0-9]+[A-z0-9]*))');        
        match = knowledgeIdPattern.matcher(req.requestURI);
        if (match.matches()){
            System.debug('knowledgeIdPattern');
            res.responseBody = Blob.valueOf(JSON.serialize(getKnowledgeById(req,tokensMap.get('knowledge'))));
        }
        //3
        Pattern knowledgeIdAccessLevelsPattern = Pattern.compile('(\\/knowledge\\/(?:[a-z][a-z]*[0-9]+[A-z0-9]*))/accessLevels[/]?');        
        match = knowledgeIdAccessLevelsPattern.matcher(req.requestURI);
        if(match.matches()){
            System.debug('knowledgeAccessLevelsPattern');
            res.responseBody = Blob.valueOf(getAccessLevelsById(req,tokensMap.get('knowledge')));
        }
        //4
        //Pattern accessLevelPattern = Pattern.compile('(\\/knowledge\\/(?:[a-z][a-z]*[0-9]+[A-z0-9]*))/accessLevels/([0-9]{1,2}[:.,-]?$)');                
        Pattern accessLevelPattern = Pattern.compile('(\\/knowledge\\/(?:[a-z][a-z]*[0-9]+[A-z0-9]*))/accessLevels/([_0-9A-z]*)');
        match = accessLevelPattern.matcher(req.requestURI);
        if(match.matches()){
            System.debug('accessLevelPattern');
            res.responseBody = Blob.valueOf(JSON.serialize(getAccessLevelName(tokensMap.get('knowledge'),tokensMap.get('accessLevels'))));
        }
        //5
        Pattern knowledgeAttachmentsPattern = Pattern.compile('(\\/knowledge\\/(?:[a-z][a-z]*[0-9]+[A-z0-9]*))\\/fileAttachments[/]?');
        match = knowledgeAttachmentsPattern.matcher(req.requestURI);
        if(match.matches()){
            System.debug('knowledgeAttachmentsPattern');
            res.responseBody = Blob.valueOf(getKnowledgeAttachments(tokensMap.get('knowledge')));
        }
        //6
        Pattern knowledgeAttachmentPattern = Pattern.compile('(\\/knowledge\\/([0-9a-z]*[A-z0-9]*)\\/fileAttachments\\/([0-9a-z]*[A-z0-9]*))');
        match = knowledgeAttachmentPattern.matcher(req.requestURI);
        if(match.matches()){
            System.debug('knowledgeAttachmentPattern');
            res.responseBody = Blob.valueOf(JSON.serialize(getKnowledgeAttachmentById(tokensMap.get('knowledge'),tokensMap.get('fileAttachments'))));
        }
        //7
        Pattern knowledgeServiceProductPattern = Pattern.compile('(\\/knowledge\\/(?:[a-z][a-z]*[0-9]+[A-z0-9]*)\\/products[/]?)');
        match = knowledgeServiceProductPattern.matcher(req.requestURI);
        if(match.matches()){
            System.debug('knowledgeServiceProductPattern');
            res.responseBody = Blob.valueOf(JSON.serialize(getKnowledgeServiceProducts(tokensMap.get('knowledge'))));
        }
        //8
        Pattern knowledgeServiceCategoriesPattern = Pattern.compile('(\\/knowledge\\/(?:[a-z][a-z]*[0-9]+[A-z0-9]*)\\/categories[/]?)');
        match = knowledgeServiceCategoriesPattern.matcher(req.requestURI);
        if(match.matches()){
            System.debug('knowledgeServiceCategoriesPattern');
            res.responseBody = Blob.valueOf(JSON.serialize(getKnowledgeServiceCategories(tokensMap.get('knowledge'))));
        }
        //13 Pattern knowledgeDeletePattern 
        Pattern knowledgeDeletePattern = Pattern.compile('(\\/knowledge\\/deleted)');
        match = knowledgeDeletePattern.matcher(req.requestURI);
        if(match.matches()){
            System.debug('knowledgeDeletedPattern');
            res.responseBody = Blob.valueOf(JSON.serialize(getDeletedKnowledge(req)));
        }        
    }    
    //13
    private static wrapper getDeletedKnowledge(RestRequest req){
        wrapper wrap = new wrapper();
        wrap.items = new List<dataItem>();
        System.debug('startDate:'+req.params.get('startDate'));
        System.debug('endDate:'+req.params.get('endDate'));
        DateTime sDate = Datetime.valueOfGMT(req.params.get('startDate'));
        DateTime eDate = Datetime.valueOfGMT(req.params.get('endDate'));
        System.debug('startTime: '+sDate);
        System.debug('endTime: '+eDate);
        for(Knowledge_Delete__c kd : [SELECT Id,Knowledge_Id__c FROM Knowledge_Delete__c WHERE CreatedDate>=:sDate AND CreatedDate<=:eDate]){            
            dataItem di = new dataItem();
            di.id=kd.Knowledge_Id__c;
            wrap.items.add(di);
        }
        return wrap;
    }
    private static void downloadAttachment(String cdId,RestResponse res){
        wrapper wrap = new wrapper();
        ContentVersion cv = [SELECT Id,VersionData,FileType,Title FROM ContentVersion WHERE ContentDocumentId=:cdId AND IsLatest=true];        
        res.responseBody=cv.VersionData;
    }
    //#8
    private static wrapper getKnowledgeServiceCategories(String kId){
        wrapper wrap = new wrapper();
        wrap.items = new List<dataItem>();        
        wrap.links = new List<link>();
        wrap.links.add(new link('canonical',baseUrl+'/services/apexrest/knowledge/'+kId+'/categories'));
        for(Knowledge__DataCategorySelection dcs : [SELECT DataCategoryName,DataCategoryGroupName
                                                    FROM Knowledge__DataCategorySelection 
                                                    WHERE ParentId=:kId])
        {
            if(dcs.DataCategoryGroupName=='Service_Categories'){                
                    dataItem di = new dataItem();
                    di.rel='canonical';
                  di.id=dcs.DataCategoryName;
                    di.Name=dcs.DataCategoryName;
                  //di.href=baseUrl+'/services/apexrest/serviceCategories/'+dcs.Id;
                    wrap.items.add(di);
                }            
        }        
        
        return wrap;
    } 
    //#7
    private static wrapper getKnowledgeServiceProducts(String kId){
        wrapper wrap = new wrapper();
        wrap.links = new List<link>();
        wrap.items = new List<dataItem>();
        wrap.links.add(new link('canonical',baseUrl+'/services/apexrest/knowledge/'+kId+'/products'));
        List<Knowledge__DataCategorySelection> dcsList = new List<Knowledge__DataCategorySelection>([SELECT Id,DataCategoryName,DataCategoryGroupName FROM Knowledge__DataCategorySelection where ParentId=:kId]);        
        for(Knowledge__DataCategorySelection dcs : dcsList){
            if(dcs.DataCategoryGroupName=='Service_Products'){                
                dataItem di = new dataItem(); 
                di.rel='canonical';
                //di.href=baseUrl+'/services/apexrest/serviceProducts/'+dcs.Id;
                di.Name=dcs.DataCategoryName;
                di.id=dcs.DataCategoryName;
                wrap.items.add(di);
            }            
        }        
        return wrap;
    }    
    //#6
    private static dataItem getKnowledgeAttachmentById(String kId, String fileId){
        
        ContentDocument cd = [SELECT Id,CreatedDate,LastModifiedDate,ContentSize,FileType,Title,LatestPublishedVersionId FROM ContentDocument WHERE Id=:fileId];
        dataItem di = new dataItem();
        di.contentType=cd.FileType;
        di.createdTime=cd.CreatedDate;
        di.fileName=cd.Title;
        di.id=cd.Id;
        di.size=cd.ContentSize;
        di.updatedTime=cd.LastModifiedDate;
        di.uRL=baseUrl+'/services/data/v46.0/sobjects/ContentVersion/'+cd.LatestPublishedVersionId+'/VersionData';
        
        return di;
    }
    //#5
    private static String getKnowledgeAttachments(String kId){        
        String jsonString = '{"items": [';
        for(ContentDocumentLink cdl : [SELECT Id,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:kId]){
            jsonString+='{"rel": "canonical","href": "'+baseUrl+'/services/apexrest/knowledge/'+kId+'/fileAttachments/'+cdl.ContentDocumentId+'"},';
        }
        jsonString = jsonString.removeEnd(',');
        jsonString+=']}';
        return jsonString;
    }
    //#4 returns what the number value in OSC was based on the SFDC level
    private static dataItem getAccessLevelName(String kId,String level){
        //wrapper wrap = new wrapper();
        Map<String,Decimal> alMap = new Map<String,Decimal>();
        for(OSC_Access_Level__mdt al : [SELECT MasterLabel,DeveloperName,Access_Level__c FROM OSC_Access_Level__mdt]){
            alMap.put(al.DeveloperName,al.Access_Level__c);            
        }         
        //wrap.items = new List<dataItem>();
        dataItem di = new dataItem();
        di.id=level;
        di.lookupName=String.valueOf(alMap.get(level));
        di.links = new List<link>();
        di.links.add(new link('canonical',baseUrl+'/services/apexrest/knowledge/'+kId+'/accessLevels/'+level));
        //wrap.items.add(di);
        return di;
    }
    //#3
    private static String getAccessLevelsById(RestRequest req,String kId){        
        //wrapper wrap = new wrapper();
        List<Knowledge__DataCategorySelection> dcsList = new List<Knowledge__DataCategorySelection>([SELECT DataCategoryName FROM Knowledge__DataCategorySelection where ParentId=:kId]);        
        Set<String> accessSet = new Set<String>();
        String jsonString='';
        for(Knowledge__DataCategorySelection dcs : dcsList){
            if(dcs.DataCategoryName.endsWith('_Access')){
                accessSet.add(dcs.DataCategoryName);
            }            
        }
        if(!accessSet.isEmpty()){
            System.debug('accessSet:'+accessSet);
            //Map<String,Decimal> alMap = new Map<String,Decimal>();
            //for(OSC_Access_Level__mdt al : [SELECT MasterLabel,DeveloperName,Access_Level__c FROM OSC_Access_Level__mdt]){
            //    alMap.put(al.DeveloperName,al.Access_Level__c);                
            //}            
            //System.debug('alMap:'+alMap);
            jsonString='{ "items": [';
            for(String accessName : accessSet){
                System.debug('getting access:'+accessName);
                jsonString+='{ "rel": "canonical", "href": "'+baseUrl+'/services/apexrest/knowledge/'+kId+'/accessLevels/'+accessName+'"},';
            }           
            jsonString = jsonString.removeEnd(',');
            jsonString+='],"links": [ { "rel": "canonical", "href": "'+baseUrl+'/services/apexrest/knowledge/'+kId+'/accessLevels" }]}';            
        }
        return jsonString;
    }
    //#2
    private static dataItem getKnowledgeById(RestRequest req,String kId){
        //wrapper wrap = new wrapper();        
        Knowledge__kav k = [SELECT Id,Custom_Created_Date_f__c,LastModifiedDate,PublishStatus,Legacy_Answer_Id__c,Summary,Legacy_Url__c,Keywords__c,Solution__c FROM Knowledge__kav WHERE Id=:kId];
        
        dataItem di = new dataItem();
        di.id=k.Legacy_Answer_Id__c;
        di.lookupName=String.valueOf(k.Legacy_Answer_Id__c);
        di.createdTime=k.Custom_Created_Date_f__c;
        di.updatedTime=k.LastModifiedDate;
        di.name=k.Legacy_Answer_Id__c;
        di.keywords=k.Keywords__c;
        di.solution=k.Solution__c;
        di.summary=k.Summary;
        di.legacyurl=k.Legacy_Url__c;
        di.uRL=baseUrl+'/'+k.Id;
        return di;
        //wrap.item = di;
        //return wrap;
    }
    //#1
    private static wrapper getKnowledge(RestRequest req){        
        Map<String,String> paramMap = req.params;
        integer soqlLimit=2000;
        String passedFromId='';
        String fromId='';
        String passedFilter='';
        if(paramMap.containskey('limit'))
            soqlLimit = integer.valueOf(paramMap.get('limit'));
        if(paramMap.containskey('fromId')){
            //fromId = integer.valueOf(paramMap.get('fromId'));
            passedFromId = paramMap.get('fromId');
        }
        if(paramMap.containskey('q')){
            passedFilter = paramMap.get('q');
        }
        String q = 'SELECT Id,Custom_Created_Date_f__c,LastModifiedDate,PublishStatus,Legacy_Answer_Id__c,Legacy_Status_with_Type__c,Legacy_Date_Updated__c FROM Knowledge__kav ';
        String qFilter='WHERE Legacy_Answer_Id__c!=null ';
        if(String.isNotBlank(passedFilter)){
            qFilter+=' '+passedFilter+' ';
        }
        String orderString='ORDER BY Id ASC ';        
        String limitString='limit :soqlLimit ';  
        if(String.isNotBlank(passedFromId))
          qFilter+='AND Id > :passedFromId ';        
        wrapper wrap = new wrapper();
        wrap.items = new List<dataItem>();
        String queryString = q+qFilter+orderString+limitString;
        for(Knowledge__kav k : Database.query(queryString)){
            dataItem di = new dataItem();
            di.id=k.Legacy_Answer_Id__c;
            di.lookupName=String.valueOf(k.Legacy_Answer_Id__c);            
            di.createdTime=k.Custom_Created_Date_f__c;
            di.updatedTime=k.LastModifiedDate;            
            di.updatedTimeLegacy=k.Legacy_Date_Updated__c;            
            di.links = new List<link>{new link('canonical',baseUrl+'/services/apexrest/knowledge/'+k.Id)};            
            wrap.items.add(di);
            fromId=k.Id;
        }      
        //integer valueOfNext=fromId+soqlLimit;
        wrap.hasMore=Database.query(q+qFilter+'AND Id>:fromId limit 1').size()>0;
        wrap.links = new List<link>();
        if(wrap.hasMore)
          wrap.links.add(new link('next',baseUrl+'/services/apexrest/knowledge'+buildNextParameters(fromId,soqlLimit,'q='+passedFilter)));
        //wrap.links.add(new link('previous',baseUrl+'/services/apexrest/knowledge'+buildPreviousParameters(fromId,passedFromId,soqlLimit,'q='+passedFilter)));
        return wrap;
    }
    private static String buildNextParameters(String fromId, integer offset, String q){        
        //integer newFromId=fromId+offset;
        return '?limit='+String.valueOf(offset)+'&fromId='+fromId+'&'+q;
    }
    private static String buildPreviousParameters(String fromId,String passedFromId, integer offset, String q){        
        //integer newFromId=fromId-offset;
        //newFromId=newFromId<0?0:newFromId;
        if(String.isBlank(passedFromId)){
            return '';
        }
        return '?limit='+String.valueOf(offset)+'&fromId='+passedFromId+'&'+q;
    }
    private static Map<String,String> getTokens(RestRequest req){       
        List<String> tokens = req.requestURI.split('/');        
        Map<String,String> tokensMap = new Map<String,String>();
        for( integer i = 1 ; i < tokens.size() ; i++ )
        {            
            if(i+1<tokens.size()){
                tokensMap.put( tokens.get( i ), tokens.get( ++i ) );
            }
        }        
        return tokensMap;
    }
    global class wrapper
    {
        dataItem item {get;set;}
        global List<dataItem> items {get;set;}
        boolean hasMore {get;set;}
        global List<link> links {get;set;}
    }
    global class dataItem
    {
        global String id {get;set;}
        global String lookupName {get;set;}
        global DateTime createdTime {get;set;}
        global DateTime updatedTime {get;set;}
        global DateTime updatedTimeLegacy {get;set;}
        global String name {get;set;}
        global String keywords {get;set;}
        global String solution {get;set;}
        global String summary {get;set;}
        global String legacyurl {get;set;}
        global String uRL {get;set;}
        global List<link> links {get;set;}
        global String contentType {get;set;}
        global String fileName {get;set;}
        global Integer size {get;set;}
        global String knowledgeFile {get;set;}        
        global String rel {get;set;}
        global String href {get;set;}
        global parent parent {get;set;}
    }
    global class parent
    {
      global List<link> links {get;set;}   
    }
    global class link
    {
        global link(String rel,String href){
            this.rel=rel;
            this.href=href;
        }
        String rel {get;set;}
        String href {get;set;}
    }
    
    public class ResponseWrapper
    {
        public boolean isError ;
        public string errorCode;
        public integer statusCode;
        
        public ResponseWrapper()
        {
            isError= false;
        }
    }
}