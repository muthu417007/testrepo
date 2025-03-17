public without sharing class PS_CustomerSessionIdService {

    public void generateSessionIdValue(List<User> users) {
        generateSessionIdValue(users, false);
    }

    public void generateSessionIdValue(List<User> users, Boolean updateUsers) {
        for (User user : users) {
            String sessionIdValue = '';
            for (Integer i = 0; i < 6; i++) {
                sessionIdValue += EncodingUtil.convertToHex(Crypto.generateAesKey(256));
            }

            sessionIdValue = EncodingUtil.base64Encode(EncodingUtil.convertFromHex(sessionIdValue));

            sessionIdValue = sessionIdValue.replace('+', '-');
            sessionIdValue = sessionIdValue.replace('/', '_');

            while (sessionIdValue.endsWith('=')) {
                sessionIdValue = sessionIdValue.substring(0, sessionIdValue.length() - 1);
            }
            user.Customer_IdP_Session_Id__c = sessionIdValue.left(225);
        }

        if (updateUsers) {
            update users;
        }
    }
}