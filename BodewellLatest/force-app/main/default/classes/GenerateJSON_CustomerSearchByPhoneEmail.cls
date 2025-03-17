/**
   * @description created by : Sukumar Venkatesan
   * This class is to call generate the JSON structure for Customer byEmailPhone Number search API
   * Test class : TBD
*/

public without sharing class GenerateJSON_CustomerSearchByPhoneEmail {
    public String P_INIT_MSG_LIST { get; set; }
    public CustObj P_CUST_GET_SEARCH_REC { get; set; }
    //Inner class to represent the "P_CUST_GET_SEARCH_REC" object
    public class CustObj {
        public String EMAIL_ADDRESS { get; set; }
        public String PHONE_NUMBER { get; set; }
    }
    
   	public GenerateJSON_CustomerSearchByPhoneEmail(string email, string phone) {
        P_INIT_MSG_LIST = 'T';
        P_CUST_GET_SEARCH_REC = new CustObj();
        P_CUST_GET_SEARCH_REC.EMAIL_ADDRESS = email;
        P_CUST_GET_SEARCH_REC.PHONE_NUMBER = phone;	
    }
	public String byEmailPhoneJSON() {
	    return JSON.serialize(this);        
    }
}