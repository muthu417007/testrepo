@RestResource(urlMapping='/Case/*')
global with sharing class CaseRestResource {
    @HttpGet
    global static List<Case> doGet(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        integer soqlLimit=2000;
        String soql='SELECT AccountId,Parent.Id,Parent.CaseNumber,Alternative_Phone_Number__c, '+
            'Appliance_Damagedpicklist__c,Brand__c, '+
            'Breaker_Tripped__c,Business_Team_f__c,CaseNumber,Case_Comment_Count__c, '+
            'Case_Re_Open_Count__c,Category__c,City__c,ClosedDate,Comments,Consumer_Description_of_Injury__c, '+
            'Consumer_Full_Address__c,Consumer_Given_Insurance_Info__c,Consumer_s_Name__c, '+
            'Consumer_Turned_Off_Appliance__c,ContactEmail,ContactFax,ContactId,ContactMobile,ContactPhone, '+
            'Country__c,CreatedById,CreatedDate,Created_By_Location__c,Cust_Class__c,Description, '+
            'Email_TAG__c,Email__c,Emergency_Services_Contactedpicklist__c,Encompass__c, '+
            'EQL_Reviewer_is_Current_User__c,EQL_Reviewer__c,EQOS_Score__c, '+
            'Escalated_to_Resolution_Time__c,Escalating_Agent__c,Escalation_Reason__c,Fire_Occurred__c, '+
            'First_Name__c,Flames_Noticed__c,AssetId,GE_Part__c,Haier_Part__c, '+
            'How_Fire_was_Extinguished__c,Id,IsClosed,IsDeleted,IsEscalated,isParent_NOT_IN_USE__c, '+
            'isParent__c,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate, '+
            'Last_Name__c,Location_f__c,Location_of_Flames__c,MasterRecordId,Medical_Attention_soughtpicklist__c, '+
            'Model_Number__c,Model_Serial__c,Order_Date__c,Origin,OSC_IncidentId__c,OwnerId, '+
            'ParentId,Personal_Injury_Occurred__c,Personal_Injury_Type__c,Phone_Number__c, '+
            'Priority,Product_in_Use_During_Incident__c,Product_Platform__c,Property_Damagedpicklist__c, '+
            'Property_Damage_Type__c,Question__c,Reason,Reason_for_Message__c,Recent_Power_Outage__c, '+
            'Recent_Service_on_Appliance__c,RecordTypeId,Reject_Escalation__c,Saved_By_Agent__c, '+
            'Serial_Number__c,State__c,Status,Street_Address__c,Subject,SuppliedCompany, '+
            'SuppliedEmail,SuppliedName,SuppliedPhone,SystemModstamp,Team_Lead_Manager_f__c,Team_Persona_f__c, '+
            'Time_of_Escalation__c,Twilio_Phone__c,Type,Type_of_Treatment__c,Web_To_Case_Origin__c, '+
            'Why_Was_CS1049_Rejected__c,Zip_Postal_Code__c,Asset.Product_Line__c,Asset.Product_Type__c, '+
            'Asset.SerialNumber,Consumer_first_Name__c,Consumer_Last_Name__c,Install_Date__c, '+
            'Incident_Date__c,Product_Line__c,Account.BillingStreet,Account.BillingCity,Account.BillingState, '+
            'Account.BillingPostalCode,Account.BillingCountry,Product_Type__c, '+
            'Product_in_Use_During_Incidentpicklist__c,Fire_Occurredpicklist__c,Flames_Noticedpicklist__c,Consumer_Turnedpicklist__c, '+
            'Breaker_Trippedpicklist__c,Recent_Power_Outagepicklist__c,Recent_Service_on_Appliancepicklist__c '+
            'FROM Case WHERE RecordType.DeveloperName=\'CS1049\'';
        if(req!=null){
            Map<String,String> reqParams = req.params;
            if(reqParams.containsKey('startTime') && reqParams.containsKey('endTime')){
                Datetime startTime = Datetime.valueOf(reqParams.get('startTime'));
                Datetime endTime = Datetime.valueOf(reqParams.get('endTime'));
                soql+=' AND CreatedDate>=:startTime AND CreatedDate<=:endTime';            
            }
            if(reqParams.containsKey('caseNumber') && reqParams.containsKey('startTime') && reqParams.containsKey('endTime')){
                String caseNumber = reqParams.get('caseNumber');
                soql+=' AND CaseNumber=:caseNumber';
            }
        }
        soql+=' ORDER BY CreatedDate DESC LIMIT :soqlLimit';
		//system.debug('soql ' + soql);
		//system.debug(' end soql' + soql.substring(soql.length()-200));        
        return Database.query(soql);
    }
}