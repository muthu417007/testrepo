public class ClosedCallsDetailsResponse {
  
    public class Cc_callhistory {
        @AuraEnabled
        public String CONSUMER_NO;
        @AuraEnabled
        public String SERIAL_NO;
        @AuraEnabled
        public String PART_NO;
        @AuraEnabled
        public String COMMENTS;
        @AuraEnabled
        public String REPAIR_TYPE_REIMBURSED;
        @AuraEnabled
        public String SYSTEM_ID;
        @AuraEnabled
        public String FULL_MODEL_NO;
        @AuraEnabled
        public String INSTALLATION_DATE;
        @AuraEnabled
        public String CONSUMER_COMPLAINT;
        @AuraEnabled
        public String BRAND_CODE;
        @AuraEnabled
        public String AMOUNT;
        @AuraEnabled
        public String PRODUCT_LINE_CODE;
        @AuraEnabled
        public String ACCOUNT_NUMBER;
        @AuraEnabled
        public String DATE_SERVICE_COMPLETED;
        @AuraEnabled
        public String SVC_REQUEST_ADDR_1;
        @AuraEnabled
        public String SERVICER_ACCT_NO;
        @AuraEnabled
        public String SERIVCE_PERFORMED;
        @AuraEnabled
        public String SVC_REQUEST_POSTAL_AREA;
        @AuraEnabled
        public String CUSTOMER_AGREEMENT_NO;
        @AuraEnabled
        public String REIMBURSED_LABOR_AMT;
        @AuraEnabled
        public String CREATE_DATE;
        @AuraEnabled
        public String CALL_TYPE;
        @AuraEnabled
        public String SERVICER_NAME;
        @AuraEnabled
        public String TELEPHONE_NO;
        @AuraEnabled
        public String PROCESSED_DATE;
        @AuraEnabled
        public String CALL_NO;
    }
  
    public class Fs_callhistory {
        @AuraEnabled
        public String SVC_ZIP;
        @AuraEnabled
        public String TRIP_CHARGE;
        @AuraEnabled
        public String CONSUMER_NO;
        @AuraEnabled
        public String SERIAL_NO;
        @AuraEnabled
        public String SERVICE_DATE;
        @AuraEnabled
        public String FS_CALL_NUMBER;
        @AuraEnabled
        public String CALL_CLASS_DESC;
        @AuraEnabled
        public String INSTALLATION_DATE;
        @AuraEnabled
        public String SVC_NAME_FIRST;
        @AuraEnabled
        public String SMG_BRAND_CODE;
        @AuraEnabled
        public String TAX_CHARGE;
        @AuraEnabled
        public String FSREGION;
        @AuraEnabled
        public String PROBLEM_DESCRIPTION;
        @AuraEnabled
        public String LABOR_CHARGE;
        @AuraEnabled
        public String TECHNO;
        @AuraEnabled
        public String PRODUCT_LINE_CODE;
        @AuraEnabled
        public String FSZONE;
        @AuraEnabled
        public String INV_CALL_CLASS;
        @AuraEnabled
        public String BILL_TO_PHONE;
        @AuraEnabled
        public String TERMS_CODE;
        @AuraEnabled
        public String PARTS_HIST_KEY;
        @AuraEnabled
        public String TOTAL_PARTS_USED;
        @AuraEnabled
        public String MODEL;
        @AuraEnabled
        public String BILL_TO_ZIP;
        @AuraEnabled
        public String SVC_NAME_LAST;
        @AuraEnabled
        public String WORK_PERFORMED_KEY;
        @AuraEnabled
        public String BILL_TO_ADDRESS;
        @AuraEnabled
        public String CALL_TAKEN_DATE;
        @AuraEnabled
        public String FSINV_TYPE;
        @AuraEnabled
        public String PARTS_CHARGE;
        @AuraEnabled
        public Integer FSINVOICE;
        @AuraEnabled
        public String NET_CHARGE;
        @AuraEnabled
        public String BILL_TO_NAME;
        @AuraEnabled
        public String TAX_CODE;
        @AuraEnabled
        public String CALL_NO;
        @AuraEnabled
        public String JOBCODE1;
        @AuraEnabled
        public List<PARTS_HIST_DATA> PARTS_HIST_DATA;
    }

        @AuraEnabled
        public Integer cc_callhistory_count;
        @AuraEnabled
        public Integer fs_callhistory_count;
        @AuraEnabled
        public List<Cc_callhistory> cc_callhistory;
        @AuraEnabled
        public List<Fs_callhistory> fs_callhistory;
   

    public class PARTS_HIST_DATA {
        public Integer PARTS_QUANTITY;
        public String ITEM_ID;
    }

    
    public static ClosedCallsDetailsResponse parse(String json) {
        return (ClosedCallsDetailsResponse) System.JSON.deserialize(json, ClosedCallsDetailsResponse.class);
    }
}