global class MedalliaIntegrationBulkTrigger {
@InvocableMethod
    global static void sendToMedallia(List<surveyPayload> records) {
        
        List<Id> caseIdsToSurvey = new List<Id>();
        try { 
            if (!records.isEmpty()) {
                
                for (Case cs :records[0].casesToSurvey){
                   caseIdsToSurvey.add(cs.Id);
                }
                /* Fecth all cases flagged to be included in the survey wave in each account */
              //List<Case> casesToSurvey = [SELECT CaseNumber, Description, Origin, Reason, ContactId, ContactEmail, ContactPhone, CreatedDate, ClosedDate, Product_Platform__c, Model_Serial__c, Brand__c, Business_Team_f__c, Team_Persona_f__c, Agent_SSO_ID__c, recordtype.developername, owner.name, gea_asset__r.In_Warranty__c, __r.Product_Line_Desc__c, Asset__r.Install_Date__c, Asset__r.Model_Number__c, Asset__r.Serial_Number__c, Asset__r.Product_Line__c, Contact.FirstName, Contact.LastName FROM Case WHERE ID IN :recordIds LIMIT 20000];
                
    
                    /* Fecth all cases flagged to be included in the survey wave in each account */
                	//List<SObject> allr = [SELECT Contact_f_First_Name__c, Contact_f_Last_Name__c, ModelNumberf__c, SerialNumberf__c, ProductLine__c, ProductTypeDesc__c, BrandName__c, Case__r.CaseNumber, Case__r.Description, Case__r.Origin, Case__r.Reason, Case__r.ContactId, Case__r.ContactEmail, Case__r.ContactPhone, Case__r.CreatedDate, Case__r.ClosedDate, Case__r.Product_Platform__c, Case__r.Business_Team_f__c, Case__r.Team_Persona_f__c, Case__r.Agent_SSO_ID__c, Case__r.Case_f_Owner__c, Case__r.Incident_f_Type__c,Asset__r.In_Warranty__c,Asset__r.Product_Line_Desc__c, Asset__r.Install_Date__c, Asset__r.Model_Number__c,Asset__r.Serial_Number__c, Asset__r.Product_Line__c FROM Case_Asset__c WHERE Case__r.ID ='5002g000001YZCvAAO'];     
                    // Get master data from config
                    // Bulked Integration only works for Case
                    String sObjectTypeMaster = 'Case_Asset__c';
                    // Fetch API details
                    String endpoint = records[0].endpoint;
                    String username = records[0].service;
                    String password = records[0].password;
                   // String recordid =records[0].recordid;
                     String queryFilter=records[0].QueryFilter==null?'':records[0].QueryFilter;
                    
                    //caseIdsToSurvey.add(recordid);
                    // Build the query
                    String query = 'SELECT ';
                    List<String> allFields = new List<String>();
                   // Map<String, Schema.FieldSet> finalfs = new Map<String, Schema.FieldSet>();
                    
                    //Gather all fields from fieldsets to query
                    String fsname = records[0].fieldSet;
                    Schema.FieldSet fields = MedalliaIntegrationBulkTrigger.readFieldSet(fsname, sObjectTypeMaster);
            
                    allFields = MedalliaIntegrationBulkTrigger.allFieldsCheck(allFields, fields);
                    query = fieldQuery(query, allFields);
                                              
                    //Complete FROM and WHERE Statements and query
                    query = query.removeEnd(', ');
                    //query += ' FROM '+sObjectTypeMaster+' WHERE  Case__r.ID IN :caseIdsToSurvey '+queryFilter;
                	query += ' FROM '+sObjectTypeMaster+queryFilter;
                
                    System.debug(LoggingLevel.Info,'DB query===> '+query);
                    List<SObject> allr = Database.query(query);
                   
                    System.debug(LoggingLevel.Info, 'DB values allr===> '+allr);
			
                    String jsonval = MedalliaIntegrationBulkTrigger.toSimpleJSON(allr);
                    System.debug(LoggingLevel.Info,'json===> '+jsonval);
                    // Send the request
                    MedalliaIntegrationBulkTrigger.sendDocJSON(jsonval, endpoint, username, password, sObjectTypeMaster, 'Bulk');
                }
            } catch (Exception e) {
                System.debug(e);
                Medallia_Integration_Log__c log = new Medallia_Integration_Log__c();
                log.Body__c = JSON.serialize(records);
                log.Status_Code__c = e.getMessage();
                log.Error_Message__c = e.getStackTraceString();
                try {
                    String sObjectTypeMaster = '';
                    //String mainId = String.valueOf(caseIdsToSurvey).substring(0,255);
                    log.Object__c = sObjectTypeMaster;
                   // log.Record_Id__c = String.valueOf(mainId);
                } catch (Exception e2) {
                    
                }
    
                insert log;
            }
    
                
        }   
    

    @future(callout=true)
    global static void sendDocJSON(String docstring, String endpoint, String username, String password, String objecttype, String recid) {
        String logall = Label.LogAllMedalliaMessages;

        HttpRequest req = new HttpRequest();
        
        // Use Basic auth if a password is set - Standard Base64 encoding is applied to credentials
        if(password != null){
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
        // For request with IP whitelisting only, the username needs to be appended as a parameter
        }else{
            endpoint = endpoint + '?' + username;
        }
        
        req.setMethod('POST');
        req.setEndpoint(endpoint);
        req.setHeader('Content-Type', 'text/json');
       
        
        
        req.setBody(docstring);
        
        Http http = new Http();
        if (!Test.isRunningTest()) {
            HttpResponse res = http.send(req);
            Medallia_Integration_Log__c log = new Medallia_Integration_Log__c();
            log.Body__c = res.getBody();
            log.Status_Code__c = String.valueOf(res.getStatusCode());
            log.Error_Message__c = '';
            log.Object__c = objecttype;
            log.Record_Id__c = String.valueOf(recid);

            insert log;
        }
        

    }

     public static void writeJSONStr(List<String> fieldList, sObject sobj, JSONGenerator gen)
    {
        for (String fieldpath : fieldList)
        	{
              
          		String val = String.valueOf(sobj.get(fieldpath));
          		if (val != null) {
           			gen.writeObjectField(fieldpath, val);
          			} else {
                    gen.writeObjectField(fieldpath, '');
                   }   
        	}      
    }
    
    global static String toSimpleJSON(List<SObject> allr)
    {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartArray();
       
        String json='';
        for(sObject s : allr)
        {
            gen.writeStartObject();
            Case csRec = (Case)s.getSObject('Case__r');
            Asset geaAsset = (Asset) s.getSObject('Asset__r');
            
            writeJSONStr(getAllFieldsRealNames('Case'),csRec,gen);
            writeJSONStr(getAllFieldsRealNames('Asset'),geaAsset,gen);
            writeJSONStr(getAllFieldsRealNames('Case_Asset__c'), s, gen); 
            
            gen.writeEndObject();
           
        }
        	gen.writeEndArray(); 
        	return gen.getAsString(); 
    }

    public static List<String> getAllFieldsRealNames(String objName){
        List<String> currentfields  = new List<String>();
        
        if(objName=='Case'){
        			currentfields.add('CaseNumber');
                     currentfields.add('Description');
                     currentfields.add('Origin');
                     currentfields.add('Reason');
                     currentfields.add('ContactId');
                     currentfields.add('ContactEmail');
                     currentfields.add('ContactPhone');
                     currentfields.add('CreatedDate');
                     currentfields.add('ClosedDate');
                     currentfields.add('Product_Platform__c');
                     currentfields.add('Business_Team_f__c');
                     currentfields.add('Team_Persona_f__c');
                     currentfields.add('Agent_SSO_ID__c');
                     currentfields.add('Case_f_Owner__c');
                     currentfields.add('Incident_f_Type__c');
       
        } else if (objName=='Asset'){
                     currentfields.add('In_Warranty__c');
                     currentfields.add('Product_Line_Desc__c');
                     currentfields.add('InstallDate');
                     currentfields.add('Model_Number__c');
                     currentfields.add('SerialNumber');
                     currentfields.add('Product_Line__c');
        }
         else if (objName=='Case_Asset__c'){
             		currentfields.add('Contact_f_First_Name__c');
                     currentfields.add('Contact_f_Last_Name__c');
                     currentfields.add('ModelNumberf__c');
                     currentfields.add('SerialNumberf__c');
                     currentfields.add('ProductLine__c');
                     currentfields.add('ProductTypeDesc__c');
             		 currentfields.add('BrandName__c');
         }
        
        return currentfields;
    }
    public static String fieldQuery(String current, List<String> allFields) {

        for(String f : allFields) {
            current += f + ', ';
        }

        return current;
    }

      public static List<String> allFieldsCheck(List<String> currentfields, Schema.FieldSet fieldset) {
            if (fieldset == null) {
                return null;
            } else {
                List<Schema.FieldSetMember> li = fieldset.getFields();
        
                for(Schema.FieldSetMember f : li) {
                    Boolean exists = false;
                    for (String c : currentfields) {
                        if (f.getFieldPath() == c) {
                            exists = true;
                        }
                    }
        
                    if (!exists) {
                        currentfields.add(f.getFieldPath());
                    }
                }
                     currentfields.add('Case__r.CaseNumber');
                     currentfields.add('Case__r.Description');
                     currentfields.add('Case__r.Origin');
                     currentfields.add('Case__r.Reason');
                     currentfields.add('Case__r.ContactId');
                     currentfields.add('Case__r.ContactEmail');
                     currentfields.add('Case__r.ContactPhone');
                     currentfields.add('Case__r.CreatedDate');
                     currentfields.add('Case__r.ClosedDate');
                     currentfields.add('Case__r.Product_Platform__c');
                     currentfields.add('Case__r.Business_Team_f__c');
                     currentfields.add('Case__r.Team_Persona_f__c');
                     currentfields.add('Case__r.Agent_SSO_ID__c');
                     currentfields.add('Case__r.Case_f_Owner__c');
                     currentfields.add('Case__r.Incident_f_Type__c');

                     currentfields.add('Asset__r.In_Warranty__c');
                     currentfields.add('Asset__r.Product_Line_Desc__c');
                     currentfields.add('Asset__r.InstallDate');
                     currentfields.add('Asset__r.Model_Number__c');
                     currentfields.add('Asset__r.SerialNumber');
                     currentfields.add('Asset__r.Product_Line__c');
                return currentfields;
            }
                
        }

    public static Schema.FieldSet readFieldSet(String fieldSetName, String ObjectName) {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();

        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        System.debug(fieldSetObj);
        System.debug(DescribeSObjectResultObj);
        return fieldSetObj; 
    }  

    global class surveyPayload {
        @InvocableVariable(required=true)
        global String endpoint;
        
        @InvocableVariable(required=true)
        global String fieldSet;
        
        @InvocableVariable(required=true)
        global List<Case> casesToSurvey;
        
        @InvocableVariable(required=true)
        global String service;
        
        @InvocableVariable(required=false)
        global String password;
        
        @InvocableVariable(required=false)
        global String QueryFilter;
    }
}