//******************************************************************************************
//Name : Mya_updateEmailApiHelper
//Requirement : Class to call Update Email API
//EPIC/US/TASK : IDMSF- 1618
//******************************************************************************************
//History
//  Version             Author                  Date                Detail
//  1.0                 Yogesh Sharma           22/09/2022          Initial
//******************************************************************************************
//@description : Class to call Update Email API
public class Mya_updateEmailApiHelper 
{
    //@description : Method is used to call future method that call API
    //Input: String GCId
    @InvocableMethod(label='UpdateEmailAPI')
    Public static void updateEmailDB(List<Mya_updateEmailApi> updateInfo)
    {
        if(updateInfo.size()!=0)
        {
            string emailToUpdate = updateInfo[0].gcid+','+updateInfo[0].oldEmail+','+updateInfo[0].newEmail;
            updateEmail(emailToUpdate);
        }
    }
    //@description : Method is used to call Update Email API
    //Input: String GCID, OldEmail and New Email
    @future( callout=true )
    public static void updateEmail(string emailInfo)
    {
        List<String> infoString = emailInfo.split(',');
        String gcid = infoString[0];
        String oldEmail = infoString[1];
        String newEmail = infoString[2];
        String domainUrl = Url.getOrgDomainUrl().getHost();
        MYA_Configuration__mdt details = MYA_MetaDataConfigHelper.getmyaConfigByDomain(domainUrl);
        Http httpCall = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(details.ReturnBaseURL__c+'/store/order/updateEmail?UID='+EncodingUtil.URLENCODE(gcid,'UTF-8')+'&oldEmailAddress='+EncodingUtil.URLENCODE(oldEmail,'UTF-8')+'&newEmailAddress='+EncodingUtil.URLENCODE(newEmail,'UTF-8'));
        request.setTimeout(60000);
        HttpResponse response ;        
        if(!Test.isRunningTest()){
            response = httpCall.send(request);
            system.debug(response.getBody());
        }
        
    }
    //@description : Wrapper class for Email Update Info
    Public class Mya_updateEmailApi
    {
        @InvocableVariable(Required=true)
        Public String gcid;
        @InvocableVariable(Required=true)
        Public String newEmail;
        @InvocableVariable(Required=true)
        Public String oldEmail;
    }
}