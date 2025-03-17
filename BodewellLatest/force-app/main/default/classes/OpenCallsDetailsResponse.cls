public class OpenCallsDetailsResponse{
    @AuraEnabled
    public List<Cc_pendingcalls> cc_pendingcalls;
     @AuraEnabled
    public List<Fs_pendingcalls> fs_pendingcalls;
     @AuraEnabled
    public Integer fs_pendingcalls_count;
     @AuraEnabled
    public Integer cc_pendingcalls_count;
    
    
    public class Cc_pendingcalls {
        @AuraEnabled
        public String  SCHD_PERIOD;
        @AuraEnabled
        public String CONSUMER_NO;
        @AuraEnabled
        public String FS_CALL_NO;
        @AuraEnabled
        public String SERIAL_NO;
        @AuraEnabled
        public String CREATE_USERID;
        @AuraEnabled
        public String SERVICE_DATE;
        @AuraEnabled
        public String COMMENTS;
        @AuraEnabled
        public String CALL_CLASS;
        @AuraEnabled
        public String FULL_MODEL_NO;
        @AuraEnabled
        public String INSTALLATION_DATE;
        @AuraEnabled
        public String BRAND_CODE;
        @AuraEnabled
        public String PRODUCT_LINE_CODE;
        @AuraEnabled
        public String SERVICER_ADDRESS;
        @AuraEnabled
        public String CALL_CATEGORY;
        @AuraEnabled
        public String SERVICER_CITY;
        @AuraEnabled
        public String SERVICER_ZIPCODE;
        @AuraEnabled
        public String SVC_REQUEST_ADDR_1;
        @AuraEnabled
        public String REPEAT_CALL_IND;
        @AuraEnabled
        public List<String > SERVICER_TELEPHONE_NO;
        @AuraEnabled
        public String SERVICER_ACCT_NO;
        @AuraEnabled
        public String SVC_REQUEST_POSTAL_AREA;
        @AuraEnabled
        public String CREATE_DATE;
        @AuraEnabled
        public String CALL_TYPE;
        @AuraEnabled
        public String TELEPHONE_NO;
        @AuraEnabled
        public String SERVICER_NAME;
        @AuraEnabled
        public String CALL_NO;
        @AuraEnabled
        public String SERVICE_CALL_TYPE;
        @AuraEnabled
        public String CONS_CONT_DATE_TIME;
    }

      

    public class Fs_pendingcalls {
        @AuraEnabled
        public String SCHD_PERIOD;
        @AuraEnabled
        public String CONSUMER_NO;
        @AuraEnabled
        public String COPS_ORDER_NO;
        @AuraEnabled
        public String FS_CALL_NO;
        @AuraEnabled
        public String SERIAL_NO;
        @AuraEnabled
        public String ZONE;
        @AuraEnabled
        public String CREATE_USERID;
        @AuraEnabled
        public String SERVICE_DATE;
        @AuraEnabled
        public String COMMENTS;
        @AuraEnabled
        public String REMARKS;
        @AuraEnabled
        public String CALL_CLASS;
        @AuraEnabled
        public String FULL_MODEL_NO;
        @AuraEnabled
        public String CALL_CLASS_DESC;
        @AuraEnabled
        public String INSTALLATION_DATE;
        @AuraEnabled
        public String BRAND_CODE;
        @AuraEnabled
        public String TECHNO;
        @AuraEnabled
        public String PRODUCT_LINE_CODE;
        @AuraEnabled
        public String CALL_CATEGORY;
        @AuraEnabled
        public String SVC_REQUEST_ADDR_1;
        @AuraEnabled
        public String PART_ORDER_CREATE_USERID;
        @AuraEnabled
        public String REPEAT_CALL_IND;
        @AuraEnabled
        public String SERVICER_ACCT_NO;
        @AuraEnabled
        public String SVC_REQUEST_POSTAL_AREA;
        @AuraEnabled
        public String REGION;
        @AuraEnabled
        public String COPS_ORD_UNIQUE_KEY;
        @AuraEnabled
        public String SMC_ORDER_NO;
        @AuraEnabled
        public String CREATE_DATE;
        @AuraEnabled
        public String PART_ORDER_CREATE_DATE_TIME;
        @AuraEnabled
        public String TECH_NAME;
        @AuraEnabled
        public String CALL_TYPE;
        @AuraEnabled
        public String TELEPHONE_NO;
        @AuraEnabled
        public String CALL_NO;
        @AuraEnabled
        public String SERVICE_CALL_TYPE;
        @AuraEnabled
        public String CONS_CONT_DATE_TIME;
    }

    
    public static openCallsDetailsResponse parse(String json) {
        return (openCallsDetailsResponse) System.JSON.deserialize(json, openCallsDetailsResponse.class);
    }
}