global class MedalliaUserHierarchy {
    @InvocableMethod
    global static void userHierarchy(List<id> userList){
        System.debug('user list is '+userList);
        
        
        List<Map<Object,Object>> userInfo=new List<Map<Object,Object>>();
        for(User u: [select id,isactive,location__c,team_lead__r.name,team_lead__r.sso_id__c,sso_id__c,firstname,lastname,team_persona__c from user where id in :userList])
        {	System.debug('team lead name is '+u.team_lead__r.name);
         	System.debug('team lead name is '+u.team_lead__r.sso_id__c);
            Map<Object, Object> MyStrings = new Map<Object, Object>{'firstName' =>u.FirstName , 'lastName' => u.LastName, 'ssoId'=> u.SSO_ID__c, 'teamLeadName'=> u.Team_Lead__r.name, 'teamLeadSSOId'=> u.Team_Lead__r.sso_id__c, 'location'=>u.Location__c,  'teamPersona' => u.Team_Persona__c,'isActive'=>u.IsActive};
            userInfo.add(MyStrings);         	
        } 
        System.debug('values'+userInfo);
        String userData = JSON.serialize(userInfo);
		system.debug('JSON String is ' + userData);
        requestMuleData(userData);
        
      
        //System.debug('resposne is:  '+res);
        
    }
    
    @future(callout=True)
    global static void requestMuleData(String userData){
        String res;
        if(!utility.isSandbox){
            res=RequestMuleAPIData.getMuleAPIData('Production_MuleAuth','Medallia_Token','Production_Medallia_UserHierarchy',null,'POST',userData);
        } else {
            res=RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Medallia_Token','Sandbox_Medallia_UserHierarchy',null,'POST',userData);
        }
        System.debug('response is '+res);
        //return res;
    }
}