/**
* @author         Akhil Raj
* @company        TCS
* @created        22.09.2022
* @description    For user deactivation
*/
public with sharing class MYA_DeleteAccountHandler {    
    // Deactivate user
    @AuraEnabled(cacheable=false)
    public static DeactivateResponse deactivate() {
        DeactivateResponse response = new DeactivateResponse();
        try	{
            Id userId=UserInfo.getUserId();            
            list<User> users = [SELECT Id, ContactId, IsPortalEnabled, IsActive FROM User WHERE Id=:userId];
            Boolean doDeactivation = true;
            if(users.isEmpty()){ 
                doDeactivation = false;
            }   
            if(doDeactivation == true) {                
                User currentUser = users.get(0);         
                contactInactivateMethod(currentUser.ContactId);
                userFutureMethod(currentUser.Id); 
            }
            response.Success = true;
            return response;
        } catch(Exception e) {
            response.Success = false;
            return response;
        }            
    }
    // No Data found Exception
    @TestVisible
    private class NoDataFoundException extends Exception {
    }
    // Future method for user deactivation
    @future 
    Private static void userFutureMethod(ID userid){
        try{
            if(userid != null) {
                User currentUser = [Select Id, IsActive from User where Id = :userid];
                if(currentUser != null) {                
                    currentUser.IsActive = false;
                    update currentUser; 
                }
            }            
        } 
        catch(Exception e){
            throw e;
        }
    }
    // Contact inactivation method
    Private static void contactInactivateMethod(ID contactId){
        system.debug('in contactInactivateMethod');
        try{
            if(contactId != null) {
                List<GEA_AccountContactRelation__c> aList = [SELECT Id,Name,MYA_Included__c from GEA_AccountContactRelation__c where Contact__c=:contactId AND MYA_Included__c=true];
                system.debug('aList'+aList);
                List<Contact> conList = [SELECT id,Is_Portal_User__c from contact where id=:contactId];  
                if(conList.size()>0)
                {
                    for(Contact con: conList)
                    { if(con.Is_Portal_User__c)
                    {
                        con.Is_Portal_User__c=false;
                    }
                    }
                    update conList;
                }
                Boolean doUpdate = true;
                if(aList.isEmpty()){ 
                    doUpdate = false;
                } 
                if(doUpdate == true) {
                    for(GEA_AccountContactRelation__c item: aList) {
                        item.MYA_Included__c = false;
                    }
                    update aList;
                }   
            }                       
        } catch(Exception e){
            system.debug('Exception'+e);
            throw e;
        }
    }    
    // Asset creation method response
    public class DeactivateResponse {
        @AuraEnabled public Boolean Success;
    }
}