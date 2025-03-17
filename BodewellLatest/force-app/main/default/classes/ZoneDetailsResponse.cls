public class ZoneDetailsResponse {

    public String CityName;
    public String StateCode;
    public String PostalAreaCode;
    public String RegionNo;
    public String ZoneCode;
    public String errorMessage;

    public static ZoneDetailsResponse parse(String json) {
        return (ZoneDetailsResponse) System.JSON.deserialize(json, ZoneDetailsResponse.class);
    }
}