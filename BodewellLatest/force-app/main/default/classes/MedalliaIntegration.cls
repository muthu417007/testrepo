global class MedalliaIntegration {
    @InvocableMethod
    global static void sendToMedallia(List<surveyPayload> records) {
        try { 
            if (!records.isEmpty()) {
                //Get master data from first record
                String sObjectTypeMaster = records[0].recordid.getSObjectType().getDescribe().getName();
                String endpoint = records[0].endpoint;
                String service = records[0].service;
                String password = records[0].password;
                String queryFilter=records[0].QueryFilter==null?'':records[0].QueryFilter;
                Id mainId = null;
                List<Id> recordIds = new List<Id>();
                String query = 'SELECT ';
               // String AssetQuery = 'SELECT ModelNumberf__c, SerialNumberf__c, ProductLine__c, ProductTypeDesc__c, BrandName__c, InWarranty__c , Install_Date__c FROM CASE_ASSET__c WHERE case__r.ID IN :recordIds LIMIT 1';
                
                Set<String> allFields = new Set<String>();
                Map<String, Schema.FieldSet> finalfs = new Map<String, Schema.FieldSet>();
				
                //Gather all fields from fieldsets to query
                for (surveyPayload rec : records) {
                    String fsname = rec.fieldSet;
                    mainId = rec.recordid;
                    recordIds.add(rec.recordid);
                    Schema.FieldSet fields = MedalliaIntegration.readFieldSet(fsname, sObjectTypeMaster);
                    finalfs.put(rec.recordid, fields);
                    allFields = MedalliaIntegration.allFieldsCheck(allFields, fields);

                    query = fieldQuery(query, allFields);
                }
                    
                //Complete FROM and WHERE Statements and query
                query = query.removeEnd(', ');
                //query += ' FROM '+sObjectTypeMaster+' WHERE ID IN :recordIds LIMIT 20000';
                query += ' FROM '+sObjectTypeMaster+' '+queryFilter;
                List<SObject> allr = Database.query(query);
                //List<SObject> allr2 = Database.query(AssetQuery);
                
                MedalliaIntegration.setAssetFields(allr);
                    
                //Map records
                Map<Id, sObject> allrmap = new Map<Id, sObject>();
                for (sObject s : allr) {
                    allrmap.put((Id)s.get('Id'), s);
                }

                //Loop through submitted records and build surveyAndSobj object for them 
                List<surveyAndSobj> typeCastRecords = new List<surveyAndSobj>();
                for (surveyPayload rec : records) {
                    sObject match = allrmap.get(rec.recordid);
                    MedalliaIntegration.surveyAndSobj newxml = new MedalliaIntegration.surveyAndSobj();
                    newxml.payload = rec;
                    newxml.obj = match;

                    typeCastRecords.add(newxml);
                }
				
                // Convert to JSON
                String jsonval = MedalliaIntegration.toJSON(typeCastRecords, finalfs);

                System.debug('JSON PAYLOAD: ==========> '+jsonval);
                
                // Send the request
                MedalliaIntegration.sendDocJSON(jsonval, endpoint, service, password, sObjectTypeMaster, mainId);
            }
        } catch (Exception e) {
            System.debug(e);
            Medallia_Integration_Log__c log = new Medallia_Integration_Log__c();
            log.Body__c = JSON.serialize(records);
            log.Status_Code__c = e.getMessage();
            log.Error_Message__c = e.getStackTraceString();
            try {
                String sObjectTypeMaster = records[0].recordid.getSObjectType().getDescribe().getName();
                Id mainId = records[0].recordid;
                log.Object__c = sObjectTypeMaster;
                log.Record_Id__c = String.valueOf(mainId);
            } catch (Exception e2) {
                
            }

            insert log;
        }

            
    }   

    // send to Medallia
    @future(callout=true)
    global static void sendDocJSON(String docstring, String endpoint, String service, String password, String objecttype, Id recid) {
        String logall = Label.LogAllMedalliaMessages;

        HttpRequest req = new HttpRequest();
        
        // Use Basic auth if a password is set - Standard Base64 encoding is applied to credentials
        if(password != null){
            Blob headerValue = Blob.valueOf(service + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
        // For request with IP whitelisting only, the username (i.e. service) needs to be appended as a parameter
        }else{
            endpoint = endpoint + '?' + service;
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
            
            if(String.valueOf(res.getStatusCode())=='200')
            {
		   		Case c = [SELECT ID, Survey_Complete__c FROM CASE WHERE ID = :recid];
        		c.Survey_Complete__c=true;
            	update c;
        	}
        }
        
        
    }

    /*
     * This method sets additional fields needed for the SOQL dynamically.  version 3.
	*/
        
    global static void setAssetFields(List<SObject> allr)
    {
                    for (sObject s : allr)
                    {
                        sObject asset = s.getSObject('Case_Asset_NOT_ON_LAYOUT__r');
                        
                        if(asset!=null)
                        {
                             if(s.get('Model_Number__c')==null || s.get('Model_Number__c')=='')
                                 s.put('Model_Number__c', asset.get('ModelNumberf__c'));
                            
                             if(s.get('Serial_Number__c')==null || s.get('Serial_Number__c')=='')
                                 s.put('Serial_Number__c', asset.get('SerialNumberf__c'));
                            
                             if(s.get('Product_Line__c')==null || s.get('Product_Line__c')=='')
                               s.put('Product_Line__c', asset.get('ProductLine__c'));
                            
                             if(s.get('Product_Type__c')==null || s.get('Product_Type__c')=='')
                                 s.put('Product_Type__c', asset.get('ProductType__c'));
                            
                             if(s.get('Brand__c')==null || s.get('Brand__c')=='')
                                // s.put('Brand__c', asset.get('BrandName__c'));
                                 s.put('Brand__c', asset.get('Product_Brand__c'));
                            
                             if(s.get('In_Warranty__c')==null || s.get('In_Warranty__c')=='')
                                s.put('In_Warranty__c', asset.get('InWarranty__c')==true?'Yes':'No');                       
                            
                             if(s.get('Install_Date__c')==null || s.get('Install_Date__c')=='')
                                 s.put('Install_Date__c', asset.get('Install_Date__c'));
                        }
                    }
                
    }
    
    global static String toJSON(List<surveyAndSobj> objects, Map<String, Schema.FieldSet> ffs) {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartArray();

        for (surveyAndSobj s : objects) {
            sObject sobj = s.obj;
            gen.writeStartObject();
            Schema.FieldSet fieldset = ffs.get((String)sobj.get('Id'));
            List<FieldSetMember> fieldsetm = fieldset.getFields();

            for (FieldSetMember fsm : fieldsetm) {
                String fieldpath = fsm.getFieldPath();
                if (fieldpath.contains('.')) {
                    List<String> fieldpath2 = fieldpath.split('\\.');
                    System.debug(fieldpath2);
                    sObject sobj2 = sobj.getSobject(fieldpath2[0]);
                    if (sobj2 != null) {
                        String val = String.valueOf(sobj2.get(fieldpath2[1]));
                        if (val != null) {
                            gen.writeObjectField(fieldpath, val);
                        } else {
                            gen.writeObjectField(fieldpath, '');
                        }
                    }
                        
                } else {
                    String val = String.valueOf(sobj.get(fieldpath));
                    if (val != null) {
                        gen.writeObjectField(fieldpath, val);
                    } else {
                        gen.writeObjectField(fieldpath, '');
                    }
                }
                
            }
            gen.writeEndObject();
        }   

        gen.writeEndArray();
        return gen.getAsString();
    }
    public static String fieldQuery(String current, Set<String> allFields) {

        for(String f : allFields) {
            current += f + ', ';
        }

        return current;
    }

    public static Set<String> allFieldsCheck(Set<String> currentfields, Schema.FieldSet fieldset) {
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
             currentfields.add('Case_Asset_NOT_ON_LAYOUT__r.ModelNumberf__c');
             currentfields.add('Case_Asset_NOT_ON_LAYOUT__r.SerialNumberf__c');
             currentfields.add('Case_Asset_NOT_ON_LAYOUT__r.ProductLine__c');
             currentfields.add('Case_Asset_NOT_ON_LAYOUT__r.ProductType__c');
             //currentfields.add('Case_Asset_NOT_ON_LAYOUT__r.BrandName__c');
            currentfields.add('Case_Asset_NOT_ON_LAYOUT__r.Product_Brand__c');
             currentfields.add('Case_Asset_NOT_ON_LAYOUT__r.InWarranty__c');
             currentfields.add('Case_Asset_NOT_ON_LAYOUT__r.Install_Date__c');
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
        global Id recordid;
        
        @InvocableVariable(required=true)
        global String service;
        
        @InvocableVariable(required=false)
        global String password;
        
        @InvocableVariable(required=false)
        global String QueryFilter;
    }

    global class surveyAndSobj {
        global MedalliaIntegration.surveyPayload payload {get;set;}
        global sObject obj {get;set;}
    }
}