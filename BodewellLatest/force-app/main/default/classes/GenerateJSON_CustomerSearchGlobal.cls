/**
   * @description created by : Gowsic
   * This class is to call generate the JSON structure for Customer byEmailPhone Number search API
   * Test class : TBD
*/
public class GenerateJSON_CustomerSearchGlobal {
	public String P_INIT_MSG_LIST { get; set; }
    public CustObj P_CUSTOMER_SEARCH_REC { get; set; }
    //Inner class to represent the "P_CUST_GET_SEARCH_REC" object
    public class CustObj {
        public String ACCOUNT_NUMBER { get; set; }
        public String SITE_USE_CODE { get; set; }
        public String ADDRESS1 { get; set; }
        public String POSTAL_CODE { get; set; }
        public String PHONE_NUMBER { get; set; }
        public String EMAIL_ADDRESS { get; set; }
    }
    
   	public GenerateJSON_CustomerSearchGlobal(string ACCOUNT_NUMBER, string SITE_USE_CODE, string ADDRESS1, string POSTAL_CODE, string PHONE_NUMBER, string EMAIL_ADDRESS) {
        P_INIT_MSG_LIST = '';
        P_CUSTOMER_SEARCH_REC = new CustObj();
        P_CUSTOMER_SEARCH_REC.ACCOUNT_NUMBER = ACCOUNT_NUMBER;
        P_CUSTOMER_SEARCH_REC.SITE_USE_CODE = SITE_USE_CODE;
        P_CUSTOMER_SEARCH_REC.ADDRESS1 = ADDRESS1;
        P_CUSTOMER_SEARCH_REC.POSTAL_CODE = POSTAL_CODE;
        P_CUSTOMER_SEARCH_REC.PHONE_NUMBER = PHONE_NUMBER;
        P_CUSTOMER_SEARCH_REC.EMAIL_ADDRESS = EMAIL_ADDRESS;
    }
	public String byGlobalJSON() {
	    return JSON.serialize(this);        
    }
}