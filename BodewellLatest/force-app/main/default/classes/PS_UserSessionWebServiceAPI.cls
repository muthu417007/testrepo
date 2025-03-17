@RestResource(UrlMapping='/customer-idm/user/v1/session/*')
global with sharing class PS_UserSessionWebServiceAPI {

    private static final String POST_METHOD = 'POST';
    private static final String GET_METHOD = 'GET';
    private static final String CONTENT_TYPE = 'Content-type';
    private static final String APPLICATION_JSON = 'application/json';
    private static final String CUSTOMER_IDP_INT_USER_NAMED_CREDENTIALS = 'callout:Salesforce_As_Customer_IdP_Int_User';
    private static final String REST_APEX_PS_INTEGRATION_USER_PATH = '/services/data/v52.0/actions/custom/apex/PS_IntegrationUserSessionService';

    @HttpDelete
    global static void deleteSession() {
        RestRequest request = RestContext.request;
        List<String> paramsSplit = request.requestURI.split('/');
        String sessionId = paramsSplit.get(paramsSplit.size() - 1);

        if (String.isBlank(sessionId)) {
            throw new IllegalArgumentException('Missing required path parameter. [sessionId]');
        }

        List<User> users = PS_WebServiceUserInfoHelper.getUsersByCustomerSessionId(sessionId);
        if (users.isEmpty()) {
            throw new NoDataFoundException('No user found.');
        }
        User currentUser = users.get(0);

        makeCalloutsTMP(currentUser.Id);

        deleteAuthSessionsCallout(currentUser.Id);

        new PS_CustomerSessionIdService().generateSessionIdValue(
                new List<User>{
                        new User(Id = currentUser.Id)
                },
                true
        );

        RestContext.response.statusCode = 204;
    }

    private static void deleteAuthSessionsCallout(Id userId) {
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setEndpoint(CUSTOMER_IDP_INT_USER_NAMED_CREDENTIALS + REST_APEX_PS_INTEGRATION_USER_PATH);
        httpRequest.setHeader(CONTENT_TYPE, APPLICATION_JSON);
        httpRequest.setMethod(POST_METHOD);

        PS_IntegrationUserSessionService.InputParameters inputParameters = new PS_IntegrationUserSessionService.InputParameters();
        inputParameters.userId = userId;

        Map<String, List<PS_IntegrationUserSessionService.InputParameters>> body =
                new Map<String, List<PS_IntegrationUserSessionService.InputParameters>>{
                        'inputs' => new List<PS_IntegrationUserSessionService.InputParameters>{
                                inputParameters
                        }
                };
        System.debug(body);
        httpRequest.setBody(JSON.serialize(body));
        Http http = new Http();
        HttpResponse response = http.send(httpRequest);
        if (response.getStatusCode() != 200) {
            throw new CalloutException('Something when wrong, please contact administrator.');
        }
    }

    private static void makeCalloutsTMP(Id userId) {
        Map<String, BigCommerce_Connection__c> bigCommerceConnectionMap =
                new Map<String, BigCommerce_Connection__c>();
        Set<Id> connectedAppIds = new Set<Id>();
        for (BigCommerce_Connection__c connection :
                PS_BigCommerceConnectionConfigHelper.getAllBigCommerceConnectionConfig()
        ) {
            bigCommerceConnectionMap.put(connection.Connected_App_Name__c, connection);
            connectedAppIds.add(connection.Connected_App_Id__c);
        }

        List<String> loginHistoryApplications = new List<String>();
        for (String loginHistoryApplication : new PS_AuthSessionService(userId).getAuthSessionsLoginHistoryApplicationsForUser()) {
            if (bigCommerceConnectionMap.keySet().contains(loginHistoryApplication)) {
                loginHistoryApplications.add(loginHistoryApplication);
            }
        }

        Map<Id, String> connectedAppIdToExternalId = new PS_UserProvisioningService()
                .getConnectedAppIdToExternalIdMap(
                        userId,
                        connectedAppIds
                );

        for (String loginHistoryApplication : loginHistoryApplications) {
            BigCommerce_Connection__c bigCommerceConnection = bigCommerceConnectionMap
                    .get(loginHistoryApplication);

            PS_OAuthStateWrapper oAuthStateWrapper = new PS_OAuthStateWrapper(
                    bigCommerceConnection.Domain__c,
                    null
            );
            PS_BigCommerceAuthService bigCommerceAuthService = new PS_BigCommerceAuthService(
                    null,
                    EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(oAuthStateWrapper)))
            );

            PageReference loginWithToken = bigCommerceAuthService.redirectToLoginWithToken(
                    null,
                    connectedAppIdToExternalId.get(bigCommerceConnection.Connected_App_Id__c),
                    bigCommerceConnection
            );

            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setEndpoint(loginWithToken.getUrl());
            httpRequest.setMethod(GET_METHOD);

            Http http = new Http();
            HttpResponse response = http.send(httpRequest);
            System.debug(response);
        }
    }

    @TestVisible
    private class NoDataFoundException extends Exception {
    }
}