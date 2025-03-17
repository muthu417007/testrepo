public class BWC_ShippingResponseWrapper {
    public String zipcode;
    public Boolean is_will_call;
    public Boolean has_will_call;
    public String sds_ap_zone;
    public String hd_ap_zone;
    public String mt_ap_zone;
    public List<AgentClass> agents = new List<AgentClass>();

    public class AgentClass {
        public String zipcode;
        public String address;
        public String method;
        public String agent_id;
        public String phone;
        public String city;
        public String name;
        public String state;
        public String display_name;
        public String v_code;
        public String loc_type;
    }
}