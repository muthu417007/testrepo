//******************************************************************************************
//Name : Mya_AgentApiPayload
//Requirement : To display PickUp Warehouse details on Order Details Page
//EPIC/US/TASK : IDMSF- 31, IDMSF- 37, IDMSF- 1032, IDMSF- 1033
//******************************************************************************************
//History
//	Version				Author					Date				Detail
//  1.0					Yogesh Sharma			07/11/2022			Initial
//******************************************************************************************
//@description : Wrapper Class to handle Agent API data while Deserializing
public without sharing class Mya_AgentApiPayload
{
	public String zipcode;
	public Boolean has_home_delivery;
	public Boolean has_small_package;
	public Boolean has_sds_delivery;
	public Boolean is_will_call;
	public Boolean has_will_call;
	public List<Agents> agents;
	
	//@description : Wrapper Class
	public class Agents 
    {
		public String zipcode;
		public String address;
		public String method;
		public String agent_id;
		public String phone;
		public String city;
		public String name;
		public String state;
		public String display_name;
	}
}