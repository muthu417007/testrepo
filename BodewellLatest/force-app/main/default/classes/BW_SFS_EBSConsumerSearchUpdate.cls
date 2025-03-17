public class BW_SFS_EBSConsumerSearchUpdate {
	@future(callout=true)
    public static void BW_SFS_EBSConsumerSearchUpdate(String Payload_EmailPhoneSearch, String Payload_GlobalSearch, String varEmail, String varPhone, Id ContactId, Id AccountId, String ParentObject, Id ParentRecordId, String varConsumerFirstname, String varConsumerLastname, String varShippingAddress1, String varShippingCity, String varShippingState, String varShippingCountry, String varBillingAddress1, String varBillingCity, String varBillingState, String varBillingCountry)
    {   
        String Payload_AddressUpdate = '';
        String varXAccountNumber = '';
        String varXPartyID = '';
        String varXCustAccountID = '';
        String varEBSShipToORGID = '';
        String varEBSShipToAddress1 = '';
        String varEBSShipToAddress2 = '';
        String varEBSShipToAddress3 = '';
        String varEBSShipToCity = '';
        String varEBSShipToState = '';
        String varEBSShipToCountry = '';
        String varEBSBillToORGID = '';
        String varEBSBillToAddress1 = '';
        String varEBSBillToAddress2 = '';
        String varEBSBillToAddress3 = '';
        String varEBSBillToCity = '';
        String varEBSBillToState = '';
        String varEBSBillToCountry = '';
        String varEBSSoldToORGID = '';
        Boolean FlagEBSShipToORGIDFound = false;
        Boolean FlagEBSBillToORGIDFound = false;
        Boolean FlagEBSSoldToORGIDFound = false;
        Boolean FlagFoundInEBS = false;
        String response_GlobalSearch;
        String response_AddLocationSearch;
        String response_EmailPhoneSearch; 
        GenerateJSON_CustomerSearchByPhoneEmail jsCustomerSearchByPhoneEmail = new GenerateJSON_CustomerSearchByPhoneEmail(varEmail,varPhone); 
		Payload_EmailPhoneSearch = jsCustomerSearchByPhoneEmail.byEmailPhoneJSON(); 
        //response_EmailPhoneSearch = SearchConsumerAPI.SearchConsumerAPI(Payload_EmailPhoneSearch, 'Sandbox_CommerceCloudSearchConsumerEmailPhone_DEV');
        response_EmailPhoneSearch = SearchConsumerAPI.SearchConsumerAPI(Payload_EmailPhoneSearch, 'Sandbox_CommerceCloudSearchConsumerEmailPhone_QA');
        JSONParser parser_EmailPhoneSearch = JSON.createParser(response_EmailPhoneSearch);
        String OutputAccountNumber = '';
        String OutputConsumerFirstname = '';
        String OutputConsumerLastname = '';
        Integer OutputsCount = 0;
        Map<String, String> OutputMap = new Map<String, String>();
        while (parser_EmailPhoneSearch.nextToken() != null) {
            if ((parser_EmailPhoneSearch.getCurrentToken() == JSONToken.FIELD_NAME) && (parser_EmailPhoneSearch.getText() == System.Label.EBSResponseAttribute_AccountNumber)) {
                parser_EmailPhoneSearch.nextToken();
                OutputAccountNumber = parser_EmailPhoneSearch.getText();
            }
            if ((parser_EmailPhoneSearch.getCurrentToken() == JSONToken.FIELD_NAME) && (parser_EmailPhoneSearch.getText() == System.Label.EBSResponseAttribute_PersonFirstName)) {
                parser_EmailPhoneSearch.nextToken();
                OutputConsumerFirstname = parser_EmailPhoneSearch.getText();
            }
            if ((parser_EmailPhoneSearch.getCurrentToken() == JSONToken.FIELD_NAME) && (parser_EmailPhoneSearch.getText() == System.Label.EBSResponseAttribute_PersonLastName)) {
                parser_EmailPhoneSearch.nextToken();
                OutputConsumerLastname = parser_EmailPhoneSearch.getText();
                OutputsCount = OutputsCount + 1;
            }
            if (String.isNotBlank(OutputAccountNumber) && String.isNotBlank(OutputConsumerFirstname) && String.isNotBlank(OutputConsumerLastname))
            {
                OutputMap.put(OutputAccountNumber, OutputConsumerFirstname + ' ' + OutputConsumerLastname);
            }
        }
        if (OutputsCount > 1)
        {
            String value = varConsumerFirstname + ' ' + varConsumerLastname;
            for(String key : OutputMap.keySet()){
                if(OutputMap.get(key) == value){
                    OutputAccountNumber = key;
                }
            }
        }
        //
        GenerateJSON_CustomerSearchGlobal jsCustomerSearchGlobal = new GenerateJSON_CustomerSearchGlobal(OutputAccountNumber,'','','','',''); 
		Payload_GlobalSearch = jsCustomerSearchGlobal.byGlobalJSON();
        //
        if (String.isNotBlank(OutputAccountNumber)) {
            //response_GlobalSearch = SearchConsumerAPI.SearchConsumerAPI(Payload_GlobalSearch, 'Sandbox_CommerceCloudSearchConsumerGlobal_DEV');
            response_GlobalSearch = SearchConsumerAPI.SearchConsumerAPI(Payload_GlobalSearch, 'Sandbox_CommerceCloudSearchConsumerGlobal_QA');
            JSONParser parser_GlobalSearch = JSON.createParser(response_GlobalSearch);
            String varOutput = '';
            while (parser_GlobalSearch.nextToken() != null) {
                if (parser_GlobalSearch.getText().trim().contains(System.Label.EBSResponseAttribute_SHIP_TO))
                {
                    FlagEBSShipToORGIDFound = true;
                }
                else if (parser_GlobalSearch.getText().trim().contains(System.Label.EBSResponseAttribute_BILL_TO))
                {
                    FlagEBSBillToORGIDFound = true;
                }
                else if (parser_GlobalSearch.getText().trim().contains(System.Label.EBSResponseAttribute_SOLD_TO))
                {
                    FlagEBSSoldToORGIDFound = true;
                }
                if ((parser_GlobalSearch.getCurrentToken() == JSONToken.FIELD_NAME) && (parser_GlobalSearch.getText() == System.Label.EBSResponseAttribute_SearchCustAccountD)) {
                    parser_GlobalSearch.nextToken();
                    varXCustAccountID = parser_GlobalSearch.getText();
                }
                if ((parser_GlobalSearch.getCurrentToken() == JSONToken.FIELD_NAME) && (parser_GlobalSearch.getText() == System.Label.EBSResponseAttribute_SearchAccountNumber)) {
                    parser_GlobalSearch.nextToken();
                    varXAccountNumber = parser_GlobalSearch.getText();
                    FlagFoundInEBS = true;
                }
                if ((parser_GlobalSearch.getCurrentToken() == JSONToken.FIELD_NAME) && (parser_GlobalSearch.getText() == System.Label.EBSResponseAttribute_SearchPartyID)) {
                    parser_GlobalSearch.nextToken();
                    varXPartyID = parser_GlobalSearch.getText();
                }
                if ((parser_GlobalSearch.getCurrentToken() == JSONToken.FIELD_NAME) && (parser_GlobalSearch.getText() == System.Label.EBSResponseAttribute_SiteUserId) && FlagEBSShipToORGIDFound == true) {
                    parser_GlobalSearch.nextToken();
                    varEBSShipToORGID = parser_GlobalSearch.getText();
                }
                if ((parser_GlobalSearch.getCurrentToken() == JSONToken.FIELD_NAME) && (parser_GlobalSearch.getText() == System.Label.EBSResponseAttribute_Address1) && FlagEBSShipToORGIDFound == true) {
                    parser_GlobalSearch.nextToken();
                    varEBSShipToAddress1 = parser_GlobalSearch.getText();
                }
                if ((parser_GlobalSearch.getCurrentToken() == JSONToken.FIELD_NAME) && (parser_GlobalSearch.getText() == System.Label.EBSResponseAttribute_Address2) && FlagEBSShipToORGIDFound == true) {
                    parser_GlobalSearch.nextToken();
                    varEBSShipToAddress2 = parser_GlobalSearch.getText();
                }
                if ((parser_GlobalSearch.getCurrentToken() == JSONToken.FIELD_NAME) && (parser_GlobalSearch.getText() == System.Label.EBSResponseAttribute_Address3) && FlagEBSShipToORGIDFound == true) {
                    parser_GlobalSearch.nextToken();
                    varEBSShipToAddress3 = parser_GlobalSearch.getText();
                }
                if ((parser_GlobalSearch.getCurrentToken() == JSONToken.FIELD_NAME) && (parser_GlobalSearch.getText() == System.Label.EBSResponseAttribute_City) && FlagEBSShipToORGIDFound == true) {
                    parser_GlobalSearch.nextToken();
                    varEBSShipToCity = parser_GlobalSearch.getText();
                }
                if ((parser_GlobalSearch.getCurrentToken() == JSONToken.FIELD_NAME) && (parser_GlobalSearch.getText() == System.Label.EBSResponseAttribute_State) && FlagEBSShipToORGIDFound == true) {
                    parser_GlobalSearch.nextToken();
                    varEBSShipToState = parser_GlobalSearch.getText();
                }
                if ((parser_GlobalSearch.getCurrentToken() == JSONToken.FIELD_NAME) && (parser_GlobalSearch.getText() == System.Label.EBSResponseAttribute_Country) && FlagEBSShipToORGIDFound == true) {
                    parser_GlobalSearch.nextToken();
                    varEBSShipToCountry = parser_GlobalSearch.getText();
                }
                if ((parser_GlobalSearch.getCurrentToken() == JSONToken.FIELD_NAME) && (parser_GlobalSearch.getText() == System.Label.EBSResponseAttribute_SiteUserId) && FlagEBSBillToORGIDFound == true) {
                    parser_GlobalSearch.nextToken();
                    varEBSBillToORGID = parser_GlobalSearch.getText();
                }
                if ((parser_GlobalSearch.getCurrentToken() == JSONToken.FIELD_NAME) && (parser_GlobalSearch.getText() == System.Label.EBSResponseAttribute_Address1) && FlagEBSBillToORGIDFound == true) {
                    parser_GlobalSearch.nextToken();
                    varEBSBillToAddress1 = parser_GlobalSearch.getText();
                }
                if ((parser_GlobalSearch.getCurrentToken() == JSONToken.FIELD_NAME) && (parser_GlobalSearch.getText() == System.Label.EBSResponseAttribute_Address2) && FlagEBSBillToORGIDFound == true) {
                    parser_GlobalSearch.nextToken();
                    varEBSBillToAddress2 = parser_GlobalSearch.getText();
                }
                if ((parser_GlobalSearch.getCurrentToken() == JSONToken.FIELD_NAME) && (parser_GlobalSearch.getText() == System.Label.EBSResponseAttribute_Address3) && FlagEBSBillToORGIDFound == true) {
                    parser_GlobalSearch.nextToken();
                    varEBSBillToAddress3 = parser_GlobalSearch.getText();
                }
                if ((parser_GlobalSearch.getCurrentToken() == JSONToken.FIELD_NAME) && (parser_GlobalSearch.getText() == System.Label.EBSResponseAttribute_City) && FlagEBSBillToORGIDFound == true) {
                    parser_GlobalSearch.nextToken();
                    varEBSBillToCity = parser_GlobalSearch.getText();
                }
                if ((parser_GlobalSearch.getCurrentToken() == JSONToken.FIELD_NAME) && (parser_GlobalSearch.getText() == System.Label.EBSResponseAttribute_State) && FlagEBSBillToORGIDFound == true) {
                    parser_GlobalSearch.nextToken();
                    varEBSBillToState = parser_GlobalSearch.getText();
                }
                if ((parser_GlobalSearch.getCurrentToken() == JSONToken.FIELD_NAME) && (parser_GlobalSearch.getText() == System.Label.EBSResponseAttribute_Country) && FlagEBSBillToORGIDFound == true) {
                    parser_GlobalSearch.nextToken();
                    varEBSBillToCountry = parser_GlobalSearch.getText();
                }
                if ((parser_GlobalSearch.getCurrentToken() == JSONToken.FIELD_NAME) && (parser_GlobalSearch.getText() == System.Label.EBSResponseAttribute_SiteUserId) && FlagEBSBillToORGIDFound == true) {
                    parser_GlobalSearch.nextToken();
                    //varEBSSoldToORGID = parser_GlobalSearch.getText();
                    varEBSSoldToORGID = '';
                }
            }
            If (varShippingAddress1.equals(varEBSShipToAddress1) == false)
            {
                FlagEBSShipToORGIDFound = false;
                FlagEBSBillToORGIDFound = false;
                FlagEBSSoldToORGIDFound = false;
                GenerateJSON_CreateLocSitePurpose js = new GenerateJSON_CreateLocSitePurpose(varShippingCountry,varShippingAddress1,'','',varShippingCity,'80218',varShippingState,'SHIP_TO','HZ_CPUI',varXPartyID,varXCustAccountID); 
                Payload_AddressUpdate = js.byGlobalJSON(); 
                response_AddLocationSearch = AddConsumerLocationAPI.AddConsumerLocationAPI(Payload_AddressUpdate);
            	JSONParser parser_AddLocationSearch = JSON.createParser(response_AddLocationSearch);
                while (parser_AddLocationSearch.nextToken() != null) {
                    if (parser_AddLocationSearch.getText().trim().contains(System.Label.EBSResponseAttribute_SHIP_TO))
                    {
                        FlagEBSShipToORGIDFound = true;
                    }
                    else if (parser_AddLocationSearch.getText().trim().contains(System.Label.EBSResponseAttribute_BILL_TO))
                    {
                        FlagEBSBillToORGIDFound = true;
                    }
                    else if (parser_AddLocationSearch.getText().trim().contains(System.Label.EBSResponseAttribute_SOLD_TO))
                    {
                        FlagEBSSoldToORGIDFound = true;
                    }
                    if ((parser_AddLocationSearch.getCurrentToken() == JSONToken.FIELD_NAME) && (parser_AddLocationSearch.getText() == 'X_SITE_USE_ID')) {
                        parser_AddLocationSearch.nextToken();
                        varEBSShipToORGID = parser_AddLocationSearch.getText();
                    }
                    if ((parser_AddLocationSearch.getCurrentToken() == JSONToken.FIELD_NAME) && (parser_AddLocationSearch.getText() == System.Label.EBSResponseAttribute_SearchCustAccountD)) {
                        parser_AddLocationSearch.nextToken();
                        varXCustAccountID = parser_AddLocationSearch.getText();
                    }
                    if ((parser_AddLocationSearch.getCurrentToken() == JSONToken.FIELD_NAME) && (parser_AddLocationSearch.getText() == System.Label.EBSResponseAttribute_SearchAccountNumber)) {
                        parser_AddLocationSearch.nextToken();
                        varXAccountNumber = parser_AddLocationSearch.getText();
                    }
                    if ((parser_AddLocationSearch.getCurrentToken() == JSONToken.FIELD_NAME) && (parser_AddLocationSearch.getText() == System.Label.EBSResponseAttribute_SearchPartyID)) {
                        parser_AddLocationSearch.nextToken();
                        varXPartyID = parser_AddLocationSearch.getText();
                    }
                    if ((parser_AddLocationSearch.getCurrentToken() == JSONToken.FIELD_NAME) && (parser_AddLocationSearch.getText() == System.Label.EBSResponseAttribute_SiteUserId) && FlagEBSShipToORGIDFound == true) {
                        parser_AddLocationSearch.nextToken();
                        varEBSShipToORGID = parser_AddLocationSearch.getText();
                    }
                    if ((parser_AddLocationSearch.getCurrentToken() == JSONToken.FIELD_NAME) && (parser_AddLocationSearch.getText() == System.Label.EBSResponseAttribute_SiteUserId) && FlagEBSBillToORGIDFound == true) {
                        parser_AddLocationSearch.nextToken();
                        varEBSBillToORGID = parser_AddLocationSearch.getText();
                    }
                    if ((parser_AddLocationSearch.getCurrentToken() == JSONToken.FIELD_NAME) && (parser_AddLocationSearch.getText() == System.Label.EBSResponseAttribute_SiteUserId) && FlagEBSBillToORGIDFound == true) {
                        parser_AddLocationSearch.nextToken();
                        //varEBSSoldToORGID = parser_AddLocationSearch.getText();
                        varEBSSoldToORGID = '';
                    }
                }
            }
            If (varBillingAddress1.equals(varEBSBillToAddress1) == false)
            {
                FlagEBSShipToORGIDFound = false;
                FlagEBSBillToORGIDFound = false;
                FlagEBSSoldToORGIDFound = false;
                GenerateJSON_CreateLocSitePurpose js = new GenerateJSON_CreateLocSitePurpose(varBillingCountry,varBillingAddress1,'','',varBillingCity,'80218',varBillingState,'BILL_TO','HZ_CPUI',varXPartyID,varXCustAccountID); 
                Payload_AddressUpdate = js.byGlobalJSON(); 
                //
                response_AddLocationSearch = AddConsumerLocationAPI.AddConsumerLocationAPI(Payload_AddressUpdate);
            	JSONParser parser_AddLocationSearch = JSON.createParser(response_AddLocationSearch);
                //
                while (parser_AddLocationSearch.nextToken() != null) {
                    if (parser_AddLocationSearch.getText().trim().contains(System.Label.EBSResponseAttribute_SHIP_TO))
                    {
                        FlagEBSShipToORGIDFound = true;
                    }
                    else if (parser_AddLocationSearch.getText().trim().contains(System.Label.EBSResponseAttribute_BILL_TO))
                    {
                        FlagEBSBillToORGIDFound = true;
                    }
                    else if (parser_AddLocationSearch.getText().trim().contains(System.Label.EBSResponseAttribute_SOLD_TO))
                    {
                        FlagEBSSoldToORGIDFound = true;
                    }
                    if ((parser_AddLocationSearch.getCurrentToken() == JSONToken.FIELD_NAME) && (parser_AddLocationSearch.getText() == 'X_SITE_USE_ID')) {
                        parser_AddLocationSearch.nextToken();
                        varEBSBillToORGID = parser_AddLocationSearch.getText();
                    }
                    if ((parser_AddLocationSearch.getCurrentToken() == JSONToken.FIELD_NAME) && (parser_AddLocationSearch.getText() == System.Label.EBSResponseAttribute_SearchCustAccountD)) {
                        parser_AddLocationSearch.nextToken();
                        varXCustAccountID = parser_AddLocationSearch.getText();
                    }
                    if ((parser_AddLocationSearch.getCurrentToken() == JSONToken.FIELD_NAME) && (parser_AddLocationSearch.getText() == System.Label.EBSResponseAttribute_SearchAccountNumber)) {
                        parser_AddLocationSearch.nextToken();
                        varXAccountNumber = parser_AddLocationSearch.getText();
                    }
                    if ((parser_AddLocationSearch.getCurrentToken() == JSONToken.FIELD_NAME) && (parser_AddLocationSearch.getText() == System.Label.EBSResponseAttribute_SearchPartyID)) {
                        parser_AddLocationSearch.nextToken();
                        varXPartyID = parser_AddLocationSearch.getText();
                    }
                    if ((parser_AddLocationSearch.getCurrentToken() == JSONToken.FIELD_NAME) && (parser_AddLocationSearch.getText() == System.Label.EBSResponseAttribute_SiteUserId) && FlagEBSShipToORGIDFound == true) {
                        parser_AddLocationSearch.nextToken();
                        varEBSShipToORGID = parser_AddLocationSearch.getText();
                    }
                    if ((parser_AddLocationSearch.getCurrentToken() == JSONToken.FIELD_NAME) && (parser_AddLocationSearch.getText() == System.Label.EBSResponseAttribute_SiteUserId) && FlagEBSBillToORGIDFound == true) {
                        parser_AddLocationSearch.nextToken();
                        varEBSBillToORGID = parser_AddLocationSearch.getText();
                    }
                    if ((parser_AddLocationSearch.getCurrentToken() == JSONToken.FIELD_NAME) && (parser_AddLocationSearch.getText() == System.Label.EBSResponseAttribute_SiteUserId) && FlagEBSBillToORGIDFound == true) {
                        parser_AddLocationSearch.nextToken();
                        varEBSSoldToORGID = '';
                    }
                }
            }
            ////
            if(String.isNotBlank(varXPartyID) && String.isNotBlank(varXAccountNumber) && String.isNotBlank(varXCustAccountID) && String.isNotBlank(varEBSShipToORGID) && String.isNotBlank(varEBSBillToORGID)){
                List<BW_SFS_EBS_Consumer_Creation_Details__e> ObjConsumerCreation = new List<BW_SFS_EBS_Consumer_Creation_Details__e>();
                ObjConsumerCreation.add(new BW_SFS_EBS_Consumer_Creation_Details__e(ContactId__c = ContactId,
                                                       AccountId__c = AccountId,
                                                       X_ACCOUNT_NUMBER_for_Search__c = varXAccountNumber,
                                                       X_CUST_ACCOUNT_ID_for_Search__c = varXCustAccountID,
                                                       X_PARTY_ID_for_Search__c = varXPartyID,
                                                       EBS_Ship_to_ORG_ID_for_Search__c = varEBSShipToORGID,
                                                       EBS_Bill_to_ORG_ID_for_Search__c = varEBSBillToORGID,
                                                       EBS_Sold_to_ORG_ID_for_Search__c = varEBSSoldToORGID,
                                                       Parent_Object_Name__c = ParentObject,
                                                       Parent_Record_Id__c = ParentRecordId,
                                                       Found_in_EBS__c = FlagFoundInEBS));
                List<Database.SaveResult> results = EventBus.publish(ObjConsumerCreation);
            }
        }
        else
        {
            List<BW_SFS_EBS_Consumer_Creation_Details__e> ObjConsumerCreation = new List<BW_SFS_EBS_Consumer_Creation_Details__e>();
                ObjConsumerCreation.add(new BW_SFS_EBS_Consumer_Creation_Details__e(ContactId__c = ContactId,
                                                       AccountId__c = AccountId,
                                                       X_ACCOUNT_NUMBER_for_Search__c = '',
                                                       X_CUST_ACCOUNT_ID_for_Search__c = '',
                                                       X_PARTY_ID_for_Search__c = '',
                                                       EBS_Ship_to_ORG_ID_for_Search__c = '',
                                                       EBS_Bill_to_ORG_ID_for_Search__c = '',
                                                       EBS_Sold_to_ORG_ID_for_Search__c = '',
                                                       Parent_Object_Name__c = ParentObject,
                                                       Parent_Record_Id__c = ParentRecordId,
                                                       Found_in_EBS__c = FlagFoundInEBS));
                List<Database.SaveResult> results = EventBus.publish(ObjConsumerCreation);
        }
    }
}