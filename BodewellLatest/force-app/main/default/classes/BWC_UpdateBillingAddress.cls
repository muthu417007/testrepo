/**
* @author Abhishek
* @date 04/08/2023
* @description This class is to check billing address of the login user in EBS.
*/
public class BWC_UpdateBillingAddress {
    /**
* This method is used to update billing contact point addresss of the login user which is not present in the EBS.
* @param
* @return - Boolean
*/
    @AuraEnabled 
    public static Boolean checkAndHitUpdateConsumer(){
        try{
            BWC_SearchConsumerPayloadWrapper.BWC_SearchConsumerPayloadResponseWrapper searchAndConsumerPayloadInstance = new BWC_SearchConsumerPayloadWrapper.BWC_SearchConsumerPayloadResponseWrapper();
            searchAndConsumerPayloadInstance = BWC_SearchConsumerPayloadWrapper.getConsumerDetail('Billing','BILL_TO');
            System.debug('searchAndConsumerPayloadInstance.shipToOrgId-->'+searchAndConsumerPayloadInstance.shipToOrgId);
            List<User> userList = [SELECT Id,
                                   AccountId,
                                   Account.BWC_Consumer_Number__c
                                   FROM User 
                                   WHERE Id =:UserInfo.getUserId() 
                                   LIMIT 1];
            
            List<ContactPointAddress> contactPointAddressList = [SELECT Id,
                                                                 Name,
                                                                 BWC_Ship_To_Org_Id__c,
                                                                 BWC_Bill_To_Org_Id__c,
                                                                 BWC_Account_Number__c,
                                                                 Street, 
                                                                 City, 
                                                                 State, 
                                                                 PostalCode, 
                                                                 Country 
                                                                 FROM ContactPointAddress 
                                                                 WHERE IsDefault = True 
                                                                 AND AddressType = 'Billing'
                                                                 AND ParentId =: userList[0].AccountId
                                                                 LIMIT 1];
            
            contactPointAddressList[0].BWC_Bill_To_Org_Id__c = searchAndConsumerPayloadInstance.shipToOrgId;
            update contactPointAddressList;
            return true;
        }
        catch(Exception e){
            System.debug('checkAndHitUpdateConsumer-->'+e.getMessage());
            System.debug('checkAndHitUpdateConsumer line number-->'+e.getLineNumber());
            return false;
        }
    }
}