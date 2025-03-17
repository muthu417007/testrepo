@isTest
public class BWC_ShippingResponseWrapperTest {
    @isTest
    public static void testWrapper() {
        // Create test data
        BWC_ShippingResponseWrapper.AgentClass agent1 = new BWC_ShippingResponseWrapper.AgentClass();
        agent1.zipcode = '12345';
        agent1.address = '123 Main St';
        agent1.method = 'Home Delivery';
        agent1.agent_id = 'A001';
        agent1.phone = '555-1234';
        agent1.city = 'City A';
        agent1.name = 'Agent A';
        agent1.state = 'State A';
        agent1.display_name = 'Agent A - Home Delivery';
        agent1.v_code = 'V001';
        agent1.loc_type = 'Residential';

        BWC_ShippingResponseWrapper.AgentClass agent2 = new BWC_ShippingResponseWrapper.AgentClass();
        agent2.zipcode = '67890';
        agent2.address = '456 Elm St';
        agent2.method = 'Will Call';
        agent2.agent_id = 'A002';
        agent2.phone = '555-5678';
        agent2.city = 'City B';
        agent2.name = 'Agent B';
        agent2.state = 'State B';
        agent2.display_name = 'Agent B - Will Call';
        agent2.v_code = 'V002';
        agent2.loc_type = 'Commercial';

        List<BWC_ShippingResponseWrapper.AgentClass> agents = new List<BWC_ShippingResponseWrapper.AgentClass>();
        agents.add(agent1);
        agents.add(agent2);

        BWC_ShippingResponseWrapper wrapper = new BWC_ShippingResponseWrapper();
        wrapper.zipcode = '12345';
        wrapper.is_will_call = false;
        wrapper.has_will_call = true;
        wrapper.sds_ap_zone = 'SDS Zone A';
        wrapper.hd_ap_zone = 'HD Zone A';
        wrapper.mt_ap_zone = 'MT Zone A';
        wrapper.agents = agents;

        // Test the values of the wrapper object
        System.assertEquals('12345', wrapper.zipcode);
        System.assertEquals(false, wrapper.is_will_call);
        System.assertEquals(true, wrapper.has_will_call);
        System.assertEquals('SDS Zone A', wrapper.sds_ap_zone);
        System.assertEquals('HD Zone A', wrapper.hd_ap_zone);
        System.assertEquals('MT Zone A', wrapper.mt_ap_zone);
        System.assertEquals('12345', wrapper.agents[0].zipcode);
        System.assertEquals('123 Main St', wrapper.agents[0].address);
        System.assertEquals('Home Delivery', wrapper.agents[0].method);
        System.assertEquals('A001', wrapper.agents[0].agent_id);
        System.assertEquals('555-1234', wrapper.agents[0].phone);
        System.assertEquals('City A', wrapper.agents[0].city);
        System.assertEquals('Agent A', wrapper.agents[0].name);
        System.assertEquals('State A', wrapper.agents[0].state);
        System.assertEquals('Agent A - Home Delivery', wrapper.agents[0].display_name);
        System.assertEquals('V001', wrapper.agents[0].v_code);
        System.assertEquals('Residential', wrapper.agents[0].loc_type);
    }
}