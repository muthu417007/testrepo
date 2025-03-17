public class GenerateJSON_CreateLocSitePurpose {
	public String P_INIT_MSG_LIST { get; set; }
    public CustObj P_LOCATION_REC { get; set; }
    ////Inner class to represent the "P_LOCATION_REC" object
    public class CustObj {
        public String COUNTRY { get; set; }
        public String ADDRESS1 { get; set; }
        public String ADDRESS2 { get; set; }
        public String ADDRESS3 { get; set; }
        public String CITY { get; set; }
        public String POSTAL_CODE { get; set; }
        public String STATE { get; set; }
        public String DESCRIPTION { get; set; }
        public String CREATED_BY_MODULE { get; set; }
        public String PARTY_ID { get; set; }
        public String CUST_ACCOUNT_ID { get; set; }
    }
    
   	public GenerateJSON_CreateLocSitePurpose(string COUNTRY, string ADDRESS1, string ADDRESS2, string ADDRESS3, string CITY, string POSTAL_CODE, string STATE, string DESCRIPTION, string CREATED_BY_MODULE, string PARTY_ID, string CUST_ACCOUNT_ID) {
        P_INIT_MSG_LIST = 'T';
        P_LOCATION_REC = new CustObj();
        P_LOCATION_REC.COUNTRY = COUNTRY;
        P_LOCATION_REC.ADDRESS1 = ADDRESS1;
        P_LOCATION_REC.ADDRESS2 = ADDRESS2;
        P_LOCATION_REC.ADDRESS3 = ADDRESS3;
        P_LOCATION_REC.CITY = CITY;
        P_LOCATION_REC.POSTAL_CODE = POSTAL_CODE;
        P_LOCATION_REC.STATE = STATE;
        P_LOCATION_REC.DESCRIPTION = DESCRIPTION;
        P_LOCATION_REC.CREATED_BY_MODULE = CREATED_BY_MODULE;
        P_LOCATION_REC.PARTY_ID = PARTY_ID;
        P_LOCATION_REC.CUST_ACCOUNT_ID = CUST_ACCOUNT_ID;
    }
	public String byGlobalJSON() {
	    return JSON.serialize(this);        
    }
}