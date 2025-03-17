@isTest
public class MedalliaUserHierarchy_Test {
    
    static testmethod void sendUserData(){
        List <id> ids= new List<id>();
        User u= [SELECT id FROM User where team_persona__c ='PSS' limit 1];
        ids.add(u.id);
        MedalliaUserHierarchy.userHierarchy(ids);
        //System.assertNotEquals(null, res);
    }
}