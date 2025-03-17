public class ClosedCallsResponse {

    public Data data;
    
    public class Data {
        public String getClosedCallInfo;
    }

    public static ClosedCallsResponse parse(String json) {
        return (ClosedCallsResponse) System.JSON.deserialize(json, ClosedCallsResponse.class);
    }
}