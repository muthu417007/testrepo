/**
   * @description created by : Santhosh Kanne
   * Test class : VA_ChatApiRelatedDataTest
*/
public without sharing class VA_ChatApiRelatedData {

    /**
	 * @description Serial number validation method.
	 * @param serialNumber
	 * @return returns serial nubmer meta data records.
	*/
    @AuraEnabled(cacheable=true)  
    public static List < Virtual_Assistant_Metadata__mdt > checkSerialWarranty(String serialNumber) {  
        List<String> strList = serialNumber.split('');
        Integer size=strList.size();
        system.debug('list size'+size);
      
        if(size>=2 && Schema.sObjectType.Virtual_Assistant_Metadata__mdt.isAccessible()){
            
        	return [ SELECT MasterLabel,DeveloperName,Month_Name__c,Valid_Year__c FROM Virtual_Assistant_Metadata__mdt where DeveloperName=:strList[0] or DeveloperName= :strList[1] WITH SECURITY_ENFORCED];
        }
        else {
        	return new List<Virtual_Assistant_Metadata__mdt>();
        }
    }
    /**
	 * @description Serial number validation method.
	 * @param serialNumber
	 * @return returns serial nubmer meta data records.
	*/
    @AuraEnabled(cacheable=true)  
    public static String getFSSavewithPartsQueueID(String queueName) {  
        List<Group> queueRecord;
        if(Schema.sObjectType.Group.isAccessible()){
            
        	 queueRecord = [ SELECT Id, Name FROM Group where DeveloperName=:queueName WITH SECURITY_ENFORCED];
        }
        if(queueRecord.size()>0)
            return (String)queueRecord[0].Id;
        return 'NoQueueFound';
    }
    
    /**
	 * @description method to insert audit record.
	 * @param auditRecord
	 * @return creates or updates vachat details record.
	*/
    @AuraEnabled
    public static VAChat_Details__c upsertVaChatDetail(VAChat_Details__c auditRecord){
        try {
            system.debug('record is '+auditRecord);
            upsert auditRecord;
            return auditRecord;
        }
        catch(Exception e){
            system.debug('error message is '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
	 * @description method to get product2 record.
	 * @param productSKU
	 * @return returns product record.
	*/
    @AuraEnabled(cacheable=true) 
    public static List<Product2> getProduct2Record(String productSKU){
        
        return [ select Id,Is_Manufacturing_Model__c,Marketing_Model__c,Marketing_Model__r.StockKeepingUnit,StockKeepingUnit from Product2 where StockKeepingUnit = :productSKU];
    }
    /**
	 * @description method to get Audit records.
	 * @param model, serial, userId
	 * @return returns audit records.
	*/
    @AuraEnabled
    public static String getVaChatDetail(String model,String serial, String userId){
        List<VAChat_Details__c> vaChatRecords =[ select Id,toLabel(ProblemCategory__c),Phone__c,CreatedDate,VAReponseComments__c,ApplianceType__c,ModelNo__c,requested_by__c,Status__c, Case__c,Case__r.CaseNumber,Case__r.Order_Number__c from VAChat_Details__c where ModelNo__c=:model and SerialNo__c=:serial and CreatedDate>= LAST_N_DAYS:30 Order by CreatedDate DESC];
        JSONGenerator gen = JSON.createGenerator(true);
		gen.writeStartObject();
        gen.writeFieldName('records');
        gen.writeStartArray();
        
        if(vaChatRecords.size()>0){
            for(VAChat_Details__c vaRec : vaChatRecords) {
                gen.writeStartObject();
                gen.writeStringField('ProblemCategory__c', vaRec.ProblemCategory__c);
                gen.writeStringField('Status__c', vaRec.Status__c);
                gen.writeStringField('CreatedDate', vaRec.CreatedDate.format('MM/dd/yyyy'));
                if(vaRec.Case__c!=null) {
                    gen.writeIdField('Case__c', vaRec.Case__c); }
                else {
	                gen.writeStringField('Case__c', '');
            	}
                gen.writeIdField('Id', vaRec.Id);
                gen.writeStringField('Phone__c', vaRec.Phone__c!=null?vaRec.Phone__c:'');
                gen.writeStringField('ModelNo__c', vaRec.ModelNo__c);
            	gen.writeStringField('Va_Bot', 'VA');
                gen.writeStringField('CaseNumber', vaRec.Case__c!=null?vaRec.Case__r.CaseNumber:'');
                gen.writeStringField('OrderNumber', vaRec.Case__c!=null?(vaRec.Case__r.Order_Number__c!=null?vaRec.Case__r.Order_Number__c:''):'');
                
                gen.writeEndObject();
            }
        }
        
        String extraurl='/issuehistory/botinteractions?modelNum=';
        
        if(model !=null && model!='') {
            extraurl+=model; }
        if(serial !=null && serial!='') {
           extraurl+='&serialNum='+serial; }
        extraurl+='&param1=&param2=';   
        String resp1;
        if(utility.isSandbox){
         	resp1 = RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','VA_Chat_Dev_Token','VA_MuleDevChatURL',extraurl,'GET',null);
        }
        else {
            resp1 = RequestMuleAPIData.getMuleAPIData('Production_MuleAuth','Prod_Connected_Token','VA_MuleProdChatURL',extraurl,'GET',null);
        
        }
        String res=resp1.remove('\n');
        //system.debug(resp);
        //String res ='{"status":"S","message":"Successfull","records":[{"SERVICECALLDATE":"04/20/2023","SUMMARY":"Not filling","STATUS":"STC","VA_BOT":"BOT"},{"SERVICECALLDATE":"04/18/2023","SUMMARY":"Not Temp","STATUS":"NS","VA_BOT":"BOT"}]}';
        InteractionHistory resp =(InteractionHistory)JSON.deserialize(res, InteractionHistory.class);
        //system.debug('resp is '+resp.status+' '+resp.message);
        for(HistoryRecords rec: resp.records){
            gen.writeStartObject();
            gen.writeStringField('ProblemCategory__c', rec.SUMMARY);
            gen.writeStringField('Status__c', rec.STATUS);
            gen.writeStringField('CreatedDate', rec.SERVICECALLDATE);
            gen.writeStringField('Va_Bot', rec.VA_BOT);
            gen.writeStringField('Phone__c', rec.PHONE);
            gen.writeStringField('Case__c', '');
            gen.writeEndObject();
        }
        gen.writeEndArray();
        gen.writeEndObject();
        String resp2 = gen.getAsString().remove('\n');
        //system.debug('resp2'+resp2);
        return resp2;
        //return ;
    }
    
    
    /**
	 * @description method to get model api data.
	 * @param model
	 * @return returns model api records.
	*/
    @AuraEnabled(cacheable=true)  
    public static String getModelData(String model) {  
        
        String extraurl='/issuehistory/modelnum?modelNum=';
        
        if(model !=null && model!='') {
            extraurl+=model; }
        extraurl+='&param1='; 
        String res;
        if(utility.isSandbox){
         	res = RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','VA_Chat_Dev_Token','VA_MuleDevChatURL',extraurl,'GET',null);
        }
        else {
            res = RequestMuleAPIData.getMuleAPIData('Production_MuleAuth','Prod_Connected_Token','VA_MuleProdChatURL',extraurl,'GET',null);
        
        }
        String resp=res.remove('\n');
        //system.debug(resp);
        return resp;
        //return '{"status":"S","message":"Successfull","records":[{"COUNT":14,"TOP_5_ISSUES":"OTHERNOTLISTEDSEEREMARKS"},{"COUNT":5,"TOP_5_ISSUES":"BURNEROPERATIONISSUES"},{"COUNT":4,"TOP_5_ISSUES":"MISSING/REPLACE/DAMAGEDPARTS"},{"COUNT":3,"TOP_5_ISSUES":"OVENPREHEATINGISSUES"},{"COUNT":2,"TOP_5_ISSUES":"OVENNOTWORKINGPROPERLY/WRONGTEMPERATURE"}]}';
    }
    /**
	 * @description method to get Serial API records.
	 * @param serial
	 * @return returns serial API records.
	*/
    @AuraEnabled(cacheable=true)  
    public static String getSerialData(String serial, String model, String phone) {  
    
        String extraurl='/issuehistory/serialnum?modelNum=';
        
        if(model !=null && model!='') {
            extraurl+=model; }
        if(serial !=null && serial!='') {
            extraurl+='&serialNum='+serial; }
		if(phone !=null && phone!='') {
			extraurl+='&svcPhone='+phone; }
        extraurl+='&param1=&param2=&param3=';
        String res;
        if(utility.isSandbox){
         	res = RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','VA_Chat_Dev_Token','VA_MuleDevChatURL',extraurl,'GET',null);
        }
        else {
            res = RequestMuleAPIData.getMuleAPIData('Production_MuleAuth','Prod_Connected_Token','VA_MuleProdChatURL',extraurl,'GET',null);
        
        }
        String resp=res.remove('\n');
        //system.debug(resp);
        return resp;
        //return '{"status":"S","message":"Successfull","records":[{"SERVICECALLDATE":"01/19/2023","PROBLEM":"LEAKINGANDFLOODING","PARTS":"WD12X28238","JOB_DESC":"1681"},{"SERVICECALLDATE":"01/19/2023","PROBLEM":"LEAKINGANDFLOODING","PARTS":"WD12X10462","JOB_DESC":"1681"},{"SERVICECALLDATE":"01/19/2023","PROBLEM":"LEAKINGANDFLOODING","PARTS":"WD08X10092","JOB_DESC":"1681"},{"SERVICECALLDATE":"01/19/2023","PROBLEM":"LEAKINGANDFLOODING","PARTS":"WD24X20586","JOB_DESC":"1681"},{"SERVICECALLDATE":"01/19/2023","PROBLEM":"LEAKINGANDFLOODING","PARTS":"WD31X29644","JOB_DESC":"1681"}]}';
    
    }
     /**
   	 * @description wrapper classs HistoryRecords
	  */
    public class HistoryRecords {
        String SERVICECALLDATE;
        String SUMMARY;
        String STATUS;
        String VA_BOT;
        String PHONE;
    }
     /**
   	 * @description wrapper classs InteractionHistory
	  */
    public class InteractionHistory {
        String status;
        String message;
        List<HistoryRecords> records = new List<HistoryRecords>();
    }   
}