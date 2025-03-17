@RestResource(urlMapping='/serviceCategories/*')
global class ServiceCategoriesRestResource {
    final static String baseUrl=URL.getSalesforceBaseUrl().toExternalForm();
	@HttpGet
    global static void doGet()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
		System.debug(req.requestURI);
        Map<String,String> tokensMap = getTokens(req);
        //10
        Pattern serviceCategoriesPattern = Pattern.compile('(\\/serviceCategories[/]?)');
        Matcher match = serviceCategoriesPattern.matcher(req.requestURI);
        if(match.matches()){
            System.debug('serviceCategoriesPattern');
            res.responseBody = Blob.valueOf(JSON.serialize(getAllServiceCategories(req.params)));
        }
        //11
        Pattern serviceCategoriesIdPattern = Pattern.compile('(\\/serviceCategories\\/(?:[0-9a-z]*[A-z0-9]*)[/]?)');
        match = serviceCategoriesIdPattern.matcher(req.requestURI);
        if(match.matches()){
            System.debug('serviceCategoriesIdPattern');
            res.responseBody = Blob.valueOf(JSON.serialize(getServiceCategoryById(tokensMap.get('serviceCategories'))));
           
        }        
    }    
    //#10
    private static knowledgeRestResource.wrapper getAllServiceCategories(Map<String,String> requestParams){
        Map<String,String> paramMap = requestParams;
        knowledgeRestResource.wrapper wrap = new knowledgeRestResource.wrapper();
        Map<Decimal,String> alMap = new Map<Decimal,String>();
        wrap.items = new List<knowledgeRestResource.dataItem>();
        wrap.links = new List<knowledgeRestResource.link>();
        /*
         List<Category_From_Knowledge__c> catList;
        if(paramMap.containsKey('nextId')){
        	catList = new List<Category_From_Knowledge__c>([SELECT Id,DataCategorySelection_Id__c,Category_Type__c,DataCategoryName__c 
                                              FROM Category_From_Knowledge__c 
                                              WHERE Category_Type__c='Service_Categories'
                                              AND Id > :paramMap.get('nextId')
                                              ORDER BY Id ASC LIMIT 2000]);
        }else{
           catList = new List<Category_From_Knowledge__c>([SELECT Id,DataCategorySelection_Id__c,Category_Type__c,DataCategoryName__c 
                                              FROM Category_From_Knowledge__c 
                                              WHERE Category_Type__c='Service_Categories'
                                              ORDER BY Id ASC LIMIT 2000]);
        }
        Id lastId = [SELECT Id FROM Category_From_Knowledge__c ORDER BY Id DESC LIMIT 1].Id;
        Id currentLastId;
        for(Category_From_Knowledge__c cat : catList){
        	knowledgeRestResource.dataItem di = new knowledgeRestResource.dataItem();
           	di.id=cat.DataCategorySelection_Id__c;
            di.lookupName=cat.DataCategoryName__c;
            di.links = new List<knowledgeRestResource.link>();
            di.links.add(new knowledgeRestResource.link('canonical',baseUrl+'/services/apexrest/serviceCategories/'+di.id));
            wrap.items.add(di);    
            currentLastId=cat.Id;
        }
        if(currentLastId!=lastId){
            wrap.links.add(new knowledgeRestResource.link('next',baseUrl+'/services/apexrest/serviceCategories?nextId='+currentLastId)); 
        }*/
        for(DataCategory dc : DescribeDataCategoryGroupStructures.getAll('Service_Categories')){
            knowledgeRestResource.dataItem di = new knowledgeRestResource.dataItem();
            di.id=dc.getName();
            di.lookupName=dc.getLabel();
            di.links = new List<knowledgeRestResource.link>();
            di.links.add(new knowledgeRestResource.link('canonical',baseUrl+'/services/apexrest/serviceCategories/'+di.id));             
            wrap.items.add(di);
        }
        return wrap;
    }
    //#11
    private static knowledgeRestResource.dataItem getServiceCategoryById(String categoryId){        
        return DescribeDataCategoryGroupStructures.getChildren(categoryId);        
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
}