public class MfgResponse {

    public String MfgModelNumber;
    public String MktModelNumber;
    public String UPCCode;

    
    public static MfgResponse parse(String json) {
        return (MfgResponse) System.JSON.deserialize(json, MfgResponse.class);
    }
}