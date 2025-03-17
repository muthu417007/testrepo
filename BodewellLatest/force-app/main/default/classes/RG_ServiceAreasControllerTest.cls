//******************************************************************************************
// Author:       Yogesh Sharma
// Company:      TCS
// Created Date: 11/04/2023
//******************************************************************************************
//@description : Apex Class to Test Service Area requests
@isTest
private class RG_ServiceAreasControllerTest 
{
    
    //@description : Apex method to test all Service Area State requests
    @isTest
    static void getServiceAreasTest()
    {
        servicearea__c statearea = new servicearea__c();        
        statearea.Name = 'Test State Area';
        insert statearea;
        servicearea__c cityarea = new servicearea__c();
        cityarea.Name = 'Test City Area';
        cityarea.State__c = statearea.Id;
        insert cityarea;
        
        List<servicearea__c> serviceArea = [SELECT Id, Name, State__c 
                                             FROM servicearea__c
                                             WHERE State__c = null
                                             ORDER BY Name];
        
        List<servicearea__c> serviceAreaTest = RG_ServiceAreasController.getServiceAreas();
        //System.assertEquals(serviceArea.size(), serviceAreaTest.size(),'Test Passed');
    }
    
    //@description : Apex method to test all Service Area City requests
    @isTest
    static void getLocalServiceAreasTest()
    {
        servicearea__c statearea = new servicearea__c();        
        statearea.Name = 'Test State Area';
        insert statearea;
        servicearea__c cityarea = new servicearea__c();
        cityarea.Name = 'Test City Area';
        cityarea.State__c = statearea.Id;
        insert cityarea;
        
        String serviceTerritoryName = 'Test State Area';
        List<servicearea__c> serviceArea = [SELECT Id, Name, State__c, State_Abbreviation__c
                                                FROM servicearea__c 
                                                WHERE State__c =:serviceTerritoryName
                                                ORDER BY Name];
        List<servicearea__c> serviceAreaTest = RG_ServiceAreasController.getLocalServiceAreas(serviceTerritoryName);
        System.assertEquals(serviceArea.size(), serviceAreaTest.size(),'Test Passed');
    }
    //@description : Apex method to test Service Area City Details requests
    @isTest
    static void getLocalAreaDetailsTest()
    {
        servicearea__c statearea = new servicearea__c();        
        statearea.Name = 'Test State Area';
        insert statearea;
        servicearea__c cityarea = new servicearea__c();
        cityarea.Name = 'Test City Area';
        cityarea.State__c = statearea.Id;
        insert cityarea;
        
        String localAreaName = 'Test City Area';
        servicearea__c localArea = [SELECT Id, Name, State_Abbreviation__c, Local_Phone__c, Side_Text__c, TollFree_Phone__c
                                        FROM servicearea__c 
                                        WHERE Name =: localAreaName
                                        LIMIT 1];
        servicearea__c localAreaTest = RG_ServiceAreasController.getLocalAreaDetails(localAreaName);
        //System.assertEquals(localArea.Name, localAreaTest.Name,'Test Passed');
    }
    //@description : Apex method to test Service Area City Details requests for Search Result Page
    @isTest
    static void getLocalAreaDetailsSearchResultsTest()
    {
        servicearea__c statearea = new servicearea__c(Name = 'Alabama',State_Abbreviation__c = 'AL');        
        /*statearea.Name = 'Alabama';
        statearea.State_Abbreviation__c = 'AL';
        insert statearea;*/
        servicearea__c cityarea = new servicearea__c(Name = 'Birmingham',State_Abbreviation__c = 'AL',Latitude__c = '34.7251794',Longitude__c = '-86.6325477',State__c = statearea.Id);
        /*cityarea.Name = 'Birmingham';
        cityarea.State_Abbreviation__c = 'AL';
        cityarea.Latitude__c = '34.7251794';
        cityarea.Longitude__c = '-86.6325477';
        cityarea.State__c = statearea.Id;
        insert cityarea;*/
        
        //String localAreaDetails = 'Birmingham, AL, USA';
        //String placeId = 'abc';
        
        //servicearea__c localAreaTest = RG_ServiceAreasController.getLocalAreaDetailsSearchResults(localAreaDetails,placeId);
        Test.setMock(HttpCalloutMock.class, new RG_PlaceSearchResponseGenerator());
        servicearea__c localAreaTest = RG_ServiceAreasController.getLocalAreaDetailsSearchResults('Birmingham, AL, USA','ChIJeRpOeF67j4AR9ydy_PIzPuM');
        //System.assertEquals(localAreaTest.Name, 'Birmingham','Test Passed');
    }
    //@description : Apex method to test all Service Area State and City requests for Sitemap
    @isTest
    static void getSiteMapServiceAreasTest()
    {
        servicearea__c statearea = new servicearea__c();        
        statearea.Name = 'Test State Area';
        insert statearea;
        servicearea__c cityarea = new servicearea__c();
        cityarea.Name = 'Test City Area';
        cityarea.State__c = statearea.Id;
        insert cityarea;
        
        List<RG_ServiceAreasController.RG_SitemapServiceList> serviceAreaSitemapListTest = RG_ServiceAreasController.getSiteMapServiceAreas();
        //System.assertNotEquals(serviceAreaSitemapListTest.size(), 0, 'Test Passed');
    }
    //@description : Mock Response generator to test address details
    private class RG_PlaceSearchResponseGenerator implements HttpCalloutMock
    {
        public HTTPResponse respond(HTTPRequest req) 
        { 
            String searchUrl = 'https://maps.googleapis.com/maps/api/geocode/json?'
                + 'place_id=' + EncodingUtil.urlEncode('ChIJeRpOeF67j4AR9ydy_PIzPuM', 'UTF-8')
                + '&key='+Label.RG_GoogleMapsGeocodeApiKey; 
            HttpResponse res = new HttpResponse();
            system.debug(req.getEndpoint());
            System.assertEquals(searchUrl, req.getEndpoint());
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{\"results\":[{\"address_components\":[{\"long_name\":\"1600\",\"short_name\":\"1600\",\"types\":[\"street_number\"]},{\"long_name\":\"Amphitheatre Parkway\",\"short_name\":\"Amphitheatre Pkwy\",\"types\":[\"route\"]},{\"long_name\":\"Mountain View\",\"short_name\":\"Mountain View\",\"types\":[\"locality\",\"political\"]},{\"long_name\":\"Santa Clara County\",\"short_name\":\"Santa Clara County\",\"types\":[\"administrative_area_level_2\",\"political\"]},{\"long_name\":\"California\",\"short_name\":\"CA\",\"types\":[\"administrative_area_level_1\",\"political\"]},{\"long_name\":\"United States\",\"short_name\":\"US\",\"types\":[\"country\",\"political\"]},{\"long_name\":\"94043\",\"short_name\":\"94043\",\"types\":[\"postal_code\"]}],\"formatted_address\":\"1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA\",\"geometry\":{\"location\":{\"lat\":37.4223995,\"lng\":-122.0847998},\"location_type\":\"ROOFTOP\",\"viewport\":{\"northeast\":{\"lat\":37.4238877802915,\"lng\":-122.0834170697085},\"southwest\":{\"lat\":37.4211898197085,\"lng\":-122.0861150302915}}},\"place_id\":\"ChIJeRpOeF67j4AR9ydy_PIzPuM\",\"plus_code\":{\"compound_code\":\"CWC8+X3 Mountain View, CA\",\"global_code\":\"849VCWC8+X3\"},\"types\":[\"street_address\"]}],\"status\":\"OK\"}');
            res.setStatusCode(200);
            return res;
        }
    }
    //@description : Apex method to test Service Area City Details requests for Search Result Page with PlaceId
    @isTest
    static void getLocalAreaDetailsSearchResultsTest1()
    {
        servicearea__c statearea = new servicearea__c(Name = 'Alabama', State_Abbreviation__c = 'AL');        
        /*statearea.Name = 'Alabama';
        statearea.State_Abbreviation__c = 'AL';
        insert statearea;*/
        servicearea__c cityarea = new servicearea__c(Name = 'Santa Clara',State_Abbreviation__c = 'AL',State__c = statearea.Id);
        /*cityarea.Name = 'Santa Clara';
        cityarea.State_Abbreviation__c = 'AL';
        cityarea.State__c = statearea.Id;
        insert cityarea;*/
        
        Test.setMock(HttpCalloutMock.class, new RG_PlaceSearchResponseGenerator());
        servicearea__c serviceCity = RG_ServiceAreasController.getLocalAreaDetailsSearchResults('Santa Clara, AL, USA', 'ChIJeRpOeF67j4AR9ydy_PIzPuM');
    }
    //@description : Apex method to test all Service Area City Details requests for Latitude and Longitude
    @isTest
    static void getLocalAreaDetailsSearchResultsLatLongTest()
    {
        servicearea__c statearea = new servicearea__c();        
        statearea.Name = 'Alabama';
        statearea.State_Abbreviation__c = 'AL';
        insert statearea;
        servicearea__c cityarea = new servicearea__c();
        cityarea.Name = 'Santa Clara';
        cityarea.State_Abbreviation__c = 'AL';
        cityarea.Latitude__c = '34.7251794';
        cityarea.Longitude__c = '-86.6325477';
        cityarea.State__c = statearea.Id;
        insert cityarea;
        
        servicearea__c serviceCity = RG_ServiceAreasController.getLocalAreaDetailsSearchResultsLatLong('34.7251794,-86.6325477');
    }
    //@description : Apex method to test get Service Area Details based on Id
    @isTest
    static void getServiceAreaByIdTest()
    {
		servicearea__c statearea = new servicearea__c();        
        statearea.Name = 'Test State Area';
        insert statearea;
        servicearea__c cityarea = new servicearea__c();
        cityarea.Name = 'Test City Area';
        cityarea.State__c = statearea.Id;
        insert cityarea;
        
        RG_ServiceAreasController.RG_ServiceAreaDetails data =  RG_ServiceAreasController.getServiceAreaById(statearea.Id);   
        System.assertEquals(statearea.Id, data.serviceArea.Id);
    }
}