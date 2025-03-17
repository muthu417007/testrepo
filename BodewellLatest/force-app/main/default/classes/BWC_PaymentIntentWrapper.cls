public class BWC_PaymentIntentWrapper {
     public String id { get; set; }
  
    public Decimal amount { get; set; }
    public Decimal amount_capturable { get; set; }
  
    public Decimal amount_received { get; set; }
    public String application { get; set; }
    public Integer application_fee_amount { get; set; }
    public AutomaticPaymentMethods automatic_payment_methods { get; set; }
    public Integer canceled_at { get; set; }
    public String cancellation_reason { get; set; }
    public String capture_method { get; set; }
    public String client_secret { get; set; }
    public String confirmation_method { get; set; }
    public Integer created { get; set; }
 
    public String customer { get; set; }
    public String description { get; set; }
    public String invoice { get; set; }
    public String last_payment_error { get; set; }
 
    public Boolean livemode { get; set; }
   
  
    public String payment_method { get; set; }
   
    public List<String> payment_method_types { get; set; }
   

    public String status { get; set; }

    
    
    public class AutomaticPaymentMethods {
        public Boolean enabled { get; set; }
    }
    
 
    
  
    	public static BWC_PaymentIntentWrapper parseIntent(String json){
            System.debug('wrapper='+json);
		return (BWC_PaymentIntentWrapper) System.JSON.deserialize(json, BWC_PaymentIntentWrapper.class);
	}
}