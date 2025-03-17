//******************************************************************************************
// Author:       Yogesh Sharma
// Company:      TCS
// Created Date: 02/05/2023
//******************************************************************************************
//@description : Apex Class to Test Service Area API Callout requests
@isTest
private class RG_SearchApiAddressControllerTest 
{
    //@description : Mock places suggestions generator
    private class RG_SearchAddressResponseGenerator implements HttpCalloutMock
    {
        public HTTPResponse respond(HTTPRequest req) 
        { 
            String searchUrl = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input='+'71101'+
                '&key='+Label.RG_GoogleMapsApiKey+'&types=postal_code&language=en&components=country:us';
            HttpResponse res = new HttpResponse();
            system.debug(req.getEndpoint());
            System.assertEquals(searchUrl, req.getEndpoint());
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"predictions" : [{"description" : "Shreveport, LA 71101, USA","matched_substrings" : [{"length" : 5,"offset" : 15}],"place_id" : "ChIJE7U-MDPNNoYRgI4w0Nz-f_c","reference" : "ChIJE7U-MDPNNoYRgI4w0Nz-f_c","structured_formatting" : {"main_text" : "71101","main_text_matched_substrings" : [{"length" : 5,"offset" : 0}],"secondary_text" : "Shreveport, LA, USA"},"terms" : [{"offset" : 0,"value" : "Shreveport"},{"offset" : 12,"value" : "LA"},{"offset" : 15,"value" : "71101"},{"offset" : 22,"value" : "USA"}],"types" : [ "postal_code", "geocode" ]}],"status" : "OK"}');
            res.setStatusCode(200);
            return res;
        }
    }
    //@description : Mock place details generator
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
    //@description : Apex method to test place suggestions and detail requests
    @isTest
    static void getAddressTest()
    {
        Test.setMock(HttpCalloutMock.class, new RG_SearchAddressResponseGenerator());
        RG_SearchApiAddressController.getAddress('71101');
        Test.setMock(HttpCalloutMock.class, new RG_PlaceSearchResponseGenerator());
        String latLong = RG_SearchApiAddressController.getPlaceDetails('ChIJeRpOeF67j4AR9ydy_PIzPuM');
        System.assertEquals(latLong, '37.4223995,-122.0847998','Test Passed');
    }
}