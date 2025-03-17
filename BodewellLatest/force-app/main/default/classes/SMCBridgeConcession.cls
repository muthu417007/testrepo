public class SMCBridgeConcession{
    Public String smcUrl {get;set;}
    Public Concession__c c{get;set;}
    String concessionAccount;
//    public SMCBridgeConcession() {
//        smcUrl = '';   
//    }
    

    public SMCBridgeConcession(ApexPages.StandardController stdController) {
        this.c= (Concession__c)stdController.getRecord();
        c = [SELECT Name,Consumers_Phone_f__c,case__r.CaseNumber,Confirmation_Number__c,Concession_Code_f__c,Asset_Model_f__c,
             Asset_Serial_f__c,Concession_Account_f__c,Reason_For_Concession__c,case__r.contactId,
             Case_Asset__r.model_number__c, Case_Asset__r.serial_number__c,Percent_Labor_Covered__c ,
             Percent_Parts_Covered__c  ,Waive_Home_Call__c ,No_Charge_Service__c,case__r.contact.firstName,
             case__r.contact.lastName,case__r.contact.phone,case__r.contact.email,concession_location__r.billingStreet,
             concession_location__r.billingCity,concession_location__r.billingState,concession_location__r.billingPostalCode,
             concession_location__r.region__c,concession_location__r.zone__c,Case_Asset__c,Case_Asset__r.Asset__c
             FROM concession__c 
             WHERE id =: c.id LIMIT 1]; 
        

    }

    public PageReference redirect() {

        String discountValue = '';
        if(c.Percent_Parts_Covered__c != null){
            //discountValue = 'DiscParts:' + c.Percent_Parts_Covered__c.subString(0,c.Percent_Parts_Covered__c.length()-1);
            //discountValue = 'DiscParts:' + c.Percent_Parts_Covered__c.subString(0,c.Percent_Parts_Covered__c.length());
            discountValue = 'DiscParts:' + c.Percent_Parts_Covered__c;
        } else {
            discountValue = 'DiscParts:';
        }
        if(c.Percent_Labor_Covered__c != null){
            //discountValue = discountValue + 'DiscLabor:' + c.Percent_Labor_Covered__c.subString(0,c.Percent_Labor_Covered__c.length()-1);
            //discountValue = discountValue + 'DiscLabor:' + c.Percent_Labor_Covered__c.subString(0,c.Percent_Labor_Covered__c.length());
            discountValue = discountValue + 'DiscLabor:' + c.Percent_Labor_Covered__c;
        } else {
            discountValue = discountValue + 'DiscLabor:';
        }
        
        //DiscParts:50%DiscLabor:25%ConcType:FSDISC
        String reasonForConcession = '';
        if(c.Percent_Parts_Covered__c == null && c.Percent_Labor_Covered__c != null 
        	&& c.No_Charge_Service__c != 'Yes' && c.Waive_Home_Call__c != 'Yes'){
           		reasonForConcession = 'FS - Labor'; 
                if(c.Percent_Labor_Covered__c != '100%'){
                    discountValue = discountValue + 'ConcType:FSDISC';
                    //reasonForConcession = 'FS Discount';  
                }
        } else if(c.Percent_Parts_Covered__c == null && c.Percent_Labor_Covered__c != null 
        	&& c.No_Charge_Service__c != 'Yes' && c.Waive_Home_Call__c == 'Yes'){
           		reasonForConcession = 'FS - Labor ' + '%26' + ' Home Call'; 
        } else if(c.Percent_Parts_Covered__c != null && c.Percent_Labor_Covered__c != null 
        	&& c.No_Charge_Service__c != 'Yes' && c.Waive_Home_Call__c != 'Yes'){
           		reasonForConcession = 'FS - Labor ' + '%26' + ' Parts'; 
                Integer partsAmount = integer.valueOf(c.Percent_Parts_Covered__c.replace('%',''));
                Integer laborAmount = integer.valueOf(c.Percent_Labor_Covered__c.replace('%',''));
                if((partsAmount + laborAmount) < 100){  
                    discountValue = discountValue + 'ConcType:FSDISC';
                    //reasonForConcession = 'FS Discount';  
                }
        } else if(c.Percent_Parts_Covered__c == null && c.Percent_Labor_Covered__c == null 
        	&& c.No_Charge_Service__c == 'Yes' && c.Waive_Home_Call__c != 'Yes'){
           		reasonForConcession = 'FS - No Charge Srvc'; 
        } else if(c.Percent_Parts_Covered__c != null && c.Percent_Labor_Covered__c == null 
        	&& c.No_Charge_Service__c != 'Yes' && c.Waive_Home_Call__c != 'Yes'){
           		reasonForConcession = 'FS - Parts'; 
                if(c.Percent_Parts_Covered__c != '100%'){
                    discountValue = discountValue + 'ConcType:FSDISC';
                    //reasonForConcession = 'FS Discount';  
                }
        } else if(c.Percent_Parts_Covered__c != null && c.Percent_Labor_Covered__c == null 
        	&& c.No_Charge_Service__c != 'Yes' && c.Waive_Home_Call__c == 'Yes'){
           		reasonForConcession = 'FS - Parts ' + '%26' + ' Home Call'; 
        } else if(c.Percent_Parts_Covered__c == null && c.Percent_Labor_Covered__c == null 
        	&& c.No_Charge_Service__c != 'Yes' && c.Waive_Home_Call__c == 'Yes'){
           		reasonForConcession = 'FS - Waive Home Call'; 
        }
        
        String concessionCode = c.Concession_Code_f__c;
        String concessionAccount = c.Concession_Account_f__c.replaceAll('-','');
        
        if(c.Waive_Home_Call__c !='Yes' && c.No_Charge_Service__c != 'Yes'){
            //concessionCode = '';
            //concessionAccount = '';
        }
        if(reasonForConcession ==''){
            //apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Reason for concession could not be determined.'));
            //return null;
        }
        List<Contact_Information__c> contactInfoRecs = [SELECT ID,Identifier__c,ID_Type__c
                                                       FROM Contact_Information__c
                                                       WHERE Contact__c =: c.case__r.contactId
                                                       AND ID_Type__c ='GE Consumer Number'
                                                       AND  (NOT  Identifier__c like '999999%')
                                                       AND Identifier__c != NULL];
		
        String consumerNumber = Utility.findGeConsumerNumber(c.case__r.contactId, c.Case_Asset__r.Asset__c);
        if(!consumerNumber.isNumeric()){
         	apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Error getting consumer number. ' + consumerNumber));
            return null;   
        }             
        smcUrl = 'http://localhost:85/BridgeSMC.aspx?val1=';
        smcUrl = smcUrl + c.Consumers_Phone_f__c + '00000(|)';     //consumer phone number 
        smcUrl = smcUrl + c.case__r.CaseNumber  + '(|)';    //incident id 
        smcUrl = smcUrl + c.name.substring(2,c.name.length()) + '(|)'; //task id
        //smcUrl = smcUrl + c.Reason_For_Concession__c + '(|)'; //reason for concesission 
        smcUrl = smcUrl + reasonForConcession + '(|)';
        smcUrl = smcUrl + concessionCode + '(|)';//concession code 
        smcUrl = smcUrl + consumerNumber + '(|)';//consumer number - get highest number
        smcUrl = smcUrl + c.Case_Asset__r.model_number__c  + '(|)';//model number 
        smcUrl = smcUrl + c.Case_Asset__r.serial_number__c  + '(|)';//serial number
        smcUrl = smcUrl + concessionAccount + '(|)';//concession account 
        if(c.Confirmation_Number__c != null && c.Confirmation_Number__c != '')
        {
            smcUrl = smcUrl + c.Confirmation_Number__c;
        }
        else
        {
            smcUrl = smcUrl + '0';
        }
        //conf number = 0 for new otherwise pass conf number for existing call
        //smcUrl = smcUrl + '&val2=&val3=ACTConcession_RN&val4=""';
        discountValue = discountValue.replaceAll('%','%25');
        smcUrl = smcUrl + '&val2=&val3=ACTConcession_RN&val4=' + discountValue;
        
        //smcUrl = smcURL.replace('%','');
        
        
        //smcURL = EncodingUtil.urlEncode(smcURL,'UTF-8');
        system.debug(smcURL);
        //PageReference pageRef = new PageReference('http://localhost:84/Home.aspx?val1="970217134600000(#||s)10097234(#||s)2725417(#||s)FS - No Charge Srvc(#||s)E140(#||s)185624832(#||s)JVM7195EKES(#||s)LH220494B(#||s)902904010401E14010(#||s)0&val2=""&val3=ACTConcession_RN&val4=""');
        //PageReference pageRef = new PageReference('http://localhost:85/BridgeSMC.aspx?val1=998614014000000(|)10097234(|)2725417(|)FS - No Charge Srvc(|)E140(|)179095747(|)JVM7195EKES(|)LH220494B(|)902904010401E14010(|)0&val2=&val3=ACTConcession_RN&val4=""');
        PageReference pageRef = new PageReference(smcUrl);
        pageRef.setRedirect(false);
        return pageRef;
    }
    
//    public PageReference setUrl(){
        //smcUrl ='https://localhost:84/Home.aspx?val1="970217134600000(#||s)10097234(#||s)2725417(#||s)FS - No Charge Srvc(#||s)E140(#||s)185624832(#||s)JVM7195EKES(#||s)LH220494B(#||s)902904010401E14010(#||s)0&val2=""&val3=ACTConcession_RN&val4=""';
//        smcUrl ='http://localhost:85/BridgeSMC.aspx?val1=998614014000000(|)10097234(|)2725417(|)FS - No Charge Srvc(|)E140(|)179095747(|)JVM7195EKES(|)LH220494B(|)902904010401E14010(|)0&val2=&val3=ACTConcession_RN&val4=""';
        
//        return null;
//    }
}