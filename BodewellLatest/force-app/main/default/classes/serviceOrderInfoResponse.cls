public class serviceOrderInfoResponse {

    public Data data;

    public class Data {
        public String findExtraInfo;
    }

    
    public static ServiceOrderInfoResponse parse(String json) {
        return (ServiceOrderInfoResponse) System.JSON.deserialize(json, ServiceOrderInfoResponse.class);
    }
}