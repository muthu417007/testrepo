public class OpenCallsResponse {

    public Data data;

    public class Data {
        public String getOpenCallInfo;
    }

    
    public static OpenCallsResponse parse(String json) {
        return (OpenCallsResponse) System.JSON.deserialize(json, OpenCallsResponse.class);
    }
}