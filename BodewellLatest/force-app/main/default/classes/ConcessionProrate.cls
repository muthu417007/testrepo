public class ConcessionProrate {
    @InvocableMethod(label='Calculate Prorate Tax ' description='Calculate Prorate Tax')
    public static List<double> calculateTax(List<Prorate_Calculator__c> proRateCalc) {
        //make callout  
        List<double> returnList = new List<Double>();
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        if(utility.isSandbox){
            request.setEndpoint('callout:Sandbox_Calculate_Tax');   
        } else {
            request.setEndpoint('callout:Production_Calculate_Tax');
        }
        
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('geasfdccode','ApplServiceCloudGEA');
        request.setHeader('appname','SiebelXML');
        String postBody = '{"request": "taxonline","payload": {"ProductCode": "90028","ZipCode": "' + proRateCalc[0].Billing_Postal_Code__c + '","CityName": "' + proRateCalc[0].Billing_City__c + '","State": "' + proRateCalc[0].Billing_State__c + '","Amount": "' + proRateCalc[0].Prorate_Price__c.setScale(2) +'"}}';
        
        // Set the body as a JSON object
        request.setBody(postBody);
        request.setTimeout(15000);
        HttpResponse response;
        if(!test.isRunningTest()){
            response = http.send(request);
            system.debug('request ' + postBody);
            system.debug('response ' + response);
            system.debug('response body ' + response.getBody());
        } else {
            response = new HttpResponse();
            response.setStatusCode(200);
            String testBody = '{"TaxAmount": "30.0"}';
            response.setBody(testBody);
        }
        
        // Parse the JSON response
        if (response.getStatusCode() == 200) {
            System.debug(response.getBody());
            calculateTaxResponse  resp = calculateTaxResponse.parse(response.getBody());
            system.debug('calculateTaxResponse ' + resp);
            returnList.add(decimal.valueOf(resp.TaxAmount));
            return returnList;
        } else {
            system.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus()));
            return null; 
        }
    
    }
}