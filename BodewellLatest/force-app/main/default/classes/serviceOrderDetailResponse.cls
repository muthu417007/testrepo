public class serviceOrderDetailResponse {

    @AuraEnabled
    public ORDER_HEADER ORDER_HEADER;
    @AuraEnabled
    public List<ORDER_LINES> ORDER_LINES;
    
    
    public class ORDER_HEADER {
        @AuraEnabled
        public String FREIGHT_CODE;
        @AuraEnabled
        public String ORDER_HDR_SUMMARY_STATUS;
        public String TYPE_ORDER;
        public String BILLTO_ADDR1;
        public Double NET_ORDER_VALUE;
        public String ORDER_NO;
        public String BILLTO_ZIPCODE;
        public String BILLTO_CITY;
        public String REQ_DATE;
        public String ORHDR_CRE_DATE_TIME;
        public String SHIPTO_ZIPCODE;
        public String SHIPTO_CITY;
        public Integer ORDER_UNIQUE_KEY;
        public String ORHDR_WHSE_STATUS;
        public String TRACKING_NO;
        public String ORDER_HDR_STATUS_DESC;
        public Integer ORHDR_STNDRD_HNDLNG_CHRG;
        public String BILLTO_NAME;
        public String SHIPTO_ADDR1;
        public Integer ORHDR_TAX_AMT;
        public String SHIPTO_STATE;
        public String CUST_CLASS_CODE;
        public Double GROSS_ORDER_VALUE;
        public String INVOICE_NO;
        public String FIRST_ORDER_DATE;
        public String CARRIER_CODE;
        public String ORHDR_CRE_USERID;
        public String SHIPTO_NAME;
        public String ORDER_HDR_STATUS;
    }

    public class ORDER_LINES {
        public Integer ORLNE_TAX_AMT;
        public String ORDER_LINE_SUMMARY_STATUS;
        public Integer ORLNE_QTY_ORDERED;
        public Double ITEM_INV_PRICE;
        public String ORDER_LINE_STATUS;
        public String ITEM_ID;
        public String ORDER_NO;
        public String ITEM_DESCRIPTION;
        public Double COST;
        public String ORDER_LINE_STATUS_DESC;
        public Integer DISC_PC;
        public Double NET_LINE_VALUE;
        public String CSN_JOB_CODE;
        public Integer ORDER_UNIQUE_KEY;
        public String SHIP_DATE;
        public String JOB_CODE_DESCRIPTION;
        public Integer ORDER_LINE;
        public Double LINE_PRICE;
    }

  
    public static ServiceOrderDetailResponse parse(String json) {
        return (ServiceOrderDetailResponse) System.JSON.deserialize(json, ServiceOrderDetailResponse.class);
    }
}