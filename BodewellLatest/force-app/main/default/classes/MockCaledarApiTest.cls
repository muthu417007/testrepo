@isTest
global class MockCaledarApiTest implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
        try{
        if (req.getEndpoint().contains('Bwc_ZipServiceAPI')) {
            BWC_AgentResponseWrapper agentResponse = new BWC_AgentResponseWrapper();
            agentResponse.zipcode = '12345';
            agentResponse.has_home_delivery = false;
            agentResponse.is_will_call = true;
            agentResponse.agents = new List<BWC_AgentResponseWrapper.Wrapper>();
            BWC_AgentResponseWrapper.Wrapper agent = new BWC_AgentResponseWrapper.Wrapper();
            agent.zipcode = '12345';
            agent.address = '123 Main St';
            agent.method = 'Method';
            agent.agent_id = 'Agent123';
            agent.phone = '123-456-7890';
            agent.city = 'City';
            agent.name = 'Agent Name';
            agent.state = 'CA';
            agent.display_name = 'Display Name';
            agent.v_code = 'V123';
            agent.loc_type = 'Type';
            agentResponse.agents.add(agent);

            String agentResponseJSON = JSON.serialize(agentResponse);

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(agentResponseJSON);
            res.setStatusCode(200);
            return res;
        }
        else if (req.getEndpoint().contains('Bwc_CalenderAPI')) {
            BWC_CalendarResponseWrapper calendarResponse = new BWC_CalendarResponseWrapper();
            calendarResponse.success = true;
            calendarResponse.responseMessage = 'Success';
            calendarResponse.zipcode = '12345';
            calendarResponse.state = 'CA';
            calendarResponse.mode = 'HD';
            calendarResponse.startDate = 'YYYY-MM-DD';
            calendarResponse.noOfDays = 31;
            calendarResponse.calendar_dates = new List<BWC_CalendarResponseWrapper.CalendarDate>();
            BWC_CalendarResponseWrapper.CalendarDate calendarDate = new BWC_CalendarResponseWrapper.CalendarDate();
            calendarDate.stdate = 'YYYY-MM-DD';
            calendarDate.available = true;
            calendarResponse.calendar_dates.add(calendarDate);

            String calendarResponseJSON = JSON.serialize(calendarResponse);

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(calendarResponseJSON);
            res.setStatusCode(200);
            return res;
        }

        HttpResponse defaultRes = new HttpResponse();
        defaultRes.setStatusCode(200);
        return defaultRes;
    }catch(Exception e){
        System.debug('errorLineNumber>>>'+e.getLineNumber());
        return null;
    }
    }
    }