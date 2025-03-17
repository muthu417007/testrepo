@RestResource(UrlMapping='/customer-idm/remote-administration/v1/register-email')
global with sharing class PS_RemoteAdminRegisterEmailWebService {

    @TestVisible
    private static final String EMAIL_PARAM = 'email';

    @HttpPut
    global static EmailRegistrationResponse getUser(String email) {
        if (String.isBlank(email)) {
            throw new IllegalArgumentException('Missing required parameter [' + EMAIL_PARAM + '].');
        }

        List<Contact> foundContacts = [
                SELECT Id,Global_Customer_Id__c,Email
                FROM Contact
                WHERE Email = :email
        ];

        List<String> pathPrefixSplit = Site.getPathPrefix().split('/');
        String siteName = pathPrefixSplit.size() >= 2 ? pathPrefixSplit.get(1) : null;

        Contact contact;
        if (foundContacts.isEmpty()) {
            contact = PS_WebServiceUserInfoHelper.insertDummyAccountAndContact(
                    null,
                    null,
                    email,
                    siteName
            );
        } else {
            contact = foundContacts.get(0);
        }

        return new EmailRegistrationResponse(
                PS_WebServiceUserInfoHelper.getContactGlobalId(contact.Id),
                contact.Email
        );
    }

    global class EmailRegistrationResponse {
        public String globalId;
        public String email;

        public EmailRegistrationResponse(String globalId, String email) {
            this.globalId = globalId;
            this.email = email;
        }
    }
}