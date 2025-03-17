public class EinsteinController {
    public String getAccessToken() {
        OCR_Settings__mdt[] OCRSettings = [SELECT OCR_Email__c, Private_Key__c FROM OCR_Settings__mdt WHERE Developername ='OCR_Credentials'];
        String keyContents = OCRSettings.isEmpty() ? '' : OCRSettings.get(0).Private_Key__c;
        keyContents = keyContents.replace('-----BEGIN RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('-----END RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('\n', '');

        JWT jwt = new JWT('RS256');
        jwt.pkcs8 = keyContents;
        jwt.iss = 'developer.force.com';
        jwt.sub = OCRSettings.isEmpty() ? '' : OCRSettings.get(0).OCR_Email__c;
        jwt.aud = 'https://api.einstein.ai/v2/oauth2/token';
        jwt.exp = '3600';
        jwt.iat = String.valueOf((dateTime.now().getTime()/1000)+1);
        String access_token = JWTBearerFlow.getAccessToken('https://api.einstein.ai/v2/oauth2/token', jwt);
        return access_token;
    }
}