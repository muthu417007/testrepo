public class PaymentMethodWrapper {
    public String id { get; set; }
   
    public BillingDetails billing_details { get; set; }
    public Card card { get; set; }
    public Integer created { get; set; }
    public String customer { get; set; }
    public Boolean livemode { get; set; }
    public Map<String, Object> metadata { get; set; }
    public String type { get; set; }
    
    public class BillingDetails {
        public Address address { get; set; }
        public String email { get; set; }
        public String name { get; set; }
        public String phone { get; set; }
    }
    
    public class Address {
        public String city { get; set; }
        public String country { get; set; }
        public String line1 { get; set; }
        public String line2 { get; set; }
        public String postal_code { get; set; }
        public String state { get; set; }
    }
    
    public class Card {
        public String brand { get; set; }
        public Checks checks { get; set; }
        public String country { get; set; }
        public Integer exp_month { get; set; }
        public Integer exp_year { get; set; }
        public String fingerprint { get; set; }
        public String funding { get; set; }
        public String generated_from { get; set; }
        public String last4 { get; set; }
        public Networks networks { get; set; }
        public ThreeDSecureUsage three_d_secure_usage { get; set; }
        public String wallet { get; set; }
    }
    
    public class Checks {
        public String address_line1_check { get; set; }
        public String address_postal_code_check { get; set; }
        public String cvc_check { get; set; }
    }
    
    public class Networks {
        public List<String> available { get; set; }
        public String preferred { get; set; }
    }
    
    public class ThreeDSecureUsage {
        public Boolean supported { get; set; }
    }
}