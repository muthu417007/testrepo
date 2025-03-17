public class ProcessOrderResponseWrapper {
    
    public  X_MESSAGESs X_MESSAGES;
    public X_HEADER_RECs X_HEADER_REC;
    public X_LINE_TBLs X_LINE_TBL;
    public class X_MESSAGESs{
        public List<X_MESSAGES_ITEMs> X_MESSAGES_ITEM = new List<X_MESSAGES_ITEMs>();
    }
    public class X_MESSAGES_ITEMs{
        public string MESSAGE_TEXT;
    }
    public class X_HEADER_RECs{
        public String HEADER_ID;
        public String FLOW_STATUS_CODE;
        public String ORDER_NUMBER;
    }
    public class X_LINE_TBLs{
        public List<X_LINE_TBL_ITEMs> X_LINE_TBL_ITEM = new List<X_LINE_TBL_ITEMs>();
    }
    public class X_LINE_TBL_ITEMs{
        public String LINE_ID;
        public String ORDERED_ITEM;
    }
}