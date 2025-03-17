public class ProductDetailBody {

    public class Headers {
        //public String date {get;set;} 
        public String server {get;set;} 
        //public String access-control-allow-origin {get;set;} 
        public String p3p {get;set;} 
        public String connection {get;set;} 
        //public String transfer-encoding {get;set;} 
        //public String content-type {get;set;} 

        public Headers(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'date') {
                            //date = parser.getText();
                        } else if (text == 'server') {
                            server = parser.getText();
                        } else if (text == 'access-control-allow-origin') {
                           // access-control-allow-origin = parser.getText();
                        } else if (text == 'p3p') {
                            p3p = parser.getText();
                        } else if (text == 'connection') {
                            connection = parser.getText();
                        } else if (text == 'transfer-encoding') {
                           // transfer-encoding = parser.getText();
                        } else if (text == 'content-type') {
                           // content-type = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Headers consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Request {
        public Uri uri {get;set;} 
        public String method {get;set;} 
        public Headers_Z headers {get;set;} 

        public Request(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'uri') {
                            uri = new Uri(parser);
                        } else if (text == 'method') {
                            method = parser.getText();
                        } else if (text == 'headers') {
                            headers = new Headers_Z(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Request consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
   
        public Integer statusCode {get;set;} 
        public String body {get;set;} 
        public Headers headers {get;set;} 
        public Request request {get;set;} 

        public ProductDetailBody(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'statusCode') {
                            statusCode = parser.getIntegerValue();
                        } else if (text == 'body') {
                            body = parser.getText();
                        } else if (text == 'headers') {
                            headers = new Headers(parser);
                        } else if (text == 'request') {
                            request = new Request(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'ProductDetailBody consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    
    
    public class Headers_Z {
        //public String x-api-key {get;set;} 

        public Headers_Z(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'x-api-key') {
                           // x-api-key = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Headers_Z consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Uri {
        public String protocol {get;set;} 
        public Boolean slashes {get;set;} 
        public Object auth {get;set;} 
        public String host {get;set;} 
        public Integer port {get;set;} 
        public String hostname {get;set;} 
        public Object hash {get;set;} 
        public String search_Z {get;set;} // in json: search
        public String query {get;set;} 
        public String pathname {get;set;} 
        public String path {get;set;} 
        public String href {get;set;} 

        public Uri(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'protocol') {
                            protocol = parser.getText();
                        } else if (text == 'slashes') {
                            slashes = parser.getBooleanValue();
                        } else if (text == 'auth') {
                            auth = parser.readValueAs(Object.class);
                        } else if (text == 'host') {
                            host = parser.getText();
                        } else if (text == 'port') {
                            port = parser.getIntegerValue();
                        } else if (text == 'hostname') {
                            hostname = parser.getText();
                        } else if (text == 'hash') {
                            hash = parser.readValueAs(Object.class);
                        } else if (text == 'search') {
                            search_Z = parser.getText();
                        } else if (text == 'query') {
                            query = parser.getText();
                        } else if (text == 'pathname') {
                            pathname = parser.getText();
                        } else if (text == 'path') {
                            path = parser.getText();
                        } else if (text == 'href') {
                            href = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Uri consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    
    public static ProductDetailBody parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new ProductDetailBody(parser);
    }
    
    public static void consumeObject(System.JSONParser parser) {
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT || 
                curr == System.JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == System.JSONToken.END_OBJECT ||
                curr == System.JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }
    

}