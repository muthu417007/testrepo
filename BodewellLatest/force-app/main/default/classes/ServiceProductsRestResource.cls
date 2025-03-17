@RestResource(urlMapping='/serviceProducts/*')
global class ServiceProductsRestResource {
	final static String baseUrl=URL.getSalesforceBaseUrl().toExternalForm();
	@HttpGet
    global static knowledgeRestResource.wrapper doGet()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Map<String,String> tokensMap = getTokens(req);
		System.debug(req.requestURI);
        Pattern spPattern = Pattern.compile('\\/serviceProducts[/]?');
        Matcher match = spPattern.matcher(req.requestURI);
        if(match.matches()){
            System.debug('spPattern');
            return getAll(req.params);
        }    /*    
        Pattern spIdPattern = Pattern.compile('(\\/serviceProducts\\/(?:[0-9a-z]*[A-z0-9]*))');        
        match = spIdPattern.matcher(req.requestURI);
        if (match.matches()){
            System.debug('spIdPattern');
            return getProductById(tokensMap.get('serviceProducts'));
        }*/
        else{
            return null;
        }
    }
    //#9
    private static knowledgeRestResource.wrapper getAll(Map<String,String> requestParams){
        Map<String,String> paramMap = requestParams;
        knowledgeRestResource.wrapper wrap = new knowledgeRestResource.wrapper();
        wrap.items = new List<knowledgeRestResource.dataItem>();
        wrap.links = new List<knowledgeRestResource.link>();
        /*List<Category_From_Knowledge__c> catList;
        if(paramMap.containskey('nextId')){
        	catList = new List<Category_From_Knowledge__c>([SELECT Id,DataCategorySelection_Id__c,Category_Type__c,DataCategoryName__c 
                                              FROM Category_From_Knowledge__c 
                                              WHERE Category_Type__c='Service_Products'
                                              AND Id > :paramMap.get('nextId')
                                              ORDER BY Id ASC LIMIT 2000]);
        }else{
            catList = new List<Category_From_Knowledge__c>([SELECT Id,DataCategorySelection_Id__c,Category_Type__c,DataCategoryName__c 
                                              FROM Category_From_Knowledge__c 
                                              WHERE Category_Type__c='Service_Products'
                                              ORDER BY Id ASC LIMIT 2000]);
        }
        Id lastId = [SELECT Id FROM Category_From_Knowledge__c ORDER BY Id DESC LIMIT 1].Id;
        Id currentLastId;
        for(Category_From_Knowledge__c cat : catList){
            knowledgeRestResource.dataItem di = new knowledgeRestResource.dataItem();
            di.id=cat.DataCategorySelection_Id__c;
            di.lookupName=cat.DataCategoryName__c;
            di.links = new List<knowledgeRestResource.link>();
            di.links.add(new knowledgeRestResource.link('canonical',baseUrl+'/services/apexrest/serviceProducts/'+di.id));             
            wrap.items.add(di);            
            currentLastId=cat.Id;
		}        
        if(currentLastId!=lastId){
            wrap.links.add(new knowledgeRestResource.link('next',baseUrl+'/services/apexrest/serviceProducts?nextId='+currentLastId)); 
        }*/
        for(DataCategory dc : DescribeDataCategoryGroupStructures.getAll('Service_Products')){
            knowledgeRestResource.dataItem di = new knowledgeRestResource.dataItem();
            di.id=dc.getName();
            di.lookupName=dc.getLabel();
            di.links = new List<knowledgeRestResource.link>();
            di.links.add(new knowledgeRestResource.link('canonical',baseUrl+'/services/apexrest/serviceProducts/'+di.id));             
            wrap.items.add(di);
        }
        return wrap;
    }
    /*
    private static knowledgeRestResource.wrapper getProductById(String dcsId){
        knowledgeRestResource.wrapper wrap = new knowledgeRestResource.wrapper();
        wrap.items = new List<knowledgeRestResource.dataItem>();
        for(Knowledge__DataCategorySelection dcs : [SELECT Id,DataCategoryName,DataCategoryGroupName
                                                    FROM Knowledge__DataCategorySelection WHERE Id=:dcsId]){
                knowledgeRestResource.dataItem di = new knowledgeRestResource.dataItem();
        		di.id=dcs.Id;
                di.lookupName=dcs.DataCategoryName;
                di.links = new List<knowledgeRestResource.link>();
            	di.links.add(new knowledgeRestResource.link('canonical',baseUrl+'/services/apexrest/serviceProducts/'+dcs.Id));                
                wrap.items.add(di);
		}        
        return wrap;
    }*/
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
}