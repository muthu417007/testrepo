/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        31.05.2021
 * @description    A class containing the Contact Search callout to the GraphQL
 */
public with sharing class CX_ContactSearchGraphQL implements CX_ContactSearch {
    private static final CX_ContactSearchGraphQL INSTANCE = new CX_ContactSearchGraphQL();
    private final CX_Logger logger = new CX_Logger(CX_Logger.LogMode.MODE_PLATFORM_EVENT);
    final Boolean isSandbox = CX_Utils.isSandbox();

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        31.05.2021
     * @description    Returns the singleton instance
     * @return         CX_ContactSearchGraphQL - a CX_ContactSearchGraphQL singleton instance
     */
	public static CX_ContactSearchGraphQL getInstance() {
		return INSTANCE;
	}

    private CX_ContactSearchGraphQL() { }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        31.05.2021
     * @description    Calls the search passing an email and/or phone and returns a map of wrapper by type with the results
     * @param          String - the email value to be searched
     * @param          String - the phone value to be searched
     * @return         Map<String, CX_ContactSearchWrapper> - a map of wrapper by type containing the results
     */
    public Map<String, CX_ContactSearchWrapper> searchContact(String email, String phone) {
        Map<String, CX_ContactSearchWrapper> searchResultByType = new Map<String, CX_ContactSearchWrapper>();

        if(String.isNotBlank(email)) {
            searchResultByType.put('email', searchContactByEmail(email));
        }
        
        if(String.isNotBlank(phone)) {
            searchResultByType.put('phone', searchContactByPhone(phone));
        }

        return searchResultByType;
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        31.05.2021
     * @description    Calls the search passing an email and returns a wrapper with the result
     * @param          String - the email value to be searched
     * @return         CX_ContactSearchWrapper - the wrapper containing the search result
     */
    public CX_ContactSearchWrapper searchContactByEmail(String email) {
        String requestBody = getSearchBody(email, 'email');
        HttpResponse response = search(requestBody);
        return CX_ContactSearchWrapper.parse(response.getBody());
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        31.05.2021
     * @description    Calls the search passing a phone and returns a wrapper with the result
     * @param          String - the phone value to be searched
     * @return         CX_ContactSearchWrapper - the wrapper containing the search result
     */
    public CX_ContactSearchWrapper searchContactByPhone(String phone) {
        String requestBody = getSearchBody(phone, 'phone');
        HttpResponse response = search(requestBody);
        return CX_ContactSearchWrapper.parse(response.getBody());
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        01.06.2021
     * @description    Returns the body for the request
     * @param          String - the value to be added to the body
     * @param          String - the type of the search, email or phone
     * @return         String - the requests body
     */
    private String getSearchBody(String param, String type) {
        Map<String, String> bodyStartByType = new Map<String, String> { 'email' => '{"variables":{"EmailAddress":"' + param.trim() + '"},"query":"query ($EmailAddress: String!) { HouseHoldByEmail(emailAddress: $EmailAddress)', 
                                                                        'phone' => '{"variables":{"PhoneNumber":"' + param.trim() + '"},"query":"query ($PhoneNumber: String!) { HouseHoldByPhone(phoneNumber: $PhoneNumber)'};

        return bodyStartByType.get(type) + ' {Phone{PhoneNumber,IsPrimaryPhone,PhoneTypeName,PhoneUseTypeName},Details{COPSPersonNumber,GEConsumerNo,PersonDetailID,PersonID},ClientPersonCode,FirstName,Gender,IsDead,LastName,MiddleName,PersonID,Orders{AddressLine1,DataSourceCode,DataSourceName,FirstName,LastName,Locality,OrderCreatedBy,OrderDate,OrderDetails{AssetID,BrandName,CleansedModelNumber,DiscountPercent,InvoiceLine,InvoiceNumber,ManufacturerCost,NetInvoiceValue,OrderID,OriginalModelNumber,PartNumber,ProductCategoryName,ProductDescription,ProductLineName,TaxAmount},OrderDiscountAmount,OrderGrossAmount,OrderID,OrderNetAmount,OrderNumber,OrderPaymentMethod,OrderPlacedOn,OrderPromoCode,OrderShipmentAmount,OrderTaxAmount,OrderUniqueKey,PersonID,PostalCode,Region},EmailAddresses{EmailAddress,IsPrimaryEmail,IsPrimaryPerson, MYAMyAccountId}PersonID,plevel,Salutation,FirstName,LastName,Assets{AssetClassName,AssetID,AssetScrappedOn,AssetShippedOn,BrandName,CleansedModelNumber,IsProductReturned,LocationID,MACAddress,OriginalEngineeringModelNumber,OwnershipStartedOn,ProductCategoryName,ProductDescription,ProductLineName,SerialNumber},Locations{LocationID,AddressLine1,AddressLine2,Locality,Region,PostalCode,CountryCode}}} "}';
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        01.06.2021
     * @description    Search for a contact in an external endpoint, if an error is received, a log is created and an exception is thrown
     * @param          String - the request body
     * @return         HttpResponse - The callout response
     */
    private HttpResponse search(String body) {
        Http http = new Http();

        HttpRequest request = new HttpRequest();
        if(this.isSandbox) {
            request.setEndpoint('callout:Sandbox_Heroku_Search');   
        } else {
            request.setEndpoint('callout:Production_Heroku_Search');
        }

        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
		request.setHeader('Accept', 'application/json');  
        request.setTimeout(60000);

        if(Test.isRunningTest()) {
            request.setHeader('Authorization', '0123456789test');
        } else {
            //request.setHeader('Authorization', Utility.getGraphQLToken());
            request.setHeader('Authorization','Bearer '+Utility.getGraphQLToken('Heroku'));
        }
        
        request.setBody(body);
        
        HttpResponse response = http.send(request);

        if(response.getStatusCode() != 200 || response.getBody().contains('socket ended') || response.getBody().contains('errors')) {
            logger.logCalloutError(request, response, 'CX_ContactSearchGraphQL', 'search', 'retrieving contacts');
            throw new CalloutException('An error ocurred while retrieving contacts!');
        }

        return response;
    }
}