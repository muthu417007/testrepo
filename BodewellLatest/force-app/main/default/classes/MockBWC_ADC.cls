public class MockBWC_ADC implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {
        // Create a mock HTTP response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        // BWC_ADC.ADC_WrapperResponse mockResponse = new BWC_ADC.ADC_WrapperResponse();
        // mockResponse.customerAccountNumber = 12345;
        // mockResponse.adcOrg = 'MockADCOrg';
        // mockResponse.returnOrg = 'MockReturnOrg';
        // mockResponse.sdsOrg = 'MockSDSOrg';
        // mockResponse.sdsZone = 'MockSDSZone';
        // mockResponse.hdOrg = 'MockHDOrg';
        // mockResponse.hdZone = 'MockHDZone';
        // mockResponse.mtOrg = 'MockMTOrg';
        // mockResponse.mtZone = 'MockMTZone';
        // mockResponse.willCallAdcOrgCode = 'MockWillCallADCOrgCode';
        // mockResponse.willCallSdsOrgCode = 'MockWillCallSDSOrgCode';
        // mockResponse.guaranteedTruck = 'MockGuaranteedTruck';
        // mockResponse.guaranteedTruckZone = 'MockGuaranteedTruckZone';
        
        // // Serialize the mock response as JSON
        // String mockResponseBody = JSON.serialize(mockResponse);
        
        // Set the response body and status code
      //  res.setBody(mockResponseBody);
       res.setBody('[{"customerAccountNumber": 12345,"adcOrg": "Org1","returnOrg": "Org2","sdsOrg": "Org3","sdsZone": "Zone1","hdOrg": "Org4","hdZone": "Zone2","mtOrg": "Org5","mtZone": "Zone3","willCallAdcOrgCode": "WillCallOrgCode","willCallSdsOrgCode": "WillCallSDSOrgCode","guaranteedTruck": "Truck1","guaranteedTruckZone": "TruckZone1"},{"customerAccountNumber": 67890,"adcOrg": "OrgA","returnOrg": "OrgB","sdsOrg": "OrgC","sdsZone": "ZoneX","hdOrg": "OrgD","hdZone": "ZoneY","mtOrg": "OrgE","mtZone": "ZoneZ","willCallAdcOrgCode": "WillCallOrgCodeA","willCallSdsOrgCode": "WillCallSDSOrgCodeB","guaranteedTruck": "Truck2","guaranteedTruckZone": "TruckZone2"}]'); 
        res.setStatusCode(0);

        return res;
    }
}