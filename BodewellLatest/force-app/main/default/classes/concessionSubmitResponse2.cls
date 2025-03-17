public class concessionSubmitResponse2 {
    
    public String ApprovalNumber;
    //public String SE2UTResponse;

    public static ConcessionSubmitResponse2 parse(String json) {
        return (ConcessionSubmitResponse2) System.JSON.deserialize(json, ConcessionSubmitResponse2.class);
    }
}