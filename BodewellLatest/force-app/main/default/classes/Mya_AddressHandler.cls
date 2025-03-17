/*********************************************
**********************************************
Name: Navya N N
Copyright: @ 2022 GE Appliances
**********************************************
Req: 
EPIC: IDMSF-1043
EPIC: IDMSF-296
**********************************************
Purpose: For Adding address which checks for 
validation and duplication.
**********************************************
History
---------------------------------------------
Version		Author		Date		Details
-------		-------		-------		-------
1.0			Navya N N	07/07/2022 	Created
**********************************************
**********************************************/
public without sharing class Mya_AddressHandler{
    
    public String Name;
    public String Status;
    
    //Get token details for mellisa address validation api 
    @AuraEnabled(cacheable=false)     
    public static String mya_AddValidation()
    {     
        String domainUrl = Url.getOrgDomainUrl().getHost();
        MYA_Configuration__mdt details=MYA_MetaDataConfigHelper.getmyaConfigByDomain(domainUrl);
        
        String postBodyToken = '{"client_id":"' + details.Token_Client_Id__c + 
            '","client_secret":"' + details.Token_Client_Secret__c + 
            '","audience":"' + details.Token_Audience__c + '","grant_type":"client_credentials"}';
        
        Http httpCall = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(details.Token_EndPoint_URL__c);
        request.setHeader('Content-Type', 'application/json');
        request.setBody(postBodyToken);
        request.setTimeout(60000);
        HttpResponse response; 
        response = httpCall.send(request);      
        GEAoAuthResponse  resp;
        resp = GEAoAuthResponse.parse(response.getBody());
        String Token=resp.access_token;
        return Token;
    }
    
    // Afx Account search response
    public class AfxAccountResponse {
        @AuraEnabled public Object Account;
        @AuraEnabled public Object Error;
        @AuraEnabled public Boolean AlreadyExist;
        @AuraEnabled public Boolean Success;
    }
    
    @AuraEnabled(cacheable=false)
    Public static AfxAccountResponse Mya_AfxAddressValidation(String Address,String City,String State,String Code,boolean Primary,String NickName,String AFXLocationId)
    {
        AfxAccountResponse response = new AfxAccountResponse();
        try
        {
            Account accountRes;
            String userId=userinfo.getUserId();
            list<User> cons=[select Id,ContactId from User where Id=:userId];
            User con=cons[0];
            System.debug(con.ContactId);
            Account[] acounts=[Select Id,Name,BillingStreet,BillingCity,BillingState,BillingPostalCode from Account where LocationID__c =:AFXLocationId Limit 1];
            if(acounts.size()>0)  
            {
                GEA_AccountContactRelation__c contactLoc=new GEA_AccountContactRelation__c();
                Account account=acounts[0];   
                list<GEA_AccountContactRelation__c> juns=[select Id,Name from GEA_AccountContactRelation__c where Account__c=:account.Id AND Contact__c=:con.ContactId AND MYA_Included__c=true Limit 1];
                if(Juns.size()<1)
                {    
                    contactLoc.Name=account.Name;   
                    contactLoc.Account__c=account.Id;
                    contactLoc.Contact__c=con.ContactId;
                    contactLoc.MYAISPrimary__c=Primary;
                    contactLoc.MYA_Included__c=true;
                    contactLoc.Nick_Name__c=NickName;
                    insert contactLoc; 
                }
                response.Account = account; 
                response.Success = true;
                response.AlreadyExist = true;
            }
            else 
            {
                response.Success = true;
                response.AlreadyExist = false;
            }
            return response;
        } catch(Exception ex) {
            response.Error = ex;
            response.Success = false;
            return response;
        }
    }
    
      

    //create account(add address)
    @AuraEnabled(cacheable=false)
    Public static Account Mya_AddressValidation(String Address,String City,String State,String Code,boolean Primary,String NickName )
    {
        
        String token=mya_AddValidation();          
        String Address1=Address;
        String City1=City;
        String State1=State;
        String ZipCode=Code; 
        boolean IsPrimary=Primary;
        String Nick_Name=NickName;
        
        String UserId=userinfo.getUserId();
        
        
        list<User> Cons=[select Id,ContactId from User where Id=:UserId];
        User Con=Cons[0];
        System.debug(Con.ContactId);    
        
        String domainUrl = Url.getOrgDomainUrl().getHost();
        MYA_Configuration__mdt details=MYA_MetaDataConfigHelper.getmyaConfigByDomain(domainUrl);
        
        String AuthToken = 'Bearer ' +token;
        
        string url= 'ADDRESS_LINE1='+EncodingUtil.urlEncode(Address1, 'UTF-8')+'&CITY='+EncodingUtil.urlEncode(City1, 'UTF-8')+'&STATE='+EncodingUtil.urlEncode(State1, 'UTF-8')+'&POSTALCODE='+EncodingUtil.urlEncode(ZipCode, 'UTF-8');
        
        Http httpCall = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(details.Mellisa_EndPoint_URL__c + url);
        request.setHeader('Content-Type','application/json');
        request.setHeader('Client_id',details.Mellisa_Client_Id__c);
        request.setHeader('Client_secret',details.Mellisa_Client_Secret__c);
        request.setHeader('Authorization',AuthToken);    
        
        request.setTimeout(60000);
        HttpResponse response ;
        
        response = httpCall.send(request); 
        system.debug('response  test' +response);
        Account Acc1=Mya_AddAddress(response,IsPrimary,Nick_Name);
        system.debug('Acc1' +Acc1);
        return Acc1;  
    }
    
    public static Account Mya_AddAddress(HttpResponse response1,boolean IsPrimary1,string Nick_Name1)
    {   
        try{   
            String Name;
            String Account_Id;              
            Account AccountRes;
            boolean IsValid=false;
            list<User> Cons=[select Id,ContactId from User where Id=:userinfo.getUserId()];
            User Con=Cons[0];
            Mya_AddValidationResponse res; 
            res = Mya_AddValidationResponse.parse(response1.getBody());
            String result=res.RESULTS;
            List<String> ResponseCodes = result.split(',');
            Account Acc=new Account();
            GEA_AccountContactRelation__c ContactLoc=new GEA_AccountContactRelation__c();                 
            if(ResponseCodes.contains('AS01'))
            { 
                IsValid=true;
            }
            String Code1;
            if(res.POSTALCODE.length()>5)
            {
                Code1=res.POSTALCODE.substring(0,5); 
            }
            else{
                Code1=res.POSTALCODE;     
            }
            
            
            Name=res.ADDRESS_LINE1+' '+res.CITY+' '+res.STATE+' '+Code1;
            String FullZipName = res.ADDRESS_LINE1+' '+res.CITY+' '+res.STATE+' '+res.POSTALCODE;
            String SpacelessName = Name.replaceAll( '\\s+', '') + '%';
            String MelisaKey = res.MELISSA_ADDRESS_KEY;
            Account[] Acounts=[SELECT Id,Name,BillingStreet,BillingCity,BillingState,BillingPostalCode FROM Account WHERE MelissaAddressKey__c=:MelisaKey LIMIT 1];
            if(Acounts.size() == 0)
            {
                Acounts=[SELECT Id,Name,BillingStreet,BillingCity,BillingState,BillingPostalCode FROM Account WHERE Name=:Name OR Name=:FullZipName OR Formatted_Account_Name__c LIKE :SpacelessName LIMIT 1];
            }
            Account Acount=new Account();
            
            Account NewAccount=new Account();    
            if(Acounts.size()>0)  
            {
                Acount=Acounts[0];   
                list<GEA_AccountContactRelation__c> Juns=[select Id,Name from GEA_AccountContactRelation__c where Account__c=:Acount.Id AND Contact__c=:Con.ContactId AND MYA_Included__c=true Limit 1];
                if(Juns.size()>0)
                {
                    system.debug(Juns);
                    Account_Id=Acount.Id;    
                    AccountRes = Acount;      		
                } 
                else if(Juns.size()<1)
                {  
                    Acount=Acounts[0];   
                    ContactLoc.Name=Name;   
                    ContactLoc.Account__c=Acount.Id;
                    ContactLoc.Contact__c=Con.ContactId;
                    ContactLoc.MYAISPrimary__c=IsPrimary1;
                    ContactLoc.MYA_Included__c=true;
                    ContactLoc.Nick_Name__c=Nick_Name1;
                    insert ContactLoc;                               //contact location record insertion
                    Mya_setNewPrimary(Con.ContactId,ContactLoc.Id,IsPrimary1);   
                    Account_Id=Acount.Id;    
                    AccountRes = Acount;     
                }                 
            }
            else
            {
                NewAccount.Name=Name;
                NewAccount.BillingStreet=res.ADDRESS_LINE1;
                NewAccount.BillingCity=res.CITY;
                NewAccount.BillingState=res.STATE;
                NewAccount.BillingPostalCode=Code1;
                NewAccount.OwnerId = system.label.Mya_AccountOwnerId;
                NewAccount.Country_Code__c=res.COUNTRY;  
                NewAccount.RecordTypeId=Schema.getGlobalDescribe().get('account').getDescribe().getRecordTypeInfosByName().get('Location').getRecordTypeId();
                NewAccount.isVerified__c=IsValid; 
                NewAccount.MelissaAddressKey__c=res.MELISSA_ADDRESS_KEY;
                NewAccount.HygieneAddressKey__c=res.ADDRESS_KEY;
                NewAccount.responsecode__c=res.RESULTS;  
                insert NewAccount;                                //account creation
                if(NewAccount.Id!=null)
                {
                    String AccountId=NewAccount.Id;
                    ContactLoc.Name=Name;  
                    ContactLoc.Account__c=AccountId;
                    ContactLoc.Contact__c=Con.ContactId;
                    ContactLoc.MYAISPrimary__c=IsPrimary1;
                    ContactLoc.MYA_Included__c=true;
                    ContactLoc.Nick_Name__c=Nick_Name1;
                    insert ContactLoc;                               //contact location record insertion
                    Mya_setNewPrimary(Con.ContactId,ContactLoc.Id,IsPrimary1);  
                    Account_Id=AccountId;
                    AccountRes = NewAccount;
                }    
            }
            return AccountRes;  
        }
        catch (Exception e) 
        {
            MYA_ApplicationErrorLog.Mya_ExHandler(e, 'Mya_AddressHandler', 'Mya_AddAddress');
            return null;  
        }     
    }  
    
    //set primary address
    @AuraEnabled(cacheable=false)
    public static void Mya_setNewPrimary(String ConId,String JunId,Boolean PrimaryFlag)
    {
        try{   
            string user1= UserInfo.getUserId();
            string userConId =ConId;
            string ContactLocationId=JunId;
            
            list<GEA_AccountContactRelation__c> AccList=[SELECT Id,Account__c,Contact__c,MYAISPrimary__c FROM GEA_AccountContactRelation__c WHERE Contact__c =:userConId AND MYA_Included__c=true];
            if(AccList.size()>1&&PrimaryFlag==true)
            {
                list<GEA_AccountContactRelation__c> UpdateList=new list<GEA_AccountContactRelation__c>();
                for(GEA_AccountContactRelation__c addrec:AccList)
                {
                    if(addRec.Id!=ContactLocationId)
                    {    
                        if(addRec.MYAISPrimary__c==true)
                        {    
                            addRec.MYAISPrimary__c=false;
                            UpdateList.add(addRec);   
                        }    
                    }
                } 
                update UpdateList;
            }
            else if(AccList.size()==1)
            {
                GEA_AccountContactRelation__c ACRel=AccList[0];
                if(ACRel.MYAISPrimary__c==false)
                {
                    ACRel.MYAISPrimary__c=true;
                    update ACRel; 
                }    
            }
        }   
        catch (Exception e) 
        {
            MYA_ApplicationErrorLog.Mya_ExHandler(e, 'Mya_AddressHandler', 'Mya_setNewPrimary');
        }  
    }
    
    //Get all address details of particular user
    @AuraEnabled(cacheable=true)
    public static list<GEA_AccountContactRelation__c> Mya_GetAddressDetails()
    {
        try{   
            string UserId= UserInfo.getUserId();
            list<User> Cons=[select Id,ContactId from User where Id=:UserId];
            User Con=Cons[0];
            list<GEA_AccountContactRelation__c> addressList = [select Id,MYAISPrimary__c,Nick_Name__c,Account__c,Account__r.BillingStreet,Account__r.BillingCity,Account__r.BillingState,Account__r.BillingPostalCode from 
                                                               GEA_AccountContactRelation__c where Contact__c=:Con.ContactId AND MYA_Included__c=true]; 
            for(GEA_AccountContactRelation__c address:addressList)
            {
                address.Account__r.BillingPostalCode = (address.Account__r.BillingPostalCode.length() > 5) ? address.Account__r.BillingPostalCode.substring(0,5) : address.Account__r.BillingPostalCode;
                
            }
            return addressList; 
            /*return [select Id,MYAISPrimary__c,Nick_Name__c,Account__c,Account__r.BillingStreet,Account__r.BillingCity,Account__r.BillingState,Account__r.BillingPostalCode from 
GEA_AccountContactRelation__c where Contact__c=:Con.ContactId AND MYA_Included__c=true]; */
        }
        catch (Exception e) 
        {
            MYA_ApplicationErrorLog.Mya_ExHandler(e, 'Mya_AddressHandler', 'Mya_GetAddressDetails');
            return null;
        }    
    }
    
    //delete Contact Location 
    @AuraEnabled(cacheable=false)
    public static void Mya_DelAddress(String ConId)
    {
        try{   
            String AccId;
            list<GEA_AccountContactRelation__c> Conn=[Select Id,Name,MYAISPrimary__c,Nick_Name__c,Account__c,Contact__c,MYA_Included__c from GEA_AccountContactRelation__c where Id=:ConId];   
            if(Conn.size()>0)
            {    
                GEA_AccountContactRelation__c Con=Conn[0];
                AccId=Con.Account__c;
                GEA_AccountContactRelation_Delete__c DelCon=new GEA_AccountContactRelation_Delete__c();
                DelCon.Account__c=Con.Account__c;
                Delcon.Contact__c=Con.Contact__c;
                Delcon.Is_Primary_Location__c=Con.MYAISPrimary__c;
                Delcon.Name=Con.Name;
                Delcon.Nick_Name__c=Con.Nick_Name__c;
                Delcon.MYA_Included__c=Con.MYA_Included__c;    
                insert Delcon;                                            //insertion of record in Contact Location delete
                delete Con;                                               //deletion of a record in Contact Location
            }
        }   
        catch (Exception e) 
        {
            MYA_ApplicationErrorLog.Mya_ExHandler(e, 'Mya_AddressHandler', 'Mya_DelAddress');
        }   
        
    }  
    
    //updates the asset address
    @AuraEnabled(cacheable=false)
    public static void Mya_UpdateAssetAddress(String AccountId,String ProdId)
    {
        try{   
            list<Asset> UpAssets=[select Id,AccountId from Asset where Id=:ProdId];
            Asset UpAsset =UpAssets[0];
            UpAsset.AccountId=AccountId;
            update UpAsset;
        }
        catch (Exception e) 
        {
            MYA_ApplicationErrorLog.Mya_ExHandler(e, 'Mya_AddressHandler', 'Mya_UpdateAssetAddress');
        }   
    }
    
    
    //Address updation from My Appliance Page
    @AuraEnabled(cacheable=false)
    public static List<Asset> Mya_UpdateAddress(String Address,String City,String State,String Code,String Name,String ProdId)
    {
        try{  
            string Name1=Name;
            Account validAccount = Mya_AddressValidation(Address,City,State,Code,false,Name1);
            String accountId = validAccount.Id;
            List<Asset> asstobj=[select Id,AccountId from Asset where Id=:ProdId];
            if(asstobj.size()>0)
            {
                Asset asset=asstobj[0];           
                asset.AccountId=accountId;
                update asset;
                
            }
            return asstobj;
        }
        catch (Exception e) 
        {
            MYA_ApplicationErrorLog.Mya_ExHandler(e, 'Mya_AddressHandler', 'Mya_UpdateAddress');
            return null;
        }
        
    }  
    
    //assign new address to asset post afx search
    @AuraEnabled(cacheable=false)
    public static void Mya_UpAssetAddress(String NewAccId,String ContactLocation_Id)
    {
        try{   
            list<GEA_AccountContactRelation__c> ConRecs=[select Id,Account__c from GEA_AccountContactRelation__c where Id=:ContactLocation_Id AND MYA_Included__c=true Limit 1];  
            if(ConRecs.size()>0)
            {
                system.debug(ConRecs);
                GEA_AccountContactRelation__c ConRec=ConRecs[0];
                list<Asset> Assetlist=[Select Id,AccountId from Asset where AccountId=:ConRec.Account__c AND deleted__c=false];
                system.debug(Assetlist);
                list<Asset> UpAsset=new list<Asset>();
                for(Asset Ast:Assetlist)
                {
                    Ast.AccountId=NewAccId;
                    UpAsset.add(Ast); 
                } 
                update UpAsset;
            } 
        }
        catch (Exception e) 
        {
            MYA_ApplicationErrorLog.Mya_ExHandler(e, 'Mya_AddressHandler', 'Mya_UpAssetAddress');
        }   
    }
    
    //get asset list
    @AuraEnabled(cacheable=true)
    public static list<Asset> Mya_AssetList()
    {
        try{
            string UserId= UserInfo.getUserId();
            list<User> Cons=[select Id,ContactId from User where Id=:UserId];
            User Con=Cons[0];
            list<Asset> ListAssets=[Select Id,AccountId from Asset where AccountId 
                                    IN (SELECT Account__c from gea_accountcontactrelation__c where MYA_Included__c=true 
                                        and contact__c=:Con.ContactId)];
            return ListAssets;
        }
        catch (Exception e) 
        {
            MYA_ApplicationErrorLog.Mya_ExHandler(e, 'Mya_AddressHandler', 'Mya_AssetList');
            return null;
        }   
    }
    
    //update contact location details
    @AuraEnabled(cacheable=false)
    public static void Mya_UpdateContLoc(string ContId,string NickName,boolean Primary)
    {
        try{   
            string NickNme=NickName;
            GEA_AccountContactRelation__c cont=[select Id,Nick_Name__c,MYAISPrimary__c from GEA_AccountContactRelation__c where Id=:ContId];
            if(string.isNotEmpty(NickNme))
            {   
                cont.Nick_Name__c=NickNme;
            }    
            cont.MYAISPrimary__c=Primary;
            update cont;
            string UserId= UserInfo.getUserId();
            list<User> Cons=[select Id,ContactId from User where Id=:UserId];
            User Con=Cons[0];  
            list<GEA_AccountContactRelation__c> AccList=[SELECT Id,Account__c,Contact__c,MYAISPrimary__c FROM GEA_AccountContactRelation__c WHERE Contact__c =:Con.ContactId AND MYA_Included__c=true];
            if(AccList.size()>1&&Primary==true)
            {
                list<GEA_AccountContactRelation__c> UpdateList=new list<GEA_AccountContactRelation__c>();
                for(GEA_AccountContactRelation__c addrec:AccList)
                {
                    if(addRec.Id!=ContId)
                    {    
                        if(addRec.MYAISPrimary__c==true)
                        {    
                            addRec.MYAISPrimary__c=false;
                            UpdateList.add(addRec);   
                        }    
                    }
                } 
                update UpdateList;
            }
        }
        
        catch (Exception e) 
        {
            MYA_ApplicationErrorLog.Mya_ExHandler(e, 'Mya_AddressHandler', 'Mya_UpdateContLoc');
        } 
    } 
    //Get all address details of particular user
    @AuraEnabled(cacheable=false)
    public static list<GEA_AccountContactRelation__c> Mya_GetApplianceAddressDetails()
    {
        try{   
            string UserId= UserInfo.getUserId();
            list<User> Cons=[select Id,ContactId from User where Id=:UserId];
            User Con=Cons[0];
            list<GEA_AccountContactRelation__c> addressList = [select Id,MYAISPrimary__c,Nick_Name__c,Account__c,Account__r.BillingStreet,Account__r.BillingCity,Account__r.BillingState,Account__r.BillingPostalCode from 
                                                               GEA_AccountContactRelation__c where Contact__c=:Con.ContactId AND MYA_Included__c=true]; 
            for(GEA_AccountContactRelation__c address:addressList)
            {
                address.Account__r.BillingPostalCode = (address.Account__r.BillingPostalCode.length() > 5) ? address.Account__r.BillingPostalCode.substring(0,5) : address.Account__r.BillingPostalCode;
                
            }
            return addressList; 
            /*return [select Id,MYAISPrimary__c,Nick_Name__c,Account__c,Account__r.BillingStreet,Account__r.BillingCity,Account__r.BillingState,Account__r.BillingPostalCode from 
GEA_AccountContactRelation__c where Contact__c=:Con.ContactId AND MYA_Included__c=true]; */
        }
        catch (Exception e) 
        {
            MYA_ApplicationErrorLog.Mya_ExHandler(e, 'Mya_AddressHandler', 'Mya_GetApplianceAddressDetails');
            return null;
        }    
    }      
}