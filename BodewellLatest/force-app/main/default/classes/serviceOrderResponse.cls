public class serviceOrderResponse {
    public Data data {get;set;}
    
    public class Data {
        public String findServicesExtraInfo  {get;set;}
    }

    public static ServiceOrderResponse parse(String json) {
        return (ServiceOrderResponse) System.JSON.deserialize(json, ServiceOrderResponse.class);
    }
}