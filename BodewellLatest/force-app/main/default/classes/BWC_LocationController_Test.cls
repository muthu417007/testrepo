/**
@description : Test Class for BWC_LocationController
Author:       Akhil M R
Company:      TCS
Created Date: 25/10/2023
*/
@isTest
private class BWC_LocationController_Test {  
    
    /**
    * @description : Mock places suggestions generator
    */
    private class BWC_SearchAddressResponseGenerator implements HttpCalloutMock
    {
        private ID  aId;

        public BWC_SearchAddressResponseGenerator(ID aId) {
            this.aId = aId;
        }
        
        public HTTPResponse respond(HTTPRequest req) 
        { 
            String searchUrl = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=35.213989,-80.9886174&result_type=street_address&key='+Label.RG_GoogleMapsGeocodeApiKey;
            HttpResponse res = new HttpResponse();
            system.debug(req.getEndpoint());
            System.assertEquals(searchUrl, req.getEndpoint());
            res.setHeader('Content-Type', 'application/json');
            //res.setBody('{"results" : [{"place_id : "ChIJqXbwdPaXVogRT5kaHM_j9s4","description" : "Shreveport, LA 71101, USA","matched_substrings" : [{"length" : 5,"offset" : 15}]}],"status" : "OK"}');
            res.setBody('{\"plus_code\":{\"compound_code\":\"6276+HHRDixie-Berryhill,Belmont,NC,USA\",\"global_code\":\"867X6276+HHR\"},\"results\":[{\"address_components\":[{\"long_name\":\"10421\",\"short_name\":\"10421\",\"types\":[\"street_number\"]},{\"long_name\":\"WalkersFerryRoad\",\"short_name\":\"WalkersFerryRd\",\"types\":[\"route\"]},{\"long_name\":\"Dixie-Berryhill\",\"short_name\":\"Dixie-Berryhill\",\"types\":[\"neighborhood\",\"political\"]},{\"long_name\":\"Charlotte\",\"short_name\":\"Charlotte\",\"types\":[\"locality\",\"political\"]},{\"long_name\":\"MecklenburgCounty\",\"short_name\":\"MecklenburgCounty\",\"types\":[\"administrative_area_level_2\",\"political\"]},{\"long_name\":\"NorthCarolina\",\"short_name\":\"NC\",\"types\":[\"administrative_area_level_1\",\"political\"]},{\"long_name\":\"UnitedStates\",\"short_name\":\"US\",\"types\":[\"country\",\"political\"]},{\"long_name\":\"28278\",\"short_name\":\"28278\",\"types\":[\"postal_code\"]}],\"formatted_address\":\"10421WalkersFerryRd,Charlotte,NC28278,USA\",\"geometry\":{\"location\":{\"lat\":35.21384,\"lng\":-80.988871},\"location_type\":\"ROOFTOP\",\"viewport\":{\"northeast\":{\"lat\":35.21518898029149,\"lng\":-80.98752201970849},\"southwest\":{\"lat\":35.2124910197085,\"lng\":-80.99021998029151}}},\"place_id\":\"ChIJqXbwdPaXVogRT5kaHM_j9s4\",\"plus_code\":{\"compound_code\":\"6276+GFCharlotte,NC,USA\",\"global_code\":\"867X6276+GF\"},\"types\":[\"street_address\"]}],\"status\":\"OK\"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    /**
    * @description : Mock place details generator
    */
    private class BWC_PlaceSearchResponseGenerator implements HttpCalloutMock
    {
        private ID  aId;

        public BWC_PlaceSearchResponseGenerator(ID aId) {
            this.aId = aId;
        }
        
        public HTTPResponse respond(HTTPRequest req) 
        { 
            String searchUrl = 'https://maps.googleapis.com/maps/api/geocode/json?place_id=ChIJqXbwdPaXVogRT5kaHM_j9s4&key='+Label.RG_GoogleMapsGeocodeApiKey; 
            HttpResponse res = new HttpResponse();
            system.debug(req.getEndpoint());
            System.assertEquals(searchUrl, req.getEndpoint());
            res.setHeader('Content-Type', 'application/json');
            //res.setBody('{\"results\":[{\"address_components\":[{\"long_name\":\"1600\",\"short_name\":\"1600\",\"types\":[\"street_number\"]},{\"long_name\":\"Amphitheatre Parkway\",\"short_name\":\"Amphitheatre Pkwy\",\"types\":[\"route\"]},{\"long_name\":\"Mountain View\",\"short_name\":\"Mountain View\",\"types\":[\"locality\",\"political\"]},{\"long_name\":\"Santa Clara County\",\"short_name\":\"Santa Clara County\",\"types\":[\"administrative_area_level_2\",\"political\"]},{\"long_name\":\"California\",\"short_name\":\"CA\",\"types\":[\"administrative_area_level_1\",\"political\"]},{\"long_name\":\"United States\",\"short_name\":\"US\",\"types\":[\"country\",\"political\"]},{\"long_name\":\"94043\",\"short_name\":\"94043\",\"types\":[\"postal_code\"]}],\"formatted_address\":\"1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA\",\"geometry\":{\"location\":{\"lat\":37.4223995,\"lng\":-122.0847998},\"location_type\":\"ROOFTOP\",\"viewport\":{\"northeast\":{\"lat\":37.4238877802915,\"lng\":-122.0834170697085},\"southwest\":{\"lat\":37.4211898197085,\"lng\":-122.0861150302915}}},\"place_id\":\"ChIJeRpOeF67j4AR9ydy_PIzPuM\",\"plus_code\":{\"compound_code\":\"CWC8+X3 Mountain View, CA\",\"global_code\":\"849VCWC8+X3\"},\"types\":[\"street_address\"]}],\"status\":\"OK\"}');
            res.setBody('{\"results\":[{\"address_components\":[{\"long_name\":\"10421\",\"short_name\":\"10421\",\"types\":[\"street_number\"]},{\"long_name\":\"WalkersFerryRoad\",\"short_name\":\"WalkersFerryRd\",\"types\":[\"route\"]},{\"long_name\":\"Dixie-Berryhill\",\"short_name\":\"Dixie-Berryhill\",\"types\":[\"neighborhood\",\"political\"]},{\"long_name\":\"Charlotte\",\"short_name\":\"Charlotte\",\"types\":[\"locality\",\"political\"]},{\"long_name\":\"MecklenburgCounty\",\"short_name\":\"MecklenburgCounty\",\"types\":[\"administrative_area_level_2\",\"political\"]},{\"long_name\":\"NorthCarolina\",\"short_name\":\"NC\",\"types\":[\"administrative_area_level_1\",\"political\"]},{\"long_name\":\"UnitedStates\",\"short_name\":\"US\",\"types\":[\"country\",\"political\"]},{\"long_name\":\"28278\",\"short_name\":\"28278\",\"types\":[\"postal_code\"]}],\"formatted_address\":\"10421WalkersFerryRd,Charlotte,NC28278,USA\",\"geometry\":{\"location\":{\"lat\":35.21384,\"lng\":-80.988871},\"location_type\":\"ROOFTOP\",\"viewport\":{\"northeast\":{\"lat\":35.2154970802915,\"lng\":-80.98783181970849},\"southwest\":{\"lat\":35.2127991197085,\"lng\":-80.99052978029151}}},\"place_id\":\"ChIJqXbwdPaXVogRT5kaHM_j9s4\",\"plus_code\":{\"compound_code\":\"6276+GFCharlotte,NC\",\"global_code\":\"867X6276+GF\"},\"types\":[\"street_address\"]}],\"status\":\"OK\"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    /**
    * @description : Apex method to test place suggestions and detail requests
    */
    @isTest
    static void getPlaceIdTest()
    {
        //Test.setMock(HttpCalloutMock.class, new BWC_SearchAddressResponseGenerator());
        Account testAcct = new Account(Name = 'Test Acct ',Party_Name__c='Test Acct ',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail').getRecordTypeId(),ShippingLatitude=35.2154970802915,ShippingLongitude = -80.98783181970849,Bodewell_Preferred_Partner__c=true);
        insert testAcct; 
        Account testAcct2 = new Account(Name = 'Test Acct2 ',Party_Name__c='Test Acct2 ',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail').getRecordTypeId(),ShippingLatitude=35.2154970802915,ShippingLongitude = -80.98783181970849,Bodewell_Preferred_Partner__c=true);
        insert testAcct2;
        Store_Hours__c testStHour1 = new Store_Hours__c(Name='Test ST1', Account__c=testAcct.Id, DayOfWeek__c='Monday',Start_Time__c= Time.newInstance(9, 0, 0, 0) , End_Time__c=Time.newInstance(18, 0, 0, 0));
        insert testStHour1; 
        Store_Hours__c testStHour2 = new Store_Hours__c(Name='Test ST2', Account__c=testAcct2.Id, DayOfWeek__c='Monday',Start_Time__c= Time.newInstance(9, 0, 0, 0) , End_Time__c=Time.newInstance(18, 0, 0, 0));
        insert testStHour2;
        Dealer_Promotion__c testdp1 = new Dealer_Promotion__c(Name ='Test1', Account__c=testAcct.Id, IsActive__c= true, Promotion__c='Test', Promotion_Terms__c='Test', PromotionExpirationDate__c=date.newinstance(2024, 11, 11), PromotionStartDate__c=date.newinstance(2024, 11, 11));
        insert testdp1;        
        Dealer_Promotion__c testdp2 = new Dealer_Promotion__c(Name ='Test2', Account__c=testAcct2.Id, IsActive__c= true, Promotion__c='Test', Promotion_Terms__c='Test', PromotionExpirationDate__c=date.newinstance(2024, 11, 11), PromotionStartDate__c=date.newinstance(2024, 11, 11));
        insert testdp2;          
        Service_Offered__c testso1 = new Service_Offered__c(Dealer_Account__c=testAcct.Id, Service__c='Delivery & Installation');
        insert testso1;
        Service_Offered__c testso2 = new Service_Offered__c(Dealer_Account__c=testAcct.Id, Service__c='Experience Center');
        insert testso2;   
        Test.startTest();
            Test.setMock(HttpCalloutMock.class,new BWC_SearchAddressResponseGenerator(testAcct.id));
            BWC_LocationController.BWC_LocationControllerResponse res = BWC_LocationController.getPlaceId('35.213989,-80.9886174');
        	System.AssertEquals(true, res.success, 'Test Passed');
       	Test.stopTest();
    }

	/**
    * @description : Apex method to test place suggestions and detail requests without mock
    */
    @isTest
    static void getPlaceIdTestWithoutMock()
    {
        //Test.setMock(HttpCalloutMock.class, new BWC_SearchAddressResponseGenerator());
        Account testAcct = new Account(Name = 'Test Acct ',Party_Name__c='Test Acct ',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail').getRecordTypeId(),ShippingLatitude=35.2154970802915,ShippingLongitude = -80.98783181970849,Bodewell_Preferred_Partner__c=true);
        insert testAcct; 
        Store_Hours__c testStHour = new Store_Hours__c(Name='Test ST', Account__c=testAcct.Id, DayOfWeek__c='Monday',Start_Time__c= Time.newInstance(9, 0, 0, 0) , End_Time__c=Time.newInstance(18, 0, 0, 0));
        insert testStHour; 
        Dealer_Promotion__c testdp = new Dealer_Promotion__c(Name ='Test', Account__c=testAcct.Id, IsActive__c= true, Promotion__c='Test', Promotion_Terms__c='Test', PromotionExpirationDate__c=date.newinstance(2024, 11, 11), PromotionStartDate__c=date.newinstance(2024, 11, 11));
        insert testdp; 
        Service_Offered__c testso = new Service_Offered__c(Dealer_Account__c=testAcct.Id, Service__c='Delivery & Installation');
        insert testso;   
        Test.startTest();
            BWC_LocationController.BWC_LocationControllerResponse res = BWC_LocationController.getPlaceId('35.213989,-80.9886174');
        	System.AssertEquals(false, res.success, 'Test Passed');
       	Test.stopTest();
    }

    
    /**
    * @description : Apex method to test place suggestions and detail requests
    */
    @isTest
    static void getPlaceDetailsTest()
    {
        
        //insert acc;
        
        //Test.setMock(HttpCalloutMock.class, new BWC_PlaceSearchResponseGenerator());
        Account testAcct = new Account(Name = 'Test Acct ',Party_Name__c='Test Acct ',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail').getRecordTypeId(),ShippingLatitude=35.2154970802915,ShippingLongitude = -80.98783181970849,Bodewell_Preferred_Partner__c=true);
        insert testAcct;
        Store_Hours__c testStHour1 = new Store_Hours__c(Name='Test ST1', Account__c=testAcct.Id, DayOfWeek__c='Monday',Start_Time__c= Time.newInstance(9, 0, 0, 0) , End_Time__c=Time.newInstance(18, 0, 0, 0));
        insert testStHour1; 
        Store_Hours__c testStHour2 = new Store_Hours__c(Name='Test ST2', Account__c=testAcct.Id, DayOfWeek__c='Monday',Start_Time__c= Time.newInstance(9, 0, 0, 0) , End_Time__c=Time.newInstance(18, 0, 0, 0));
        insert testStHour2;
        Dealer_Promotion__c testdp1 = new Dealer_Promotion__c(Name ='Test1', Account__c=testAcct.Id, IsActive__c= true, Promotion__c='Test', Promotion_Terms__c='Test', PromotionExpirationDate__c=date.newinstance(2024, 11, 11), PromotionStartDate__c=date.newinstance(2024, 11, 11));
        insert testdp1;        
        Dealer_Promotion__c testdp2 = new Dealer_Promotion__c(Name ='Test2', Account__c=testAcct.Id, IsActive__c= true, Promotion__c='Test', Promotion_Terms__c='Test', PromotionExpirationDate__c=date.newinstance(2024, 11, 11), PromotionStartDate__c=date.newinstance(2024, 11, 11));
        insert testdp2;          
        Service_Offered__c testso1 = new Service_Offered__c(Dealer_Account__c=testAcct.Id, Service__c='Delivery & Installation');
        insert testso1;
        Service_Offered__c testso2 = new Service_Offered__c(Dealer_Account__c=testAcct.Id, Service__c='Experience Center');
        insert testso2;
        Account testAcct1 = new Account(Name = 'Test Acct ',Party_Name__c='Test Acct ',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail').getRecordTypeId(),ShippingLatitude=35.2154970802915,ShippingLongitude = -80.98783181970849,Bodewell_Preferred_Partner__c=true);
        insert testAcct1;
        Store_Hours__c testStHour11 = new Store_Hours__c(Name='Test ST1', Account__c=testAcct1.Id, DayOfWeek__c='Monday',Start_Time__c= Time.newInstance(9, 0, 0, 0) , End_Time__c=Time.newInstance(18, 0, 0, 0));
        insert testStHour11; 
        Store_Hours__c testStHour21 = new Store_Hours__c(Name='Test ST2', Account__c=testAcct1.Id, DayOfWeek__c='Monday',Start_Time__c= Time.newInstance(9, 0, 0, 0) , End_Time__c=Time.newInstance(18, 0, 0, 0));
        insert testStHour21;
        Dealer_Promotion__c testdp11 = new Dealer_Promotion__c(Name ='Test1', Account__c=testAcct1.Id, IsActive__c= true, Promotion__c='Test', Promotion_Terms__c='Test', PromotionExpirationDate__c=date.newinstance(2024, 11, 11), PromotionStartDate__c=date.newinstance(2024, 11, 11));
        insert testdp11;        
        Dealer_Promotion__c testdp21 = new Dealer_Promotion__c(Name ='Test2', Account__c=testAcct1.Id, IsActive__c= true, Promotion__c='Test', Promotion_Terms__c='Test', PromotionExpirationDate__c=date.newinstance(2024, 11, 11), PromotionStartDate__c=date.newinstance(2024, 11, 11));
        insert testdp21;          
        Service_Offered__c testso11 = new Service_Offered__c(Dealer_Account__c=testAcct1.Id, Service__c='Delivery & Installation');
        insert testso11;
        Service_Offered__c testso21 = new Service_Offered__c(Dealer_Account__c=testAcct1.Id, Service__c='Experience Center');
        insert testso21;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class,new BWC_PlaceSearchResponseGenerator(testAcct.id));
            BWC_LocationController.BWC_LocationControllerResponse res = BWC_LocationController.getPlaceDetails('ChIJqXbwdPaXVogRT5kaHM_j9s4');
            System.assertEquals(true, res.success,'Test Passed');
        Test.stopTest();
    }
    
    /**
    * @description : Apex method to test place suggestions and detail requests without mock
    */
    @isTest
    static void getPlaceDetailsTestWithoutMock()
    {
        
        //insert acc;
        
        //Test.setMock(HttpCalloutMock.class, new BWC_PlaceSearchResponseGenerator());
        Account testAcct = new Account(Name = 'Test Acct ',Party_Name__c='Test Acct ',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail').getRecordTypeId(),ShippingLatitude=35.2154970802915,ShippingLongitude = -80.98783181970849,Bodewell_Preferred_Partner__c=true);
        insert testAcct; 
        Store_Hours__c testStHour = new Store_Hours__c(Name='Test ST', Account__c=testAcct.Id, DayOfWeek__c='Monday',Start_Time__c= Time.newInstance(9, 0, 0, 0) , End_Time__c=Time.newInstance(18, 0, 0, 0));
        insert testStHour; 
        Dealer_Promotion__c testdp = new Dealer_Promotion__c(Name ='Test', Account__c=testAcct.Id, IsActive__c= true, Promotion__c='Test', Promotion_Terms__c='Test', PromotionExpirationDate__c=date.newinstance(2024, 11, 11), PromotionStartDate__c=date.newinstance(2024, 11, 11));
        insert testdp; 
        Service_Offered__c testso = new Service_Offered__c(Dealer_Account__c=testAcct.Id, Service__c='Delivery & Installation');
        insert testso;  
        Test.startTest();
        	BWC_LocationController.BWC_LocationControllerResponse res = BWC_LocationController.getPlaceDetails('ChIJqXbwdPaXVogRT5kaHM_j9s4');
            System.assertEquals(false, res.success,'Test Passed');
        Test.stopTest();
    }
    
    /**
    * @description : Apex method to test place suggestions and detail requests with lat long values
	*/
    @isTest
    static void getPlaceDetailsByLatLongTest()
    {
        Account testAcct = new Account(Name = 'Test Acct ',Party_Name__c='Test Acct ',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail').getRecordTypeId(),ShippingLatitude=35.2154970802915,ShippingLongitude = -80.98783181970849,Bodewell_Preferred_Partner__c=true);
        insert testAcct; 
        Store_Hours__c testStHour = new Store_Hours__c(Name='Test ST', Account__c=testAcct.Id, DayOfWeek__c='Monday',Start_Time__c= Time.newInstance(9, 0, 0, 0) , End_Time__c=Time.newInstance(18, 0, 0, 0));
        insert testStHour; 
        Dealer_Promotion__c testdp = new Dealer_Promotion__c(Name ='Test', Account__c=testAcct.Id, IsActive__c= true, Promotion__c='Test', Promotion_Terms__c='Test', PromotionExpirationDate__c=date.newinstance(2024, 11, 11), PromotionStartDate__c=date.newinstance(2024, 11, 11));
        insert testdp; 
        Service_Offered__c testso = new Service_Offered__c(Dealer_Account__c=testAcct.Id, Service__c='Delivery & Installation');
        insert testso;  
        Test.startTest();
            BWC_LocationController.BWC_LocationControllerResponse res = BWC_LocationController.getPlaceDetailsByLatLong('35.2154970802915','-80.98783181970849');
            System.assertEquals(true, res.success,'Test Passed');
        Test.stopTest();
    }
    
    /**
    * @description : Apex method to test place suggestions and detail requests with lat long values using standard user
	*/    
    @isTest
    static void getPlaceDetailsByLatLongUserTest()
    {
        Account testAcct = new Account(Name = 'Test Acct ',Party_Name__c='Test Acct ',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail').getRecordTypeId(),ShippingLatitude=35.2154970802915,ShippingLongitude = -80.98783181970849,Bodewell_Preferred_Partner__c=true);
        insert testAcct; 
        Store_Hours__c testStHour = new Store_Hours__c(Name='Test ST', Account__c=testAcct.Id, DayOfWeek__c='Monday',Start_Time__c= Time.newInstance(9, 0, 0, 0) , End_Time__c=Time.newInstance(18, 0, 0, 0));
        insert testStHour; 
        Dealer_Promotion__c testdp = new Dealer_Promotion__c(Name ='Test', Account__c=testAcct.Id, IsActive__c= true, Promotion__c='Test', Promotion_Terms__c='Test', PromotionExpirationDate__c=date.newinstance(2024, 11, 11), PromotionStartDate__c=date.newinstance(2024, 11, 11));
        insert testdp; 
        Service_Offered__c testso = new Service_Offered__c(Dealer_Account__c=testAcct.Id, Service__c='Delivery & Installation');
        insert testso; 
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName=uniqueUserName);
        
        Test.startTest();
        	System.runAs(u) {
           		BWC_LocationController.BWC_LocationControllerResponse res = BWC_LocationController.getPlaceDetailsByLatLong('35.2154970802915','-80.98783181970849');
 				System.assertEquals(false, res.success, 'Test Passed');
            }
      	Test.stopTest();
    }
}