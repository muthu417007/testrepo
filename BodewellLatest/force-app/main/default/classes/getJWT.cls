public class getJWT {

    public static String generateJWTToken(String iss, String sub, Integer validFor, String singingKey){

    String jwt = '';
    
    JSONGenerator header = JSON.createGenerator(false);
    header.writeStartObject();
    header.writeStringField('alg', 'HS256');
    header.writeEndObject();
    String encodedHeader = base64URLencode(Blob.valueOf(header.getAsString()));
        
    JSONGenerator body = JSON.createGenerator(false);
    body.writeStartObject();
    body.writeStringField('iss', iss);
    body.writeStringField('sub', sub);
    Long rightNow = (dateTime.now().getTime()/1000)+1;
    body.writeNumberField('iat', rightNow);
    body.writeNumberField('exp', (rightNow + validFor));
    /*if (claims != null) {
        for (String claim : claims.keySet()) {
            body.writeStringField(claim, claims.get(claim));
        }
    }*/
    body.writeEndObject();
    
    jwt = encodedHeader + '.' + base64URLencode(Blob.valueOf(body.getAsString()));
    Blob key = EncodingUtil.base64Decode(singingKey);
    Blob signature = Crypto.generateMac('hmacSHA256',Blob.valueof(jwt),key);
                
    //Blob signature = Crypto.generateMac('hmacSHA256',Blob.valueof(jwt),Blob.valueOf(singingKey));
    jwt += '.' + base64URLencode(signature);
    return jwt;

}

public static String base64URLencode(Blob input){ 
    String output = encodingUtil.base64Encode(input);
    output = output.replace('+', '-');
    output = output.replace('/', '_');
    while ( output.endsWith('=')){
        output = output.subString(0,output.length()-1);
    }
    return output;
}
}