@isTest 
private class SearchEmailResponse_test {
    static testMethod void test1() {
        SearchEmailResponse testResponse = new SearchEmailResponse();
        SearchEmailResponse.statusMessage sm = new SearchEmailResponse.statusMessage();
        sm.Message = 'test';
        sm.responseCode = '200';
        SearchEmailResponse.locations loc = new SearchEmailResponse.locations();
        loc.AddressLine1 = 'test';
        loc.AddressLine2 = 'test2';
        loc.CountryCode = 'US';
        loc.Locality = 'FL';
        loc.LocationID = '1';
        loc.PostalCode = '32137';
        loc.Region = '1';
        SearchEmailResponse.HouseHoldByEmail hbe = new SearchEmailResponse.HouseHoldByEmail();
        hbe.FirstName = 'test';
        hbe.LastName = 'test2';
        hbe.PersonID = '1';
        hbe.plevel = '1';
        
     }

}