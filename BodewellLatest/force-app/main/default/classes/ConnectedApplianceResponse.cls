public class ConnectedApplianceResponse {

    public String applianceId {get;set;}
    public Integer brandId {get;set;}
    public String brandName {get;set;}
    public String country {get;set;}
    public String environment {get;set;}
    public String kind {get;set;}
    public String poolId {get;set;}
    public String presence {get;set;}
    public String region {get;set;}
    public String userId {get;set;}

    public static ConnectedApplianceResponse parse(String json) {
        return (ConnectedApplianceResponse) System.JSON.deserialize(json, ConnectedApplianceResponse.class);
    }
}