public class CN1Response {

    public String ConsumerNo;
    public String AddressId;
    public String PhoneId;
    public String ErrorMessage;

    
    public static CN1Response parse(String json) {
        return (CN1Response) System.JSON.deserialize(json, CN1Response.class);
    }
}