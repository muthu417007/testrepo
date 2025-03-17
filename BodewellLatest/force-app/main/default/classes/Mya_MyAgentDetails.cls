//******************************************************************************************
//Name : Mya_AgentApiZipHelper
//Requirement : To display PickUp Warehouse details on Order Details Page
//EPIC/US/TASK : IDMSF- 31, IDMSF- 37, IDMSF- 1032, IDMSF- 1033
//******************************************************************************************
//History
//	Version				Author					Date				Detail
//  1.0					Yogesh Sharma			07/11/2022			Initial
//******************************************************************************************
//@description : Class to fetch Agent API data
public without sharing class Mya_MyAgentDetails 
{
    //@description : Method is used for handling requests for Agent API data
    //Input: String Zip
    //Return: Mya_Agents Data
    @AuraEnabled(Cacheable=true)
    public static Mya_Agents Mya_MyAgentDetails(String Zip) 
    {
        String jsonData = Mya_AgentApiZipHelper.mya_ZipDetail(Zip);
        Mya_Agents APIDetails = mya_FetchAPIDetail(jsonData);
        return APIDetails;
    }

    //@description : Method is used for handling deserializing Agent API data
    //Input: String Agent API JSON data
    //Return: Mya_Agents Data
    @AuraEnabled(Cacheable=false)
    Public static Mya_Agents mya_FetchAPIDetail(String jsonData)
    {
        Mya_AgentApiPayload JD;
        JD = (Mya_AgentApiPayload) JSON.deserialize(jsonData, Mya_AgentApiPayload.class);

        List<Mya_AgentApiPayload.Agents> AgentDetails = New List<Mya_AgentApiPayload.Agents>();
        AgentDetails = JD.agents;
        
        Mya_Agents AgentData = new Mya_Agents();
        AgentData.zipcode = JD.zipcode;
        AgentData.has_home_delivery = JD.has_home_delivery;
        AgentData.has_small_package = JD.has_small_package;
        AgentData.has_sds_delivery = JD.has_sds_delivery;
        AgentData.is_will_call = JD.is_will_call;
        AgentData.has_will_call = JD.has_will_call;

        List<Mya_AgentDetails> AD = new List<Mya_AgentDetails>();
        for(Mya_AgentApiPayload.Agents EA:AgentDetails)
        {
            Mya_AgentDetails A = new Mya_AgentDetails();
            A.address = EA.address;
            A.agent_id = EA.agent_id;
            A.city = EA.city;
            A.display_name = EA.display_name;
            A.method = EA.name;
            A.name = EA.name;
            A.phone = EA.phone;
            A.state = EA.state;
            A.zipcode = EA.zipcode;
            AD.add(A);
        }
        AgentData.agents = AD;
        return AgentData;
    }
}