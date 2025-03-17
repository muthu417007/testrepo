public class BWC_AgentResponseWrapper {
    public String response_status {get; set; }   
    public String response_message {get;set; }
    public String zipcode { get; set; } 
    public Boolean has_home_delivery { get; set; } 
    public Boolean has_small_package { get; set; } 
    public Boolean has_sds_delivery { get; set; } 
    public Boolean is_will_call { get; set; } 
    public Boolean has_will_call { get; set; } 
    public String sds_ap_zone { get; set; } 
    public String hd_ap_zone { get; set; } 
    public String mt_ap_zone { get; set; } 
    public List<Wrapper> agents { get; set; } 
    //List<Wrapper> agents = new List<Wrapper>();

    public class Wrapper { 
        public String zipcode { get; set; } 
        public String address { get; set; } 
        public String method { get; set; } 
        public String agent_id { get; set; } 
        public String phone { get; set; } 
        public String city { get; set; } 
        public String name { get; set; } 
        public String state { get; set; } 
        public String display_name { get; set; } 
        public String v_code { get; set; } 
        public String loc_type { get; set; } 
    }
}