public class ConcessionNCECall {
    @InvocableMethod(label='Submit Concession NCE' description='Submit Concession NCE')
    public static List<String> submit(List<String > concessionID) {
        system.debug('concessionID ' + concessionID);
        User u = [Select SSO_ID__c from User where Id =: UserInfo.getUserId() LIMIT 1];
        Concession__c concession = [SELECT ID,Region__c ,Fault_Code_f__c ,Zone__c ,CustDistrict__c ,CustCode__c ,
                                    Consumers_Phone_f__c ,Concession_Amount__c ,Tax_Amount__c,case__r.Account.BillingStreet,
                                    case__r.Account.BillingCity,case__r.Account.BillingState, case__r.Account.BillingPostalCode,
                                    Replacement_Upgrade_Model_Product__r.StockKeepingUnit,Concession_Location__r.Region__c,
                                    Concession_Location__r.zone__c,Name_f__c,Case_Asset__r.serial_number__c,
                                    Case_Asset__r.model_number__c,Case_Asset__r.Install_Date_f__c,ReplAddress1__c,
                                    ReplAddress2__c,ReplCity__c,ReplState__c,ReplZip__c,Case__r.Contact.FirstName,
                                    Case__r.Contact.LastName,case__r.caseNumber, Accessory_1_Product__r.StockKeepingUnit,
                                    Accessory_2_Product__r.StockKeepingUnit FROM Concession__c 
                                    WHERE ID = :concessionId LIMIT 1];
        
        List<String> returnList = new List<String>();
        
        concessionSubmitResponse  submitResults;
        concessionSubmitResponse2  submitResults2;
        
        //Edit check
        if(string.isBlank(u.SSO_ID__c) && !test.isRunningTest()){
            returnList.add('Error - SSO Number required on user.');
            return returnList;
        }
        if(concession.Concession_Location__r.region__c == null){
            returnList.add('Error - Region required');return returnList;
        }
        if(string.isBlank(concession.Concession_Location__r.zone__c)){
            returnList.add('Error - Zone required');return returnList;  
        }
        if(string.isBlank(concession.case__r.Account.BillingStreet)){
            returnList.add('Error - Location Street required');return returnList;  
        }
        if(string.isBlank(concession.Name_f__c)){
            returnList.add('Error - Contact Name required');return returnList;  
        }
        if(concession.CustDistrict__c == null){
            returnList.add('Error - District required');return returnList; 
        }
        if(string.isBlank(concession.Consumers_Phone_f__c)){
            returnList.add('Error - Consumer Phone Number required.');return returnList; 
        }
        if(string.isBlank(concession.Fault_Code_f__c)){
            returnList.add('Error - Fault Code required.');return returnList;
        }
        
        //Replacement Address
        String repZone = '';
        if(string.isBlank(concession.ReplAddress1__c)){
            concession.ReplAddress1__c = concession.Name_f__c;
        }
        if(string.isBlank(concession.ReplAddress2__c)){
            concession.ReplAddress2__c = concession.case__r.Account.BillingStreet;
        }
        if(string.isBlank(concession.ReplCity__c)){
            concession.ReplCity__c = concession.case__r.Account.BillingCity;
        }
        if(string.isBlank(concession.ReplState__c)){
            concession.ReplState__c = concession.case__r.Account.BillingState;
        }
        if(string.isBlank(concession.ReplZip__c)){
            concession.ReplZip__c = concession.case__r.Account.BillingPostalCode;
            repZone = concession.concession_Location__r.Zone__c;
        }
        
        //Get repzone
        if(repZone == ''){
          zoneDetailsResponse zd = utility.addressVerify(concession.ReplZip__c);
            if(zd.errorMessage == null || zd.errorMessage == ''){
                repZone = zd.ZoneCode;  
            } else {
                returnList.add('Error retrieving zone/region ' + zd.errorMessage);
                return returnList;
            }    
            
        }

        
        //region
        String region = string.valueOf(concession.Concession_Location__r.Region__c);
        if(region.length() == 3){
            region = region.substring(1, region.length());
        }
        
        String token = Utility.getGraphQLToken();
        //if token has error return error
        if(token.substring(0,4) == 'Error'){
            returnList.add(token);
            return returnList;
        }
        
        String address3 = 'CS' + concession.case__r.caseNumber.leftPad(10, '0') + 'CU';
        
        String strAccessory1;
        String strAccessory2;
        if(concession.Accessory_1_Product__r.StockKeepingUnit == null || concession.Accessory_1_Product__r.StockKeepingUnit == ''){
            strAccessory1 = '';  
        } 
        else 
        {
            strAccessory1 = concession.Accessory_1_Product__r.StockKeepingUnit;
        } 
        if(concession.Accessory_2_Product__r.StockKeepingUnit == null || concession.Accessory_2_Product__r.StockKeepingUnit == ''){
            strAccessory2 = '';  
        } 
        else 
        {
            strAccessory2 = concession.Accessory_2_Product__r.StockKeepingUnit;
        } 
        
        Http httpCall = new Http();
        HttpRequest request = new HttpRequest();
        if(utility.isSandbox){
            request.setEndpoint('callout:Sandbox_GraphQL_Concession');   
        } else {
            request.setEndpoint('callout:Production_GraphQL_Concession');
        }
        //return list of records
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/graphql');
        request.setHeader('Authorization', token);                       
        system.debug(token);
        //String postBody1 = '{"query":"mutation  { processConcession(payload: {sso:\\"240029287\\",Region:\\"25\\",MrCode:\\"A14\\",CsdZone:\\"09\\",CustDist:\\"81\\",CustCode: \\"57777\\",CsAddr1:\\"Gowsic S\\",CsAddr2:\\"Test Street\\", CsCity:\\"AIEA\\",CsState: \\"HI\\",CsZip: \\"96701\\",CsPhone:\\"9986140140\\",RepModel:\\"ABE21DGKBS\\",  RepAvailability:\\"AVAILABL\\",RepZone:\\"\\",RepAddr1:\\"\\",RepAddr2:\\"\\",RepCity:\\"\\",RepState:\\"\\",RepZip: \\"\\",CsModel: \\"\\",CsSerial: \\"\\",CsDate: \\"\\",CsType: \\"\\",CsCall: \\"\\",CustomerPayment: \\"093750\\",CsTaxValue: \\"004419\\",ConcessionType: \\"ProRate\\"})}"}';
        //system.debug('postBody1' + postBody1);
        String installDate = '';
        if(concession.Case_Asset__r.Install_Date_f__c != null){
           Integer d = concession.Case_Asset__r.Install_Date_f__c.day();
            Integer mo = concession.Case_Asset__r.Install_Date_f__c.month();
            Integer yr = concession.Case_Asset__r.Install_Date_f__c.year();
            DateTime tempDate = DateTime.newInstance(yr, mo, d);
            installDate = tempDate.format('MM/dd/yyyy');
        }
        String ccType = 'FS';
        if(concession.concession_Location__r.Zone__c == '09'){
            ccType = 'CC'; 
        }
        
        String postBody = '{"query":"mutation  { processConcession(payload: {sso:\\"' + u.SSO_ID__c + 
            '\\",Region:\\"' + region + 
            '\\",MrCode:\\"' + concession.Fault_Code_f__c + 
            '\\",CsdZone:\\"' + concession.concession_Location__r.Zone__c + 
            '\\",CustDist:\\"' + concession.CustDistrict__c + 
            '\\",CustCode: \\"' + concession.CustCode__c + 
            '\\",CsAddr1:\\"' + utility.truncate(concession.Case__r.Contact.FirstName +' '+ concession.Case__r.Contact.LastName,25) + 
            '\\",CsAddr2:\\"' + utility.truncate(concession.case__r.Account.BillingStreet,25) + 
            '\\", CsCity:\\"' + utility.truncate(concession.case__r.Account.BillingCity,15) + 
            '\\",CsState: \\"' + concession.case__r.Account.BillingState + 
            '\\",CsZip: \\"' + concession.case__r.Account.BillingPostalCode.subString(0,5) + 
            '\\",CsPhone:\\"' + concession.Consumers_Phone_f__c.replaceAll('-','') + 
            '\\",RepModel:\\"' + concession.Replacement_Upgrade_Model_Product__r.StockKeepingUnit + 
            '\\",  RepAvailability:\\"AVAILABL\\"' + 
            ',RepZone:\\"' + repZone +
            '\\",RepAddr1:\\"' + utility.truncate(concession.Case__r.Contact.FirstName +' '+ concession.Case__r.Contact.LastName,25) +
            '\\",RepAddr2:\\"' + utility.truncate(concession.ReplAddress2__c,25) +
            '\\",RepAddr3:\\"' + address3 +
            '\\",RepCity:\\"' + utility.truncate(concession.ReplCity__c,15) + 
            '\\",RepState:\\"' + concession.ReplState__c +  
            '\\",RepZip: \\"' + concession.ReplZip__c.subString(0,5) + 
            '\\",CsModel: \\"' + concession.Case_Asset__r.model_number__c +
            '\\",CsSerial: \\"' + concession.Case_Asset__r.serial_number__c + 
            '\\",CsDate: \\"' + installDate + 
            '\\",CsType: \\"' + ccType + 
            '\\",CsCall: \\"1\\"' + 
            ',CustomerPayment: \\"\\"' + 
            ',CsTaxValue: \\"\\"' + 
            ',ConcessionType: \\"NCE\\"' + 
            ',AccessoryModel1:\\"' + strAccessory1 +
            '\\",AccessoryModel2:\\"' + strAccessory2 +
            '\\"})}"}';
        system.debug('postBody' + postBody);
        system.debug('postBody2 ' + postBody.substring(300, postBody.length()));
//        String postBody = '{"variables":{"PhoneNumber":"' + phone.trim() + '"},"query":"query ($PhoneNumber: String!) { HouseHoldByPhone(phoneNumber: $PhoneNumber) {Phone{PhoneNumber,IsPrimaryPhone,PhoneTypeName,PhoneUseTypeName},Details{COPSPersonNumber,GEConsumerNo,PersonDetailID,PersonID},ClientPersonCode,FirstName,Gender,IsDead,LastName,MiddleName,PersonID,Orders{AddressLine1,DataSourceCode,DataSourceName,FirstName,LastName,Locality,OrderCreatedBy,OrderDate,OrderDetails{AssetID,BrandName,CleansedModelNumber,DiscountPercent,InvoiceLine,InvoiceNumber,ManufacturerCost,NetInvoiceValue,OrderID,OriginalModelNumber,PartNumber,ProductCategoryName,ProductDescription,ProductLineName,TaxAmount},OrderDiscountAmount,OrderGrossAmount,OrderID,OrderNetAmount,OrderNumber,OrderPaymentMethod,OrderPlacedOn,OrderPromoCode,OrderShipmentAmount,OrderTaxAmount,OrderUniqueKey,PersonID,PostalCode,Region},EmailAddresses{EmailAddress,IsPrimaryEmail,IsPrimaryPerson, MYAMyAccountId}PersonID,plevel,Salutation,FirstName,LastName,Assets{AssetClassName,AssetID,AssetScrappedOn,AssetShippedOn,BrandName,CleansedModelNumber,IsProductReturned,LocationID,MACAddress,OriginalEngineeringModelNumber,OwnershipStartedOn,ProductCategoryName,ProductDescription,ProductLineName,SerialNumber},Locations{LocationID,AddressLine1,AddressLine2,Locality,Region,PostalCode,CountryCode}}} "}';
        // Set the body as a JSON object
        request.setBody(postBody);
        request.setTimeout(50000);
        //HttpResponse response = httpCall.send(request);
        HttpResponse response;
        if(!test.isRunningTest()){
            response = httpCall.send(request);
            system.debug('request ' + postBody);
            system.debug('response ' + response);
            system.debug('response body ' + response.getBody());
        } else {
            response = new HttpResponse();
            response.setStatusCode(200);
            String testBody = '{"data":{"processConcession":"123"},"errors":[{"path":["processConcession"],"data":null,"errorType":"Lambda:Handled","errorInfo":null,"locations":[{"line":1,"column":13,"sourceName":null}],"message":"No Approval Number Found Please Check Request Parameters"}]}';
            response.setBody(testBody);
        }
        
        system.debug('response ' + response.getBody());
        // Parse the JSON response
        if (response.getStatusCode() == 200 && !response.getBody().contains('errors') ) {
            System.debug(response.getBody());
            //returnList.add(response.getBody());
            submitResults = concessionSubmitResponse.parse(response.getBody());
            submitResults2 = concessionSubmitResponse2.parse(submitResults.data.processConcession);
            system.debug('Approval Number ' + submitResults2.ApprovalNumber);
            returnList.add(submitResults2.ApprovalNumber);
            return returnList;
        } else if (response.getStatusCode() == 200 && response.getBody().contains('errors')){
            submitResults = concessionSubmitResponse.parse(response.getBody());
            System.debug(response.getBody());
            system.debug('submitResults ' + submitResults);
            returnList.add('Error - ' + submitResults.errors[0].message);
            system.debug('Error returned ' + returnList);
            return returnList;
        } else {
            system.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            String errorMessage = 'Error ' + 'Error ' + response.getStatusCode() + ' ' + response.getStatus();
            returnList.add(errorMessage);
            return returnList;
        }

    }
}