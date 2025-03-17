public class ContactDashboardController {
    public ID contactId{get;set;}
    public Contact contactRec {get;set;}
    public List<Case> cases {get;set;}
    public List<CaseWrapper> caseList {get;set;}
    public List<Account> serviceLocations {get;set;}
    public List<Asset> assets {get;set;}
    public List<serviceLocationWrapper> locationAssets {get;set;}
    public List<LocationWrapper> locationsList {get;set;}
    public List<assetWrapper> assetsList {get;set;}
    public String modelNumber {get;set;}
    public String serialNumber {get;set;}
    public String streetName {get;set;}
    public String zipCode {get;set;}
   	public String selectedAssetId{get;set;}
    public String selectedAccountID {get;set;}
    public String selectedLocationId{get;set;}
    public Set<ID> serviceLocIDs {get;set;}
    public Set<ID> householdAccountIds {get;set;}
    public String caseSubject {get;set;}
    public String caseNotes {get;set;}
    public Set<ID> householdContactIds{get;set;}
    public String ani{get;set;}
    public Boolean displayMulti {get;set;}
    public searchPhoneResponse searchResult {get;set;}
    public Case newCase {get;set;}
    public Boolean renderAddLocation {get;set;}
    public Boolean renderAddAsset {get;set;}
    public Boolean renderRelocationAsset {get;set;}
    public Date installDate {get;set;}
    public Boolean locationError{get;set;}
    public Boolean assetError{get;set;}
    public Boolean caseError{get;set;}
    Boolean boolWarranty = false;
 
    public Boolean getWarrantyStatus() {
        return boolWarranty;
    }
            
    public void setWarrantyStatus(Boolean boolWarranty) {
        this.boolWarranty = boolWarranty;
    }
    public List<c360_emailengagement__x> emails {get;set;} 
    
    public contactDashboardController (){
        renderAddLocation = false;
        renderAddAsset = false;
        renderRelocationAsset = false;
        newCase = new Case();
        displayMulti = false;
        locationError = false;
        assetError = false;
        caseError = false;
        //get contact record by id passed or phone number
        searchPhoneResponse searchResult = new searchPhoneResponse();
        try{
            
            contactId = ApexPages.currentPage().getParameters().get('id');
            if(contactId != null){
                contactRec = [SELECT ID,NAME,Phone,email,accountId, personid__c, Secondary_Email__c, Alternative_Email_2__c   FROM CONTACT WHERE ID =: contactId LIMIT 1];
            }
        
            ani = ApexPages.currentPage().getParameters().get('ani');
            if(ani != null){
               
                String sosl = 'FIND \''+ ani + '\'IN ALL FIELDS RETURNING Contact(id )'; 
                
                List<List<Sobject>>searchList=search.query(sosl);
                Integer returnSize = 0;
                for(List<sObject> counts:searchList){
                    returnSize =counts.size();
                }
                system.debug('searchList '  + searchList.size() + ' ' + returnSize + searchList) ;
                if(returnSize == 1){
                    List<Contact> contactList = ((List<Contact>)searchList[0]);
                    contactRec = [SELECT ID,NAME,Phone,email,accountId, personid__c FROM CONTACT WHERE id =: contactList[0].id LIMIT 1];   
                }
                
                
                
                //contactRec = [SELECT ID,NAME,Phone,email,accountId FROM CONTACT WHERE phone =: ani LIMIT 1];
            }
        
            //find accounts
            findAccounts();
            
             //find emails send from marketing cloud.
            emails = new List<c360_emailengagement__x>();
            if(contactRec!=null)  {
             List<c360_emailengagement__x> emailList = [SELECT Id, SentEventDate__c, ClickEventDate__c, OpenEventDate__c, subject__c, previewurl__c, FromName__c, FromEmail__c, status__c , BounceReason__c FROM c360_emailengagement__x where  (EmailAddress__c =:contactRec.Secondary_Email__c OR EmailAddress__c =:contactRec.Alternative_Email_2__c OR EmailAddress__c =:contactRec.email) order by SentEventDate__c desc LIMIT 500];
                if(emailList!=null && emailList.size()>0){
                        for(c360_emailengagement__x engagement: emailList){
                            if(!String.isBlank(engagement.previewurl__c)){
                                emails.add(engagement);
                            }
                        }
                    }
            }
            
            //List<Contact> householdContacts = [SELECT ID FROM contact where accountID in :householdAccountIds and accountID != null];
                
            //Set<ID> householdContactIds = new Set<ID>();
            //for(Contact hc:householdContacts){
            //     householdContactIds.add(hc.id);  
            //}
          cases = [SELECT ID,description,CaseNumber,subject,status,CreatedDate,closedDate,Asset.Model_Number__c, Asset.SerialNumber,
                 contact.name, account.billingStreet,Asset.account.billingStreet,Consumer_Full_Address__c,owner.name
                 FROM Case 
                 WHERE contactId in : householdContactIds
                 OR accountID in : householdAccountIds
                 ORDER BY createdDate desc
                 LIMIT 200];
        
            caseList = new List<CaseWrapper>();
            Set<ID> caseIds = new Set<ID>();
            //query assets related to cases
            for(Case c: cases){
              caseIds.add(c.id);        
            }
            
            List<Case_Asset__c> caseAssets = [SELECT Id,case__c, Model_Number__c, Serial_Number__c
                                              FROM Case_Asset__c
                                              WHERE case__c in :caseIds];
            
            for(Case c: cases){
                String modelNumber ='';
                String serialNumber = '';
              for(Case_Asset__c ca : caseAssets){
                    if(ca.case__c == c.id){
                      modelNumber = modelNumber + ca.Model_Number__c + ',';
                      serialNumber = serialNumber + ca.Serial_Number__c + ',';    
                    }
              }
                modelNumber = modelNumber.removeEnd(',');
                serialNumber = serialNumber.removeEnd(',');
                caseList.add(new CaseWrapper(c,modelNumber,SerialNumber));
            }
            
            
            
            //loop cases and assets and create wrapper            
            getServiceLocations();      
            getAssets();
        }
        catch (exception e){
            contactRec = null;     
        }
        
    }
    public void resetError(){
        caseError = false;
        locationError = false;
        assetError = false;
    }
    
    public pageReference addLocation(){
        renderAddLocation = true;
        return null;
    }
    
    public pageReference removeLocation(){
        //renderAddLocation = true;
        Set<ID> accountsToRemove = new Set<ID>();
        for(LocationWrapper lw : locationsList){
            if(lw.selected){
                accountsToRemove.add(lw.serviceLocation.id);    
            }
        }
        //contact__c,Account__c from GEA_AccountContactRelation__c
        List<GEA_AccountContactRelation__c> removeLinks = [SELECT ID,Account__c,Contact__c,Is_Primary_Location__c,Is_Primary_Person__c,
                                                           Location_Person_Data_Source_Code__c,Location_Person_Data_Source_Name__c,
                                                           LocationPersonID__c,Name,Personmovedinon__c,Personmovedouton__c,Special_Handling_Code__c
                                                          FROM GEA_AccountContactRelation__c
                                                          WHERE contact__c = :contactRec.id
                                                          AND Account__c IN :accountsToRemove ];
        
        //create deletion log rec
        List<GEA_AccountContactRelation_Delete__c> logRecs = new List<GEA_AccountContactRelation_Delete__c>();
        for(GEA_AccountContactRelation__c gacr :removeLinks){
          GEA_AccountContactRelation_Delete__c logRec = new GEA_AccountContactRelation_Delete__c();
            logRec.Account__c = gacr.Account__c;
            logRec.Contact__c = gacr.Contact__c;
            logRec.Is_Primary_Location__c = gacr.Is_Primary_Location__c;
            logRec.Is_Primary_Person__c = gacr.Is_Primary_Person__c;
            logRec.Location_Person_Data_Source_Code__c = gacr.Location_Person_Data_Source_Code__c;
            logRec.Location_Person_Data_Source_Name__c = gacr.Location_Person_Data_Source_Name__c;
            logRec.LocationPersonID__c = gacr.LocationPersonID__c;
            logRec.Name = gacr.Name;
            logRec.Personmovedinon__c = gacr.Personmovedinon__c;
            logRec.Personmovedouton__c = gacr.Personmovedouton__c;
            logRec.Special_Handling_Code__c = gacr.Special_Handling_Code__c;
            
            logRecs.add(logRec);
            
        }
    insert logRecs;        

        
        delete removeLinks;
        findAccounts();
        getServiceLocations();
        getAssets();
        return null;
    }
    
    public pageReference cancelAddLocation(){
        renderAddLocation = false;
        return null;
    }
    
    public pageReference addAsset(){
        renderAddAsset = true;
        return null;
    }
    
    public pageReference relocateAssetButton(){
        renderRelocationAsset = true;
        return null;
    }
    
    public pageReference relocateAsset(){
        resetError();
        Boolean assetSelected = false;
        for(assetWrapper lw:assetsList){
            if(lw.selected && !assetSelected){
                assetSelected = true;   
            } 
        }
        if(!assetSelected){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Please select an asset')); 
            assetError = true;
            return null;
        }
        
        //Asset WHERE Account
        //selectedLocationID
        for(assetWrapper lw:assetsList){
            List<Asset> updateAssets = new List<Asset>();
            if(lw.selected ){
                //loop gea asset and update Account
                for(Asset ga:  assets){
                    if(ga.id == lw.asset.id ){
                        ga.AccountId = selectedLocationId;
                        updateAssets.add(ga);
                    }
                }
            } 
            update updateAssets;
            findAccounts();
            getServiceLocations(); 
            getAssets();
        }
        
        renderRelocationAsset = false;
        return null;
    }
    
    public pageReference removeAsset(){
        resetError();
        Boolean assetSelected = false;
        for(assetWrapper lw:assetsList){
            if(lw.selected && !assetSelected){
                assetSelected = true;   
            } 
        }
        if(!assetSelected){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Please select an asset')); 
            assetError = true;
            return null;
        }
        

        for(assetWrapper lw:assetsList){
            List<Asset> deleteAssets = new List<Asset>();
            if(lw.selected ){
                //loop gea asset and update Account_Location__c
                for(Asset ga:  assets){
                    if(ga.id == lw.asset.id ){
                        deleteAssets.add(ga);
                    }
                }
            } 
            try {
                delete deleteAssets;
            } catch(exception e) {        apexpages.addmessages(e);
              apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,e.getMessage())); 
                assetError = true;
                return null;        
            }
            
            findAccounts();
            getServiceLocations(); 
            getAssets();
        }
        
        renderRelocationAsset = false;
        return null;
    }
    
    public pageReference cancelAddAsset(){
        renderAddAsset = false;
        renderRelocationAsset = false;
        return null;
    }
    
    public pageReference searchContact(){
        PageReference p = new PageReference('/apex/contactSearch?ani=' + ani);
        return p;
    }
    
    
    public pageReference redirectSearch(){
        //redirect to search page
        searchResult = new searchPhoneResponse();
        if(contactRec == null){
            PageReference p = new PageReference('/apex/contactSearch?ani=' + ani);
            return p;
            // if no contact found by phone search 360 by phone number  --- send phone number over to search page - have search page execute call as if they clicked search button --- 
            // if single result then auto restore  
                
 //           searchResult = utility.getArchivedContacts(ani);
            
 //           system.debug(searchResult);
            // if single match found restore
 //           if(searchResult.data != null &&  searchResult.Data.HouseHoldByPhone.size() == 1){
                // restore and set contactRec
 //               ID contactID =  utility.restoreContact(searchResult.Data.HouseHoldByPhone[0]);
 //               contactRec = [SELECT ID,NAME,Phone,email,accountId FROM CONTACT WHERE id =: contactID LIMIT 1];
 //           }
             
            // if multiple matches found then show responses and allow restore    
  //          if(searchResult.data != null &&  searchResult.Data.HouseHoldByPhone.size() > 1){
 //             displayMulti = true;
 //               return null;
 //           }
                
            // if no match found go to search page
            //if(contactRec == null){
            //  PageReference p = new PageReference('/apex/contactSearch');
            //   return p;
            //}
            
            //find accounts
//            findAccounts();
            
 //           cases = [SELECT ID,description,CaseNumber,subject,status,CreatedDate,closedDate,GEA_Asset__r.Model_Number__c, GEA_Asset__r.Serial_Number__c,
 //               GEA_Asset__r.Service_Location__r.AddressLine1__c,GEA_Asset__r.Service_Location__r.City__c,GEA_Asset__r.Service_Location__r.Zip_Code__c,
 //                    contact.name, account.billingStreet,GEA_Asset__r.account_location__r.billingStreet
 //                    from case where contactId in : householdContactIds
  //                  order by createdDate desc];//
 //           getServiceLocations();      
 //           getAssets();
        } 
        return null;
    }
    
    public void findAccounts(){
        
        /*List<AccountContactRelation> householdAccounts = [SELECT ID,contactId,accountID from AccountContactRelation where contactId =: contactRec.id];
        householdAccountIds = new Set<ID>();
        householdContactIds = new Set<ID>();
        for(AccountContactRelation acr:householdAccounts){
             householdAccountIds.add(acr.accountID);
             householdContactIds.add(acr.contactId); 
        } 
        */
        List<GEA_AccountContactRelation__c> householdAccounts = [SELECT ID,contact__c,Account__c from GEA_AccountContactRelation__c where contact__c =: contactRec.id];
        householdAccountIds = new Set<ID>();
        householdContactIds = new Set<ID>();
        for(GEA_AccountContactRelation__c acr:householdAccounts){
             householdAccountIds.add(acr.Account__c);
             householdContactIds.add(acr.contact__c); 
        } 
    }
    
    public void getServiceLocations(){
        //serviceLocations = [select ID,name,AddressLine1__c,City__c,Zip_Code__c from Service_Location__c where Account__c =: contactRec.accountId and Account__c != null];
        serviceLocations = [select ID,name,billingStreet,billingCity,billingState,billingPostalCode from Account where id in : householdAccountIds ];
        locationsList = new List<LocationWrapper>();
        serviceLocIDs = new Set<ID>();
        for(Account sl:serviceLocations){
            serviceLocIDS.add(sl.id);
            locationsList.add(new LocationWrapper(sl)); 
        }   
    }
    
    
    
    public void getAssets(){
        //assets = [SELECT Id, name,Service_Location__c,Model_Number__c,Serial_Number__c,Product_Type__c,Product_Line__c
         //   from GEA_Asset__c WHERE Service_Location__c in :serviceLocIDS];
        assets = [SELECT Id, name,Model_Number__c,SerialNumber,Product_Type__c,Product_Line__c,AccountId,BrandName__c,
                 Product_Brand__c, OwnershipStartedOn__c,InstallDate,In_Warranty__c 
            from Asset WHERE AccountId  in :householdAccountIds
                 LIMIT 500];
        

        
        assetsList = new List<assetWrapper>();
        locationAssets = new List<serviceLocationWrapper>();
        for(Account sl:serviceLocations){
            locationAssets.add(new serviceLocationWrapper(sl,null,true));
            for(Asset ga: assets){
                if(ga.AccountId == sl.id){
                    locationAssets.add(new serviceLocationWrapper(sl,ga,false)); 
                    assetsList.add(new assetWrapper(sl,ga)); 
                }      
            }    
        }

    }
    
    public pageReference  cancel(){
        return null;
    }
    
    
    public pageReference createCase(){
        resetError();
        Boolean assetSelected = false;
        
        for(assetWrapper lw:assetsList){
            if(lw.selected && !assetSelected){
                assetSelected = true;
                //selectedAssetId = lw.asset.id;
                selectedAccountId = lw.asset.AccountId;
            //} else if(lw.selected && assetSelected){
                //apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Please select a single asset'));
                //return null; 
            } 
        }
        
        User currentUser = [SELECT ID,Business_Team__c,Team_Persona__c
            FROM User
            WHERE id = :UserInfo.getUserId() LIMIT 1];


        if(!assetSelected && (currentUser.Business_Team__c != 'Home Delivery' && 
                              currentUser.Business_Team__c != 'PSS' && 
                              currentUser.Business_Team__c != 'SSG' &&
                              currentUser.Business_Team__c != 'Innovations' &&
                              currentUser.Business_Team__c != 'DTC')){
             apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Please select an asset')); 
             caseError = true;
            return null;
        }

        newCase.contactId = contactRec.id;
        system.debug('@@@@ newCase.contactId: ' +newCase.contactId);
        system.debug('@@@@ selectedAccountId: ' +selectedAccountId);
        newCase.accountID = selectedAccountId;
        //newCase.GEA_Asset__c = selectedAssetId;
        newCase.Subject = caseSubject;
        newCase.description = caseNotes;
        newCase.origin = 'Phone';
        
        //Fetching the assignment rules on case
        AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        
        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
        newCase.setOptions(dmlOpts);
       
        insert newCase;
        //loop asset records and create junction record
        //Id, Case__c, GEA_Asset__c FROM Case_Asset__c
        if(assetSelected){
            List<Case_Asset__c> CaList = new List<Case_Asset__c>();
            for(assetWrapper lw:assetsList){
                if(lw.selected ){
                    Case_Asset__c newCA = new Case_Asset__c();
                    newCA.Asset__c = lw.asset.id;
                    newCA.Case__c = newCase.id;
                    newCA.Model_Number__c =lw.asset.Model_Number__c;
                    newCa.Serial_Number__c = lw.asset.SerialNumber;
                    newCa.Install_Date__c = lw.asset.InstallDate;
                   if(lw.asset.In_Warranty__c == true)
                    {
                        newCa.In_Warranty_CaseAsset__c = 'Yes';
                    }
                    else
                    {
                        newCa.In_Warranty_CaseAsset__c = 'No';
                    }
                    CaList.add(newCA);
                    //selectedAssetId = lw.asset.id;
                }   
            }
            insert CaList;
        }
        
        
        
        PageReference p = new PageReference('/' + newCase.id);
        return p;
    }
    
    public PageReference verifyServiceLocation(){
        resetError();
        Boolean hasErrors = false;
        
        if(streetName == '' || streetName == null){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Please enter street.')); 
            hasErrors = true;
        }
        if(zipCode == '' || zipCode == null){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Please enter zip.')); 
            hasErrors = true;
        }
         if(hasErrors){
            locationError = true;
            return null;
        }    
        
   /* String zipRegex = '\\d{5}(-\\d{4})?';
    Pattern zipPattern = Pattern.compile(zipRegex);
    Matcher zipMatcher = zipPattern.matcher(zipCode); 
  if(zipMatcher.matches()) { */
//make callout
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
        String postBody = '{"request": "ZoneDetailsRequest","payload": {"PostalAreaCode": "' + zipCode +'"}}';
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
            String testBody = '{"CityName": "PALM COAST", "StateCode": "FL","PostalAreaCode": "32137", "RegionNo": "133", "ZoneCode": "35"}';
            response.setBody(testBody);
        }
        
        
        // Parse the JSON response
        if (response.getStatusCode() == 200) {
            
            System.debug(response.getBody());
            if(response.getBody().contains('NO DATA FOUND')){
                apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Error : ' +
                                                           response.getBody() ));
                return null;  
            }
            zoneDetailsResponse resp = zoneDetailsResponse.parse(response.getBody()); 
            //check for existing account
            Account newAccount;   
            List<Account> existingAccount = [SELECT ID,NAME,BillingStreet,BillingCity,BillingState,BillingPostalCode
                                               FROM Account
                                               WHERE street_search__c  = :streetName
                                               AND Zip_Search__c =:zipCode];

            if(existingAccount.size() >0 ){
                newAccount = existingAccount[0];
            } else {
                newAccount = new account();
                newAccount.name = streetName.trim() + ' ' + utility.initCap(resp.CityName.toLowerCase()).trim() + ' ' + resp.StateCode.trim() + ' ' + zipCode.trim();
                newAccount.BillingStreet = streetName.trim();
                newAccount.BillingCity = utility.initCap(resp.CityName.toLowerCase()).trim();
                newAccount.BillingState = resp.StateCode.trim();
                newAccount.BillingPostalCode = zipCode.trim();
                newAccount.Street_Search__c= streetName.trim();
                newAccount.Zip_Search__c  = zipCode.trim();
                newAccount.Region__c = integer.valueOf(resp.RegionNo);
                newAccount.Zone__c = string.valueOf(resp.ZoneCode);
                if(resp.ZoneCode != null && resp.ZoneCode == '09'){
                  newAccount.Service_Region_Zone__c =  'Customer Care';  
                } else {
                   newAccount.Service_Region_Zone__c =  'Factory Service'; 
                }
                insert newAccount;   
                
            }
          GEA_AccountContactRelation__c acRelation = new GEA_AccountContactRelation__c();
                acRelation.Contact__c  = contactRec.id;
                acRelation.Account__c = newAccount.id;
                insert acRelation;
                
                findAccounts();
                getServiceLocations();
                getAssets();
            
        } else {
            system.debug('The status code returned was not expected: ' +
            response.getStatusCode() + ' ' + response.getStatus());
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'The status code returned was not expected: ' +
            response.getStatusCode() + ' ' + response.getStatus()));
            locationError = true;
            return null; 
        }
        
      renderAddLocation = false;
        return null;
 }
     // return null; 
