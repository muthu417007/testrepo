public class SMCBridgeCase{
    Public String smcUrl {get;set;}
    Public Case c{get;set;}


    public SMCBridgeCase(ApexPages.StandardController stdController) {
        this.c= (Case)stdController.getRecord();
        c = [SELECT Id,contactId,contact.phone,caseNumber,contact.lastName,
             contact.firstName,contact.email,account.billingStreet,account.BillingCity,
             account.BillingState,account.BillingPostalCode,contact.mobilephone,account.region__c,
             account.zone__c
             FROM case
             WHERE id =: c.id LIMIT 1]; 
       
    }

    public PageReference redirect() {
        String reasonForConcession = '';
     	if(c.account.region__c == null  || string.isBlank(c.account.zone__c )){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Location missing zone/region, please click Update Location Zone/Region button.'));
            return null;
        }
        //get consumer number
        //case --> ContactId --> Contact_Information__c  id type = GE Consumer Number field value identifier
        
        List<Contact_Information__c> contactInfoRecs = [SELECT ID,Identifier__c,ID_Type__c
                                                       FROM Contact_Information__c
                                                       WHERE Contact__c =: c.contactId
                                                       AND Identifier__c != NULL
                                                       AND  (NOT  Identifier__c like '999999%')
                                                       AND ID_Type__c ='GE Consumer Number'];
        Long consumerNumber = 0;
        for(Contact_Information__c ci : contactInfoRecs){
            if(long.valueOf(ci.Identifier__c) > consumerNumber){
                consumerNumber = long.valueOf(ci.Identifier__c);
            }
        }
        
        //if consumerNumber == 0 go get a consumerNumber
        ////Get CN1 consumer number
        if(consumerNumber == 0){
            User u = [Select SSO_ID__c from User where Id =: UserInfo.getUserId() LIMIT 1];
            contact CN1Contact = new contact();
            CN1Contact.lastName = c.contact.lastName;
            CN1Contact.firstName = c.contact.firstName;
            CN1Contact.Phone = c.contact.phone;
            CN1Contact.Email = c.contact.email;
            account a = new account();
            a.BillingStreet = c.account.billingStreet;
            a.BillingCity =  c.account.BillingCity;
            a.BillingPostalCode = c.account.BillingPostalCode;
            a.BillingState = c.account.BillingState;
            CN1Response CN1Resp = Utility.CN1CustomerNumber(CN1Contact, u.SSO_ID__c, a);
            
            if(CN1Resp.ConsumerNo == null){
                 apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Error occured creating GE Consumer Number please try again.' + CN1Resp.ErrorMessage));
                 return null; 
            }
            
            //create Consumer Number rec
            Contact_Information__c  newCI = new Contact_Information__c ();
            newCI.ID_Type__c = 'GE Consumer Number';
            newCI.Contact__c =c.contactId;
            newCI.Identifier__c = CN1Resp.ConsumerNo;
            insert newCI;
            consumerNumber = integer.valueOf(CN1Resp.ConsumerNo);
        }
        //get asset info
        List<Case_Asset__c> assets = [SELECT ID, Serial_Number__c,Model_Number__c
                                        FROM Case_Asset__c
                                        WHERE Case__c = :c.id];
                                        
        String serialNumber = '';
        String modelNumber = '';
        if(assets.size() > 0){
            serialNumber = assets[0].Serial_Number__c;
            modelNumber = assets[0].Model_Number__c;
        }   
        
        String cPhone = c.contact.phone;
        If(string.isBlank(c.contact.phone)){
            cPhone = c.contact.mobilePhone;
        }
       
        smcUrl = 'http://localhost:85/BridgeSMC.aspx?val1=';
        smcUrl = smcUrl + cPhone + '00000(|)';     //consumer phone number 
        smcUrl = smcUrl + c.CaseNumber  + '(|)';    //incident id 
        smcUrl = smcUrl + c.CaseNumber  + '(|)'; //task id
        smcUrl = smcUrl + '(|)';
        smcUrl = smcUrl + '(|)';//concession code 
        smcUrl = smcUrl + consumerNumber + '(|)';//consumer number - get highest number
        smcUrl = smcUrl + modelNumber  + '(|)';//model number 
        smcUrl = smcUrl + serialNumber  + '(|)';//serial number
        smcUrl = smcUrl + '(|)';//concession account 
        smcUrl = smcUrl + '0' ;//conf number = 0
        smcUrl = smcUrl + '&val2=&val3=ACTConcession_RN&val4=';
        
        PageReference pageRef = new PageReference(smcUrl);
        pageRef.setRedirect(false);
        return pageRef;
    }
       
}