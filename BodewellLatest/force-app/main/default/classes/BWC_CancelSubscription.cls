/**
@description : Apex Class to cancel subscription details
Author:       Hima Poornima M
Created Date: 11/03/2024
*/
public without sharing class BWC_CancelSubscription {

    @AuraEnabled(cacheable=false)
    public static void cancelSubscription(String userId){
        try
        {
           String globalCustomerId = [SELECT Id, Name, AccountId, Account.global_customer_id__pc FROM USER WHERE Id =: userId].Account.global_customer_id__pc;
           String cancelReason = 'Unknown';
           Date todaysDate = system.today();
           String cancelDate = String.valueOf(todaysDate.year()) + '-'+String.valueOf(todaysDate.month())+'-'+String.valueOf(todaysDate.day());
           System.debug('cancelDate -> ' + cancelDate);
           
           String res;

           JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('clientReferenceId', globalCustomerId); 
            gen.writeStringField('cancelDate', cancelDate);
            gen.writeStringField('cancelReason', cancelReason);
            gen.writeEndObject();
            String jsonString = gen.getAsString();
            system.debug('jsonString - '+ jsonString);

           if(!test.isRunningTest())
           {
                //hitting cache availabilty api
                if(utility.isSandbox){
                    res=RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_QA_Token','Sandbox_AssurantEnrollment_QA',null,'PATCH',jsonString);
                }
                /*else{
                    res=RequestMuleAPIData.getMuleAPIData('BWC_Production_MuleAuth','BWC_PROD_EBS_Token','BWC_PROD_CommerceCloudCacheAvailability',null,'POST',jsonString);
                }*/
            }
            else
            {
                res='{  "errorStatus": "Success",  "errorMessage": "",  "availabilityDetails": [    {      "requestedDateQuantity": 10,      "shipDate": "2023-09-30",      "availableQuantity": 8.5,      "requestedShipDate": "2023-10-05",      "errorCode": null,      "quantityOrdered": 5,      "message": "",      "inventoryItemName": "ItemA"    },    {      "requestedDateQuantity": 5,      "shipDate": "2023-10-10",      "availableQuantity": 4.0,      "requestedShipDate": "2023-10-15",      "errorCode": null,      "quantityOrdered": 2,      "message": "",      "inventoryItemName": "ItemB"    }  ]}';
            }

            system.debug('res -> '+ res);
        }
         catch(Exception ex){
             system.debug('Exception - ' + ex.getMessage());
          throw new AuraHandledException(ex.getMessage());
      }

    }

   

}