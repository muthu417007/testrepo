@RestResource(UrlMapping='/customer-idm/user/v1/profile')
global with sharing class PS_UserProfileWebServiceAPI {

    @HttpGet
    global static PS_WebServiceUserInfoExtWrapper getUser() {
        return new PS_WebServiceUserInfoHelper().getUserInfoWrapper(
                PS_WebServiceUserInfoHelper.getUserById(System.UserInfo.getUserId()),
                true,
                true
        );
    }

    @HttpPatch
    global static void updateUser() {
        PS_WebServiceUserInfoWrapper bodyWrapper = (PS_WebServiceUserInfoWrapper) JSON.deserialize(
                RestContext.request.requestBody.toString(),
                PS_WebServiceUserInfoWrapper.class
        );

        //set User Trigger experienceName
        List<String> pathPrefixSplit = Site.getPathPrefix().split('/');
        String siteName = pathPrefixSplit.size() >= 2 ? pathPrefixSplit.get(1) : null;
        PS_UserTriggerHandler.experienceName = siteName;
        PS_WebServiceUserInfoHelper.updateCurrentUser(bodyWrapper);

        RestContext.response.statusCode = 204;
    }
}