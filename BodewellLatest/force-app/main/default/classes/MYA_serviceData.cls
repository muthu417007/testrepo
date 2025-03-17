public with sharing class MYA_serviceData 
{
    
    @AuraEnabled(cacheable=true)
    public static list<Service__c> MYA_getAccountProduct1()
    {
        string user1 = UserInfo.getUserId();
        String userName =[Select Id, Name from User where Id=:user1].Name; 
        String contactId=[select id, Name from Contact where Name=:userName].id;
        date yestDay = Date.today().addDays(-1);
        return [SELECT Id,Name,natureOfProblem__c,Service_Type_Description__c,Contact__r.Global_Customer_Id__c,Contact__r.LastName,Asset__r.OriginalModelNumber__c,Asset__r.ModelValidityFlag__c,Asset__r.Model_Number__c,Asset__r.SerialNumber,MYA_Service_Status__c,Call_Number__c,Service_Date__c,Service_Appt_Time__c,Contact__c 
                FROM Service__c 
                WHERE Contact__c=:contactId AND MYA_Service_Status__c!='NotActive' AND Service_Date__c>=:yestDay
                ORDER BY CreatedDate DESC];
    }
    
    @AuraEnabled(cacheable=true)
    public static servicesDataC360 MYA_getAccountProductC360()
    {
        Set<Decimal> pIds= new Set<Decimal>();
        Set<String> pIdss = new Set<String>();
        string user1 = UserInfo.getUserId();
        String userName =[Select Id, Name from User where Id=:user1].Name; 
        String contactId=[select id, Name,Global_Customer_Id__c from Contact where Name=:userName].Global_Customer_Id__c;
        List<c360_email__x> personId = [select personid__c from c360_email__x where myamyaccountid__c=:contactId];
        for(c360_email__x pId:personId)
        {
            pIds.add((Decimal.valueOf(pId.personid__c)));
            pIdss.add(pId.personid__c);
        }
        List<c360_asset__x> assests = [select id,serialnumber__c,connectedserialnumber__c,originalengineeringmodelnumber__c,assetid__c,originalmodelnumber__c,personid__c from c360_asset__x where personid__c IN :pIdss];
        List<c360_service__x> services =[SELECT Id,entitycreatedon__c,callnumber__c,assetid__c,servicertechnicianid__c,calltype__c,invoicenumber__c,personid__c,servicedate__c,servicenetcost__c,servicejobtypeid__c,servicejobtypedescription__c 
                                         FROM c360_service__x 
                                         WHERE personid__c IN : pIds 
                                         ORDER BY entitycreatedon__c DESC];
        servicesDataC360 s = new servicesDataC360();
        s.ass=assests;
        s.ser=services;
        return s; 
    }
    
    public class servicesDataC360
    {
        @AuraEnabled public List<c360_asset__x> ass;
        @AuraEnabled public List<c360_service__x> ser;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<servicesData> MYA_getAccountProduct()
    {
        List<servicesData> serData = new List<servicesData>();
        string user1 = UserInfo.getUserId();
        String userName =[Select Id, Name from User where Id=:user1].Name; 
        Contact cont=[select id, Name,Global_Customer_Id__c from Contact where Name=:userName LIMIT 1];
        string contactId = cont.Id;
            
        date refdate = system.today().addDays(-1);
        list<Service__c> closedService = new list<Service__c>();
        closedService = [SELECT Id,Name,natureOfProblem__c,Service_Type_Description__c,Contact__r.Global_Customer_Id__c,
                         Contact__r.LastName,Asset__r.OriginalModelNumber__c,Asset__r.ModelValidityFlag__c,
                         Asset__r.Model_Number__c,Asset__r.SerialNumber,MYA_Service_Status__c,
                         Call_Number__c,Service_Date__c,Service_Appt_Time__c,Contact__c, Service_Net_Cost__c, Call_Type__c, GEServicerID__c 
                FROM Service__c 
                WHERE Contact__c=:contactId AND MYA_Service_Status__c!='NotActive' AND Service_Date__c<:refdate
                ORDER BY CreatedDate DESC];
        if(closedService.size()>0)
        {
            for(Service__c ES:closedService)
            {
                servicesData serviceToAdd = new servicesData();
                serviceToAdd.invoice = ES.Call_Number__c;
                serviceToAdd.serviceDate = string.valueof(ES.Service_Date__c);
                serviceToAdd.modelNo = ES.Asset__r.OriginalModelNumber__c;
                serviceToAdd.serialNo = ES.Asset__r.SerialNumber;
                serviceToAdd.description = ES.natureOfProblem__c;
                serviceToAdd.serviceType = string.valueof(ES.Call_Type__c);
                serviceToAdd.serviceBy = ES.GEServicerID__c;
                serviceToAdd.serviceAmount = string.valueOf(ES.Service_Net_Cost__c);
                try 
                {
                    MYA_EndecaApiHandler.EndecaResponseDetails data = MYA_EndecaApiHandler.MYA_EndecaResponseDetails(ES.GEA_Asset__r.OriginalModelNumber__c);
                    MYA_EndecaApiHandler.EndecaResponse prdInfo = data.ProductInfo;
                    String url1=prdInfo.defaultImageUrl;
                    if(url1 != null)
                    {
                    	//serviceToAdd.productImageLink = url1+'&Variant=Thumbnail'; 
                    	serviceToAdd.productImageLink = url1.left(url1.lastIndexOf('/'))+'/w_192,h_200'+url1.right(url1.length()-url1.lastIndexOf('/'));// changed as part of SPR-146 Salsify-endeca transisiton project changes
                    }   
                    serviceToAdd.productDescription = prdInfo.ProductDescription.toString();
                } 
                catch (Exception Ex) 
                {
                }
                serData.add(serviceToAdd);
            }
        }
        return serData;
    }
    
    public class servicesData
    {
        @AuraEnabled public String invoice;
        @AuraEnabled public String serviceDate;
        @AuraEnabled public String modelNo;
        @AuraEnabled public String serialNo;
        @AuraEnabled public String description;
        @AuraEnabled public String serviceType;
        @AuraEnabled public String serviceBy;
        @AuraEnabled public String serviceAmount;
        @AuraEnabled public String productImageLink;
        @AuraEnabled public String productDescription;
    }  
}