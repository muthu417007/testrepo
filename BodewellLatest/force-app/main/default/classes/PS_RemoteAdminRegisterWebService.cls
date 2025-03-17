@RestResource(UrlMapping='/customer-idm/remote-administration/v1/register')
global with sharing class PS_RemoteAdminRegisterWebService {

    @HttpPost
    global static PS_WebServiceUserInfoExtWrapper register() {

        PS_WebServiceUserInfoPasswordWrapper inputBody = (PS_WebServiceUserInfoPasswordWrapper) JSON.deserialize(
                RestContext.request.requestBody.toString(),
                PS_WebServiceUserInfoPasswordWrapper.class
        );

        if (String.isBlank(inputBody.email) || String.isBlank(inputBody.password)) {
            throw new IllegalArgumentException('Missing required parameter. [email|password]');
        }

        if ([
                SELECT Id
                FROM User
                WHERE Email = :inputBody.email
                AND IsActive = TRUE
                AND IsPortalEnabled = TRUE
        ].size() > 0) {
            throw new UserAlreadyExistsException('User with this email address already exists.');
        }

        List<String> pathPrefixSplit = Site.getPathPrefix().split('/');
        String siteName = pathPrefixSplit.size() >= 2 ? pathPrefixSplit.get(1) : null;

        Contact contact = PS_WebServiceUserInfoHelper.insertDummyAccountAndContact(
                inputBody.firstname,
                inputBody.lastname,
                inputBody.email,
                siteName,
                null,
                inputBody
        );

        User newUser = PS_WebServiceUserInfoHelper.insertUser(
                contact,
                inputBody.password,
                true,
                inputBody.language,
                inputBody,
                inputBody.mobile
        );

        PS_WebServiceUserInfoHelper.insertMissingAuthorizationFormConsents(
                newUser,
                inputBody
        );

        newUser = PS_WebServiceUserInfoHelper.getUserById(newUser.Id);

        return new PS_WebServiceUserInfoHelper().getUserInfoWrapper(
                newUser,
                true,
                true,
                false
        );
    }

    @TestVisible
    private class UserAlreadyExistsException extends Exception {
    }
}