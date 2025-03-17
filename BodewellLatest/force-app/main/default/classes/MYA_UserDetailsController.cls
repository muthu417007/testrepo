/**
 * @author         Akhil Raj
 * @company        TCS
 * @created        25.04.2022
 * @description    For manage user deatils
 */
public without sharing class MYA_UserDetailsController {
    public MYA_UserDetailsController() {
        System.debug(LoggingLevel.WARN, 'MYA_UserDetailsController');
    }
	// For getting user deatils
    @AuraEnabled(cacheable=true)
    public static List<User> getUserDetails(String UserId) {
        return [SELECT Id,Name,FirstName,LastName,Email,ContactId,Customer_IdP_Session_Id__c FROM User WHERE Id=:UserId];
    }
	// For getting user contact deatils
    @AuraEnabled(cacheable=false)
    public static List<Contact> getContactDetails(String ContactId) {
        return [SELECT Id, Name, FirstName, LastName, Email, AccountId from Contact WHERE Id=:ContactId];
    }
    // For Saving new contact
    @AuraEnabled(cacheable=false)
    public static Contact_Point__c createContact(String contactId, String phone, Boolean isPrimary ) {  
        Boolean myaIncluded = true;
        Boolean myaDeleted = true;
        Contact_Point__c response = new Contact_Point__c();        
        if(isPrimary == true) {
       		List<Contact_Point__c> cp = setPrimaryOnCreate(contactId);
        }
        List<Contact_Point__c> res = [SELECT Id, Contact__c, MYA_IsDeleted__c, MYAISPrimary__c FROM Contact_Point__c WHERE Phone__c=:phone AND Contact__c=:contactId AND MYA_Included__c=:myaIncluded AND MYA_IsDeleted__c=:myaDeleted];
        if (res.size() > 0) {
            Contact_Point__c con = res[0];
            con.MYA_IsDeleted__c = false;
            con.MYAISPrimary__c = isPrimary;
            update con;
            response = con;
        } else {
         	Contact_Point__c contact = new Contact_Point__c();
            contact.Contact__c = contactId;
            contact.Phone__c = phone;
            contact.MYA_Included__c = true;
            contact.MYAISPrimary__c = isPrimary;
            insert contact;
            response = contact;
        }
        return response;
    }   
	// For getting user contact point deatils
    @AuraEnabled(cacheable=false)
    public static List<Contact_Point__c> getContactPointByContactId(String ContactId) {
        Boolean MyaIncluded = true;
        Boolean MyaDeleted = false;
        List<Contact_Point__c> Res = [SELECT Id, Contact__c, ContactType__c, Phone__c, Email__c, MYAISPrimary__c  FROM Contact_Point__c WHERE Contact__c=:ContactId AND MYA_Included__c=:MyaIncluded AND MYA_IsDeleted__c=:MyaDeleted ORDER BY CreatedDate];
        return Res;
    }
	// For setting user primary contact point on delete existing primary contact
    @AuraEnabled(cacheable=false)
    public static List<Contact_Point__c> setPrimaryOnDelete(String ContactId) {        
        Boolean MyaIncluded = true;
        Boolean MyaDeleted = false;
        List<Contact_Point__c> Cons = [SELECT Id, MYAISPrimary__c  FROM Contact_Point__c WHERE Contact__c=:ContactId AND MYA_Included__c=:MyaIncluded AND MYA_IsDeleted__c=:MyaDeleted LIMIT 1];
        if (Cons.size() > 0) {
            Contact_Point__c Con = Cons[0];
            Con.MYAISPrimary__c = true;
            update Con;
        }
        return Cons;            
    }
	// For setting old primary contact point to false on new primary contact point creation
    @AuraEnabled(cacheable=false)
    public static List<Contact_Point__c> setPrimaryOnCreate(String ContactId) {
        Boolean isPrimary = true;
        Boolean MyaIncluded = true;
        Boolean MyaDeleted = false;
        List<Contact_Point__c> Cons = [SELECT Id, MYAISPrimary__c FROM Contact_Point__c WHERE Contact__c=:ContactId AND MYAISPrimary__c=:isPrimary AND MYA_Included__c=:MyaIncluded AND MYA_IsDeleted__c=:MyaDeleted LIMIT 1];
        if (Cons.size() > 0) {
            Contact_Point__c Con = Cons[0];
            Con.MYAISPrimary__c = false;
            update Con;
        }         
        return Cons;
    }
	// For getting user contact deatils by user id
    @AuraEnabled(cacheable=false)
    public static List<Contact> getContactDetailsByUserId() {
        String Id = UserInfo.getUserId();
        return [SELECT Id, Name, FirstName, LastName, Email from Contact WHERE CreatedById=:Id ORDER BY CreatedDate];
    }
	// For getting user contact point deatils by user id
    @AuraEnabled(cacheable=false)
    public static List<Contact_Point__c> getContactPointByUserId() {
        String Id = UserInfo.getUserId();
        Boolean MyaIncluded = true;
        Boolean MyaDeleted = false;
        List<Contact_Point__c> Res = null;
        List<Contact> Cons = [SELECT Id, Name, FirstName, LastName, Email from Contact WHERE CreatedById=:Id ORDER BY CreatedDate];
        if(Cons.size() > 0) {
            Contact Con = Cons[0];
            Res = [SELECT Id, Contact__c, ContactType__c, Phone__c, Email__c, MYAISPrimary__c from Contact_Point__c WHERE Contact__c=:Con.Id AND MYA_Included__c=:MyaIncluded AND MYA_IsDeleted__c=:MyaDeleted ORDER BY CreatedDate];
        }        
        return Res;
    }
    
    public class EmailUpdateResponse {
        @AuraEnabled public Object Data;
        @AuraEnabled public String Message;
        @AuraEnabled public Boolean Success;
    }
    
    // For Editing email address
    @AuraEnabled(cacheable=false)
    public static EmailUpdateResponse updateEmail(String contactId, String email) {  
        EmailUpdateResponse res = new EmailUpdateResponse();
        
        List<Contact> conList = [SELECT Id, Email from Contact WHERE Email=:email AND Id!=:contactId];
        if(conList.size() > 0) {
            res.Success = false;
            res.Message = 'Email already exist';
        } else {
            List<Contact> cons = [SELECT Id, Email from Contact WHERE Id=:contactId];
            if(cons.size() > 0) {
                Contact con = cons[0];
                con.Email = email;
                update con;
                res.Success = true;
            	res.Message = 'Email updated';
                res.Data = con;
            } else {
                res.Success = false;
            	res.Message = 'Contact not found';
            }
        } 
        return res;
    } 
    
    @AuraEnabled(cacheable=false)
    public static TwoFactorMethodsInfo twoFactorMethodsInfo(String userId) {
        TwoFactorMethodsInfo info = [SELECT Id, HasUserVerifiedEmailAddress FROM TwoFactorMethodsInfo WHERE UserId=:userId LIMIT 1];
        return info;
    }
    
    @AuraEnabled(cacheable=false)
    public static Boolean sendEmailVerification(String userId, String experienceName, String callbackUrl) {
        try {
            PS_SendVerificationWebServiceHelper.sendEmailVerification(
                    userId,
                    null,
                    experienceName,
                    callbackUrl
            );        
        	return true;
        } catch (Exception e) {            	
    		throw e;
        }    
        
    }
     @AuraEnabled(cacheable=false) 
    public static void updateContactPoint(String updatedContactPointIds) 
    {
        Id updatedContactPointId = Id.valueOf(updatedContactPointIds);
        List<Contact_Point__c> relatedContactPoints = [Select Id, MYAISPrimary__c, Contact__c FROM Contact_Point__c
                                                     WHERE Contact__C =: [SELECT Id, Contact__c FROM Contact_Point__c WHERE Id =: updatedContactPointId LIMIT 1].Contact__c];
        for(Contact_Point__c eachCP: relatedContactPoints)
        {
            if(eachCP.Id != updatedContactPointId)
            {
                eachCP.MYAISPrimary__c = false;
            }
            else
                eachCP.MYAISPrimary__c = true;
        }
        update relatedContactPoints;
    }
}