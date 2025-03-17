public without sharing class SearchControllerVFAuth0 {

    public String firstName {get;set;}
    public String lastName {get;set;}
    public String email {get;set;}
    public String phone {get;set;}
    public String street {get;set;}
    public String zip {get;set;}
    public List<Contact> contacts {get;set;}
    public List<Contact> tempContacts {get;set;}
    public List<DA_Contact__b> archivedContacts {get;set;}
    
    public String index1 {get;set;}
   
    public Account newAccount{get;set;}
    public searchPhoneResponse searchResults{get;set;}
    public searchEmailResponse searchResultsEmail{get;set;}
    public boolean showArchived {get;set;}
    public boolean showArchivedEmail {get;set;}
    public String ani{get;set;}
    public Contact newContact{get;set;}
    public Boolean showCreateContact{get;set;}
    public Boolean createUnknownAddress {get;set;}
    
    public searchControllerVFAuth0(){
        showCreateContact = false;
        showArchivedEmail = false;
        showArchived = false;
        createUnknownAddress = false;
        newContact = new Contact();
        newContact.Contact_Type__c  = 'Consumer';
        User currentUser = [SELECT ID,Business_Team__c,Team_Persona__c
            FROM User
            WHERE id = :UserInfo.getUserId() LIMIT 1];
        
        //tag or social media pre-populate unknown address     
        if(currentUser.Business_Team__c == 'TAG'){
           //|| currentUser.Business_Team__c == 'Social Media' ||
          //currentUser.Business_Team__c == 'Digital Media' || currentUser.Business_Team__c == 'eCommerce'){
            firstName = 'NoName';
            lastName = 'NoName';
            Street = 'NoAddress';
            Zip = '00000';
            createUnknownAddress = true;
        }
    }
    
    public pageReference redirectSearch(){
        contacts = new List<Contact>();
        ani = ApexPages.currentPage().getParameters().get('ani');
            if(ani != null){
                String sosl = 'FIND \''+ ani.trim() + '\'IN PHONE FIELDS RETURNING Contact(id,name,accountId,phone,email,mailingStreet,mailingPostalCode,PersonID__c,Special_Handling_Code__c WHERE Special_Handling_Code__c = null )'; 
            
                List<List<Sobject>>searchList=search.query(sosl);
                
                List<contact> tempContacts;
                if(searchList.size() != 0){
                    tempContacts = ((List<Contact>)searchList[0]);
                }    
                
                for(contact c:tempContacts){
                    if(string.isBlank(c.Special_Handling_Code__c)){
                        contacts.add(c);
                    } 
                }
                
                
                //redirect to search page
                searchResults = new searchPhoneResponse();
                
                // if no contact found by phone search 360 by phone number  --- send phone number over to search page - have search page execute call as if they clicked search button --- 
                // if single result then auto restore  
                
                searchResults = utility.getArchivedContacts(ani);
                if(searchResults.status != null && searchResults.status.message != null ){
                   phone = ani;
                   apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Error ' + searchResults.status.message)); 
                   return null;
                }
                /*for(Contact c:contacts){
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
                }  */              
                system.debug(searchResults);
                // if single match found restore
                if(searchResults.data != null &&  searchResults.Data.HouseHoldByPhone.size() == 1){
                    // restore and set contactRec
                    ID contactID =  utility.restoreContact(searchResults.Data.HouseHoldByPhone[0]);
                    //contactRec = [SELECT ID,NAME,Phone,email,accountId FROM CONTACT WHERE id =: contactID LIMIT 1];
                    PageReference p = new PageReference('/apex/contactDashboard?id=' +contactID);
                    return p;
                }
                
                // if multiple matches found then show responses and allow restore    
                if(searchResults.data != null &&  searchResults.Data.HouseHoldByPhone.size() > 1){
                    showArchived=true;
                    phone = ani;
                    return null;
                }
                phone = ani;
            }
  
        return null;
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
    
    public pageReference search(){
        showCreateContact = true;
        showArchivedEmail = false;
        showArchived = false;
        List<contact> returnContacts = new List<Contact>();
        
        if(phone != null && phone != ''){
            phone = phone.replaceAll('\\D','');
            phone = phone.replaceAll('-','');
            phone = phone.replace('(','');
            phone = phone.replace(')','');
            String sosl = 'FIND \''+ phone.trim() + '\'IN PHONE FIELDS RETURNING Contact(id,name,accountId,phone,email,mailingStreet,mailingPostalCode,PersonID__c,Special_Handling_Code__c  )'; 
            
            List<List<Sobject>>searchList=search.query(sosl);
            
            if(searchList.size() != 0){
                tempContacts = ((List<Contact>)searchList[0]);
                if(tempContacts != null)
                {
                    for(Contact c:tempContacts){
                        if(string.isBlank(c.Special_Handling_Code__c)){
                            returnContacts.add(c);   
                        }
                        
                    }
                }
                
            }    
        } else {
            String qryString = 'SELECT  id,name,accountId,phone,email,mailingStreet,mailingPostalCode,PersonID__c FROM Contact WHERE ID != NULL  ';
            //if(firstName != null && firstName != '' ){
            //    qryString += 'AND firstName =:  firstName ';    
            //}
            //if(lastName != null && lastName != ''){
            //    qryString += 'AND lastName =: lastName ';    
            //}
            if(email != null && email != ''){
                qryString += 'AND email =: email ';    
            }
            //if(phone != null && phone != ''){
            //    qryString += 'AND phone =: phone ';    
            //}
            //if(street != null && street != '' && zip != null && zip != ''){
            //    qryString += 'AND mailingstreet =: street AND mailingPostalCode =: zip ';    
            //}
            qryString += ' ORDER BY lastName LIMIT 100 ';  
            
            returnContacts = Database.query(qryString);
        }
        
        
        
        
        /* TODO - phase 1 will only search by phone and email - to add later
        if(street != null && street != '' && zip != null && zip != ''){
            
            String sosl = 'FIND \''+ street + '\'IN ALL FIELDS RETURNING Account(id,Name where zip_search__c =\'' + zip + '\')';
            List<List<SObject>>searchList=search.query(sosl);
 
            Set<ID> accountIds = new Set<ID>();
            for(List<Sobject> s:searchList){
                for(Sobject s1:s){
                      accountIds.add(s1.id);
                }
            }
        
            List<contact> locationContacts = [SELECT  id,name,accountId,phone,email,mailingStreet,mailingPostalCode 
                                              FROM Contact 
                                              WHERE accountID in: accountIds Limit 100];
            for(contact c:locationContacts){
                returnContacts.add(c);  
            }
        }
        */
        
        contacts = returnContacts;
        getArchivedContacts();
        getArchivedContactsEmail();
        system.debug('emailarch ' + searchResultsEmail);
        showArchivedEmail = true;
        showCreateContact = true;
        system.debug('showArchivedEmail ' + showArchivedEmail);
        return null;

    }
        
    public void getArchivedContacts(){
        showCreateContact = true;
        phone = '9986140140';
        if(phone != null && phone != ''){
            //TODO change to call utility and handle errors
            
            String token = Utility.getGraphQLToken();
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
            
            
            // Parse the JSON response
            if (response.getStatusCode() == 200 && !response.getBody().contains('socket ended') && !response.getBody().contains('errors')) {
                System.debug(response.getBody());
                
                searchResults = searchPhoneResponse.parse(response.getBody());
                if(tempContacts != null)
                {
                    for(Contact c:tempContacts){
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
                }
                
            } else {
                system.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
                apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus()));
            }
        }
        showCreateContact = true;
    }
    
    public void getArchivedContactsEmail(){
        system.debug('Start of Function getArchivedContactsEmail');
        showCreateContact = true;
        String email = 'gowsics@gmail.com';
        if(email != null && email != ''){
            //String token = UtilityAuth0.getGraphQLToken();
            //system.debug('calling UtilityAuth0New1');
            String token = Utility.getGraphQLToken();
            system.debug('calling Utility');
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
            system.debug('Generated Token for AWS Call--' + token);
            // String postBody = '{"request": "ZoneDetailsRequest","payload": {"PostalAreaCode": "' + zipCode +'"}}';
            // 6179654594
            //String postBody = '{"variables":{"EmailAdress:gowsics@gmail.com"},"query":"query ($EmailAdress: String!) { HouseHoldByEmail(emailAddress: $EmailAdress) {Phone{PhoneNumber,IsPrimaryPhone,PhoneTypeName,PhoneUseTypeName},Details{COPSPersonNumber,GEConsumerNo,PersonDetailID,PersonID},ClientPersonCode,FirstName,Gender,IsDead,LastName,MiddleName,PersonID,Orders{AddressLine1,DataSourceCode,DataSourceName,FirstName,LastName,Locality,OrderCreatedBy,OrderDate,OrderDetails{AssetID,BrandName,CleansedModelNumber,DiscountPercent,InvoiceLine,InvoiceNumber,ManufacturerCost,NetInvoiceValue,OrderID,OriginalModelNumber,PartNumber,ProductCategoryName,ProductDescription,ProductLineName,TaxAmount},OrderDiscountAmount,OrderGrossAmount,OrderID,OrderNetAmount,OrderNumber,OrderPaymentMethod,OrderPlacedOn,OrderPromoCode,OrderShipmentAmount,OrderTaxAmount,OrderUniqueKey,PersonID,PostalCode,Region},EmailAddresses{EmailAddress,IsPrimaryEmail,IsPrimaryPerson, MYAMyAccountId}PersonID,plevel,Salutation,FirstName,LastName,Assets{AssetClassName,AssetID,AssetScrappedOn,AssetShippedOn,BrandName,CleansedModelNumber,IsProductReturned,LocationID,MACAddress,OriginalEngineeringModelNumber,OwnershipStartedOn,ProductCategoryName,ProductDescription,ProductLineName,SerialNumber},Locations{LocationID,AddressLine1,AddressLine2,Locality,Region,PostalCode,CountryCode}}} "}';
            String postBody = '{"variables":{"EmailAdress":"' + email.trim() + '"},"query":"query ($EmailAdress: String!) { HouseHoldByEmail(emailAddress: $EmailAdress) {Phone{PhoneNumber,IsPrimaryPhone,PhoneTypeName,PhoneUseTypeName},Details{COPSPersonNumber,GEConsumerNo,PersonDetailID,PersonID},ClientPersonCode,FirstName,Gender,IsDead,LastName,MiddleName,PersonID,Orders{AddressLine1,DataSourceCode,DataSourceName,FirstName,LastName,Locality,OrderCreatedBy,OrderDate,OrderDetails{AssetID,BrandName,CleansedModelNumber,DiscountPercent,InvoiceLine,InvoiceNumber,ManufacturerCost,NetInvoiceValue,OrderID,OriginalModelNumber,PartNumber,ProductCategoryName,ProductDescription,ProductLineName,TaxAmount},OrderDiscountAmount,OrderGrossAmount,OrderID,OrderNetAmount,OrderNumber,OrderPaymentMethod,OrderPlacedOn,OrderPromoCode,OrderShipmentAmount,OrderTaxAmount,OrderUniqueKey,PersonID,PostalCode,Region},EmailAddresses{EmailAddress,IsPrimaryEmail,IsPrimaryPerson, MYAMyAccountId}PersonID,plevel,Salutation,FirstName,LastName,Assets{AssetClassName,AssetID,AssetScrappedOn,AssetShippedOn,BrandName,CleansedModelNumber,IsProductReturned,LocationID,MACAddress,OriginalEngineeringModelNumber,OwnershipStartedOn,ProductCategoryName,ProductDescription,ProductLineName,SerialNumber},Locations{LocationID,AddressLine1,AddressLine2,Locality,Region,PostalCode,CountryCode}}} "}';
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
                StaticResource sr = [select id,body from StaticResource Where Name = 'searchEmailTestResponse'];
                String testBody = sr.body.toString();
                response.setBody(testBody);
            }
            // Parse the JSON response
            if (response.getStatusCode() == 200 && response.getBody().length() > 100 && !response.getBody().contains('"HouseHoldByEmail":null') ) {
                System.debug(response.getBody());
                showArchivedEmail = true;
                searchResultsEmail = searchEmailResponse.parse(response.getBody());
                system.debug('contacts ' + contacts);
                //for(Contact c:contacts){
                //    system.debug('check existing ');
                //    Integer j = 0;
                 //   while (j < searchResultsEmail.Data.HouseHoldByEmail.size())
                 //   {
                 //     if(searchResultsEmail.Data.HouseHoldByEmail.get(j).PersonID == c.personid__c)
                 //     {
                  //      searchResultsEmail.Data.HouseHoldByEmail.remove(j);
                   //   }else
                 //     {
                  //      j++;
                 //     }
                  //  }
                //}
                
            } else if(response.getStatusCode() == 200){
                
            
            } else {
                system.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
                apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus()));
            }
        }
        system.debug('returned searchResultsEmail ' + searchResultsEmail);
        showArchivedEmail= true;
        showCreateContact = true;
    }
    
    public void getArchivedContactsEmailAuth0(){
        system.debug('Start of Function getArchivedContactsEmail');
        showCreateContact = true;
        //String email1 = 'gowsics@gmail.com';
        String email1 = 'rebecca.thompson@geappliances.com';
        if(email1 != null && email1 != ''){
            //String token = UtilityAuth0New1.getGraphQLToken();
            //system.debug('calling UtilityAuth0New1');
            //String token = Utility.getGraphQLToken();
            String token = UtilityAuth0New1.getGraphQLTokenAuth0New1();
            system.debug('calling Utility');
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
            system.debug('Generated Token for AWS Call--' + token);
            // String postBody = '{"request": "ZoneDetailsRequest","payload": {"PostalAreaCode": "' + zipCode +'"}}';
            // 6179654594
            //String postBody = '{"variables":{"EmailAdress:gowsics@gmail.com"},"query":"query ($EmailAdress: String!) { HouseHoldByEmail(emailAddress: $EmailAdress) {Phone{PhoneNumber,IsPrimaryPhone,PhoneTypeName,PhoneUseTypeName},Details{COPSPersonNumber,GEConsumerNo,PersonDetailID,PersonID},ClientPersonCode,FirstName,Gender,IsDead,LastName,MiddleName,PersonID,Orders{AddressLine1,DataSourceCode,DataSourceName,FirstName,LastName,Locality,OrderCreatedBy,OrderDate,OrderDetails{AssetID,BrandName,CleansedModelNumber,DiscountPercent,InvoiceLine,InvoiceNumber,ManufacturerCost,NetInvoiceValue,OrderID,OriginalModelNumber,PartNumber,ProductCategoryName,ProductDescription,ProductLineName,TaxAmount},OrderDiscountAmount,OrderGrossAmount,OrderID,OrderNetAmount,OrderNumber,OrderPaymentMethod,OrderPlacedOn,OrderPromoCode,OrderShipmentAmount,OrderTaxAmount,OrderUniqueKey,PersonID,PostalCode,Region},EmailAddresses{EmailAddress,IsPrimaryEmail,IsPrimaryPerson, MYAMyAccountId}PersonID,plevel,Salutation,FirstName,LastName,Assets{AssetClassName,AssetID,AssetScrappedOn,AssetShippedOn,BrandName,CleansedModelNumber,IsProductReturned,LocationID,MACAddress,OriginalEngineeringModelNumber,OwnershipStartedOn,ProductCategoryName,ProductDescription,ProductLineName,SerialNumber},Locations{LocationID,AddressLine1,AddressLine2,Locality,Region,PostalCode,CountryCode}}} "}';
            String postBody = '{"variables":{"EmailAdress":"' + email1.trim() + '"},"query":"query ($EmailAdress: String!) { HouseHoldByEmail(emailAddress: $EmailAdress) {Phone{PhoneNumber,IsPrimaryPhone,PhoneTypeName,PhoneUseTypeName},Details{COPSPersonNumber,GEConsumerNo,PersonDetailID,PersonID},ClientPersonCode,FirstName,Gender,IsDead,LastName,MiddleName,PersonID,Orders{AddressLine1,DataSourceCode,DataSourceName,FirstName,LastName,Locality,OrderCreatedBy,OrderDate,OrderDetails{AssetID,BrandName,CleansedModelNumber,DiscountPercent,InvoiceLine,InvoiceNumber,ManufacturerCost,NetInvoiceValue,OrderID,OriginalModelNumber,PartNumber,ProductCategoryName,ProductDescription,ProductLineName,TaxAmount},OrderDiscountAmount,OrderGrossAmount,OrderID,OrderNetAmount,OrderNumber,OrderPaymentMethod,OrderPlacedOn,OrderPromoCode,OrderShipmentAmount,OrderTaxAmount,OrderUniqueKey,PersonID,PostalCode,Region},EmailAddresses{EmailAddress,IsPrimaryEmail,IsPrimaryPerson, MYAMyAccountId}PersonID,plevel,Salutation,FirstName,LastName,Assets{AssetClassName,AssetID,AssetScrappedOn,AssetShippedOn,BrandName,CleansedModelNumber,IsProductReturned,LocationID,MACAddress,OriginalEngineeringModelNumber,OwnershipStartedOn,ProductCategoryName,ProductDescription,ProductLineName,SerialNumber},Locations{LocationID,AddressLine1,AddressLine2,Locality,Region,PostalCode,CountryCode}}} "}';
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
                StaticResource sr = [select id,body from StaticResource Where Name = 'searchEmailTestResponse'];
                String testBody = sr.body.toString();
                response.setBody(testBody);
            }
            // Parse the JSON response
            if (response.getStatusCode() == 200 && response.getBody().length() > 100 && !response.getBody().contains('"HouseHoldByEmail":null') ) {
                System.debug(response.getBody());
                showArchivedEmail = true;
                searchResultsEmail = searchEmailResponse.parse(response.getBody());
                system.debug('contacts ' + contacts);
                //for(Contact c:contacts){
                 //   system.debug('check existing ');
                  //  Integer j = 0;
                 //   while (j < searchResultsEmail.Data.HouseHoldByEmail.size())
                  //  {
                  //    if(searchResultsEmail.Data.HouseHoldByEmail.get(j).PersonID == c.personid__c)
                  //    {
                  //      searchResultsEmail.Data.HouseHoldByEmail.remove(j);
                 //     }else
                 //     {
                //        j++;
                 //     }
                 //   }
                //}
                
            } else if(response.getStatusCode() == 200){
                
            
            } else {
                system.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
                apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus()));
            }
        }
        //system.debug('returned searchResultsEmail ' + searchResultsEmail);
        showArchivedEmail= true;
        showCreateContact = true;
    }
    
    public pageReference clearSearch(){
        showCreateContact = true;
        firstName = null;
        lastName = null;
        email = null;
        phone = null;
        street = null;
        zip = null;
        contacts = null;
        archivedContacts = null;
        searchResults = null;
        searchResultsEmail = null;
        showArchivedEmail = false;
        showArchived = false;
        return null;
    }
    /*
    public pageReference restoreContact(){
        String restoreString = 'S_Name_Indexed__c = \'' + index1 + '\' and S_Phone_Indexed__c  = \'' + index2 + '\' and S_Id_Indexed__c = \'' + index3 + '\'';
        
        System.debug('restoreString ' +restoreString );
        Map<string,string> restoreResult = ceparc.DataArchivaDetailComponentController.unarchive(restoreString, 'Contact');
        
        System.debug('restoreResult ' +restoreResult );
        if(restoreResult.get('INFO') != null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please try again ' + restoreResult.get('INFO')));
            return null;
        }
        // restore response   {SUCCESS=0036C00000AlCpRQAV}
        //{INFO=Schema sync submitted successfully! Please try again after some time.
        List<String> responseString = new List<String>();
      
        List<Contact> contactRec = [SELECT ID,ACCOUNTID,Archive_Flag__c  FROM CONTACT WHERE ID =: restoreResult.get('SUCCESS')];
        // clear archive flag
        contactRec[0].Archive_Flag__c  = '';
        update contactRec;

        system.debug(restoreResult.get('SUCCESS'));
        PageReference p = new PageReference('/apex/contactDashboard?id=' + restoreResult.get('SUCCESS'));

        
        String contactID = index3.mid(0,15);
        //createAccountContactRelation(contactID,restoreResult.get('SUCCESS'));

        return p;

    }
    */
    
    public pageReference restoreContact(){
        ID contactId;
        for(searchPhoneResponse.HouseHoldByPhone sr: searchResults.Data.HouseHoldByPhone){
            if(index1 == sr.PersonID){
                contactID = utility.restoreContact(sr);    
            }
        }
        system.debug('restored contact id ' + contactId);
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
        PageReference p = new PageReference('/apex/contactDashboard?id=' + contactId);
        return p;
    }
    
    /*
    public PageReference createTagContact(){
        Boolean hasErrors = false;
        if(phone == null || phone == ''){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Phone Required.'));
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
        
        if(!showCreateContact){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Please search before creating a contact.'));
            hasErrors = true;
        }
        if(hasErrors){
            return null;                                                           
        }
        //Contact newContact = new Contact();
        newContact.firstName = firstName;
        newContact.LastName = lastName;
        newContact.email = email;
        newContact.phone = phone;
        
        try{
            insert newContact;
        }catch(exception e){
            throw new AuraHandledException('Error creating contact: '
            + e.getMessage()); 
        }
        PageReference p = new PageReference('/apex/contactDashboard?id=' + newContact.id);
        return p;
    }
    */
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
        newContact.LastName = LastName;
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
        ////PageReference p = new PageReference('/one/one.app#/alohaRedirect/apex/contactDashboard?id=' + newContact.id);
        PageReference p = new PageReference('/apex/contactDashboard?id=' + newContact.id);
       
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
        
        //if tag contact call create tag contact and return
        if(currentUser.Business_Team__c == 'TAG'){
            //return createTagContact();
        }
        
        //edit check
        Boolean hasErrors = false;
        if(string.isBlank(street)){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Street Required.'));
            hasErrors = true;
        }
        //if((string.isBlank(phone)) && currentUser.Business_Team__c != 'TAG'){
        if((string.isBlank(phone)) ){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Phone Required.'));
            hasErrors = true;
        }
        if(string.isBlank(zip) ){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Zip Required.'));
            hasErrors = true;
        }
        if(string.isBlank(firstName) ){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'First Name Required.'));
            hasErrors = true;
        }
        if(string.isBlank(lastName) ){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Last Name Required.'));
            hasErrors = true;
        }  
        
        if(!showCreateContact){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Please search before creating a contact.'));
            hasErrors = true;
        }
        if(hasErrors){
            return null;                                                           
        }
        
        zip = zip.subString(0,5);
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
                       AND Special_Handling_Code__c = NULL
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
            request.setTimeout(60000);
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
                if(string.isBlank(resp.CityName) || string.isBlank(resp.StateCode) ){
                    apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Address could not be verified please try again. '));
                    return null;    
                }
                newAccount = new account();
                newAccount.name = street.trim() + ' ' + utility.initCap(resp.CityName.toLowerCase()).trim() + ' ' + resp.StateCode.trim() + ' ' + zip.trim();
                newAccount.BillingStreet = street.trim();
                newAccount.BillingCity = utility.initCap(resp.CityName.toLowerCase()).trim();
                newAccount.BillingState = resp.StateCode.trim();
                newAccount.BillingPostalCode = zip.trim();
                newAccount.Region__c = decimal.valueOf(resp.RegionNo);
                
                newAccount.Zone__c = resp.ZoneCode;
                if(resp.ZoneCode != null && resp.ZoneCode == '09'){
                    newAccount.Service_Region_Zone__c =  'Customer Care';  
                } else {
                   newAccount.Service_Region_Zone__c =  'Factory Service'; 
                }
                
                newAccount.Zip_Search__c = zip.trim();
                newAccount.Street_Search__c=street.trim();
                
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
        CN1Contact.Phone = phone;
        CN1Contact.Email = email;
        account a = new account();
        a.BillingStreet = street.trim();
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
        
        
        //Contact newContact = new Contact();
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
      
        system.debug('Create contact ' + newContact);
        //PageReference p = new PageReference('/one/one.app#/alohaRedirect/apex/contactDashboard?id=' + newContact.id);
        PageReference p = new PageReference('/apex/contactDashboard?id=' + newContact.id);
       
        return p;

    }
}