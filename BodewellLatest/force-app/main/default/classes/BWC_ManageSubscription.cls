/**
@description : Apex Class to cancel subscription details
Author:       Hima Poornima M
Created Date: 11/03/2024
*/
public class BWC_ManageSubscription 
{
    
     @AuraEnabled(cacheable=false)
    public static void enroll(String userId)
    {
        try
        {
           system.debug('In BWC_ManageSubscription class');
           User userDetails = [SELECT Id, Name, AccountId, Account.global_customer_id__pc, Account.Name,
           Account.Firstname, Account.LastName, Account.Phone, Account.PersonEmail
            FROM USER WHERE Id =: userId LIMIT 1];
            system.debug('userDetails.Name - ' + userDetails.Name);
            system.debug('userDetails.AccountId - ' + userDetails.AccountId);
            system.debug('userDetails.AccountName - ' + userDetails.Account.Name);

           /*ContactPointAddress addressDetails = [SELECT Id, Name, Street, City, State, PostalCode, IsDefault 
            FROM ContactPointAddress WHERE ParentId =: userDetails.AccountId AND BWC_isActive__c = true LIMIT 1];*/

           Date todaysDate = system.today();
           String year = String.valueOf(todaysDate.year());
           String month =  String.valueOf(todaysDate.month()).length() == 1 ? '0'+String.valueOf(todaysDate.month()) : String.valueOf(todaysDate.month());
           String day =  String.valueOf(todaysDate.day()).length() == 1 ? '0'+String.valueOf(todaysDate.day()) : String.valueOf(todaysDate.day());
           String enrollDate = year + '-'+month+'-'+day;
           System.debug('enrollDate -> ' + enrollDate);

            PolicyRequest request = new PolicyRequest();
            request.clientReferenceId = userDetails.Account.global_customer_id__pc;
            request.dateOfSale = Date.valueOf(enrollDate);
            request.emailOptIn = true;
            request.smsOptIn = true;

            PolicyHolderInfo holderInfo = new PolicyHolderInfo();
            holderInfo.firstName = userDetails.Account.Firstname;
            holderInfo.lastName = userDetails.Account.LastName;
            holderInfo.email = userDetails.Account.PersonEmail;
            holderInfo.cellPhone = userDetails.Account.Phone == null ? '1234567890' : userDetails.Account.Phone;

            /*Address address = new Address();
            address.addressType = 'Home';
            address.streetAddress1 = addressDetails.Street == null ? '': addressDetails.Street;
            address.streetAddress2 = '';
            address.city = addressDetails.City == null ? '': addressDetails.City;
            address.state = addressDetails.State == null ? '': addressDetails.State;
            address.zipCode = addressDetails.PostalCode == null ? '': addressDetails.PostalCode;

            holderInfo.addresses = new List<Address>{ address };*/
            request.policyHolderInfo.add(holderInfo);

            String jsonRequest = JSON.serialize(request);
            System.debug(jsonRequest);

            String result = execute(jsonRequest,'POST');
            system.debug('result - ' + result);

            if(!result.contains('Error'))
            {
                JSONParser parser = JSON.createParser(result);
                while(parser.nextToken() != null)
                {
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) 
                    {
                        continue;
                    }
                    if (parser.getCurrentToken() == JSONToken.FIELD_NAME) 
                    {
                        String fieldName = parser.getText();
                        parser.nextToken(); // Move to the value of the field
                        if (fieldName == 'status') 
                        {
                            String status = parser.getText();
                            system.debug('Integration status - ' + status);
                            if(status == 'Failure')
                            {
                                system.debug('In BWC_ManageSubscription class In faliure status, Assurant PTP Coverage remains false');
                                break;
                            }
                            if(status == 'Success')
                            {
                                system.debug('In BWC_ManageSubscription class In success status, Assurant PTP Coverage remains true');
                                Account a = new Account();
                                a.Id = userDetails.AccountId;
                                a.Assurant_PTP_Coverage__pc = true;
                                update a;
                                break;

                            }

                        } 
                    }  
                }  
            }

              
                    
        }
         catch(Exception ex){
             system.debug('In BWC_ManageSubscription class Exception - ' + ex.getMessage()+ 'Line number - ' + ex.getLineNumber());
          throw new AuraHandledException(ex.getMessage());
      }

    }

    @AuraEnabled(cacheable=false)
    public static String cancel(String userId)
    {
        String returnvalue = 'error';
        try
        {
           //String globalCustomerId = [SELECT Id, Name, AccountId, Account.global_customer_id__pc FROM USER WHERE Id =: userId].Account.global_customer_id__pc;
           User userDetails = [SELECT Id, Name, AccountId, Account.global_customer_id__pc, Account.Name,
           Account.Firstname, Account.LastName, Account.Phone, Account.PersonEmail
            FROM USER WHERE Id =: userId LIMIT 1];
            system.debug('userDetails.Name - ' + userDetails.Name);
            system.debug('userDetails.AccountId - ' + userDetails.AccountId);
            system.debug('userDetails.AccountName - ' + userDetails.Account.Name);
           String cancelCode = 'DC';
           String cancelReason = 'Unknown';
           Date todaysDate = system.today();
           String year = String.valueOf(todaysDate.year());
           String month =  String.valueOf(todaysDate.month()).length() == 1 ? '0'+String.valueOf(todaysDate.month()) : String.valueOf(todaysDate.month());
           String day =  String.valueOf(todaysDate.day()).length() == 1 ? '0'+String.valueOf(todaysDate.day()) : String.valueOf(todaysDate.day());
           String cancelDate = year + '-'+month+'-'+day;
           System.debug('cancelDate -> ' + cancelDate);

           JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('clientReferenceId', userDetails.Account.global_customer_id__pc); 
            gen.writeStringField('cancelDate', cancelDate);
            gen.writeStringField('cancelCode', cancelCode);
            gen.writeStringField('cancelReason', cancelReason);
            gen.writeEndObject();
            String jsonString = gen.getAsString();
            system.debug('jsonString - '+ jsonString);
            String result = execute(jsonString,'PATCH');
            system.debug('result - ' + result);

             JSONParser parser = JSON.createParser(result);
            while(parser.nextToken() != null)
            {
                if (parser.getCurrentToken() == JSONToken.START_OBJECT) 
                {
                    continue;
                }
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) 
                {
                    String fieldName = parser.getText();
                    parser.nextToken(); // Move to the value of the field
                    if (fieldName == 'status') 
                    {
                        String status = parser.getText();
                        system.debug('Integration status - ' + status);
                        if(status == 'Failure')
                        {
                            system.debug('In faliure status, something went wrong');
                            
                            break;
                        }
                        if(status == 'Success')
                        {
                            system.debug('In success status remove buyer group');
                            /*BuyerGroupMember bgmDetails = [SELECT Id, Name FROM BuyerGroupMember
                            WHERE BuyerGroup.Name = 'Member' AND buyerId =: userDetails.AccountId LIMIT 1];
                            
                            BuyerGroupMember bgm = new BuyerGroupMember();
                            bgm.Id = bgmDetails.Id;
                            delete bgm;*/
                            BWC_PAController.revertMembership(userDetails.AccountId);
                            returnvalue = 'success';
                            break;

                        }
                        
                        

                    } 
               }  
            } 
            
         return returnvalue;
        }
         catch(Exception ex){
             system.debug('Exception - ' + ex.getMessage());
          throw new AuraHandledException(ex.getMessage());
      }

    }

    
    
    
    public static String execute(String jsonString, String method)
    {
        String res;
        if(!test.isRunningTest())
           {
                //hitting Assurant Enrollment api
                if(utility.isSandbox){
                    res=RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_QA_Token','Sandbox_AssurantEnrollment_QA',null,method,jsonString);
                    
                    
                }
                /*else{
                    res=RequestMuleAPIData.getMuleAPIData('BWC_Production_MuleAuth','BWC_PROD_EBS_Token','BWC_PROD_CommerceCloudCacheAvailability',null,'POST',jsonString);
                }*/
            }
            else
            {
                res='{  "errorStatus": "Success",  "errorMessage": "",  "availabilityDetails": [    {      "requestedDateQuantity": 10,      "shipDate": "2023-09-30",      "availableQuantity": 8.5,      "requestedShipDate": "2023-10-05",      "errorCode": null,      "quantityOrdered": 5,      "message": "",      "inventoryItemName": "ItemA"    },    {      "requestedDateQuantity": 5,      "shipDate": "2023-10-10",      "availableQuantity": 4.0,      "requestedShipDate": "2023-10-15",      "errorCode": null,      "quantityOrdered": 2,      "message": "",      "inventoryItemName": "ItemB"    }  ]}';
                
            }

         return res;   

    }

public class PolicyHolderInfo {
    public String firstName;
    public String lastName;
    public String email;
    public String cellPhone;
    //public List<Address> addresses;
}

/*public class Address {
    public String addressType;
    public String streetAddress1;
    public String streetAddress2;
    public String city;
    public String state;
    public String zipCode;
}*/

public class PolicyRequest {
    public String clientReferenceId;
    public Date dateOfSale; // Format: YYYY-MM-DD
    public Boolean emailOptIn;
    public Boolean smsOptIn;
    public List<PolicyHolderInfo> policyHolderInfo;

    public PolicyRequest() {
        policyHolderInfo = new List<PolicyHolderInfo>();
    }
}




}