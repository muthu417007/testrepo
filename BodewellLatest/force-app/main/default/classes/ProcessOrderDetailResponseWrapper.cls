global class ProcessOrderDetailResponseWrapper {
 
    global  P_OUT_LINE_VAL_TBL_CLS P_OUT_LINE_TBL;
    
    global class P_OUT_LINE_VAL_TBL_ITEMS_CLS {
            global String CUSTOMER_JOB;
        	global String LINE_ID;
    }
    global class P_OUT_LINE_VAL_TBL_CLS {
            global List<P_OUT_LINE_VAL_TBL_ITEMS_CLS> P_OUT_LINE_TBL_ITEMS;
    }
}