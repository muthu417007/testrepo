public class ConcessionSubmitResponse {

    public Data data;
    public List<Errors> errors;
    
    public class Errors {
		public List<String> path;
		public String data;
		public String errorType;
		public String errorInfo;
		public List<Locations> locations;
		public String message;
	}
    
    public class Locations {
		public String line;
		public String column;
		public String sourceName;
	}
    
    public class Data {
        public String processConcession;
        public String errors;
    }

    public static ConcessionSubmitResponse parse(String json) {
        return (ConcessionSubmitResponse) System.JSON.deserialize(json, ConcessionSubmitResponse.class);
    }
}