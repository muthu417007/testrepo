/*********************************************
**********************************************
Name: Navya N N
Copyright: @ 2022 GE Appliances
**********************************************
Req: 
EPIC: IDMSF-1043
EPIC: IDMSF-32
**********************************************
Purpose: get details of all registered
products
**********************************************
History
---------------------------------------------
Version		Author		Date		Details
-------		-------		-------		-------
1.0			Navya N N	07/07/2022 	Created
**********************************************
**********************************************/
public without sharing class MYA_MyProducts {
     
  

	@AuraEnabled(cacheable=false)    
	public static list<mya_RegisteredProducts> MYA_ProductDetails()
	{ 
       try
       {    
		string userId = UserInfo.getUserId();
		list<User> cons=[select Id,ContactId from User where Id=:userId];
		User con=cons[0];
    
		list<GEA_AccountContactRelation__c> Accs=[SELECT Id,Account__c,Nick_Name__c,Account__r.BillingStreet,Account__r.BillingCity,Account__r.BillingState,Account__r.BillingPostalCode, MYAISPrimary__c FROM gea_accountcontactrelation__c WHERE contact__c=:con.ContactId AND MYA_Included__c=true ORDER BY MYAISPrimary__c DESC];

		list<mya_RegisteredProducts> ProdDetails=new list<mya_RegisteredProducts>();
        
        //list<GEA_Asset__c> AssetList=[select id,Account_Location__c,Model_Number__c,Serial_Number__c,AssetNickname__c from GEA_Asset__c where Account_Location__c In (select Account__c from gea_accountcontactrelation__c where contact__c=:con.ContactId) and ModelValidityFlag__c=true and Deleted__c=false];
        list<Asset> AssetList=[select id,AccountId,Connectivity_Type__c,MACAddress__c,Model_Number__c,OriginalModelNumber__c,SerialNumber,AssetNickname__c,ModelValidityFlag__c from Asset where AccountId In (select Account__c from gea_accountcontactrelation__c where contact__c=:con.ContactId) and Deleted__c=false];
         
		for(GEA_AccountContactRelation__c Acc:Accs)
		{
   			boolean iterate=true;
   			mya_RegisteredProducts prod=new mya_RegisteredProducts();
   			list<mya_products> asets=new list<mya_products>(); 
   			 system.debug('Assert: ');
            for(Asset asset:AssetList)
   			{   
               
                if(Acc.Account__c==asset.AccountId)
                {
          			mya_products NewProd = new mya_products();
                    
                    //to check wifi connection
                    String macAdd=asset.MACAddress__c;
                    system.debug('mac Address' +macAdd);
                    if(asset.Connectivity_Type__c == 'Not Connectable' || asset.Connectivity_Type__c == 'null'){
                        NewProd.onlineStatus = false;
                        NewProd.isconnectable = false;
                    }
                    else{
                    if(macAdd!=null){
                    ConnectedApplianceResponse status = ConnectedApplianceHelper.checkOnlineStatus(macAdd); 
                    system.debug('status' +status);
                    String conn = status.presence;
                    system.debug('### conn' +conn);
                         if(conn == 'ONLINE'){
                            NewProd.onlineStatus = true;}
                        else if(conn == 'OFFLINE') {
                            NewProd.onlineStatus = false; 
                             NewProd.isconnectable = true;
                            }
                       }
                    }
                    
                
                    String ModelNo=asset.Model_Number__c;
          			MYA_EndecaApiHandler.EndecaResponseDetails data=MYA_EndecaApiHandler.MYA_EndecaResponseDetails(ModelNo); 
          			MYA_EndecaApiHandler.EndecaResponse prdInfo=data.ProductInfo;
          			String Description;
         			String url;
         			Boolean IsConsumerReady;
                    
              		system.debug('prdInfo: '+ prdInfo);
          			if(prdInfo!=null)
          			{
                        Description=prdInfo.ProductDescription.toString();              //prod description
                        String url1=prdInfo.defaultImageUrl;  
                        //url=url1+'&Variant=Thumbnail';
                        url=url1.left(url1.lastIndexOf('/'))+'/w_192,h_200'+url1.right(url1.length()-url1.lastIndexOf('/'));// changed as part of SPR-146 Salsify-endeca transisiton project changes
                        IsConsumerReady=prdInfo.isConsumerReady;                       //is consumer ready
          			system.debug('Description++:'+Description);
                    system.debug('url1++'+url1);    
                    }
                        if(iterate)
                        {
                            prod.AccId=Acc.Account__c; 
                            prod.UserName=Acc.Nick_Name__c; 
                            prod.Street=Acc.Account__r.BillingStreet; 
                            prod.City=Acc.Account__r.BillingCity;     
                            prod.State=Acc.Account__r.BillingState;
                            //prod.zipcode=Acc.Account__r.BillingPostalCode;                            
                            prod.zipcode=(Acc.Account__r.BillingPostalCode.length() > 5) ? Acc.Account__r.BillingPostalCode.substring(0,5) : Acc.Account__r.BillingPostalCode;
                            iterate=false; 
                        } 
                        NewProd.AssetId=asset.Id;
                        NewProd.ProductImage=url != null ? url : '';
                        NewProd.ProductDesc=Description != null ? Description : '';
                        NewProd.NickName=(asset.AssetNickname__c != null) ? asset.AssetNickname__c : 
                    						(Description != null ? Description : 'Appliance1');
                    	NewProd.IsConsumerReady=IsConsumerReady != null ? IsConsumerReady : false;
                    	NewProd.IsValidAsset=asset.ModelValidityFlag__c;
                    	NewProd.ModelNumber=asset.Model_Number__c;
                       
                    if(NewProd.AssetId!=null)
                    {
                        asets.add(NewProd);
                    }
                    prod.Product=asets;
                }
   			}
			if(Prod.AccId!=null){     
			ProdDetails.add(Prod); 
			}  
                
		}
	   return ProdDetails;
      } 
      catch (Exception e) {
        MYA_ApplicationErrorLog.Mya_ExHandler(e, 'MYA_MyProducts', 'MYA_ProductDetails');
        return null;
      } 
	}
    
   
    
    //get global id of user
    @AuraEnabled(cacheable=false)    
	public static Asset MYA_ProductDetails1(Id assetId)
	{
      try
      {    
		    Asset ProDetails=[select Id,AccountId,Model_Number__c,ModelValidityFlag__c,OriginalModelNumber__c,Contact.Global_Customer_Id__c,SerialNumber,AssetNickname__c from Asset where id=:assetId];
            return ProDetails;
      }
      catch (Exception e) {
        MYA_ApplicationErrorLog.Mya_ExHandler(e, 'MYA_MyProducts', 'MYA_ProductDetails1');
        return null;  
      }  
    }		
}