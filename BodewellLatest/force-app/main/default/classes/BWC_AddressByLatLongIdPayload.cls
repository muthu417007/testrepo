public  class BWC_AddressByLatLongIdPayload
{
	

    public List<results> results{get;set;}
	public String status{get;set;}

public	class results {
		public List<address_components> address_components{get;set;}
		
	}
    	public class address_components {
		public String long_name{get;set;}    //HXJG+J3P
		public String short_name{get;set;}    //HXJG+J3P
		public List<String> types{get;set;}
	}
  }