//}
    public PageReference verifyAsset(){
        resetError();
        Boolean hasErrors = false;
        
        if(modelNumber == '' || modelNumber == null){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Please enter model number.')); 
            hasErrors = true;
        }
        if(selectedLocationId == 'Select service location' ){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Please select a location.')); 
            hasErrors = true;
        }
        if(!string.isBlank(modelNumber)  && !modelNumber.isAlphanumeric() ){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Model Number can only contain alphanumeric characters.')); 
            hasErrors = true;
        }
        if(hasErrors){
            assetError = true;
            return null;
        }
        
        modelNumber = modelNumber.toUpperCase();
        
        //make callout
        //
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setTimeout(25000);
        //request.setEndpoint('https://gc9zw2x6fa.execute-api.us-east-1.amazonaws.com/DEV/validatemodelnumber');
        if(utility.isSandbox){
            request.setEndpoint('callout:Sandbox_ValidateModelNumber');   
        } else {
            request.setEndpoint('callout:Production_ValidateModelNumber');
        }
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('geasfdccode','ApplServiceCloudGEA');
        request.setHeader('appname','SiebelXML');
        String postBody = ' {"request": "ModelNumberValidateRequest","payload": {"ModelNumber": "' + modelNumber.trim() +'","BrandCode": "", "ProductTypeCode": "", "ProductLineCode": ""}}';
      //  {"request": "ModelNumberValidateRequest","payload": {"ModelNumber": "GSD2100VBB","BrandCode": "", "ProductTypeCode": "", "ProductLineCode": ""}}
        // Set the body as a JSON object
        request.setBody(postBody);
        HttpResponse response;
        if(!test.isRunningTest()){
            response = http.send(request);
            system.debug('request ' + postBody);
            system.debug('response ' + response);
            system.debug('response body ' + response.getBody());
        } else {
            response = new HttpResponse();
            response.setStatusCode(200);
            String testBody = '{"CityName": "PALM COAST", "StateCode": "FL","PostalAreaCode": "32137", "RegionNo": "133", "ZoneCode": "35"}';
            response.setBody(testBody);
        }
        
        // Parse the JSON response
        if (response.getStatusCode() == 200) {
            System.debug(response.getBody());
            modelNumberResponse resp = modelNumberResponse.parse(response.getBody());
                

  //  public String ModelNumber;   Account_Location__c
 //   public String BrandCode;  BrandName__c
  //  public String ProductTypeCode; Product_Type__c
  //  public String ProductLineCode;Product_Line__c
  //  
            Asset newAsset = new Asset();
            newAsset.Name = modelNumber + '-'+serialNumber; // This is added for Asset Transformation project. Asset Name is required field on the Asset Object
            newAsset.AccountId = selectedLocationId;
            newAsset.Model_Number__c = modelNumber;
            newAsset.SerialNumber = serialNumber;
            newAsset.In_Warranty__c = boolWarranty;
            newAsset.BrandName__c = resp.BrandCode;
            newAsset.Product_Type__c = resp.ProductTypeCode;
            newAsset.Product_Line__c = resp.ProductLineCode;
            newAsset.Product_Line_Desc__c = resp.ProductLineDesc;
            newAsset.Product_Type_Desc__c = resp.ProductTypeDesc;
            newAsset.InstallDate = installDate;
            insert newAsset;
            //call createSiebelAsset to create asset in siebel
            utility.createSiebelAsset(newAsset.id, contactRec.id);
            getAssets();
            modelNumber = '';
            serialNumber = '';     
            
                
            
        } else {
            system.debug('The status code returned was not expected: ' +
            response.getStatusCode() + ' ' + response.getStatus());
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'The status code returned was not expected: ' +
            response.getStatusCode() + ' ' + response.getStatus()));
            assetError = true;
        }
        
        
        
       
        return null;
    }
    
    public List<SelectOption> getLocationSelections() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Select service location','Select service location'));
        for(LocationWrapper lw: locationsList){
            options.add(new SelectOption(lw.serviceLocation.id,lw.locationDesc));    
        }
        return options;
    }
    
    
    public class serviceLocationWrapper {
        public Account serviceLocation {get; set;}
        public Asset asset {get;set;}
        public String locationDesc {get;set;}
        public Boolean selected {get; set;}
        public Boolean parentRec {get;set;}
 
        //This is the contructor method. When we create a new wrapAccount object we pass a Account that is set to the acc property. We also set the selected value to false
        public serviceLocationWrapper(Account sl, Asset a, Boolean isParent) {
            asset = a;
            serviceLocation = sl;
            parentRec = isParent;
            selected = false;
            if(isParent){
                locationDesc = sl.billingStreet + ' ' + sl.BillingCity + ' ' + sl.billingState + ' ' + sl.BillingPostalCode;   
            }
        }
    }
    
    public class LocationWrapper {
        public Account serviceLocation {get; set;}
        public String locationDesc {get;set;}
        public Boolean selected {get; set;}

        public LocationWrapper(Account sl) {
            serviceLocation = sl;
            selected = false;
            locationDesc = sl.billingStreet + ' ' + sl.BillingCity + ' ' + sl.billingState + ' ' + sl.BillingPostalCode;  
        }
    }
    
    public class assetWrapper {
        public Asset asset {get;set;}
        public String locationDesc {get;set;}
        public Boolean selected {get; set;}
        public Account serviceLocation {get; set;}

        public assetWrapper(Account sl, Asset a) {
            asset = a;
            serviceLocation = sl;
            selected = false;
            locationDesc = sl.billingStreet+ ' ' + sl.BillingCity + ' ' + sl.billingState + ' ' + sl.billingPostalCode;  
        }
    }
    
    public class caseWrapper {
        public Case c {get;set;}
        public String modelNumbers {get;set;}
        public String serialNumbers {get;set;}

        public caseWrapper(Case caseParam,String mNum, String sNum) {
            c = caseParam; 
            modelNumbers = mNum;
            serialNumbers = sNum;
        }
    }
    
   
    
}