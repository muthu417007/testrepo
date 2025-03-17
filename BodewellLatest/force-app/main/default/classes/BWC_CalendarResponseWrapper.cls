public class BWC_CalendarResponseWrapper {
    public class CalendarDate {
        public String stdate { get; set; }
        public Boolean available { get; set; }
    }

    public Boolean success { get; set; }
    public String error { get; set; }
    public String responseMessage { get; set; }
    public List<CalendarDate> calendar_dates { get; set; }
    public String zipcode { get; set; }
    public String state { get; set; }
    public String mode { get; set; }
    public String deliveryAgent { get; set; }
    public String typeOfCall { get; set; }
    public String startDate { get; set; }
    public String vendorCode { get; set; }
    public String accountNo { get; set; }
    public Integer noOfDays { get; set; }
}