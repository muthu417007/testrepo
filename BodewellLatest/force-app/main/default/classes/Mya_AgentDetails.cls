//******************************************************************************************
//Name : Mya_AgentDetails 
//Requirement : To display PickUp Warehouse details on Order Details Page
//EPIC/US/TASK : IDMSF- 31, IDMSF- 37, IDMSF- 1032, IDMSF- 1033
//******************************************************************************************
//History
//	Version				Author					Date				Detail
//  1.0					Yogesh Sharma			07/11/2022			Initial
//******************************************************************************************
//@description : Wrapper Class to handle Agent API data after Deserializing
public without sharing class Mya_AgentDetails 
{
    @AuraEnabled public String zipcode;
	@AuraEnabled public String address;
	@AuraEnabled public String method;
	@AuraEnabled public String agent_id;
	@AuraEnabled public String phone;
	@AuraEnabled public String city;
	@AuraEnabled public String name;
	@AuraEnabled public String state;
	@AuraEnabled public String display_name;
}