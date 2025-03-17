@RestResource(urlMapping='/queryResults')
global class QueryResultsRestResource {
    final static String baseUrl=URL.getSalesforceBaseUrl().toExternalForm();
	@HttpGet
    global static void doGet()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Map<String,String> paramMap = req.params;
        String soqlQuery;
        String passedColumns;
        if(paramMap.containskey('query')){
        	soqlQuery = paramMap.get('query');
            /*Pattern columnPattern = Pattern.compile('(?<=select)(.*)(?=FROM)');
            Matcher m = columnPattern.matcher(soqlQuery);
            if(m.find()){
                passedColumns=m.group(0);
            }else{
                passedColumns='unknown';
            }*/
            integer afterSelect = soqlQuery.indexOfIgnoreCase(' ');
			integer beforeFrom = soqlQuery.indexOfIgnoreCase(' FROM ');
            if(afterSelect==-1 || beforeFrom==-1){
                passedColumns='error parsing query';
            }else{
                passedColumns=soqlQuery.substring(afterSelect,beforeFrom);
            }
        }        
        
     	wrap w = new wrap();
        w.items = new List<dataItem>();        
        List<SObject> soList = Database.query(soqlQuery);
        Schema.SObjectType soType = soList.getSobjectType();
        dataItem di = new dataItem();
        w.items.add(di);
        di.tableName=soType.getDescribe().getName();
        di.count=soList.size();
        di.rows = new List<row>();
        String jsonString;
        String fullURL = baseUrl+'/services/apexrest'+req.requestURI+'?';
        for(String s:req.params.keyset()){
            fullURL+=s+'='+RestContext.request.params.get(s)+'&';
        }
        fullURL=fullURL.removeEnd('&');
        if(di.count>0){            
            di.columnNames = new List<String>();
            String columnNames='';
            //for(String key : soList.get(0).getPopulatedFieldsAsMap().keySet()){
            for(String key : passedColumns.split(',')){
                //di.columnNames.add(key);
                columnNames+='"'+key.trim()+'",';
            }
            columnNames=columnNames.removeEnd(',');
            jsonString='{ "items": [ { "tableName": "'+soType.getDescribe().getName()+'", "count": '+soList.size()+', "columnNames": ['+columnNames+'], "rows": [ ';
            for(Sobject so : soList){
                jsonString+='[';
                for(String key : so.getPopulatedFieldsAsMap().keySet()){
                	jsonString+='"'+key+'":'+JSON.serialize(so.get(key))+',';
                }
                jsonString=jsonString.removeEnd(',');
                jsonString+='],';
			}
            jsonString=jsonString.removeEnd(',');
            jsonString+=']}],';            
            jsonString+='"links": [{ "rel": "self", "href": "'+fullUrl+'" }] }';
        }
        else
        {
            jsonString='{ "items": [ { "tableName": "'+soType.getDescribe().getName()+'", "count": 0}], "links": [ { "rel": "self", "href" : "'+fullUrl+'" } ] }';
        }
        w.links = new List<link>();
        w.links.add(new link('canonical',baseUrl+'/services/apexrest'+req.requestURI));
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(jsonString);        
    }
    global class wrap
    {
        List<dataItem> items {get;set;}        
        List<link> links {get;set;}
    }
    global class dataItem
    {
        String tableName {get;set;}		
        Integer count {get;set;}
        List<String> columnNames {get;set;}
        List<row> rows {get;set;}
    }
    global class row
    {
        List<String> rowData {get;set;}
    }
    global class link
    {
        link(String rel,String href){
            this.rel=rel;
            this.href=href;
        }
        String rel {get;set;}
        String href {get;set;}
    }
}