public class BWC_SearchConsumerResponseWrapper {
    public class CustomerHeader {
        public List<CustomerHeaderItem> P_OUT_CUSTOMER_HDR_TAB_ITEM;
    }
    
    public class CustomerHeaderItem {
        public String PARTY_NAME;
        public String PARTY_NUMBER;
        public String PARTY_ID;
        public String CUST_ACCOUNT_ID;
        public String ACCOUNT_NAME;
        public String ACCOUNT_NUMBER;
        public String PERSON_FIRST_NAME;
        public String PERSON_LAST_NAME;
        public String PHONE_NUMBER;
        public String EMAIL_ADDRESS;
        public String STATUS;
        public String SALES_CHANNEL_CODE;
        public String PARTY_STATUS;
        public String CCR_NAME;
        public String ACCOUNT_CLASSIFICATION;
    }
    
    public String P_HEADER_STATUS;
    public String P_HEADER_MSG;
    
    public class CustomerDetails {
        public List<CustomerDetailsItem> P_OUT_CUSTOMER_DTLS_TAB_ITEM;
    }
    
    public class CustomerDetailsItem {
        public String SITE_USE_CODE;
        public String SITE_USE_ID;
        public String LOCATION;
        public String LOCATION_ID;
        public String PRIMARY_FLAG;
        public String PARTY_SITE_ID;
        public String CUST_ACCT_SITE_ID;
        public String ADDRESS1;
        public String ADDRESS2;
        public String ADDRESS3;
        public String CITY;
        public String STATE;
        public String PROVINCE;
        public String COUNTY;
        public String COUNTRY;
        public String POSTAL_CODE;
        public String PHONE_NUMBER;
        public String EMAIL_ADDRESS;
    }
    
    public String P_LINE_STATUS;
    public String P_LINE_MSG;
    
    public CustomerHeader P_OUT_CUSTOMER_HDR_TAB;
    public CustomerDetails P_OUT_CUSTOMER_DTLS_TAB;
}