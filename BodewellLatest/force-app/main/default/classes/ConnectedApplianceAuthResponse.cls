public class ConnectedApplianceAuthResponse {

    public String access_token;
    public Integer expires_in;
    public String refresh_token;
    public String token_type;
    
    public static ConnectedApplianceAuthResponse parse(String json) {
        return (ConnectedApplianceAuthResponse) System.JSON.deserialize(json, ConnectedApplianceAuthResponse.class);
    }
}