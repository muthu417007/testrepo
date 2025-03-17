public class UtilityAuth0New1 {
    public static Boolean isSandbox{
        get{return [select IsSandbox from Organization limit 1].IsSandbox;}
    }
    /*
    @future
    public static void publishArticles(){
        List<KnowledgeArticleVersion> adamIsSuperMan = [SELECT Id,KnowledgeArticleId ,PublishStatus FROM KnowledgeArticleVersion 
                                                where publishStatus = 'draft'
                                                and id = 'ka0m00000000x9HAAQ'LIMIT 1];
        for(KnowledgeArticleVersion kav:adamIsSuperMan){
            KbManagement.PublishingService.publishArticle(kav.KnowledgeArticleId, true);
             //KbManagement.PublishingService.editOnlineArticle(kav.KnowledgeArticleId, true);
        }
    }
    */
    
    public static String truncate(String inputString, Integer maxSize){
        if(inputString.length() > maxSize ){
            return inputString.substring(0, maxSize);
        } else {
            return inputString;
        }   
    }
    public static String initCap(String inputString){
        List<String> splitString = inputString.split(' ');
        String responseString = '';
        for (String x : splitString)
        {
            responseString += x.substring(0,1).toUpperCase()+x.substring(1,x.length()) + ' ';
        }
        return responseString;
    }
    
    public static String impliedDecimal(Decimal dec){
        if(dec == null){
            return '';
        }
        Decimal d = dec *100;
        String tempString = string.valueOf(d);
        return tempString.substring(0, tempString.indexOf('.'));
    }
    
    public static String findGeConsumerNumber(String ContactId, String assetId){
        List<GEA_Asset__c> assets = [SELECT ID,BrandName__c,Product_Line_Desc__c,Product_Type_Desc__c,
                                     Model_Number__c, Serial_Number__c,Install_Date__c,Account_Location__r.BillingStreet,
                                     Account_Location__r.BillingCity, Account_Location__r.BillingState,
                                     Account_Location__r.BillingPostalCode
                                    FROM GEA_Asset__c
                                    WHERE id = :assetId LIMIT 1];
        if(assets.size() == 0){return 'Error - No Asset Found';}
        //make open service call
        openCallsDetailsResponse openCalls = ServiceHistory.openCalls(ContactId);
        //loop and check if open service for model number passed in
        String mfgModelNumber = '';
        for(OpenCallsDetailsResponse.Cc_pendingcalls pc: openCalls.cc_pendingcalls){
            //get mfg model number to compare to...
            
            mfgModelNumber = Utility.getMFGNumber(pc.FULL_MODEL_NO);
            if(!string.isBlank(mfgModelNumber)){
                if(mfgModelNumber.contains('Error')){
                    //return 'Error - ' + mfgModelNumber;
                }
                
                if(pc.FULL_MODEL_NO == assets[0].Model_number__c || mfgModelNumber == assets[0].Model_number__c ){
                    return pc.CONSUMER_NO;
                }        
            }
        }
        for(OpenCallsDetailsResponse.Fs_pendingcalls pc: openCalls.fs_pendingcalls){
            mfgModelNumber = Utility.getMFGNumber(pc.FULL_MODEL_NO);
            if(!string.isBlank(mfgModelNumber)){
                if(mfgModelNumber.contains('Error')){
                   // return 'Error - ' + mfgModelNumber;
                }
                if(pc.FULL_MODEL_NO == assets[0].Model_number__c || mfgModelNumber == assets[0].Model_number__c){
                    return pc.CONSUMER_NO;
                }
            }
        }
        
        
        //Create CN1 consumer number
        User u = [Select SSO_ID__c from User where Id =: UserInfo.getUserId() LIMIT 1];        
        
        Contact_Information__c  newCI = new Contact_Information__c ();
        Contact contactRec = [SELECT lastName,firstName,phone,email
                                 FROM Contact
                                 WHERE id = :contactId LIMIT 1];
        
            contact CN1Contact = new contact();
            CN1Contact.lastName = contactRec.lastName;
            CN1Contact.firstName = contactRec.firstName;
            CN1Contact.Phone = contactRec.phone;
            CN1Contact.Email = contactRec.email;
            account a = new account();
            a.BillingStreet = assets[0].Account_Location__r.BillingStreet;
            a.BillingCity =  assets[0].Account_Location__r.BillingCity;
            a.BillingPostalCode = assets[0].Account_Location__r.BillingPostalCode;
            a.BillingState = assets[0].Account_Location__r.BillingState;
            CN1Response CN1Resp = Utility.CN1CustomerNumber(CN1Contact, u.SSO_ID__c, a);
            
            
            //create Consumer Number rec
            
            newCI.ID_Type__c = 'GE Consumer Number';
            newCI.Contact__c = contactId;
            newCI.Identifier__c = CN1Resp.ConsumerNo;
       //     insert newCI;
            Integer consumerNumber = integer.valueOf(CN1Resp.ConsumerNo);    
      
        
        
        //public Static CN1Response CN1CustomerNumber(Contact c, String ssno, Account a){
        //add asset to that consumer number via api call
        //get GEA_asset record
       
        
        
        if(assets.size() == 0){
            return null;
        }
        GEA_Asset__c asset = assets[0];
        String installDate = '';
        if(asset.Install_Date__c != null){
            Integer d = asset.Install_Date__c.day();
            Integer mo = asset.Install_Date__c.month();
            Integer yr = asset.Install_Date__c.year();
            DateTime tempDate = DateTime.newInstance(yr, mo, d);
            installDate = tempDate.format('yyyyMMdd');
            system.debug(installDate);
        }
        
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        if(utility.isSandbox){
            request.setEndpoint('callout:Sandbox_Create_Asset');   
        } else {
            request.setEndpoint('callout:Production_Create_Asset');
        }
        
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('geasfdccode','ApplServiceCloudGEA');
        request.setHeader('appname','SiebelXML');
        
        String postBody = '{"request": "InsertUpdateOwnershipRequest","searchvalue": "",' +
            '"payload": {"ConsumerNo": "' + consumerNumber + '",' +
    //' "AssetNumber": "7", ' +   
            '"BrandCode": "' + asset.BrandName__c + '", ' +   
            '"ProductTypeDesc": "' + asset.Product_Type_Desc__c + '", ' +    
            '"ProductLineDesc": "' + asset.Product_Line_Desc__c + '", ' +  
            '"ModelNumber": "' + asset.Model_Number__c + '", ' +    
            '"SerialNumber": "' +  asset.Serial_Number__c + '", ' +   
            '"ItemCount": "1",' +
            '"AddressNumber": "1",' +
            '"InstallationDate": "' + installDate + '", ' +  
            '"Comments": "",' +
            '"OwnershipEndDate": "",' +
            '"UpdateUserId": "' + u.SSO_ID__c + '",' +   
            '"UpdatedDate": "' + datetime.now().format('yyyyMMddhhmm00') +'"}}';  
        
        

        // Set the body as a JSON object
        request.setBody(postBody);
        request.setTimeout(25000);
        HttpResponse response;
        if(!test.isRunningTest()){
            system.debug('request ' + postBody);
            system.debug('request2 ' + postBody.substring(250, postBody.length()));
            response = http.send(request);
            system.debug('response ' + response);
            system.debug('response body ' + response.getBody());
        } else {
            response = new HttpResponse();
            response.setStatusCode(200);
            String testBody = '{"ConsumerNo": "187616956","AddressId": "01876169560001","PhoneId": "01876169560001"}';
            response.setBody(testBody);
        }
        
        
        insert newCI;    
       
            
        
        // Parse the JSON response
        if (response.getStatusCode() == 200) {
            System.debug(response.getBody());
         //   CN1Response  resp = CN1Response.parse(response.getBody());
         //   system.debug('CN1Response ' + resp);
         
            asset.Create_Asset_Response__c = response.getBody();
            //update asset;
            return string.valueOf(consumerNumber);
        } else {
            //system.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            //apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus()));
            asset.Create_Asset_Response__c = response.getBody();
            //update asset;
            return 'Error - ' + response.getBody(); 
        }
        
        
    }
    
    public static void createSiebelAssetRealTime(String assetId, String contactId){
        
        
        
    }
    
    @future(callout=true)
    public static void createSiebelAsset(String assetId, String contactId){
        
        //get GEA_asset record
        User u = [Select SSO_ID__c from User where Id =: UserInfo.getUserId() LIMIT 1];
        
        List<GEA_Asset__c> assets = [SELECT ID,BrandName__c,Product_Line_Desc__c,Product_Type_Desc__c,
                                     Model_Number__c, Serial_Number__c,Install_Date__c,Account_Location__r.BillingStreet,
                                     Account_Location__r.BillingCity, Account_Location__r.BillingState,
                                     Account_Location__r.BillingPostalCode
                                    FROM GEA_Asset__c
                                    WHERE id = :assetID LIMIT 1];
        if(assets.size() == 0){
            return;
        }
        GEA_Asset__c asset = assets[0];
        String installDate = '';
        if(asset.Install_Date__c != null){
            Integer d = asset.Install_Date__c.day();
            Integer mo = asset.Install_Date__c.month();
            Integer yr = asset.Install_Date__c.year();
            DateTime tempDate = DateTime.newInstance(yr, mo, d);
            installDate = tempDate.format('yyyyMMdd');
            system.debug(installDate);
        }
        
        List<Contact_Information__c> contactInfoRecs = [SELECT ID,Identifier__c,ID_Type__c
                                                       FROM Contact_Information__c
                                                       WHERE Contact__c =: contactId
                                                       AND Identifier__c != NULL
                                                       AND  (NOT  Identifier__c like '999999%') 
                                                       AND ID_Type__c ='GE Consumer Number'];
       Long consumerNumber = 0;
        for(Contact_Information__c ci : contactInfoRecs){
            if(Long.valueOf(ci.Identifier__c) > consumerNumber){
                consumerNumber = long.valueOf(ci.Identifier__c);
            }
        }
        
        Contact_Information__c  newCI = new Contact_Information__c ();
        Boolean insertCI = false;
        if(consumerNumber == 0){
            insertCI = true;
            Contact contactRec = [SELECT lastName,firstName,phone,email
                                 FROM Contact
                                 WHERE id = :contactId LIMIT 1];
            contact CN1Contact = new contact();
            CN1Contact.lastName = contactRec.lastName;
            CN1Contact.firstName = contactRec.firstName;
            CN1Contact.Phone = contactRec.phone;
            CN1Contact.Email = contactRec.email;
            account a = new account();
            a.BillingStreet = assets[0].Account_Location__r.BillingStreet;
            a.BillingCity =  assets[0].Account_Location__r.BillingCity;
            a.BillingPostalCode = assets[0].Account_Location__r.BillingPostalCode;
            a.BillingState = assets[0].Account_Location__r.BillingState;
            CN1Response CN1Resp = Utility.CN1CustomerNumber(CN1Contact, u.SSO_ID__c, a);
            
            
            //create Consumer Number rec
            
            newCI.ID_Type__c = 'GE Consumer Number';
            newCI.Contact__c = contactId;
            newCI.Identifier__c = CN1Resp.ConsumerNo;
       //     insert newCI;
            consumerNumber = integer.valueOf(CN1Resp.ConsumerNo);    
        }
        
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        if(utility.isSandbox){
            request.setEndpoint('callout:Sandbox_Create_Asset');   
        } else {
            request.setEndpoint('callout:Production_Create_Asset');
        }
        
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('geasfdccode','ApplServiceCloudGEA');
        request.setHeader('appname','SiebelXML');
        
        String postBody = '{"request": "InsertUpdateOwnershipRequest","searchvalue": "",' +
            '"payload": {"ConsumerNo": "' + consumerNumber + '",' +
    //' "AssetNumber": "7", ' +   
            '"BrandCode": "' + asset.BrandName__c + '", ' +   
            '"ProductTypeDesc": "' + asset.Product_Type_Desc__c + '", ' +    
            '"ProductLineDesc": "' + asset.Product_Line_Desc__c + '", ' +  
            '"ModelNumber": "' + asset.Model_Number__c + '", ' +    
            '"SerialNumber": "' +  asset.Serial_Number__c + '", ' +   
            '"ItemCount": "1",' +
            '"AddressNumber": "1",' +
            '"InstallationDate": "' + installDate + '", ' +  
            '"Comments": "",' +
            '"OwnershipEndDate": "",' +
            '"UpdateUserId": "' + u.SSO_ID__c + '",' +   
            '"UpdatedDate": "' + datetime.now().format('yyyyMMddhhmm00') +'"}}';  
        
        

        // Set the body as a JSON object
        request.setBody(postBody);
        request.setTimeout(25000);
        HttpResponse response;
        if(!test.isRunningTest()){
            system.debug('request ' + postBody);
            system.debug('request2 ' + postBody.substring(250, postBody.length()));
            response = http.send(request);
            system.debug('response ' + response);
            system.debug('response body ' + response.getBody());
        } else {
            response = new HttpResponse();
            response.setStatusCode(200);
            String testBody = '{"ConsumerNo": "187616956","AddressId": "01876169560001","PhoneId": "01876169560001"}';
            response.setBody(testBody);
        }
        
        if(insertCI){
            insert newCI;    
        }
            
        
        // Parse the JSON response
        if (response.getStatusCode() == 200) {
            System.debug(response.getBody());
         //   CN1Response  resp = CN1Response.parse(response.getBody());
         //   system.debug('CN1Response ' + resp);
         
            asset.Create_Asset_Response__c = response.getBody();
            update asset;
            return;
        } else {
            //system.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            //apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus()));
            asset.Create_Asset_Response__c = response.getBody();
            update asset;
            return; 
        }
        
        
    }
    //AUTHO CHANGE START//
    public static Long FuncDateDurationDiff(DateTime start_date_time, DateTime end_date_time) {
        Long start_in_seconds = (start_date_time.year() * 31556926) + (start_date_time.dayOfYear() * 86400) + (start_date_time.hour() * 3600) + (start_date_time.minute() * 60) + (start_date_time.second() * 1); //convert the start date to a value in seconds
        Long end_in_seconds = (end_date_time.year() * 31556926) + (end_date_time.dayOfYear() * 86400) + (end_date_time.hour() * 3600) + (end_date_time.minute() * 60) + (end_date_time.second() * 1); //convert the end date to a value in seconds
        Long total_duration_in_seconds = end_in_seconds - start_in_seconds; //duration in seconds
        Long TotalMinutes = math.floor(total_duration_in_seconds/60).intValue(); //number of minutes
        system.debug('TotalMinutes: ' + TotalMinutes);
        return TotalMinutes; //pass back the final string
    }
    //AUTHO CHANGE END//
    
    public static String getGraphQLTokenAuth0New1(){
        //AUTHO CHANGE START//
        Boolean boolIsActive;
        Integer intAuthExpires;
        Auth0TokenTimeout__c valAuth = Auth0TokenTimeout__c.getInstance('00e4P000001Uk36QAC');
        if(valAuth != null)
        {   
            if(valAuth.IsActive__c != null)
            {
                boolIsActive = valAuth.IsActive__c;
                system.debug('boolIsActive - ' + boolIsActive );
            }
            else
            {
                boolIsActive = false;
            }
            if(valAuth.TimeoutMins__c != '' && valAuth.TimeoutMins__c != null)
            {
                intAuthExpires =  integer.valueOf(valAuth.TimeoutMins__c);
                system.debug('intAuthExpires - ' + intAuthExpires );
            }
            else
            {
                intAuthExpires = 900;
            }
            //
            if (boolIsActive == true)
            {
                Cache.OrgPartition OrgPart = Cache.Org.getPartition('local.Auth0');
                if (OrgPart.contains('AuthToken')) 
                {
                    system.debug('ORG TOKEN FOUND IN CACHE - ' + Cache.Org.get('local.Auth0.AuthToken'));
                    String strOrgData = (String)Cache.Org.get('local.Auth0.AuthToken');
                    String[] arrData = strOrgData.split(';,;');
                    DateTime StartDatetime = (DateTime)DateTime.parse(arrData[0]);
                    datetime dtEnd = datetime.Now();
                    String StrEndDateTime = dtEnd.format();
                    DateTime EndDatetime = (DateTime)DateTime.parse(StrEndDateTime);
                    System.debug('START DATE VALUE FROM CACHE : ' + StartDatetime);
                    System.debug('END DATE VALUE : ' + EndDatetime);
                    system.debug('Token Generated Time Difference: ' + FuncDateDurationDiff(StartDatetime, EndDatetime));
                    System.debug('Token Expiry in Minutes : ' + intAuthExpires);
                    //
                    if(FuncDateDurationDiff(StartDatetime, Datetime.now()) < intAuthExpires)
                    {
                        system.debug('ORG TOKEN NOT EXPIRED- REUSING THE OLD TOKEN - ' + Cache.Org.get('local.Auth0.AuthToken'));
                        system.debug('arrData0 - Created Datetime : ' + arrData[0]);
                        system.debug('arrData1 - Token : ' + arrData[1]);
                        system.debug((String)arrData[1]);
                        return (String)arrData[1];
                    }
                    else
                    {
                        system.debug('ORG TOKEN EXPIRED- GENERATING NEW TOKEN - ' + Cache.Org.get('local.Auth0.AuthToken'));
                    }
                }
                else
                {
                    system.debug('ORG TOKEN NOT FOUND IN CACHE. NEED TO GENERATE NEW TOKEN');
                }
            }
            else
            {
                system.debug('AUTH0 VALIDATION IS INACTIVE');
            }
        }
        //AUTHO CHANGE END//
        Http httpToken = new Http();
        HttpRequest requestToken = new HttpRequest();
        if(utility.isSandbox){
            requestToken.setEndpoint('callout:GEAoAuth');   
        } else {
            requestToken.setEndpoint('callout:GEAoAuth');
        }
        
        requestToken.setMethod('POST');
        requestToken.setHeader('Content-Type', 'application/json;charset=UTF-8');
        GraphQL__mdt settings = [SELECT  Audience__c,Client_Id__c,Client_Secret__c 
                                 From GraphQL__mdt 
                                 Where DeveloperName = 'GraphQL_Settings' LIMIT 1];

        //
        //settings.Client_Id__c = 'iKBqZOO6HyMYWbF4wLV74ZFNFHhU3PEL';
        //settings.Client_Secret__c = 'tYbI_0Ak6gemZoqNyp-T9EvjM-fd1yU08xQbQZVptti6xpEbM5kt1q2XWr6ZfTbS';
        //settings.Audience__c = 'front-api-dev.c360.geappliances.com';
        //
        String postBodyToken = '{"client_id":"' + settings.Client_Id__c + 
            '","client_secret":"' + settings.Client_Secret__c + 
            '","audience":"' + settings.Audience__c + '","grant_type":"client_credentials"}';
        
        // Set the body as a JSON object
        requestToken.setBody(postBodyToken);
        requestToken.setTimeout(25000);
        HttpResponse responseToken;

        if(!test.isRunningTest()){
            responseToken = httpToken.send(requestToken);
            system.debug('request ' + postBodyToken);
            system.debug('response ' + responseToken);
            system.debug('response body ' + responseToken.getBody());
        } else {
            responseToken = new HttpResponse();
            responseToken.setStatusCode(200);
            String testBody = '{"access_token": "eyJ0hZJqr6eBzw","scope": "read:person read:location ","expires_in": 86400, "token_type": "Bearer"}';
            responseToken.setBody(testBody);
        }


        // Parse the JSON response
        GEAoAuthResponse  resp;
        if (responseToken.getStatusCode() == 200) {
            System.debug(responseToken.getBody());
            resp = GEAoAuthResponse.parse(responseToken.getBody());
            //AUTH0 CHANGE START//
            if (boolIsActive == true)
            {
                datetime dtStart = datetime.Now();
                String StrStartDateTime = dtStart.format();
                Cache.Org.put('local.Auth0.AuthToken', StrStartDateTime + ';,;' + resp.access_token);
                system.debug('GENERATED NEW TOKEN - ' + Cache.Org.get('local.Auth0.AuthToken'));
                system.debug(resp.access_token);
            }
            else
            {
                system.debug(resp.access_token);
                system.debug('AUTH0 VALIDATION IS INACTIVE');
            }
            //AUTHO CHANGE END//
            return resp.access_token;
        } else {
            system.debug('The status code returned was not expected: ' +
            responseToken.getStatusCode() + ' ' + responseToken.getStatus());
            String message = 'Error ' + responseToken.getStatusCode() + ' ' + responseToken.getStatus();
            return message; 
        }
           
    }
   
    public Static String getMFGNumber(String modelNumber){
        User u = [Select SSO_ID__c from User where Id =: UserInfo.getUserId() LIMIT 1];  
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        //request.setEndpoint('https://gc9zw2x6fa.execute-api.us-east-1.amazonaws.com/DEV/zonedetails');
        if(utility.isSandbox){
            request.setEndpoint('callout:Sandbox_Get_MFG_Model_Number');   
        } else {
            request.setEndpoint('callout:Production_Get_MFG_Model_Number');
        }
        
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('geasfdccode','ApplServiceCloudGEA');
        request.setHeader('appname','SiebelXML');
        String postBody = '{"request": "FetchPDMFGRequest","payload": {"MfgModelNumber": "' + modelNumber +'","UserNo": "' + u.SSO_ID__c +'"}}';
        
        
        // Set the body as a JSON object
        request.setBody(postBody);
        request.setTimeout(25000);
        HttpResponse response;
            
        if(!test.isRunningTest()){
            response = http.send(request);
            system.debug('request ' + postBody);
            system.debug('response ' + response);
            system.debug('response body ' + response.getBody());
        } else {
            response = new HttpResponse();
            response.setStatusCode(200);
            String testBody = '{"request": "FetchPDMFGRequest","payload": {"MfgModelNumber": "AJCQ08ACFQ1","UserNo": "084998"}}';
            response.setBody(testBody);
        }
            
        // Parse the JSON response
        if (response.getStatusCode() == 200 && !response.getBody().contains('error') ) {
            System.debug(response.getBody());
            MfgResponse resp = MfgResponse.parse(response.getBody());
            return resp.MktModelNumber;
        } else {
            system.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            system.debug( response.getBody());
           // MfgResponse errorResponse = new MfgResponse();
            //errorResponse.errorMessage = 'Error ' + response.getStatusCode() + ' ' + response.getBody();
           // return errorResponse;
            return 'Error ' + response.getStatusCode() + ' ' + response.getBody();
        }
        
    }
    
    public Static zoneDetailsResponse addressVerify(String zip){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        //request.setEndpoint('https://gc9zw2x6fa.execute-api.us-east-1.amazonaws.com/DEV/zonedetails');
        if(utility.isSandbox){
            request.setEndpoint('callout:Sandbox_ZoneDetails');   
        } else {
            request.setEndpoint('callout:Production_ZoneDetails');
        }
        
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('geasfdccode','ApplServiceCloudGEA');
        request.setHeader('appname','SiebelXML');
        String postBody = '{"request": "ZoneDetailsRequest","payload": {"PostalAreaCode": "' + zip +'"}}';
        // Set the body as a JSON object
        request.setBody(postBody);
        request.setTimeout(25000);
        HttpResponse response;
            
        if(!test.isRunningTest()){
            response = http.send(request);
            system.debug('request ' + postBody);
            system.debug('response ' + response);
            system.debug('response body ' + response.getBody());
        } else {
            response = new HttpResponse();
            response.setStatusCode(200);
            String testBody = '{"CityName": "LOUISVILLE","StateCode": "KY","PostalAreaCode": "40225","RegionNo": "126","ZoneCode": "57"}';
            response.setBody(testBody);
        }
            
        // Parse the JSON response
        if (response.getStatusCode() == 200) {
            System.debug(response.getBody());
            zoneDetailsResponse resp = zoneDetailsResponse.parse(response.getBody());
            return resp;
        } else {
            system.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            system.debug( response.getBody());
            zoneDetailsResponse errorResponse = new zoneDetailsResponse();
            errorResponse.errorMessage = 'Error ' + response.getStatusCode() + ' ' + response.getBody();
            return errorResponse;
        }
        
    }
    
    public Static CN1Response CN1CustomerNumber(Contact c, String ssno, Account a){
        
       // Contact contactRec = [SELECT ID,FirstName,LastName 
       //                      FROM CONTACT
       //                      WHERE ID = :c.id LIMIT 1];
       //newAccount.BillingStreet = street;
       //         newAccount.BillingCity = resp.CityName;
        //        newAccount.BillingState = resp.StateCode;
        //        newAccount.BillingPostalCode = zip;       
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        if(utility.isSandbox){
            request.setEndpoint('callout:Sandbox_CN1_Customer_Number');   
        } else {
            request.setEndpoint('callout:Production_CN1_Customer_Number');
        }
        
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('geasfdccode','ApplServiceCloudGEA');
        request.setHeader('appname','SiebelXML');
        String phoneNo = '';
        If(!string.isBlank(c.phone)){
            phoneNo = c.phone;
            phoneNo = phoneNo.replaceAll('-','');
            phoneNo = phoneNo.replace('(','');
            phoneNo = phoneNo.replace(')','');
        }
        //String postBody = '{"request": "taxonline","payload": {"ProductCode": "90029","ZipCode": "' + proRateCalc[0].Billing_Postal_Code__c + '","CityName": "' + proRateCalc[0].Billing_City__c + '","State": "' + proRateCalc[0].Billing_State__c + '","Amount": "' + proRateCalc[0].Prorate_Price__c +'"}}';
        String postBody = '{"request": "ConsumerInsertUpdateRequest","searchvalue": "","payload": {"ConsumerNo": "","LastName": "' + 
            c.LastName + '","FirstName": "' + c.FirstName + '", ' + '"ConsumerTitle": "","TelephoneNo": "' + phoneNo + '", "EmailAddr": "' + 
            c.Email + '","CreateUserId": "' + ssno + '", "UpdateUserId": "' + ssno + '", "Addr1": "' + a.BillingStreet + '", ' +
            '"Addr2": "","Addr3": "", "Addr4": "", "CityName": "' + a.BillingCity + '", "CityNameOverride": "", "StateCode": "' + a.BillingState + '",  "PostalAreaCode": "' + 
            a.BillingPostalCode + '", ' + '"BusinessIndicator": "N", "BusinessName": "", "DbaName": ""  }} ';

        // Set the body as a JSON object
        request.setBody(postBody);
        request.setTimeout(50000);
        HttpResponse response;
        if(!test.isRunningTest()){
            response = http.send(request);
            system.debug('request ' + postBody);
            system.debug('response ' + response);
            system.debug('response body ' + response.getBody());
        } else {
            response = new HttpResponse();
            response.setStatusCode(200);
            String testBody = '{"ConsumerNo": "187616956","AddressId": "01876169560001","PhoneId": "01876169560001"}';
            response.setBody(testBody);
        }
        
        // Parse the JSON response
        if (response.getStatusCode() == 200) {
            System.debug(response.getBody());
            CN1Response  resp = CN1Response.parse(response.getBody());
            system.debug('CN1Response ' + resp);
            if(resp.ConsumerNo == null){
                resp.errorMessage = response.getBody();
            }
            return resp;
        } else {
            system.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus()));
            return null; 
        }
    
    }
    
    public Static searchPhoneResponse getArchivedContacts(String phone){
        searchPhoneResponse searchResults;
        if(phone != null && phone != ''){
            
            String token = Utility.getGraphQLToken();
            //if token has error return error
            if(token.substring(0,4) == 'Error'){
                searchResults.status.responseCode = '201';
                searchResults.status.message = token;
                return searchResults;
            }
            Http httpCall = new Http();
            HttpRequest request = new HttpRequest();
            if(utility.isSandbox){
                request.setEndpoint('callout:Sandbox_GraphQL_Search');   
            } else {
                request.setEndpoint('callout:Production_GraphQL_Search');
            }
            //return list of records
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/graphql');
            request.setHeader('Authorization', token);                       
            system.debug(token);
            // String postBody = '{"request": "ZoneDetailsRequest","payload": {"PostalAreaCode": "' + zipCode +'"}}';
            // 6179654594
            String postBody = '{"variables":{"PhoneNumber":"' + phone.trim() + '"},"query":"query ($PhoneNumber: String!) { HouseHoldByPhone(phoneNumber: $PhoneNumber) {Phone{PhoneNumber,IsPrimaryPhone,PhoneTypeName,PhoneUseTypeName},Details{COPSPersonNumber,GEConsumerNo,PersonDetailID,PersonID},ClientPersonCode,FirstName,Gender,IsDead,LastName,MiddleName,PersonID,Orders{AddressLine1,DataSourceCode,DataSourceName,FirstName,LastName,Locality,OrderCreatedBy,OrderDate,OrderDetails{AssetID,BrandName,CleansedModelNumber,DiscountPercent,InvoiceLine,InvoiceNumber,ManufacturerCost,NetInvoiceValue,OrderID,OriginalModelNumber,PartNumber,ProductCategoryName,ProductDescription,ProductLineName,TaxAmount},OrderDiscountAmount,OrderGrossAmount,OrderID,OrderNetAmount,OrderNumber,OrderPaymentMethod,OrderPlacedOn,OrderPromoCode,OrderShipmentAmount,OrderTaxAmount,OrderUniqueKey,PersonID,PostalCode,Region},EmailAddresses{EmailAddress,IsPrimaryEmail,IsPrimaryPerson, MYAMyAccountId}PersonID,plevel,Salutation,FirstName,LastName,Assets{AssetClassName,AssetID,AssetScrappedOn,AssetShippedOn,BrandName,CleansedModelNumber,IsProductReturned,LocationID,MACAddress,OriginalEngineeringModelNumber,OwnershipStartedOn,ProductCategoryName,ProductDescription,ProductLineName,SerialNumber},Locations{LocationID,AddressLine1,AddressLine2,Locality,Region,PostalCode,CountryCode}}} "}';
            // Set the body as a JSON object
            request.setBody(postBody);
            request.setTimeout(60000);
            HttpResponse response;
            
            if(!test.isRunningTest()){
                response = httpCall.send(request);
                system.debug('request ' + postBody);
                system.debug('response ' + response);
                system.debug('response body ' + response.getBody());
            } else {
                response = new HttpResponse();
                response.setStatusCode(200);
                StaticResource sr = [select id,body from StaticResource Where Name = 'searchPhoneTestResponse'];
                String testBody = sr.body.toString();
                response.setBody(testBody);
            }
            
            
            system.debug('response ' + response.getBody());
            // Parse the JSON response
            if (response.getStatusCode() == 200 && !response.getBody().contains('"HouseHoldByPhone":null') ) {
                                                                                 
                System.debug(response.getBody());
                
                searchResults = searchPhoneResponse.parse(response.getBody());
                //searchResults.status.responseCode = '201';
                return searchResults;
                //showArchived=true;
            } else if (response.getStatusCode() == 200 && response.getBody().contains('"HouseHoldByPhone":null')){
                searchResults.status = new searchPhoneResponse.statusMessage();
                searchResults.status.message = 'Error ' + response.getBody();
                return searchResults;
            
            } else {
                system.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
                //apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'The status code returned was not expected: ' +
                //response.getStatusCode() + ' ' + response.getStatus()));
                searchResults.status.responseCode = '201';
                searchResults.status.message = 'Error ' + response.getStatusCode() + ' ' + response.getStatus() ;
                return searchResults;
            }
        }
        return searchResults;
    }
    
    public Static searchIdResponse getById(String id){
        searchIdResponse searchResults = new searchIdResponse() ;
        if(id != null && id != ''){
            
            String token = Utility.getGraphQLToken();
            //if token has error return error
            if(token.substring(0,4) == 'Error'){
                searchResults.status.responseCode = '201';
                searchResults.status.message = token;
                return searchResults;
            }
            Http httpCall = new Http();
            HttpRequest request = new HttpRequest();
            if(utility.isSandbox){
               request.setEndpoint('callout:Sandbox_GraphQL_Search_ID');

            } else {
                request.setEndpoint('callout:Production_GraphQL_Search_ID');
            }
            //return list of records
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/graphql');
            request.setHeader('Authorization', token);                       
            system.debug(token);
            //                 {"variables":{"PersonID":"2440481","query":"query ($PersonID: String!) { PersonById(id: $PersonID)
            String postBody = '{"variables":{"PersonID":"' + id.trim() + '"},"query":"query ($PersonID: String!) { PersonById(id: $PersonID) {Phone{PhoneNumber,IsPrimaryPhone,PhoneTypeName,PhoneUseTypeName},Details{COPSPersonNumber,GEConsumerNo,PersonDetailID,PersonID},ClientPersonCode,FirstName,Gender,IsDead,LastName,MiddleName,PersonID,Orders{AddressLine1,DataSourceCode,DataSourceName,FirstName,LastName,Locality,OrderCreatedBy,OrderDate,OrderDetails{AssetID,BrandName,CleansedModelNumber,DiscountPercent,InvoiceLine,InvoiceNumber,ManufacturerCost,NetInvoiceValue,OrderID,OriginalModelNumber,PartNumber,ProductCategoryName,ProductDescription,ProductLineName,TaxAmount},OrderDiscountAmount,OrderGrossAmount,OrderID,OrderNetAmount,OrderNumber,OrderPaymentMethod,OrderPlacedOn,OrderPromoCode,OrderShipmentAmount,OrderTaxAmount,OrderUniqueKey,PersonID,PostalCode,Region},EmailAddresses{EmailAddress,IsPrimaryEmail,IsPrimaryPerson, MYAMyAccountId}PersonID,plevel,Salutation,FirstName,LastName,Assets{AssetClassName,AssetID,AssetScrappedOn,AssetShippedOn,BrandName,CleansedModelNumber,IsProductReturned,LocationID,MACAddress,OriginalEngineeringModelNumber,OwnershipStartedOn,ProductCategoryName,ProductDescription,ProductLineName,SerialNumber},Locations{LocationID,AddressLine1,AddressLine2,Locality,Region,PostalCode,CountryCode}}} "}';
            system.debug('post body'  + postBody);
            // Set the body as a JSON object
            request.setBody(postBody);
            request.setTimeout(60000);
            HttpResponse response ;
            if(!test.isRunningTest()){
                response = httpCall.send(request);
                system.debug('request ' + postBody);
                system.debug('response ' + response);
                system.debug('response body ' + response.getBody());
            } else {
                response = new HttpResponse();
                response.setStatusCode(200);
                StaticResource sr = [select id,body from StaticResource Where Name = 'searchIdTestResponse'];
                String testBody = sr.body.toString();
                response.setBody(testBody);
            }
            // Parse the JSON response
             System.debug(response.getBody());
            if (response.getStatusCode() == 200 && !response.getBody().contains('"PersonById":null')) {
                
                
                searchResults = searchIdResponse.parse(response.getBody());
                
                return searchResults;
                
                //showArchived=true;
            } else if (response.getStatusCode() == 200 && response.getBody().contains('"PersonById":null')){
                searchResults.status = new searchIdResponse.statusMessage();
                searchResults.status.message = 'Error ' + response.getBody();
                return searchResults;
            
            } else {
                system.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
                //apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'The status code returned was not expected: ' +
                //response.getStatusCode() + ' ' + response.getStatus()));
                searchResults.status.responseCode = '201';
                searchResults.status.message = 'Error ' + response.getStatusCode() + ' ' + response.getStatus() ;
                return searchResults;
 
            }
        }
            return searchResults;

    }
    
    
    public Static Id restoreContact(searchPhoneResponse.HouseHoldByPhone sr){
        system.debug('response ' + sr);
        //create contact
        //for(searchPhoneResponse.HouseHoldByPhone sr: searchResults.Data.HouseHoldByPhone){
            //if(index1 == sr.PersonID){
                Contact newContact = new Contact();
                newContact.FirstName = sr.FirstName ;
                newContact.LastName = sr.LastName;
                if(string.isBlank(newContact.LastName)){
                    newContact.LastName = sr.FirstName;         
                }
                newContact.MiddleName = sr.MiddleName;
                newContact.PersonID__c = sr.PersonID;
                newContact.Gender__c = sr.Gender;
    Schema.SObjectField f = Contact.Fields.PersonID__c;
    Database.UpsertResult cr = Database.upsert(newContact, f, false);  
        
        
        
       // insert newContact;
                
                // locations/accounts
                Set<String> locIDs = new Set<String>();
                for(searchPhoneResponse.Locations  l: sr.Locations){
                    locIDs.add(l.LocationID);       
                }
                
                List<Account> existingAccounts = [SELECT ID,LocationID__c FROM ACCOUNT WHERE LocationID__c in :locIDs];
                
                List<Account> newAccounts = new List<Account>();
                List<GEA_AccountContactRelation__c> acr = new List<GEA_AccountContactRelation__c>();
                system.debug('locations ' + sr.Locations);
                for(searchPhoneResponse.Locations  l: sr.Locations){
                    boolean accountFound = false;
                    for(Account a: existingAccounts){
                        if(a.LocationID__c == l.LocationID){
                            GEA_AccountContactRelation__c newACR = new GEA_AccountContactRelation__c();
                            newACR.Contact__c = newContact.id;
                            newACR.Account__c = a.id;
                            acr.add(newACR);
                            accountFound = true;
                            newContact.accountId = a.id;
                        }    
                    }
                    if(!accountFound){
                        Account newAccount = new Account();
                        newAccount.name = l.AddressLine1 + ' ' + l.Locality + ' ' + l.Region + ' ' + l.PostalCode;
                        newAccount.BillingStreet = l.AddressLine1;
                        newAccount.BillingCity = l.Locality;
                        newAccount.BillingState = l.Region;
                        newAccount.BillingPostalCode = l.PostalCode;
                        newAccount.LocationID__c = l.locationID;
                        newAccounts.add(newAccount);
                    }
                    
                }
                
                if(newAccounts.size() > 0){
                    insert newAccounts;
                    for(Account a: newAccounts){
                        GEA_AccountContactRelation__c newACR = new GEA_AccountContactRelation__c();
                        newACR.Contact__c = newContact.id;
                        newACR.Account__c = a.id;
                        acr.add(newACR);
                        newContact.accountId = a.id;
                    }
                    
                }
                //Schema.SObjectField facr = GEA_AccountContactRelation__c.Fields.LocationPersonID__c;
                //List<Database.UpsertResult> crAcr = Database.upsert(acr, facr, false);
                insert acr;
                
                
                // assets
                Set<String> assetIDs = new Set<String>();
                Set<String> assetAccountIds = new Set<String>();
                for(searchPhoneResponse.Assets  a: sr.Assets){
                    assetIDs.add(a.AssetID);
                    assetAccountIds.add(a.LocationID);
                }
                
                List<Account> existingAssetAccounts = [SELECT ID,LocationID__c FROM ACCOUNT WHERE LocationID__c in :assetAccountIds];
                List<GEA_Asset__c> existingAssets = [SELECT ID,AssetID__c FROM GEA_Asset__c WHERE AssetID__c in :assetIDs];
                
                List<GEA_Asset__c> newAssets = new List<GEA_Asset__c>();
                
                for(searchPhoneResponse.Assets  a: sr.Assets){
                    boolean assetFound = false;
                    for(GEA_Asset__c ea: existingAssets){
                        if(ea.AssetID__c == a.AssetID){
                            assetFound = true;
                        }    
                    }
                    if(!assetFound){
                        GEA_Asset__c newAsset = new GEA_Asset__c();
                        newAsset.AssetClassName__c = a.AssetClassName;
                        newAsset.AssetID__c = a.AssetID;
                        if(a.AssetScrappedOn != null){
                            String dateString = a.AssetScrappedOn.subString(0,10);
                            newAsset.AssetScrappedOn__c = date.valueOf(dateString);
                        }
                        if(a.AssetShippedOn != null){
                            String dateString2 = a.AssetShippedOn.subString(0,10);
                            newAsset.AssetShippedOn__c = date.valueOf(dateString2);
                        }
                        newAsset.BrandName__c = a.BrandName;
                        newAsset.CleansedEngineeringModelNumber__c = a.CleansedModelNumber;
                     //   newAsset.IsProductReturned__c = a.IsProductReturned;
                        for(Account ac: existingAssetAccounts){
                            if(ac.LocationID__c == a.LocationID ){
                                newAsset.Account_Location__c = ac.id;
                                break;
                            }
                        }
                        newAsset.MACAddress__c = a.MACAddress;
                        newAsset.OriginalEngineeringModelNumber__c = a.OriginalEngineeringModelNumber;
                        if(a.OwnershipStartedOn != null){
                            String dateString3 = a.OwnershipStartedOn.subString(0,10);
                            newAsset.OwnershipStartedOn__c = date.valueOf(dateString3);
                        }
                     //   newAsset. ProductCategoryName;
                        newAsset.ProductDescription__c = a.ProductDescription;
                        newAsset.Product_Line_Desc__c = a.ProductLineName;
                        newAsset.Serial_Number__c = a.SerialNumber;
                        
                        newAssets.add(newAsset);
                    }
                    
                }
                
                if(newAssets.size() > 0){
                    insert newAssets;
                }
          
                
                // contact info with consumer number from PersonDetail
                List<Contact_Information__c> contactInformation = new List<Contact_Information__c>();
                for(searchPhoneResponse.PersonDetail  a: sr.Details){
                    Contact_Information__c newCi = new Contact_Information__c();
                    newCi.ID_Type__c = 'GE Consumer Number';
                    newCi.PersonDetailID__c = a.PersonDetailID;
                    newCi.Contact__c = newContact.id;
                    newCi.Identifier__c = a.GEConsumerNo;
                    contactInformation.add(newCi);
  
                }
        //upsert by personDetailID
               
                Schema.SObjectField fCI = Contact_Information__c.Fields.PersonDetailID__c;
                List<Database.UpsertResult> crCI = Database.upsert(contactInformation, fCI, false);
                //insert contactInformation;   
                
                
                //emails
                for(searchPhoneResponse.EmailAddress em: sr.EmailAddresses){
                    if(em.IsPrimaryEmail == '1'){
                        newContact.Email = em.EmailAddress;
                        update newContact;
                        break;
                    }    
                }
                
                //phone
                for(searchPhoneResponse.Phone p: sr.Phone){
                    if(p.PhoneTypeName == 'Cellular'){
                        newContact.MobilePhone = p.PhoneNumber;
                        if(p.isPrimaryPhone == '1'){
                            newContact.Mobile_is_Primary__c = true;   
                        } else {
                           newContact.Mobile_is_Primary__c = false;  
                        }
                        newContact.Mobile_Use_Type__c = p.PhoneUseTypeName;
                        //newContact.MobilePersonPhoneID__c = p.
                    }  if(p.PhoneTypeName == 'Land line'){
                        newContact.phone = p.PhoneNumber;
                        if(p.isPrimaryPhone == '1'){
                            newContact.Phone_is_Primary__c = true;   
                        } else {
                           newContact.Phone_is_Primary__c = false;  
                        }
                       
                        newContact.Phone_Use_Type__c = p.PhoneUseTypeName;
                        //newContact.PhonePersonPhoneID__c = p.
                    }  if(p.PhoneTypeName == 'Unknown'){
                        newContact.OtherPhone = p.PhoneNumber;
                        if(p.isPrimaryPhone == '1'){
                            newContact.Other_Phone_is_Primary__c = true;   
                        } else {
                           newContact.Other_Phone_is_Primary__c = false;  
                        }
                        newContact.Other_Phone_Use_Type__c = p.PhoneUseTypeName;
                        //newContact.OtherPersonPhoneID__c = p.
                    }  if(p.PhoneTypeName == 'VOIP'){
                        newContact.VOIP_Phone__c = p.PhoneNumber;
                        if(p.isPrimaryPhone == '1'){
                            newContact.VOIP_Phone_is_Primary__c = true;   
                        } else {
                           newContact.VOIP_Phone_is_Primary__c = false;  
                        }
                        newContact.VOIP_Use_Type__c = p.PhoneUseTypeName;
                        //newContact.VoipPersonPhoneID__c = p.
                    }    
                }
                update newContact;
                       
                //PageReference p = new PageReference('/apex/contactDashboard?id=' + newContact.id);
               
                return newContact.Id;
            //}            
            
        //}
        
        //return null;  
    }
    
    public Static ID restoreContactEmail(searchEmailResponse.HouseHoldByEmail sr){
        //create contact
        //for(searchEmailResponse.HouseHoldByEmail sar: searchResultsEmail.Data.HouseHoldByEmail){
           // if(index1 == sr.PersonID){
                Contact newContact = new Contact();
                newContact.FirstName = sr.FirstName ;
                newContact.LastName = sr.LastName;
                if(string.isBlank(newContact.LastName)){
                    newContact.LastName = sr.FirstName;         
                }
                newContact.PersonID__c = sr.PersonID;
                newContact.MiddleName = sr.MiddleName;
                newContact.Gender__c = sr.Gender;
                Schema.SObjectField f = Contact.Fields.PersonID__c;
                Database.UpsertResult cr = Database.upsert(newContact, f, false);         
                //insert newContact;
                
                // locatoions/accounts
                Set<String> locIDs = new Set<String>();
                for(searchEmailResponse.Locations  l: sr.Locations){
                    locIDs.add(l.LocationID);       
                }
                
                List<Account> existingAccounts = [SELECT ID,LocationID__c FROM ACCOUNT WHERE LocationID__c in :locIDs];
                
                List<Account> newAccounts = new List<Account>();
                List<GEA_AccountContactRelation__c> acr = new List<GEA_AccountContactRelation__c>();
                for(searchEmailResponse.Locations  l: sr.Locations){
                    boolean accountFound = false;
                    for(Account a: existingAccounts){
                        if(a.LocationID__c == l.LocationID){
                            GEA_AccountContactRelation__c newACR = new GEA_AccountContactRelation__c();
                            newACR.Contact__c = newContact.id;
                            newACR.Account__c = a.id;
                            acr.add(newACR);
                            newContact.accountId = a.id;
                            accountFound = true;
                        }    
                    }
                    if(!accountFound){
                        Account newAccount = new Account();
                        newAccount.name = l.AddressLine1 + ' ' + l.Locality + ' ' + l.Region + ' ' + l.PostalCode;
                        newAccount.BillingStreet = l.AddressLine1;
                        newAccount.BillingCity = l.Locality;
                        newAccount.BillingState = l.Region;
                        newAccount.BillingPostalCode = l.PostalCode;
                        newAccount.LocationID__c = l.locationID;
                        newAccounts.add(newAccount);
                    }
                    
                }
                
                if(newAccounts.size() > 0){
                    insert newAccounts;
                    for(Account a: newAccounts){
                        GEA_AccountContactRelation__c newACR = new GEA_AccountContactRelation__c();
                        newACR.Contact__c = newContact.id;
                        newACR.Account__c = a.id;
                        acr.add(newACR);
                        newContact.accountId = a.id;
                    }
                    
                }
                insert acr;
                
                
                // assets
                Set<String> assetIDs = new Set<String>();
                Set<String> assetAccountIds = new Set<String>();
                for(searchEmailResponse.Assets  a: sr.Assets){
                    assetIDs.add(a.AssetID);
                    assetAccountIds.add(a.LocationID);
                }
                
                List<Account> existingAssetAccounts = [SELECT ID,LocationID__c FROM ACCOUNT WHERE LocationID__c in :assetAccountIds];
                List<GEA_Asset__c> existingAssets = [SELECT ID,AssetID__c FROM GEA_Asset__c WHERE AssetID__c in :assetIDs];
                
                List<GEA_Asset__c> newAssets = new List<GEA_Asset__c>();
                
                for(searchEmailResponse.Assets  a: sr.Assets){
                    boolean assetFound = false;
                    for(GEA_Asset__c ea: existingAssets){
                        if(ea.AssetID__c == a.AssetID){
                            assetFound = true;
                        }    
                    }
                    if(!assetFound){
                        GEA_Asset__c newAsset = new GEA_Asset__c();
                        newAsset.AssetClassName__c = a.AssetClassName;
                        newAsset.AssetID__c = a.AssetID;
                        if(a.AssetScrappedOn != null){
                            String dateString = a.AssetScrappedOn.subString(0,10);
                            newAsset.AssetScrappedOn__c = date.valueOf(dateString);
                        }
                        if(a.AssetShippedOn != null){
                            String dateString2 = a.AssetShippedOn.subString(0,10);
                            newAsset.AssetShippedOn__c = date.valueOf(dateString2);
                        }
                        newAsset.BrandName__c = a.BrandName;
                        newAsset.CleansedEngineeringModelNumber__c = a.CleansedModelNumber;
                     //   newAsset.IsProductReturned__c = a.IsProductReturned;
                        for(Account ac: existingAssetAccounts){
                            if(ac.LocationID__c == a.LocationID ){
                                newAsset.Account_Location__c = ac.id;
                                break;
                            }
                        }
                        newAsset.MACAddress__c = a.MACAddress;
                        newAsset.OriginalEngineeringModelNumber__c = a.OriginalEngineeringModelNumber;
                        if(a.OwnershipStartedOn != null){
                            String dateString3 = a.OwnershipStartedOn.subString(0,10);
                            newAsset.OwnershipStartedOn__c = date.valueOf(dateString3);
                        }
                     //   newAsset. ProductCategoryName;
                        newAsset.ProductDescription__c = a.ProductDescription;
                        newAsset.Product_Line_Desc__c = a.ProductLineName;
                        newAsset.Serial_Number__c = a.SerialNumber;
                        
                        newAssets.add(newAsset);
                    }
                    
                }
                
                if(newAssets.size() > 0){
                    insert newAssets;
                }
          
                
                // contact info with consumer number from PersonDetail
                List<Contact_Information__c> contactInformation = new List<Contact_Information__c>();
                for(searchEmailResponse.PersonDetail  a: sr.Details){
                    Contact_Information__c newCi = new Contact_Information__c();
                    newCi.ID_Type__c = 'GE Consumer Number';
                    newCi.PersonDetailID__c = a.PersonDetailID;
                    newCi.Contact__c = newContact.id;
                    newCi.Identifier__c = a.GEConsumerNo;
                    contactInformation.add(newCi);
  
                }
        //upsert by personDetailID
               
                Schema.SObjectField fCI = Contact_Information__c.Fields.PersonDetailID__c;
                List<Database.UpsertResult> crCI = Database.upsert(contactInformation, fCI, false);
                //insert contactInformation;         
        
          
                
                
                //emails
                for(searchEmailResponse.EmailAddress em: sr.EmailAddresses){
                    if(em.IsPrimaryEmail == '1'){
                        newContact.Email = em.EmailAddress;
                        update newContact;
                        break;
                    }    
                }
                
                //phone
                for(searchEmailResponse.Phone p: sr.Phone){
                    if(p.PhoneTypeName == 'Cellular'){
                        newContact.MobilePhone = p.PhoneNumber;
                        if(p.isPrimaryPhone == '1'){
                            newContact.Mobile_is_Primary__c = true;   
                        } else {
                           newContact.Mobile_is_Primary__c = false;  
                        }
                        newContact.Mobile_Use_Type__c = p.PhoneUseTypeName;
                        //newContact.MobilePersonPhoneID__c = p.
                    }  if(p.PhoneTypeName == 'Land line'){
                        newContact.phone = p.PhoneNumber;
                        if(p.isPrimaryPhone == '1'){
                            newContact.Phone_is_Primary__c = true;   
                        } else {
                           newContact.Phone_is_Primary__c = false;  
                        }
                       
                        newContact.Phone_Use_Type__c = p.PhoneUseTypeName;
                        //newContact.PhonePersonPhoneID__c = p.
                    }  if(p.PhoneTypeName == 'Unknown'){
                        newContact.OtherPhone = p.PhoneNumber;
                        if(p.isPrimaryPhone == '1'){
                            newContact.Other_Phone_is_Primary__c = true;   
                        } else {
                           newContact.Other_Phone_is_Primary__c = false;  
                        }
                        newContact.Other_Phone_Use_Type__c = p.PhoneUseTypeName;
                        //newContact.OtherPersonPhoneID__c = p.
                    }  if(p.PhoneTypeName == 'VOIP'){
                        newContact.VOIP_Phone__c = p.PhoneNumber;
                        if(p.isPrimaryPhone == '1'){
                            newContact.VOIP_Phone_is_Primary__c = true;   
                        } else {
                           newContact.VOIP_Phone_is_Primary__c = false;  
                        }
                        newContact.VOIP_Use_Type__c = p.PhoneUseTypeName;
                        //newContact.VoipPersonPhoneID__c = p.
                    }    
                }
                update newContact;
                       
                //PageReference p = new PageReference('/apex/contactDashboard?id=' + newContact.id);
               
                //return p;
                return newContact.id;
          //  }            
            
       // }
        
        //return null;  
    }
}