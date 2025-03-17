public class OrderResponse {

    public Data data;


    public class Data {
        public String findServicesExtraInfo;
    }

    
    public static OrderResponse parse(String json) {
        return (OrderResponse) System.JSON.deserialize(json, OrderResponse.class);
    }
}