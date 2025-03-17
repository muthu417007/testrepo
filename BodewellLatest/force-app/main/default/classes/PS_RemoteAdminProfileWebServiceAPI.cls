@RestResource(UrlMapping='/customer-idm/remote-administration/v1/profile')
global with sharing class PS_RemoteAdminProfileWebServiceAPI {

    @TestVisible
    private static final String GLOBAL_ID_PARAM = 'globalId';
    @TestVisible
    private static final String EMAIL_PARAM = 'email';

    @HttpGet
    global static PS_WebServiceUserInfoExtAdminWrapper getUser() {
        RestRequest request = RestContext.request;

        if (request.params.containsKey(GLOBAL_ID_PARAM) && request.params.containsKey(EMAIL_PARAM)) {
            throw new IllegalArgumentException('Only one parameter accepted. Both "id" and "email" can not be passed.');
        }

        if (!request.params.containsKey(GLOBAL_ID_PARAM) && !request.params.containsKey(EMAIL_PARAM)) {
            throw new IllegalArgumentException('Missing required parameter.');
        }

        List<User> users = PS_WebServiceUserInfoHelper.getUsersByGlobalIdOrEmail(request.params);
        if (users.isEmpty()) {
            throw new NoDataFoundException('No user found.');
        }

        User currentUser = users.get(0);

        PS_WebServiceUserInfoHelper userInfoHelper = new PS_WebServiceUserInfoHelper();
        PS_WebServiceUserInfoExtWrapper userInfoExtWrapper =
                userInfoHelper.getUserInfoWrapper(
                        currentUser,
                        true,
                        true
                );

        return userInfoHelper.includeUsername(currentUser, userInfoExtWrapper);
    }

    @HttpPatch
    global static void updateUser() {
        RestRequest request = RestContext.request;
        PS_WebServiceUserInfoWrapper bodyWrapper = (PS_WebServiceUserInfoWrapper) JSON.deserialize(
                request.requestBody.toString(),
                PS_WebServiceUserInfoWrapper.class
        );

        if (request.params.containsKey(GLOBAL_ID_PARAM) && request.params.containsKey(EMAIL_PARAM)) {
            throw new IllegalArgumentException('Only one parameter accepted. Both "globalId" and "email" can not be passed.');
        }

        if (!request.params.containsKey(GLOBAL_ID_PARAM) && !request.params.containsKey(EMAIL_PARAM)) {
            throw new IllegalArgumentException('Missing required parameter.');
        }

        List<User> users = PS_WebServiceUserInfoHelper.getUsersByGlobalIdOrEmail(request.params);
        if (users.isEmpty()) {
            throw new NoDataFoundException('No user found.');
        }

        User currentUser = users.get(0);

        if (bodyWrapper.isFrozen != null) {
            PS_WebServiceUserInfoHelper.freezeUser(currentUser.Id, bodyWrapper.isFrozen);
        }

        //update Account data
        if (bodyWrapper.address != null) {
            PS_WebServiceUserInfoHelper.updateUserAccount(currentUser, bodyWrapper);
        }

        Map<String, Object> requestBodyMap = (Map<String, Object>) JSON.deserializeUntyped(
                request.requestBody.toString()
        );

        //update rest of user data
        //set User Trigger experienceName
        List<String> pathPrefixSplit = Site.getPathPrefix().split('/');
        String siteName = pathPrefixSplit.size() >= 2 ? pathPrefixSplit.get(1) : null;
        PS_UserTriggerHandler.experienceName = siteName;
        updateUserData(
                currentUser.Id,
                bodyWrapper,
                requestBodyMap.containsKey('geolocation') && requestBodyMap.get('geolocation') == null
        );

        PS_WebServiceUserInfoHelper.insertMissingAuthorizationFormConsents(currentUser, bodyWrapper);

        RestContext.response.statusCode = 204;
    }

    @HttpDelete
    global static void deactivateUser() {
        RestRequest request = RestContext.request;

        if (request.params.containsKey(GLOBAL_ID_PARAM) && request.params.containsKey(EMAIL_PARAM)) {
            throw new IllegalArgumentException('Only one parameter accepted. Both "id" and "email" can not be passed.');
        }

        if (!request.params.containsKey(GLOBAL_ID_PARAM) && !request.params.containsKey(EMAIL_PARAM)) {
            throw new IllegalArgumentException('Missing required parameter.');
        }

        List<User> users = PS_WebServiceUserInfoHelper.getUsersByGlobalIdOrEmail(request.params);
        System.debug(users);
        if (users.isEmpty()) {
            throw new NoDataFoundException('No user found.');
        }

        User currentUser = users.get(0);
        //deactivate user
        currentUser.IsPortalEnabled = false;
        currentUser.IsActive = false;
        update currentUser;

        //scramble user data
        myFutureMethod(currentUser.ContactId);
        UserManagement.obfuscateUser(currentUser.Id);
        RestContext.response.statusCode = 204;
    }
    //added for - JIRA CCOE-605
	@future 
    Private static void myFutureMethod(ID contactid){
        try{
            List <Contact> contacts = [Select ID, Global_Customer_Id__c FROM Contact WHERE Id =:contactid];
            contacts[0].Global_Customer_Id__c = '';
           	Update(contacts);
        }
        catch(Exception e){}
           // System.debug(e.getMessage());
        }
    private static void updateUserData(
            Id userId,
            PS_WebServiceUserInfoWrapper wrapper,
            Boolean clearGeolocationData
    ) {
        User currentUser = new User(
                Id = userId
        );
        if (String.isNotBlank(wrapper.email)) {
            currentUser.Email = wrapper.email;
        }
        if (String.isNotBlank(wrapper.firstname)) {
            currentUser.FirstName = wrapper.firstname;
        }
        if (String.isNotBlank(wrapper.lastname)) {
            currentUser.LastName = wrapper.lastname;
        }
        if (String.isNotBlank(wrapper.mobile)) {
            currentUser.MobilePhone = wrapper.mobile;
        }
        if (String.isNotBlank(wrapper.language)) {
            currentUser.LanguageLocaleKey = wrapper.language;
        }
        if (String.isNotBlank(wrapper.region)) {
            currentUser.ServerRegion__c = wrapper.region;
        }

        if (clearGeolocationData) {
            currentUser.Latitude = null;
            currentUser.Longitude = null;
        } else {
            if (String.isNotBlank(String.valueOf(wrapper.geolocation?.latitude))) {
                currentUser.Latitude = wrapper.geolocation.latitude;
            }
            if (String.isNotBlank(String.valueOf(wrapper.geolocation?.longitude))) {
                currentUser.Longitude = wrapper.geolocation.longitude;
            }
        }

        update currentUser;
    }

    @TestVisible
    private class NoDataFoundException extends Exception {
    }
}