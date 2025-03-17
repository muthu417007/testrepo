@isTest(seeAllData=true)
public class AnalyticsReportResultsRestResource_test {

    static testMethod void test1(){
        RestResponse res = new RestResponse();
        
        RestRequest request = new RestRequest();
        request.requestUri ='https://cs13.salesforce.com/services/apexrest/AnalyticsReportResultsRestResource';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof('{"apiNumber":1,"limit":100,"filters":[{"name": "Knowledge__kav.Language","values": "English"}, {"name": "01I4P000001wZpx.DataCategorySelection.DataCategory.DeveloperName",     "operator": { "id": 10  },  "values": [   "Mini_Manual"   ]  }, {    "name": "Access",   "operator": {       "id": 10    },    "values": [       "TAG_Access"   ]  }]}');
        
        RestContext.request = request;
        RestContext.response = res;
        AnalyticsReportResultsRestResource.doPost();
      
    }
    static testMethod void test2(){
        RestResponse res = new RestResponse();
        
        RestRequest request = new RestRequest();
        request.requestUri ='https://cs13.salesforce.com/services/apexrest/AnalyticsReportResultsRestResource';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof('{"apiNumber":2,"limit":10,"filters":[{"name":"Access","operator":{"id": 10},"values":["TAG_Access"]}]}');
        
        RestContext.request = request;
        RestContext.response = res;
        AnalyticsReportResultsRestResource.doPost();
      
    }

    static testMethod void test3(){
        RestResponse res = new RestResponse();
        
        RestRequest request = new RestRequest();
        request.requestUri ='https://cs13.salesforce.com/services/apexrest/AnalyticsReportResultsRestResource';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof('{"apiNumber":3,"limit":10,"filters":[{"name":"Access","operator":{"id":10},"values":["TAG_Access"]}]}');
        
        RestContext.request = request;
        RestContext.response = res;
        AnalyticsReportResultsRestResource.doPost();
      
    }
    static testMethod void test4(){
        RestResponse res = new RestResponse();
        
        RestRequest request = new RestRequest();
        request.requestUri ='https://cs13.salesforce.com/services/apexrest/AnalyticsReportResultsRestResource';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof('{"apiNumber":4,"limit":100,"filters":[{"name": "Knowledge__kav.Keywords__c","values": "PFE29PSDASS"   }, {"name": "01I4P000001wZpx.DataCategorySelection.DataCategory.DeveloperName","operator": {"id": 10},"values": [ "Mini_Manual" ]  } ]}');
        
        RestContext.request = request;
        RestContext.response = res;
        AnalyticsReportResultsRestResource.doPost();
    }
    static testMethod void test5(){
        RestResponse res = new RestResponse();
        
        RestRequest request = new RestRequest();
        request.requestUri ='https://cs13.salesforce.com/services/apexrest/AnalyticsReportResultsRestResource';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof('{"apiNumber":5,"limit":5,"filters":[{"name": "Knowledge__kav.Keywords__c","values": "PFE29PSDASS"   }, {"name": "01I4P000001wZpx.DataCategorySelection.DataCategory.DeveloperName","operator": {"id": 10},"values": [ "Mini_Manual" ]  } ]}');
        
        RestContext.request = request;
        RestContext.response = res;
        AnalyticsReportResultsRestResource.doPost();
    }
}