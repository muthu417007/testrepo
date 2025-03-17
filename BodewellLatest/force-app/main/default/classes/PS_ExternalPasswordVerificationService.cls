public without sharing class PS_ExternalPasswordVerificationService {

    private final String PASSWORD_LOCKOUT = 'Password Lockout';
    private static final String POST_METHOD = 'POST';
    private static final String CONTENT_TYPE = 'Content-Type';
    private static final String APPLICATION_JSON = 'application/json';
    private static final String X_API_KEY = 'x-api-key';
    private static final String AUTHORIZATION = 'Authorization';
    private static final String JWT = 'JWT';
    private static final String RSA_SHA_256 = 'RSA-SHA256';
    private static final String GIGYA_AUTHENTICATE = 'gigya#authenticate';

    private Id userId;
    private String email;
    private String password;
    private Customer_IdP_Password_Service_Config__c passwordServiceConfig;

    public PS_ExternalPasswordVerificationService(
            Id userId,
            String email,
            String password
    ) {
        this.userId = userId;
        this.email = email;
        this.password = password;
        this.passwordServiceConfig = [
                SELECT Id,API_Key__c,JWT_Audience__c,JWT_Expiry__c,
                        JWT_Issuer__c,JWT_Signing_Key__c,Named_Credential__c
                FROM Customer_IdP_Password_Service_Config__c
                LIMIT 1
        ];
    }

    public void setPassword() {
        System.setPassword(this.userId, this.password);
    }

    public Boolean verifyPassword() {
        if (isUserLockedOut()) {
            return false;
        }

        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:' + passwordServiceConfig.Named_Credential__c);
        request.setMethod(POST_METHOD);
        request.setTimeout(30000);
        request.setHeader(CONTENT_TYPE, APPLICATION_JSON);
        request.setHeader(X_API_KEY, passwordServiceConfig.API_Key__c);
        request.setHeader(AUTHORIZATION, 'JWT ' + generateJWT());

        Map<String, String> payload = new Map<String, String>();
        payload.put('kind', GIGYA_AUTHENTICATE);
        payload.put('email', this.email);
        request.setBody(JSON.serialize(payload));

        Http http = new Http();
        HttpResponse response = http.send(request);
        Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        if (response.getStatusCode() != 200 || (Boolean) responseBody.get('success') != true) {
            return false;
        }

        return true;
    }

    private Boolean isUserLockedOut() {
        List<LoginHistory> loginHistories = [
                SELECT LoginTime,Status
                FROM LoginHistory
                WHERE UserId = :this.userId
                LIMIT 1
        ];
        System.debug(loginHistories);
        if (loginHistories.isEmpty()) {
            return false;
        }
        LoginHistory loginHistory = loginHistories.get(0);
        if (loginHistory.Status == PASSWORD_LOCKOUT) {
            Integer lockoutTimeout = Integer.valueOf(
                    PS_GEAIdPCustomerConfigHelper.getSiteConfiguration().Lockout_Timeout__c
            );
            System.debug(lockoutTimeout);
            if (loginHistory.LoginTime > System.now().addMinutes((-1) * lockoutTimeout)) {
                return true;
            }
        }

        return false;
    }

    private String generateJWT() {
        Long now = System.currentTimeMillis() / 1000;
        Map<String, Object> body = new Map<String, Object>{
                'iss' => this.passwordServiceConfig.JWT_Issuer__c,
                'iat' => now,
                'exp' => now + this.passwordServiceConfig.JWT_Expiry__c,
                'aud' => this.passwordServiceConfig.JWT_Audience__c,
                'sub' => EncodingUtil.base64Encode(Blob.valueOf(this.email + ':' + this.password))
        };

        Map<String, String> header = new Map<String, String>{
                'alg' => 'RS256',
                'typ' => JWT
        };

        String headerBody = base64URLEncode(Blob.valueOf(Json.serialize(header))) + '.'
                + base64URLEncode(Blob.valueOf(Json.serialize(body)));

        Blob jwtToken = Crypto.sign(
                RSA_SHA_256,
                Blob.valueOf(headerBody),
                EncodingUtil.base64Decode(passwordServiceConfig.JWT_Signing_Key__c)
        );
        String token = headerBody + '.' + base64URLEncode(jwtToken);
        return token;
    }

    private static String base64URLEncode(Blob input) {
        String output = EncodingUtil.base64Encode(input);
        output = output.replace('+', '-');
        output = output.replace('/', '_');
        while (output.endsWith('=')) {
            output = output.substring(0, output.length() - 1);
        }
        return output;
    }
}