//******************************************************************************************
//Name : Mya_Agents 
//Requirement : To display PickUp Warehouse details on Order Details Page
//EPIC/US/TASK : IDMSF- 31, IDMSF- 37, IDMSF- 1032, IDMSF- 1033
//******************************************************************************************
//History
//	Version				Author					Date				Detail
//  1.0					Yogesh Sharma			07/11/2022			Initial
//******************************************************************************************
//@description : Wrapper Class to handle Agent API data after Deserializing
public without sharing class Mya_Agents 
{
    @AuraEnabled public String zipcode;
	@AuraEnabled public Boolean has_home_delivery;
	@AuraEnabled public Boolean has_small_package;
	@AuraEnabled public Boolean has_sds_delivery;
	@AuraEnabled public Boolean is_will_call;
	@AuraEnabled public Boolean has_will_call;
	@AuraEnabled public List<Mya_AgentDetails> agents;
}