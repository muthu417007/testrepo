public with sharing class PS_BigCommerceUserManagementService {

    private BigCommerce_Connection__c config;
    private String endpoint;
    private CustomerAPIResponseWrapper responseData;
    private String externalUserId;
    private String emailIn;

    private static final String GET_METHOD = 'GET';
    private static final String POST_METHOD = 'POST';
    private static final String CONTENT_TYPE = 'Content-Type';
    private static final String APPLICATION_JSON = 'application/json';
    private static final String X_AUTH_TOKEN = 'X-Auth-Token';
    private static final String STATUS_ACTIVE = 'Active';
    private static final String LINK_STATE_LINKED = 'linked';

    
    public PS_BigCommerceUserManagementService(
            BigCommerce_Connection__c config,
            String emailIn
    ) {
        this.config = config;
        this.endpoint = this.config.API_Base_Url__c;
        this.endpoint += String.format(
                '/stores/{0}/v3/customers',
                new List<Object>{
                        this.config.Store_Hash__c
                }
        );
        this.emailIn = emailIn;
    }

    public String getUserIdFromBigCommerceAPI() {
        externalUserId = callCustomersGET();
        if (externalUserId == null) {
            externalUserId = callCustomersPOST();
        }

        return externalUserId;
    }

    private String callCustomersGET() {
        String endPoint = this.endpoint;
        endPoint += '?email:in=' + EncodingUtil.urlEncode(emailIn,'UTF-8');

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint);
        request.setMethod(GET_METHOD);
        request.setHeader(X_AUTH_TOKEN, this.config.Auth_Token__c);

        Http http = new Http();
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            responseData = (CustomerAPIResponseWrapper) JSON.deserialize(
                    response.getBody(),
                    CustomerAPIResponseWrapper.class
            );
            System.debug(responseData);
            return getUserIdFromResponse(responseData);
        }
        return null;
    }

    private String callCustomersPOST() {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(this.endpoint);
        request.setMethod(POST_METHOD);
        request.setHeader(CONTENT_TYPE, APPLICATION_JSON);
        request.setHeader(X_AUTH_TOKEN, this.config.Auth_Token__c);

        User currentUser = [
                SELECT Id,FirstName,LastName,City,State,PostalCode,Country,Username,Email,Profile.Name, contact.account.Dealer_Status__c
                FROM User
                WHERE Id = :System.UserInfo.getUserId()
                LIMIT 1
        ];
        CustomerPostAPIRequestWrapper requestWrapper = createRequestWrapper(currentUser);
        System.debug(JSON.serialize(
                new List<CustomerPostAPIRequestWrapper>{
                        requestWrapper
                }
        ));
        request.setBody(JSON.serialize(
                new List<CustomerPostAPIRequestWrapper>{
                        requestWrapper
                }
        ));

        Http http = new Http();
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 422) {
            throw new IllegalArgumentException('Big Commerce User Creation failed : ' + response.getBody());
        }

        if (response.getStatusCode() == 200) {
            responseData = (CustomerAPIResponseWrapper) JSON.deserialize(
                    response.getBody(),
                    CustomerAPIResponseWrapper.class
            );
            return getUserIdFromResponse(responseData);
        }
        return null;
    }

    private static String getUserIdFromResponse(CustomerAPIResponseWrapper responseData) {
        if (responseData != null) {
            if (responseData != null && !responseData.data.isEmpty()) {
                return responseData.data.get(0).id;
            }
        }
        return null;
    }

    public void insertUserProvAccountRecord(String connectedAppId) {
        if (String.isNotBlank(externalUserId)) {
            UserProvAccount userProvAccount = new UserProvAccount();
            userProvAccount.ExternalUserId = externalUserId;
            userProvAccount.Status = STATUS_ACTIVE;
            userProvAccount.LinkState = LINK_STATE_LINKED;
            userProvAccount.ConnectedAppId = connectedAppId;
            userProvAccount.SalesforceUserId = System.UserInfo.getUserId();

            if (responseData != null && !responseData.data.isEmpty()) {
                Data responseDataFirst = responseData.data.get(0);
                userProvAccount.ExternalEmail = responseDataFirst.email;
                userProvAccount.ExternalUsername = responseDataFirst.email;
                userProvAccount.ExternalFirstName = responseDataFirst.first_name;
                userProvAccount.ExternalLastName = responseDataFirst.last_name;
            }

            insert userProvAccount;
        }
    }

    private static CustomerPostAPIRequestWrapper createRequestWrapper(User currentUser) {
        CustomerPostAPIRequestWrapper requestWrapper = new CustomerPostAPIRequestWrapper();
        requestWrapper.first_name = currentUser.FirstName;
        requestWrapper.last_name = currentUser.LastName;
        requestWrapper.email = currentUser.Email;
        Customer_IdP_Configuration__mdt siteConfig=PS_GEAIdPCustomerConfigHelper.getSiteConfiguration();
        System.debug('siteConfig.QualifiedApiName: ====> '+siteConfig.QualifiedApiName);
        if(siteConfig.QualifiedApiName=='AirAndWater')
			requestWrapper.customer_group_id=Integer.valueOf(getCustomerGroupId(currentUser));
        return requestWrapper;
    }
    
    private static Integer getCustomerGroupId(User currentUser){
       return PS_BigCommerceUpdateUserInvocable.getCustomerGroupId(currentUser.Profile.Name, currentUser.Contact.Account.Dealer_Status__c);    
    }
    
    public class CustomerAPIResponseWrapper {
        public List<Data> data;
    }

    public class Data {
        public String id;
        public String first_name;
        public String last_name;
        public String email;
        public Integer customer_group_id;
    }

    public class CustomerPostAPIRequestWrapper {
        public String email;
        public String first_name;
        public String last_name;
        public Integer customer_group_id;
    }
}