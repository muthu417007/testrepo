public class GEAoAuthResponse {

    public String access_token;
    public String scope;
    public Integer expires_in;
    public String token_type;

    
    public static GEAoAuthResponse parse(String json) {
        return (GEAoAuthResponse) System.JSON.deserialize(json, GEAoAuthResponse.class);
    }
}