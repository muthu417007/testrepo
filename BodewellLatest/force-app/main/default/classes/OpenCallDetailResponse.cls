public class OpenCallDetailResponse {

    public class PARTS_ORDER_DETAILS {
        public Integer SMC_ORDER_NO;
        public String ZIP;
        public String COPS_ORDER_NO;
        public ORDER_HEADER_DETAILS ORDER_HEADER_DETAILS;
        public String SMC_CALL_NO;
        public List<ORDER_LINE_DETAILS> ORDER_LINE_DETAILS;
        public Integer COPS_ORD_UNIQUE_KEY;
    }

    public class Cc_pendingcalls {
    }

    public class ORDER_HEADER_DETAILS {
        public String FREIGHT_CODE;
        public String ORDER_HDR_SUMMARY_STATUS;
        public String TYPE_ORDER;
        public Double NET_ORDER_VALUE;
        public String SHIPTO_ADDR1;
        public String ORDER_NO;
        public String SHIPTO_STATE;
        public String CUST_CLASS_CODE;
        public Double GROSS_ORDER_VALUE;
        public String ORHDR_CRE_DATE_TIME;
        public String FIRST_ORDER_DATE;
        public String SHIPTO_ZIPCODE;
        public String SHIPTO_CITY;
        public Integer ORDER_UNIQUE_KEY;
        public String ORHDR_WHSE_STATUS;
        public String ORHDR_CRE_USERID;
        public String ORDER_HDR_STATUS_DESC;
        public String LAST_ORDER_DATE;
        public String SHIPTO_NAME;
        public String ORDER_HDR_STATUS;
    }

    public class Fs_pendingcalls {
        public Integer SCHD_PERIOD;
        public Integer CONSUMER_NO;
        public String COPS_ORDER_NO;
        public Integer FS_CALL_NO;
        public String SERIAL_NO;
        public String ZONE;
        public String CREATE_USERID;
        public Integer SERVICE_DATE;
        public String COMMENTS;
        public String REMARKS;
        public String CALL_CLASS;
        public String FULL_MODEL_NO;
        public String CALL_CLASS_DESC;
        public Integer INSTALLATION_DATE;
        public PARTS_ORDER_DETAILS PARTS_ORDER_DETAILS;
        public String BRAND_CODE;
        public String TECHNO;
        public String PRODUCT_LINE_CODE;
        public String CALL_CATEGORY;
        public String SVC_REQUEST_ADDR_1;
        public String PART_ORDER_CREATE_USERID;
        public String REPEAT_CALL_IND;
        public String SERVICER_ACCT_NO;
        public String SVC_REQUEST_POSTAL_AREA;
        public String REGION;
        public Integer COPS_ORD_UNIQUE_KEY;
        public Integer SMC_ORDER_NO;
        public String CREATE_DATE;
        public String PART_ORDER_CREATE_DATE_TIME;
        public String TECH_NAME;
        public String CALL_TYPE;
        public Long TELEPHONE_NO;
        public Integer CALL_NO;
        public String SERVICE_CALL_TYPE;
        public String CONS_CONT_DATE_TIME;
    }

    public List<Cc_pendingcalls> cc_pendingcalls;
    public List<Fs_pendingcalls> fs_pendingcalls;
    public Integer fs_pendingcalls_count;
    public Integer cc_pendingcalls_count;

    public class ORDER_LINE_DETAILS {
        public String ORDER_LINE_SUMMARY_STATUS;
        public Integer ORLNE_QTY_ORDERED;
        public Double ITEM_INV_PRICE;
        public String ORDER_LINE_STATUS;
        public String ITEM_ID;
        public String ORDER_NO;
        public String MATERIAL_TYPE;
        public String ORDER_LINE_STATUS_DESC;
        public Double NET_LINE_VALUE;
        public Integer ORDER_UNIQUE_KEY;
        public String SHIP_DATE;
        public Integer ORDER_LINE;
        public Double LINE_PRICE;
    }

    
    public static OpenCallDetailResponse parse(String json) {
        return (OpenCallDetailResponse) System.JSON.deserialize(json, OpenCallDetailResponse.class);
    }
}