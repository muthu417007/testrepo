public class CaseDashboardController {
    public Case caseRec {get;set;}
    public String phone{get;set;}
    public String email{get;set;}
    public List<Asset> assets {get;set;}
    public List<Asset> additionalAssets {get;set;}
    public List<assetWrapper> additionalAssetsWrapper {get;set;}
    public List<caseAssetWrapper> caseAssets {get;set;}
    public String modelNumber{get;set;}
    public String serialNumber{get;set;}
    public boolean showArchived {get;set;}
    public boolean showArchivedEmail {get;set;}
    public List<Contact> contacts {get;set;}
    public searchPhoneResponse searchResults{get;set;}
    public String selectedContactId {get;set;}
    public searchEmailResponse searchResultsEmail{get;set;}
    public String firstName {get;set;}
    public String lastName {get;set;}
    public String street {get;set;}
    public String zip {get;set;}
    public String index1 {get;set;}
    public Account newAccount{get;set;}
    public Date installDate {get;set;}
    public Boolean createUnknownAddress {get;set;}

    public caseDashboardController (){
        String caseId = ApexPages.currentPage().getParameters().get('id');
        caseRec = [SELECT ID,caseNumber,subject,accountID,account.name,contactID,contact.name,contact.accountId,
                   First_Name__c,Last_name__c,SuppliedEmail,SuppliedPhone,Street_Address__c,Zip_Postal_Code__c,Phone_Number__c,
                   Model_Number__c,Serial_Number__c
                   from case where id = :caseId LIMIT 1];
        
        firstName = caseRec.First_Name__c;
        lastName = caseRec.Last_Name__c;
        if(!string.isBlank(caseRec.Phone_Number__c)){
            phone = caseRec.Phone_Number__c.replaceAll('\\D','');   
        }
        
        email = caseRec.SuppliedEmail;
        street = caseRec.Street_Address__c;
        zip = caseRec.Zip_Postal_Code__c;
        serialNumber = caseRec.Serial_Number__c;
        modelNumber = caseRec.Model_Number__c;
        User currentUser = [SELECT ID,Business_Team__c,Team_Persona__c
            FROM User
            WHERE id = :UserInfo.getUserId() LIMIT 1];
        createUnknownAddress = false;
        if(currentUser.Business_Team__c == 'TAG'){ 
           //|| currentUser.Business_Team__c == 'Social Media' ||
          //currentUser.Business_Team__c == 'Digital Media' || currentUser.Business_Team__c == 'eCommerce'){
            firstName = 'NoName';
            lastName = 'NoName';
            Street = 'NoAddress';
            Zip = '00000';
            createUnknownAddress = true;
        }
        //modelNumber = caseRec.Model_Number__c;
        //serialNumber = caseRec.Serial_Number__c;
        getAssets();
    }
    
    public PageReference setUnknown(){
        if(createUnknownAddress){
            firstName = 'NoName';
            lastName = 'NoName';
            Street = 'NoAddress';
            Zip = '00000';    
        }
        return null;
    }
    
    public pageReference restoreContact(){
        ID contactId;
        for(searchPhoneResponse.HouseHoldByPhone sr: searchResults.Data.HouseHoldByPhone){
            if(index1 == sr.PersonID){
                contactID = utility.restoreContact(sr);    
            }
        }
        caseRec.contactID = contactID;
        update caseRec;
        PageReference p = new PageReference('/apex/contactDashboard?id=' + contactId);
        return p;
    }
    public pageReference restoreContactEmail(){
        ID contactId;
        for(searchEmailResponse.HouseHoldByEmail sr: searchResultsEmail.Data.HouseHoldByEmail){
            if(index1 == sr.PersonID){
                contactID = utility.restoreContactEmail(sr);    
            }
        }
        caseRec.contactID = contactID;
        update caseRec;
        PageReference p = new PageReference('/apex/contactDashboard?id=' + contactId);
        return p;
    }
    public PageReference createUnknownContactAddress(){
        
        newAccount = new account();
        newAccount.name = 'NoAddress City ST 00000';
        newAccount.BillingStreet = Street;
        newAccount.BillingCity = 'City';
        newAccount.BillingState = 'ST';
        newAccount.BillingPostalCode = zip;
        insert newAccount;
        
        Contact newContact = new Contact();
        newContact.email = email;
        newContact.phone = phone;
        newContact.firstName = firstName;
        newContact.LastName = lastName;
        newContact.accountID = newAccount.id;
        newContact.MailingStreet = Street;
        newContact.MailingCity = 'City';
        newContact.MailingState = 'ST';
        newContact.MailingPostalCode = zip;
        insert newContact;

        GEA_AccountContactRelation__c acRelation = new GEA_AccountContactRelation__c();
        acRelation.contact__c = newContact.id;
        acRelation.account__c = newAccount.id;
        insert acRelation;
      
        system.debug('Create Unknown contact ' + newContact);
        caseRec.contactID = newContact.id;
        update caseRec;
        
        PageReference p = new PageReference('/one/one.app#/alohaRedirect/apex/contactDashboard?id=' + newContact.id);
       
        return p;
   
    }
    
    
    public PageReference createContact(){
        
        if(createUnknownAddress){
            //createUnknownContact
            return createUnknownContactAddress();
        }
        
        User currentUser = [SELECT ID,Business_Team__c,Team_Persona__c
            FROM User
            WHERE id = :UserInfo.getUserId() LIMIT 1];
        //edit check
        Boolean hasErrors = false;
        if(street == null || street == ''){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Street Required.'));
            hasErrors = true;
        }
        if((phone == null || phone == '') && currentUser.Business_Team__c != 'TAG'){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Phone Required.'));
            hasErrors = true;
        }
        if(zip == null || zip == ''){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Zip Required.'));
            hasErrors = true;
        }
        if(firstName == null || firstName == ''){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'First Name Required.'));
            hasErrors = true;
        }
        if(lastName == null || lastName == ''){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Last Name Required.'));
            hasErrors = true;
        }
        
        if(hasErrors){
            return null;                                                           
        }
        List<Account> households = [SELECT ID,BillingState,BillingCity FROM Account
                                       WHERE Zip_Search__c =: zip
                                       AND Street_Search__c  = : Street
                                       AND recordType.name = 'Location'];
        system.debug('households ' + households);
        If(households.size() == 1){
            system.debug('1 account found');                                    
        } else {
            system.debug('not accounts found' + households.size());      
            households = [SELECT Id,BillingState,BillingCity
                       FROM Account
                       WHERE phone =: phone 
                       AND phone != null
                       AND recordType.name = 'Location'
                      ];
        }
        Boolean newAccountCreated = false;
        
        if(households.size() != 1){
            system.debug('make callout for address');       
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
            request.setTimeout(15000);
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
                if(response.getBody().contains('NO DATA FOUND')){
                    apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Error : ' +
                    response.getBody() ));
                    return null;  
                }
                zoneDetailsResponse resp = zoneDetailsResponse.parse(response.getBody());
                newAccount = new account();
                newAccount.name = street.trim() + ' ' + utility.initCap(resp.CityName.toLowerCase()).trim() + ' ' + resp.StateCode.trim() + ' ' + zip.trim();
                newAccount.BillingStreet = street.trim();
                newAccount.BillingCity = utility.initCap(resp.CityName.toLowerCase()).trim();
                newAccount.BillingState = resp.StateCode.trim();
                newAccount.BillingPostalCode = zip.trim();
                newAccount.Zip_Search__c = zip.trim();
                newAccount.Street_Search__c=street.trim();
                newAccount.Region__c = integer.valueOf(resp.RegionNo);
                newAccount.Zone__c = string.valueOf(resp.ZoneCode);
                if(resp.ZoneCode != null && resp.ZoneCode == '09'){
                    newAccount.Service_Region_Zone__c =  'Customer Care';  
                } else {
                   newAccount.Service_Region_Zone__c =  'Factory Service'; 
                }
                newAccountCreated = true;
                //insert newAccount;
             
            } else {
                system.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
                apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus()));
                return null; 
            }
        }
        
        //Get CN1 consumer number
        User u = [Select SSO_ID__c from User where Id =: UserInfo.getUserId() LIMIT 1];
        contact CN1Contact = new contact();
        CN1Contact.lastName = lastName;
        CN1Contact.firstName = firstName;
        CN1Contact.phone = phone;
        CN1Contact.Email = email;
        account a = new account();
        a.BillingStreet = street;
        a.BillingCity =  newAccountCreated == true ? newAccount.BillingCity :households[0].BillingCity;
        a.BillingPostalCode = zip;
        a.BillingState = newAccountCreated == true ? newAccount.BillingState :households[0].BillingState;
        CN1Response CN1Resp = Utility.CN1CustomerNumber(CN1Contact, u.SSO_ID__c, a);
        
        if(CN1Resp.ConsumerNo == null){
             apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Error occured creating contact please try again.' + CN1Resp.ErrorMessage));
             return null; 
        }
        
        if(newAccountCreated){
            insert newAccount;    
        }
        
        Contact newContact = new Contact();
        newContact.firstName = firstName;
        newContact.LastName = lastName;
        if(newAccount != null){
            system.debug('using new account');
             newContact.accountID = newAccount.id;
             newContact.MailingState = newAccount.BillingState;
             newContact.MailingCity = newAccount.BillingCity;  
        } else {
             system.debug('using household');
            newContact.accountID = households[0].id;
            newContact.MailingState = households[0].BillingState;
            newContact.MailingCity = households[0].BillingCity;
        }
       
        newContact.email = email;
        newContact.phone = phone;
        newContact.MailingStreet = street;
        newContact.MailingPostalCode = zip;
                
         try{
            insert newContact;
        }catch(exception e){
            throw new AuraHandledException('Error creating contact: '
            + e.getMessage()); 
        }
        
        //create Consumer Number rec
        Contact_Information__c  newCI = new Contact_Information__c ();
        newCI.ID_Type__c = 'GE Consumer Number';
        newCI.Contact__c = newContact.id;
        newCI.Identifier__c = CN1Resp.ConsumerNo;
        insert newCI;
        
          GEA_AccountContactRelation__c acRelation = new GEA_AccountContactRelation__c();
          acRelation.contact__c = newContact.id;
          if(newAccount != null){
            acRelation.account__c = newAccount.id;
          } else {
            acRelation.account__c = households[0].id;  
          }
          insert acRelation;
            
        
        caseRec.contactID = newContact.id;
        update caseRec;
        
        PageReference p = new PageReference('/one/one.app#/alohaRedirect/apex/contactDashboard?id=' + newContact.id);
       
        return p;

    }
    
    public pageReference linkContact(){
        caseRec.contactId = selectedContactId;
        update caseRec;
        caseRec = [SELECT ID,caseNumber,subject,accountID,account.name,contactID,contact.name from case where id = :caseRec.id LIMIT 1];
        return null;
    }
    
    public void search(){
        showArchivedEmail = false;
        showArchived = false;
        List<contact> returnContacts = new List<Contact>();
        
        if(phone != null && phone != ''){
            phone = phone.replaceAll('\\D','');
            phone = phone.replaceAll('-','');
            phone = phone.replace('(','');
            phone = phone.replace(')','');
            String sosl = 'FIND \''+ phone.trim() + '\'IN PHONE FIELDS RETURNING Contact(id,name,accountId,phone,email,mailingStreet,mailingPostalCode,PersonID__c )'; 
            
            List<List<Sobject>>searchList=search.query(sosl);
            
            if(searchList.size() != 0){
                returnContacts = ((List<Contact>)searchList[0]);
            }    
        } else {
            String qryString = 'SELECT  id,name,accountId,phone,email,mailingStreet,mailingPostalCode,PersonID__c FROM Contact WHERE ID != NULL  ';
            
            if(email != null && email != ''){
                qryString += 'AND email =: email ';    
            }
            
            qryString += ' ORDER BY lastName LIMIT 100 ';  
            
            returnContacts = Database.query(qryString);
        }
        
        
        contacts = returnContacts;
        getArchivedContacts();
        getArchivedContactsEmail();   
       

    }
    
    public void getArchivedContacts(){
        if(phone != null && phone != ''){
            //TODO change to call utility and handle errors
            String token = Utility.getGraphQLToken('Heroku');
            //String token = Utility.getGraphQLToken();
            Http httpCall = new Http();
            HttpRequest request = new HttpRequest();
            if(utility.isSandbox){
                request.setEndpoint('callout:Sandbox_Heroku_Search');   
            } else {
                request.setEndpoint('callout:Production_Heroku_Search');
            }
            //return list of records
            request.setMethod('POST');
            //request.setHeader('Content-Type', 'application/graphql');
            //request.setHeader('Authorization', token); 
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Accept', 'application/json');
            request.setHeader('Authorization', 'Bearer '+token);  
                                  
            system.debug(token);
            // String postBody = '{"request": "ZoneDetailsRequest","payload": {"PostalAreaCode": "' + zipCode +'"}}';
            // 6179654594
            String postBody = '{"variables":{"PhoneNumber":"' + phone.trim() + '"},"query":"query ($PhoneNumber: String!) { HouseHoldByPhone(phoneNumber: $PhoneNumber) {Phone{PhoneNumber,IsPrimaryPhone,PhoneTypeName,PhoneUseTypeName},Details{COPSPersonNumber,GEConsumerNo,PersonDetailID,PersonID},ClientPersonCode,FirstName,Gender,IsDead,LastName,MiddleName,PersonID,Orders{AddressLine1,DataSourceCode,DataSourceName,FirstName,LastName,Locality,OrderCreatedBy,OrderDate,OrderDetails{AssetID,BrandName,CleansedModelNumber,DiscountPercent,InvoiceLine,InvoiceNumber,ManufacturerCost,NetInvoiceValue,OrderID,OriginalModelNumber,PartNumber,ProductCategoryName,ProductDescription,ProductLineName,TaxAmount},OrderDiscountAmount,OrderGrossAmount,OrderID,OrderNetAmount,OrderNumber,OrderPaymentMethod,OrderPlacedOn,OrderPromoCode,OrderShipmentAmount,OrderTaxAmount,OrderUniqueKey,PersonID,PostalCode,Region},EmailAddresses{EmailAddress,IsPrimaryEmail,IsPrimaryPerson, MYAMyAccountId}PersonID,plevel,Salutation,FirstName,LastName,Assets{AssetClassName,AssetID,AssetScrappedOn,AssetShippedOn,BrandName,CleansedModelNumber,IsProductReturned,LocationID,MACAddress,OriginalEngineeringModelNumber,OwnershipStartedOn,ProductCategoryName,ProductDescription,ProductLineName,SerialNumber},Locations{LocationID,AddressLine1,AddressLine2,Locality,Region,PostalCode,CountryCode}}} "}';
            // Set the body as a JSON object
            request.setBody(postBody);
            request.setTimeout(50000);
            HttpResponse response ;
            
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
            // Parse the JSON response
            if (response.getStatusCode() == 200) {
                System.debug(response.getBody());
                
                searchResults = searchPhoneResponse.parse(response.getBody());
                for(Contact c:contacts){
                    Integer j = 0;
                    while (j < searchResults.Data.HouseHoldByPhone.size())
                    {
                      if(searchResults.Data.HouseHoldByPhone.get(j).PersonID == c.personid__c)
                      {
                        searchResults.Data.HouseHoldByPhone.remove(j);
                      }else
                      {
                        j++;
                      }
                    }
                }
                showArchived=true;
            } else {
                system.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
                apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus()));
            }
        }
        
    }
    
    public void getArchivedContactsEmail(){
        if(email != null && email != ''){
            String token = Utility.getGraphQLToken('Heroku');
            Http httpCall = new Http();
            HttpRequest request = new HttpRequest();
            if(utility.isSandbox){
                request.setEndpoint('callout:Sandbox_Heroku_Search');   
            } else {
                request.setEndpoint('callout:Production_Heroku_Search');
            }
            //return list of records
            request.setMethod('POST');
            //request.setHeader('Content-Type', 'application/graphql');
            //request.setHeader('Authorization', token); 
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Accept', 'application/json');
            request.setHeader('Authorization', 'Bearer '+token);  
            system.debug(token);
            // String postBody = '{"request": "ZoneDetailsRequest","payload": {"PostalAreaCode": "' + zipCode +'"}}';
            // 6179654594
            String postBody = '{"variables":{"EmailAdress":"' + email.trim() + '"},"query":"query ($EmailAdress: String!) { HouseHoldByEmail(emailAddress: $EmailAdress) {Phone{PhoneNumber,IsPrimaryPhone,PhoneTypeName,PhoneUseTypeName},Details{COPSPersonNumber,GEConsumerNo,PersonDetailID,PersonID},ClientPersonCode,FirstName,Gender,IsDead,LastName,MiddleName,PersonID,Orders{AddressLine1,DataSourceCode,DataSourceName,FirstName,LastName,Locality,OrderCreatedBy,OrderDate,OrderDetails{AssetID,BrandName,CleansedModelNumber,DiscountPercent,InvoiceLine,InvoiceNumber,ManufacturerCost,NetInvoiceValue,OrderID,OriginalModelNumber,PartNumber,ProductCategoryName,ProductDescription,ProductLineName,TaxAmount},OrderDiscountAmount,OrderGrossAmount,OrderID,OrderNetAmount,OrderNumber,OrderPaymentMethod,OrderPlacedOn,OrderPromoCode,OrderShipmentAmount,OrderTaxAmount,OrderUniqueKey,PersonID,PostalCode,Region},EmailAddresses{EmailAddress,IsPrimaryEmail,IsPrimaryPerson, MYAMyAccountId}PersonID,plevel,Salutation,FirstName,LastName,Assets{AssetClassName,AssetID,AssetScrappedOn,AssetShippedOn,BrandName,CleansedModelNumber,IsProductReturned,LocationID,MACAddress,OriginalEngineeringModelNumber,OwnershipStartedOn,ProductCategoryName,ProductDescription,ProductLineName,SerialNumber},Locations{LocationID,AddressLine1,AddressLine2,Locality,Region,PostalCode,CountryCode}}} "}';
            // Set the body as a JSON object
            request.setBody(postBody);
            request.setTimeout(50000);
            HttpResponse response;
            
            if(!test.isRunningTest()){
                response = httpCall.send(request);
                system.debug('request ' + postBody);
                system.debug('response ' + response);
                system.debug('response body ' + response.getBody());
            } else {
                response = new HttpResponse();
                response.setStatusCode(200);
                StaticResource sr = [select id,body from StaticResource Where Name = 'searchEmailTestResponse'];
                String testBody = sr.body.toString();
                response.setBody(testBody);
            }
            // Parse the JSON response
            if (response.getStatusCode() == 200 && response.getBody().length() > 100 ) {
                System.debug(response.getBody());
                
                searchResultsEmail = searchEmailResponse.parse(response.getBody());
                for(Contact c:contacts){
                    Integer j = 0;
                    while (j < searchResultsEmail.Data.HouseHoldByEmail.size())
                    {
                      if(searchResultsEmail.Data.HouseHoldByEmail.get(j).PersonID == c.personid__c)
                      {
                        searchResultsEmail.Data.HouseHoldByEmail.remove(j);
                      }else
                      {
                        j++;
                      }
                    }
                }
                showArchivedEmail = true;
            } else if(response.getStatusCode() == 200){
                
            
            } else {
                system.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
                apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus()));
            }
        }
        
    }
    
    public pageReference clearSearch(){
        //showCreateContact = true;
        firstName = null;
        lastName = null;
        email = null;
        phone = null;
        street = null;
        zip = null;
        contacts = null;
        //archivedContacts = null;
        searchResults = null;
        searchResultsEmail = null;
        showArchivedEmail = false;
        showArchived = false;
        return null;
    
    }
    
    public void getAssets(){
        List<Case_Asset__c> linkedAssets = [Select id,Asset__c,
                                            Asset__r.name,Asset__r.Model_Number__c,Asset__r.SerialNumber,Asset__r.Product_Type__c,
                                            Asset__r.Product_Line__c,Asset__r.AccountId,Asset__r.BrandName__c,Asset__r.Product_Brand__c,
                                            Asset__r.InstallDate
                                            FROM  Case_Asset__c     
                                            WHERE Case__c = :caseRec.id];
        Set<ID> assetIds = new Set<ID>();
        caseAssets = new List<caseAssetWrapper>();
        for(Case_Asset__c ca:linkedAssets){
            assetIds.add(ca.Asset__c );
            caseAssets.add(new caseAssetWrapper(ca));
        }
        
        
        assets = [SELECT Id, name,Model_Number__c,SerialNumber,Product_Type__c,Product_Line__c,AccountID,BrandName__c,Product_Brand__c,InstallDate 
            from Asset WHERE id in :assetIds ];
        
        //get additional assets
        Set<ID> contactAccountIds = new Set<ID>();
        List<GEA_AccountContactRelation__c> geaACR = [SELECT ID,Account__c
                                               FROM GEA_AccountContactRelation__c
                                               WHERE Contact__c = :  caseRec.contact.id];
        
        for(GEA_AccountContactRelation__c gea :geaACR){
            contactAccountIds.add(gea.Account__c);
        }
        
        additionalAssets = [SELECT Id, name,Model_Number__c,SerialNumber,Product_Type__c,Product_Line__c,AccountId,BrandName__c ,Product_Brand__c,InstallDate
            from Asset WHERE AccountId in :contactAccountIds and AccountId != null and id not in :assetIds ];
        
        additionalAssetsWrapper = new List<assetWrapper>();
        for(Asset a : additionalAssets){
            additionalAssetsWrapper.add(new assetWrapper(a));
        }
        
        

    }
    
    public PageReference verifyAsset(){
        Boolean hasErrors = false;
        
        if(modelNumber == '' || modelNumber == null){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Please enter model number.')); 
            hasErrors = true;
        }
        if(!string.isBlank(modelNumber)  && !modelNumber.isAlphanumeric() ){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Model Number can only contain alphanumeric characters.')); 
            hasErrors = true;
        }
        
        if(hasErrors){
            return null;
        }
        
        modelNumber = modelNumber.toUpperCase();
        //make callout
        //
        Http http = new Http();
        HttpRequest request = new HttpRequest();
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
            String testBody = '{"ProductLineDesc": "MICROWAVE","ModelNumber": "PVM9179FLDS","ProductTypeDesc": "MICROWAVE","ProductLineCode": "27","BrandCode": "GEC","ProductTypeCode": "MWO"}';
            response.setBody(testBody);
        }
        // Parse the JSON response
        if (response.getStatusCode() == 200) {
            System.debug(response.getBody());
            modelNumberResponse resp = modelNumberResponse.parse(response.getBody());
                


            Asset newAsset = new Asset();
            newAsset.AccountId = caseRec.accountID;
            newAsset.Model_Number__c = modelNumber;
            newAsset.SerialNumber = serialNumber;
            newAsset.BrandName__c = resp.BrandCode;
            //newAsset.Brand__c = resp.BrandCode;
            newAsset.Product_Type__c = resp.ProductTypeCode;
            newAsset.Product_Line__c = resp.ProductLineCode;
            newAsset.Product_Line_Desc__c = resp.ProductLineDesc;
            newAsset.Product_Type_Desc__c = resp.ProductTypeDesc;
            newAsset.InstallDate = installDate;
            insert newAsset;
            utility.createSiebelAsset(newAsset.id, caseRec.ContactId);
            
            Case_Asset__c newLink = new Case_Asset__c();
            newLink.Case__c = caseRec.id;
            newLink.Asset__c = newAsset.id;
            newLink.Model_Number__c =modelNumber;
            newLink.Serial_Number__c = serialNumber;
            newLink.Install_Date__c = installDate;
            insert newLink;
            
            
            getAssets();
            modelNumber = '';
            serialNumber = '';     
            
                
            
        } else {
            system.debug('The status code returned was not expected: ' +
            response.getStatusCode() + ' ' + response.getStatus());
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'The status code returned was not expected: ' +
            response.getStatusCode() + ' ' + response.getStatus()));
        }
        
        
        return null;
    }
    
    public pageReference attachAsset(){
        //loop selected assets
        // create case asset record Case_Asset__c    Case__c, Asset
        List<Case_Asset__c> newCaseAssetRecords = new List<Case_Asset__c>();
        for(assetWrapper aw : additionalAssetsWrapper){
            if(aw.isSelected){
                Case_Asset__c newRec = new Case_Asset__c();
                newRec.Case__c = caseRec.id;
                newRec.Asset__c = aw.asset.id;
                newREc.Model_Number__c = aw.asset.Model_Number__c;
                newREc.Serial_Number__c = aw.asset.SerialNumber;
                newRec.Install_Date__c = aw.asset.InstallDate;   
                newCaseAssetRecords.add(newRec);
            }
        }
        insert newCaseAssetRecords;
        
        getAssets();
        return null;
    }
    
    public pageReference removeCaseAsset(){
        Boolean assetSelected = false;
        for(caseAssetWrapper caw:caseAssets){
            if(caw.isSelected && !assetSelected){
                assetSelected = true;   
            } 
        }
        if(!assetSelected){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Please select an asset')); 
            return null;
        }
        
        for(caseAssetWrapper caw:caseAssets){
            List<Case_Asset__c> deleteCaseAssets = new List<Case_Asset__c>();
            if(caw.isSelected ){
                deleteCaseAssets.add(caw.caseAsset);
            } 
            try {
                delete deleteCaseAssets;
            } catch(exception e) {        //apexpages.addmessages(e);
                apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,e.getMessage())); 
                return null;        
            }
         }

        getAssets();
        return null;
    }
    
    public class assetWrapper{
    
        public Asset asset{get;set;}
        public boolean isSelected{get;set;}
     
        public assetWrapper(Asset a){
         asset=a;
         isselected=false;
       }
    }
    
    public class caseAssetWrapper{
    
        public Case_Asset__c caseAsset{get;set;}
        public boolean isSelected{get;set;}
     
        public caseAssetWrapper(Case_Asset__c ca){
         caseAsset=ca;
         isselected=false;
       }
    }
    
}