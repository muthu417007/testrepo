/******************************************************************************************
// Author:      Shubhada Kurumkar
//@description : Apex Class to get address product Services
******************************************************************************************/

public without sharing class BWC_ProductViewServicesController 
{
    
    //@description : Apex method to handle  API Callout requests for address from latitude and longitude
    @AuraEnabled
    Public Static BundleServiceWrapper getProductServices(String skuProduct,String zipcode)
    {
        BWC_DTC_Controller.ServiceWrapper ServiceWrapper=new BWC_DTC_Controller.ServiceWrapper();
        if(!Test.isRunningTest())
        {
            Product2 pro=[SELECT Id, BWC_IsPurchasable__c,stockkeepingUnit FROM Product2 where stockkeepingUnit=:skuProduct ];
            if(pro.BWC_IsPurchasable__c==true)
            {
               ServiceWrapper  =BWC_DTC_Controller.getDTC_data(skuProduct,zipcode);   
            }
           
        }
        else
        {
            List<String> serviceSKU=new List<String>();
            serviceSKU.add('FREESTANDING INSTALL');
            serviceSKU.add('HOME DELIVERY');
            
        }
        +
            system.debug('Services-===='+ServiceWrapper.services);
        for(String s:ServiceWrapper.services)
        {
            system.debug('Services-===='+s);
        }
        
        List<BWC_Product_Bundle_Services__mdt> deliveryServices=[SELECT Id,BWC_Member_Price__c, DeveloperName, MasterLabel, Product_SKU__c, Product_Sf_Id__c, Type__c, Price__c, Description__c, QualifiedApiName, Label FROM BWC_Product_Bundle_Services__mdt WHERE Product_SKU__c IN:ServiceWrapper.services AND Type__c='Delivery' AND Product_SKU__c!='SMALL PACKAGE DELIVERY'];
        List<BWC_Product_Bundle_Services__mdt> installationServices=[SELECT Id,BWC_Member_Price__c, DeveloperName, MasterLabel, Product_SKU__c, Product_Sf_Id__c, Type__c, Price__c, Description__c, QualifiedApiName, Label FROM BWC_Product_Bundle_Services__mdt WHERE Product_SKU__c IN:ServiceWrapper.services AND Type__c='Installation Service'];
        List<BWC_Product_Bundle_Services__mdt> mcodesServicesList=[SELECT Id,BWC_Member_Price__c, DeveloperName, MasterLabel, Product_SKU__c, Product_Sf_Id__c, Type__c, Price__c, Description__c, QualifiedApiName, Label FROM BWC_Product_Bundle_Services__mdt WHERE Product_SKU__c IN:ServiceWrapper.services AND Type__c='MCode'];
        system.debug('deliveryServices-===='+deliveryServices);
        system.debug('installationServices-===='+installationServices);
        system.debug('mcodesServicesList-===='+mcodesServicesList);
        BundleServiceWrapper bundleServiceWrapper=new BundleServiceWrapper();
        bundleServiceWrapper.deliveryServices=deliveryServices;
        bundleServiceWrapper.installationServices=installationServices;
        bundleServiceWrapper.mcodesServices=mcodesServicesList;
        
        return bundleServiceWrapper;
    }
    @AuraEnabled
    public static string getADC_Details(List<String> skuList, String postalCodeInstance){
        
        try{
            DateTime GMTDate = DateTime.now()-2;
            String strRequestedDate = GMTDate.format('yyyy-MM-dd');
            String jsonString= '{"date":"'+strRequestedDate+'","postalCode":"'+postalCodeInstance+'"}';
            String res = '';
            String adcOrgValue = '';
            System.debug('jsonString-->'+jsonString);
            if(!test.isRunningTest()){
                //hitting adc api            
                if(utility.isSandbox){
                    res = RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_QA_Token','Sandbox_CommerceCloudADC_QA',null,'POST',jsonString);
                }
                else{
                    res = RequestMuleAPIData.getMuleAPIData('BWC_Production_MuleAuth','BWC_PROD_EBS_Token','BWC_PROD_CommerceCloudADC',null,'POST',jsonString);
                }
            }
            else{
                res = '[{"customerAccountNumber":12345,"adcOrg":"Org123","returnOrg":"ReturnOrg456","sdsOrg":"SDSOrg789","sdsZone":"SDSZoneXYZ","hdOrg":"HDOrgABC","hdZone":"HDZone123","mtOrg":"MTOrg456","mtZone":"MTZone789","willCallAdcOrgCode":"WillCallADC","willCallSdsOrgCode":"WillCallSDS","guaranteedTruck":"GuaranteedTruck123",  "guaranteedTruckZone":"GuaranteedTruckZone456"}]';
            }
            System.debug('res>>>'+res);
            //  List<BWC_ADC.ADC_WrapperResponse> adc_WrapperResponseInstance = (List<BWC_ADC.ADC_WrapperResponse>) JSON.deserialize(res, List<BWC_ADC.ADC_WrapperResponse>.class);
            //adcOrgValue = adc_WrapperResponseInstance[0].adcOrg;
            System.debug('adcOrgValue-->'+adcOrgValue);
            return adcOrgValue;
        }
        Catch(Exception e){
            System.debug('Exception ADC message-->'+e.getMessage());
            System.debug('Exception ADC Line number-->'+e.getLineNumber());
            return null;
        }  
    }
    /*  public class BundleServiceParser{

public String sku{get;set;}

public list<String> services{get;set;}


}*/
    
    public class BundleServiceWrapper{
        @AuraEnabled
        public List<BWC_Product_Bundle_Services__mdt> deliveryServices;
        @AuraEnabled
        public List<BWC_Product_Bundle_Services__mdt> installationServices;
        @AuraEnabled
        public List<BWC_Product_Bundle_Services__mdt> mcodesServices;
        public BundleServiceWrapper()
        {
            this.deliveryServices=new List<BWC_Product_Bundle_Services__mdt>();
            this.installationServices=new List<BWC_Product_Bundle_Services__mdt>();
            this.mcodesServices=new List<BWC_Product_Bundle_Services__mdt>();
        }
        
    }
    
    /*
@AuraEnabled(cacheable=true)
Public Static List<BWC_Product_Service__c> bwc_getRelatedCartItemOld(String itemId)
{
List<BWC_Product_Service__c> relatedItem=[Select Id, Name, BWC_SKU__c, BWC_Service_Type__c, BWC_Member_Price__c,Cart_Item__c, BWC_Service_Description__c, BWC_Service_Price__c FROM BWC_Product_Service__c where Cart_Item__c=:itemId and BWC_Service_Type__c='Installation' ];
return relatedItem;
}*/
    
    //    @wire(getRelatedCartItem,{itemId:'$cartItemId',zipCode:'$zipCode',skuProduct:'$productId',cartId:'$cartId',quantity:'$productQuantity'})
    
    @AuraEnabled
    Public Static List<BWC_Product_Service__c> bwc_getRelatedCartItem(String itemId,String zipCode,String skuProduct,String cartId,String quantity)
    {
        
        String sku=[select stockKeepingUnit,id from product2 where id=:skuProduct].stockKeepingUnit;
        Product2 pro=[SELECT Id, BWC_Small_Appliance__c, StockKeepingUnit FROM Product2 where id=:skuProduct LIMIT 1];
        
        list<String> installationSKU=new List<String>();
        list<String> deliverySKU=new List<String>();
        list<String> mcodeSKU=new List<String>();
        
        // List<BWC_Product_Service__c> relatedItemOld=[Select Id, Name, BWC_SKU__c, BWC_Service_Type__c, BWC_Member_Price__c,Cart_Item__c, BWC_Service_Description__c, BWC_Service_Price__c FROM BWC_Product_Service__c where Cart_Item__c=:itemId and BWC_Service_Type__c='Installation' and BWC_ZipCode__c!=:zipCode  ];
        //  List<BWC_Product_Service__c> relatedItemOld=[Select Id, Name, BWC_SKU__c, BWC_Service_Type__c, BWC_Member_Price__c,Cart_Item__c, BWC_Service_Description__c, BWC_Service_Price__c FROM BWC_Product_Service__c where Cart_Item__c=:itemId and BWC_Service_Type__c='Installation' and BWC_ZipCode__c!=:zipCode ];
        
        
        List<BWC_Product_Service__c> relatedItemDelivery=[Select Id, Name, BWC_SKU__c, BWC_Service_Type__c,BWC_Quantity__c, BWC_Member_Price__c,Cart_Item__c, BWC_Service_Description__c, BWC_Service_Price__c FROM BWC_Product_Service__c where Cart_Item__c=:itemId and BWC_Service_Type__c='Delivery' and BWC_ZipCode__c=:zipCode  ];
        List<BWC_Product_Service__c> relatedItemDeliverySmall=[Select Id, Name, BWC_SKU__c, BWC_Service_Type__c,BWC_Quantity__c, BWC_Member_Price__c,Cart_Item__c, BWC_Service_Description__c, BWC_Service_Price__c FROM BWC_Product_Service__c where BWC_Cart_Id__c=:cartId and BWC_Service_Type__c='Delivery' and BWC_SKU__c='SMALL PACKAGE DELIVERY' ];
        
        List<BWC_Product_Service__c> relatedItemInstallaion=[Select Id, Name, BWC_SKU__c, BWC_Service_Type__c,BWC_Quantity__c, BWC_Member_Price__c,Cart_Item__c, BWC_Service_Description__c, BWC_Service_Price__c FROM BWC_Product_Service__c where Cart_Item__c=:itemId and BWC_Service_Type__c='Installation' and BWC_ZipCode__c=:zipCode  ];
        List<BWC_Product_Service__c> relatedItemMcodes=[Select Id, Name, BWC_SKU__c, BWC_Service_Type__c,BWC_Quantity__c, BWC_Member_Price__c,Cart_Item__c, BWC_Service_Description__c, BWC_Service_Price__c FROM BWC_Product_Service__c where Cart_Item__c=:itemId and BWC_Service_Type__c='MCode' and BWC_ZipCode__c=:zipCode  ];
        List<BWC_Product_Service__c> sdsWillCallItemDelivery=[Select Id, Name, BWC_SKU__c, BWC_Service_Type__c,BWC_Quantity__c, BWC_Member_Price__c,Cart_Item__c, BWC_Service_Description__c, BWC_Service_Price__c FROM BWC_Product_Service__c where BWC_Cart_Id__c=:cartId and BWC_Service_Type__c='Delivery' and BWC_SKU__c='SDS HANDLING' ];
        
        BundleServiceWrapper bundleServiceWrapper=getProductServices(sku,zipCode);
        system.debug('bundleServiceWrapper=='+bundleServiceWrapper);
        if(pro.BWC_Small_Appliance__c==true)
        {
            if(!(relatedItemDeliverySmall.size()>0))
            {
              //  deliverySKU.add('SMALL PACKAGE DELIVERY');	  
            }
            
        }
        //Abhishek Changes
        List<String> skuListInstance = new List<String>{sku};
            if(checkSdsWillCall(skuListInstance,zipCode)){
               
                    //deliverySKU.add('SDS HANDLING');  
                
               	 
            }
        //Abhishek Changes
        if(relatedItemInstallaion.size()==0)
        {
            for(BWC_Product_Bundle_Services__mdt mdtInstallation:bundleServiceWrapper.installationServices)
            {
                installationSKU.add(mdtInstallation.Product_SKU__c);
            }
        }
        else
        {
            List<BWC_Product_Service__c> updateserviceList=new List<BWC_Product_Service__c>();
            
            
            for(BWC_Product_Service__c ext:relatedItemInstallaion)
            {
                Decimal unitPrize=(ext.BWC_Service_Price__c)/ (ext.BWC_Quantity__c);
                Decimal unitPrizemember=(ext.BWC_Member_Price__c)/ (ext.BWC_Quantity__c);
                
                ext.BWC_Quantity__c=Integer.valueOf(quantity);
                
                ext.BWC_Service_Price__c=unitPrize*Integer.valueOf(quantity);
                ext.BWC_Member_Price__c=unitPrizemember*Integer.valueOf(quantity);
                ext.BWC_ZipCode__c=zipCode;
                updateserviceList.add(ext);
                
                
            }
            update updateserviceList;
        }
        if(relatedItemDelivery.size()==0)
        {
            for(BWC_Product_Bundle_Services__mdt mdtInstallation:bundleServiceWrapper.deliveryServices)
            {
                deliverySKU.add(mdtInstallation.Product_SKU__c);
                
            }
        }
        if(relatedItemMcodes.size()==0)
        {
            for(BWC_Product_Bundle_Services__mdt mdtInstallation:bundleServiceWrapper.mcodesServices)
            {
                mcodeSKU.add(mdtInstallation.Product_SKU__c);
            }
        }
        if(mcodeSKU.size()>0 || deliverySKU.size()>0 || installationSKU.size()>0)
        {
            List<BWC_Product_Service__c> newServices= BWC_GetInfo.addRelatedServices( itemId, cartId,deliverySKU,installationSKU, quantity, zipCode,mcodeSKU);
            
        }
        
        
        List<BWC_Product_Service__c> relatedItemFinaCodes=new List<BWC_Product_Service__c>();
        List<BWC_Product_Service__c> relatedItemFinal=[Select Id, Name, BWC_SKU__c, BWC_Service_Type__c, BWC_Member_Price__c,Cart_Item__c, BWC_Service_Description__c, BWC_Service_Price__c FROM BWC_Product_Service__c where Cart_Item__c=:itemId and BWC_Service_Type__c='Installation' and BWC_ZipCode__c=:zipCode and BWC_Quantity__c=:Integer.valueOf(quantity) ];
        List<BWC_Product_Service__c> relatedItemFinalAddons=[Select Id, Name, BWC_SKU__c, BWC_Service_Type__c, BWC_Member_Price__c,Cart_Item__c, BWC_Service_Description__c, BWC_Service_Price__c FROM BWC_Product_Service__c where Cart_Item__c=:itemId and BWC_Service_Type__c='Additional Mcode' and BWC_ZipCode__c=:zipCode];
                relatedItemFinaCodes.addAll(relatedItemFinal);
        relatedItemFinaCodes.addAll(relatedItemFinalAddons);

        // List<BWC_Product_Service__c> relatedItemOld=[Select Id, Name, BWC_SKU__c, BWC_Service_Type__c, BWC_Member_Price__c,Cart_Item__c, BWC_Service_Description__c, BWC_Service_Price__c FROM BWC_Product_Service__c where Cart_Item__c=:itemId and BWC_Service_Type__c='Installation' and BWC_ZipCode__c!=:zipCode ];
        List<BWC_Product_Service__c> relatedItemOld=[Select Id, Name, BWC_SKU__c, BWC_Service_Type__c, BWC_Member_Price__c,Cart_Item__c, BWC_Service_Description__c, BWC_Service_Price__c FROM BWC_Product_Service__c where Cart_Item__c=:itemId  and BWC_ZipCode__c!=:zipCode and BWC_Service_Type__c!='Protection Plan' and BWC_Service_Type__c!='Additional Mcode' ];
        
        if(relatedItemOld.size()>0)
        {
            
            delete relatedItemOld;
        }   
        return relatedItemFinaCodes;
    }
    
    @AuraEnabled(cacheable=true)
    Public Static SerciceWrapper bwc_getAllRelatedCartItem(String cartId,String zipCode)
    {
        List<BWC_Product_Service__c> relatedItemAll=[Select Id, Name,BWC_Member_Price__c, BWC_SKU__c, BWC_Service_Type__c, Cart_Item__c, BWC_Service_Description__c, BWC_Service_Price__c FROM BWC_Product_Service__c where BWC_Cart_Id__c=:cartId and BWC_Service_Type__c='Installation' and BWC_ZipCode__c=:zipCode ];
        
        //List<cartItem> relatedItemAll=[Select id,Name,TotalPrice from CartItem where cartId=:cartId AND BWC_Related_Service_Type__c='Installation'];
        // List<cartItem> relatedItemAllProduct=[Select id,Name,TotalPrice from CartItem where cartId=:cartId AND BWC_Related_Service_Type__c='Product'];
        
        SerciceWrapper sw=new SerciceWrapper();
        sw.relatedItemAll=relatedItemAll;
        sw.relatedItemAllProduct=new List<cartItem>();
        return sw;
    }
    
    public class SerciceWrapper {
        @auraenabled
        public List<BWC_Product_Service__c> relatedItemAll;
        @auraenabled
        public List<cartItem> relatedItemAllProduct;
        public  SerciceWrapper()
        {
            List<BWC_Product_Service__c> relatedItemAll =new List<BWC_Product_Service__c> ();
            List<cartItem> relatedItemAllProduct =new List<cartItem> ();
        }
        
    }
    
    @AuraEnabled
    Public Static SerciceWrapperFees bwc_getRelatedCartItemAll(String itemId,Boolean isMember,String zipCode)
    {
        Decimal InstallationFeeMember=0;
        Decimal MemberInstallationFee=0;
        Decimal InstallationFeeOriginal=0;
        Decimal protectionFeeOriginal=0;
        Decimal MemberProtectionFee=0;
        Decimal protectionFeeMember=0;
        Decimal partsShipFeeMember=0;
        Decimal partsShipFeeOriginal=0;
        Decimal hdFee=0;
        // Decimal InstallationFee=[Select Sum(TotalPrice) from CartItem where cartId=:itemId and BWC_Related_Service_Type__c='Installation' ];
        // //        List<BWC_Product_Service__c> relatedItem=[Select Id, Name, BWC_SKU__c, BWC_Service_Type__c, Cart_Item__c, BWC_Service_Description__c, BWC_Service_Price__c FROM BWC_Product_Service__c where Cart_Item__c=:itemId and BWC_Service_Type__c='Installation' ];
        if(isMember)
        {
            for(AggregateResult  objAgr: [Select Sum(BWC_Member_Price__c) total from BWC_Product_Service__c where BWC_Cart_Id__c=:itemId and ((BWC_Service_Type__c='Installation' and BWC_ZipCode__c=:zipCode) OR( BWC_Service_Type__c='Additional Mcode' and BWC_ZipCode__c=:zipCode)) ])
            {
                InstallationFeeMember=(Decimal)objAgr.get('total');
            } 
            
            for(AggregateResult  objAgr: [Select Sum(BWC_Member_Price__c) total from BWC_Product_Service__c where BWC_Cart_Id__c=:itemId and BWC_Service_Type__c='Parts Ship Fee'])
            {
                partsShipFeeMember=(Decimal)objAgr.get('total');
            }
            
            for(AggregateResult  objAgr: [Select Sum(BWC_Member_Price__c) total from BWC_Product_Service__c where BWC_Cart_Id__c=:itemId and BWC_Service_Type__c='Protection Plan'])
            {
                protectionFeeMember=(Decimal)objAgr.get('total');
            }
        }
        else
        {
            InstallationFeeMember=0;
            partsShipFeeMember=0;
            protectionFeeMember=0;
        }
        
        
        for(AggregateResult  objAgr: [Select Sum(BWC_Service_Price__c) total from BWC_Product_Service__c where BWC_Cart_Id__c=:itemId and(( BWC_Service_Type__c='Installation'  and BWC_ZipCode__c=:zipCode) OR ( BWC_Service_Type__c='Additional Mcode' and BWC_ZipCode__c=:zipCode)) ])
        {
            InstallationFeeOriginal=(Decimal)objAgr.get('total');
        }  
        
        for(AggregateResult  objAgr: [Select Sum(BWC_Service_Price__c) total from BWC_Product_Service__c where BWC_Cart_Id__c=:itemId and BWC_Service_Type__c='Protection Plan' ])
        {
            protectionFeeOriginal=(Decimal)objAgr.get('total');
        }  
        
        for(AggregateResult  objAgr: [Select Sum(BWC_Service_Price__c) total from BWC_Product_Service__c where BWC_Cart_Id__c=:itemId and BWC_Service_Type__c='Parts Ship Fee' ])
        {
            partsShipFeeOriginal=(Decimal)objAgr.get('total');
        }  
        for(AggregateResult  objAgr: [Select Sum(BWC_Member_Price__c) total from BWC_Product_Service__c where BWC_Cart_Id__c=:itemId  and ((BWC_Service_Type__c='Installation' and BWC_ZipCode__c=:zipCode) OR( BWC_Service_Type__c='Additional Mcode' and BWC_ZipCode__c=:zipCode)) ])
        {
            MemberInstallationFee=(Decimal)objAgr.get('total');
        } 
        
        for(AggregateResult  objAgr: [Select Sum(BWC_Member_Price__c) total from BWC_Product_Service__c where BWC_Cart_Id__c=:itemId and BWC_Service_Type__c='Protection Plan' ])
        {
            MemberProtectionFee=(Decimal)objAgr.get('total');
        } 
        
        SerciceWrapperFees sWF=new SerciceWrapperFees();
        //Parts Ship Fee
        if(partsShipFeeOriginal==null)
        {
            sWF.partsShipFeeTotal=0;
        }
        else
        {
            sWF.partsShipFeeTotal=partsShipFeeOriginal;
        }
        if(partsShipFeeMember==null)
        {
            sWF.partsShipFeeMemberTotal=0;
        }
        else
        {
            sWF.partsShipFeeMemberTotal=partsShipFeeMember;
            
        }
        
        //Protection Plan Fee
        if(protectionFeeOriginal==null)
        {
            sWF.protectionPlanTotal=0;
        }
        else
        {
            sWF.protectionPlanTotal=protectionFeeOriginal;
            
        }
        
        //Member Protection Fee
        if(MemberProtectionFee==null)
        {
            sWF.protectionPlanForMember=0;
        }
        else
        {
            sWF.protectionPlanForMember=MemberProtectionFee;
            
        }
        
        //MemberInstallation Fee
        if(MemberInstallationFee==null)
        {
            sWF.installationFeeForMember=0;
        }
        else
        {
            sWF.installationFeeForMember=MemberInstallationFee;
            
        }
        
        //Installation Services Fee
        if(InstallationFeeOriginal==null)
        {
            sWF.totalFee=0;
        }
        else
        {
            sWF.totalFee=InstallationFeeOriginal;
        }
        
        if(InstallationFeeMember==null)
        {
            sWF.memberTotalFee=0;
        }
        else
        {
            sWF.memberTotalFee=InstallationFeeMember;
        }
        
        
        return sWF;
    }
    //Abhishek Changes
    public static Boolean checkSdsWillCall(List<String> skuList, String zipCodeInstance){
        BWC_RateAPIController.ResponseWrapper responseWrapper = BWC_RateAPIController.hitRateApi(skuList,zipCodeInstance);
        system.debug('responseWrapper==='+responseWrapper);
        for(BWC_RateAPIController.ItemWrapper shippingItemInstance : responseWrapper.items){
            for(BWC_RateAPIController.ValueWrapper val : shippingItemInstance.values){
                if(val.shippingMethod == 'SDS Will Call'){
                    return true;
                }
            }
        }
        return false;
    }
    //Abhishek Changes
    public class SerciceWrapperFees {
        @auraenabled
        public Decimal totalFee;
        @auraenabled
        public Decimal memberTotalFee;
        @auraenabled
        public Decimal protectionPlanTotal;  
        @AuraEnabled
        public Decimal protectionPlanForMember;  
        @AuraEnabled
        public Decimal partsShipFeeTotal;
        @AuraEnabled
        public Decimal partsShipFeeMemberTotal;
        @AuraEnabled
        public Decimal installationFeeForMember;
        
        
        
    }
    
    /*
@AuraEnabled
public static List<CartItem> bwc_CreateCartItems(String productId,String quantity,String unitPrice,String sku,List<String> servicesListDelivery,List<String> servicesListInstallation) {
List<CartItem> returnList=new List<CartItem>();  
List<CartItem> relatedList=new List<CartItem>();
try{
CartItem ctItem=new CartItem();

List<WebCart> cartList=[Select Id from WebCart where Status='Active' OR Status='Checkout' limit 1];
System.debug('cartList>>'+cartList);
Product2 productRecord=[Select Id,Name from Product2 where Id=:productId limit 1];
if(cartList.isEmpty()){
System.debug('insideIf');
Id accountIdInstance = [Select AccountId from User where Id =:UserInfo.getUserId() LIMIT 1][0].AccountId;
WebStore webStore = [SELECT Id FROM WebStore WHERE Name = 'Bodewell Store' LIMIT 1];
WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=accountIdInstance);
insert cart;

cartList.add(cart);
}
//CartDeliveryGroup cartDeliveryGroupExisting=[select Id from CartDeliveryGroup where CartId=:cartList[0].Id ];
CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cartList[0].Id, Name='Default Delivery');
insert cartDeliveryGroup;


if(productId!=null && quantity!=null && unitPrice!=null && sku!=null){

ctItem.Name=productRecord.Name;
ctItem.Product2Id=productId;
ctItem.CartId=cartList[0].Id;
ctItem.Sku=sku;    
ctItem.Type='Product';
ctItem.CartDeliveryGroupId=cartDeliveryGroup.Id;
ctItem.Quantity=Integer.valueOf(quantity);
ctItem.SalesPrice=Decimal.valueOf(unitPrice);
ctItem.TotalPrice=Decimal.valueOf(unitPrice);
ctItem.BWC_Related_Service_Type__c='Product';
insert ctItem;
returnList.add(ctItem);

}
if(servicesListDelivery!=null && servicesListDelivery.size()>0)
{
BWC_Product_Bundle_Services__mdt deliveryServices=[SELECT Id, DeveloperName, MasterLabel, Product_SKU__c, Product_Sf_Id__c, Type__c, Price__c, Description__c, QualifiedApiName, Label FROM BWC_Product_Bundle_Services__mdt WHERE Product_SKU__c =:servicesListDelivery];
//  List<BWC_Product_Bundle_Services__mdt> installationServices=[SELECT Id, DeveloperName, MasterLabel, Product_SKU__c, Product_Sf_Id__c, Type__c, Price__c, Description__c, QualifiedApiName, Label FROM BWC_Product_Bundle_Services__mdt WHERE Product_SKU__c IN:ServiceWrapper.services AND Type__c='Installation Service'];


CartItem ctItem1=new CartItem();
ctItem1.Name=deliveryServices.Label;
ctItem1.Product2Id=deliveryServices.Product_Sf_Id__c;
ctItem1.CartId=cartList[0].Id;
ctItem1.Sku=deliveryServices.Product_SKU__c;    
ctItem1.Type='Product';
ctItem1.CartDeliveryGroupId=cartDeliveryGroup.Id;
ctItem1.Quantity=1;
ctItem1.SalesPrice=deliveryServices.Price__c;
ctItem1.TotalPrice=deliveryServices.Price__c;
ctItem1.BWC_Related_Delivery_Service__c=ctItem.Id;
ctItem1.BWC_Related_Service_Type__c='Delivery';
ctItem1.Services__c=ctItem.Id;
//insert ctItem1;
//returnList.add(ctItem1);
}
if(servicesListInstallation!=null && servicesListInstallation.size()>0)
{
List<BWC_Product_Bundle_Services__mdt> installationServices=[SELECT Id, DeveloperName, MasterLabel, Product_SKU__c, Product_Sf_Id__c, Type__c, Price__c, Description__c, QualifiedApiName, Label FROM BWC_Product_Bundle_Services__mdt WHERE Product_SKU__c IN :servicesListInstallation];
//  List<BWC_Product_Bundle_Services__mdt> installationServices=[SELECT Id, DeveloperName, MasterLabel, Product_SKU__c, Product_Sf_Id__c, Type__c, Price__c, Description__c, QualifiedApiName, Label FROM BWC_Product_Bundle_Services__mdt WHERE Product_SKU__c IN:ServiceWrapper.services AND Type__c='Installation Service'];

for(BWC_Product_Bundle_Services__mdt pBS:installationServices)
{
CartItem ctItem2=new CartItem();
ctItem2.Name=pBS.Label;
ctItem2.Product2Id=pBS.Product_Sf_Id__c;
ctItem2.CartId=cartList[0].Id;
ctItem2.Sku=pBS.Product_SKU__c;    
ctItem2.Type='Product';
ctItem2.CartDeliveryGroupId=cartDeliveryGroup.Id;
ctItem2.Quantity=1;
ctItem2.SalesPrice=pBS.Price__c;
ctItem2.TotalPrice=pBS.Price__c;
ctItem2.Services__c=ctItem.Id;
ctItem2.BWC_Related_Service_Type__c='Installation';
relatedList.add(ctItem2);
}

insert relatedList;
returnList.addAll(relatedList);
}

}
catch(DMLException e){
System.debug('Error>>'+e.getMessage());
}
return returnList;
}*/
    
    
}