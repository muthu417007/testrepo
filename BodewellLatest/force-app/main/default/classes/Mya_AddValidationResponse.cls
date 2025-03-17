public class Mya_AddValidationResponse {
    
    public String RESULTS;
    public string ADDRESS_LINE1;
    public string CITY;
    public string STATE;
    public string POSTALCODE;
    public string COUNTRY;
    public string MELISSA_ADDRESS_KEY;
    public string ADDRESS_KEY;
  
    public static Mya_AddValidationResponse parse(String json) {
        return (Mya_AddValidationResponse) System.JSON.deserialize(json, Mya_AddValidationResponse.class);
    }
}