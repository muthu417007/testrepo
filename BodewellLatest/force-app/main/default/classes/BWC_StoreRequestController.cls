//******************************************************************************************
// Author:       Akhil M R
// Company:      TCS
// Created Date: 11/06/2023
//******************************************************************************************
//@description : Apex Class to handle Store requests
public without sharing class BWC_StoreRequestController {
	//@description : Response Class to handle Store requests
    public class BWC_StoreRequestResponse {
        @AuraEnabled public Boolean success;
        @AuraEnabled public Object data;
    	@AuraEnabled public Object error;
    
        public BWC_StoreRequestResponse(Boolean success, Object data, Exception error) {
            this.success = success;
            this.data = data;
            this.error = error;
        }
    }
    //@description : Method to request coupon from LWC
    @AuraEnabled
    public static BWC_StoreRequestResponse requestCoupon(String firstName, String lastName, String email, String phone, String appDate, String appTime, Boolean sendText, String dealerId, String productId) 
    {
        try 
        {      
            List<Account> consumerAcc = new List<Account>();
            Referral__c refObj = new Referral__c();            
            if(email != null) {
            	consumerAcc = [SELECT Id, FirstName,LastName,Email__c,Phone,IsBuyer FROM Account WHERE RecordType.Name = 'Person Account' AND Email__c=:email AND LastName=:lastName AND FirstName=:firstName];
            }            
            if(consumerAcc.size() > 0) {   
                if(consumerAcc[0].IsBuyer == false) {                     
                	BuyerAccount buyerAccountObj = createBuyerAccount(consumerAcc[0]);
                }
                BuyerGroupMember bgmObj = assignBuyerGroup(consumerAcc[0]); 
            	Opportunity oppObj = createOpportunity(firstName, lastName);
                refObj = createReferral(firstName,lastName,email,phone,appDate,appTime,sendText,consumerAcc[0].Id,dealerId,productId,oppObj.Id);
            } else {
                Account consumerObj = createConsumer(firstName, lastName, email, phone); 
                BuyerAccount buyerAccountObj = createBuyerAccount(consumerObj);
                BuyerGroupMember bgmObj = assignBuyerGroup(consumerObj);
            	Opportunity oppObj = createOpportunity(firstName, lastName);
                refObj = createReferral(firstName,lastName,email,phone,appDate,appTime,sendText,consumerObj.Id,dealerId,productId,oppObj.Id);
            }
            return new BWC_StoreRequestResponse(true,refObj.Name,Null);
            //return new BWC_StoreRequestResponse(true,Null,Null);
        } catch(Exception ex) {
            return new BWC_StoreRequestResponse(false,Null,ex);
        }
    }
    //@description : Method to create referral
    public static Referral__c createReferral(String firstName, String lastName, String email, String phone, String appDate, String appTime, Boolean sendText, String consumerId, String dealerId, String productId, String oppId) {
        Referral__c refObj = new Referral__c();
        refObj.Name =  lastName + ' ' + firstName + ' - Bodewell Lead Exchange';
        if(oppId != null) {
            refObj.Opportunity__c = oppId;
        }
        if(email != null) {
        	refObj.Consumer_Email__c = email;                
        }
        if(phone != null) {
        	refObj.Consumer_Phone__c = phone;                
        }
        if(sendText != null) {
        	refObj.Send_Text__c = sendText;                
        }
        if(appDate != null) {
            String [] dateVal = appDate.split('-');
            Integer year = integer.valueof(dateVal[0]);
            Integer month = integer.valueof(dateVal[1]);
            Integer day = integer.valueof(dateVal[2]);
            Date formattedDate = date.newinstance(year, month, day);
        	refObj.Consumer_Preferred_Date__c = formattedDate;                
        }
        if(appTime != null) {
            String [] timeVal = appTime.split(':');
            Integer hour = Integer.valueof(timeVal[0]);
            Integer min = Integer.valueof(timeVal[1]);
            Time formattedTime = Time.newInstance(hour, min, 0, 0);
        	refObj.Consumer_Preferred_Time__c = formattedTime;                
        }
        if(dealerId != null) {
        	refObj.Partner_Account__c = dealerId;                
        }
        if(productId != null) {
        	refObj.Product_Interested__c = productId;
      	}
        if(consumerId != null) {
        	refObj.Consumer_Account__c = consumerId;                
        }
        refObj.Coupon_Code__c = BWC_LeadExchangeHelper.getGuId();
        refObj.LeadSource__c = 'Web';
        insert refObj;            
        return refObj;
    }
    //@description : Method to create consumer account for the referral
    public static Account createConsumer(String firstName, String lastName,String email, String phone) {
		Account refConsumer = new Account();
        refConsumer.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        if(firstName != null) {
         	refConsumer.FirstName = firstName;
      	}
        if(lastName != null) {
            refConsumer.LastName = lastName;
        }
        if(email != null) {
            refConsumer.Email__c = email;
        }
        if(phone != null) {
            refConsumer.Phone = phone;
        }
        insert refConsumer; 
        return refConsumer;
    }
    //@description : Method to create oportunity for the referral
    public static Opportunity createOpportunity(String firstName, String lastName) {
        Opportunity opp = new Opportunity();
        opp.CloseDate=date.today().addDays(1);
        opp.Name='Bodewell Lead Exchange - ' + firstName + ' ' + lastName;
        opp.LeadSource='Bodewell Store Lead Exchange';
		opp.StageName='New';
        insert opp;
        return opp;
    }
    //@description : Method to create oportunity for the referral
    public static BuyerAccount createBuyerAccount(Account consumer) { 
        BuyerAccount buyerAccount = new BuyerAccount();
        buyerAccount.IsActive = true;
        buyerAccount.Name = consumer.LastName + ' ' + consumer.FirstName;
        buyerAccount.BuyerId = consumer.Id;
        insert buyerAccount;
        return buyerAccount;
    }
    //@description : Method to create oportunity for the referral
    public static BuyerGroupMember assignBuyerGroup(Account consumer) {
        BuyerGroupMember bgm = new BuyerGroupMember();
        if([SELECT Id FROM BuyerGroupMember WHERE BuyerId = :consumer.Id ].size() == 0) {
            bgm.BuyerId = consumer.Id;
        	bgm.BuyerGroupId = [SELECT Id FROM BuyerGroup Where Name = 'Bodewell Lead Exchange Buyer Group'].Id;
        	insert bgm;                    
        }        
        return bgm;
    }
}