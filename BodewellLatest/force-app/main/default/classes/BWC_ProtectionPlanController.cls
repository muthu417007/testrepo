public without sharing class BWC_ProtectionPlanController {
  
    @AuraEnabled
    Public Static AdditionalServicesWrapper addDeliveryServices(String skuProduct,String zipCode)
    {
       // String sku='AZ91H12E3E';
        BWC_DTC_Controller.ServiceWrapper ServiceWrapper=new BWC_DTC_Controller.ServiceWrapper();
        if(!Test.isRunningTest())
        {
            //ServiceWrapper  =BWC_DTC_Controller.getDTC_data(skuProduct,zipcode); 
        }
        else
        {
            List<String> serviceSKU=new List<String>();
            serviceSKU.add('FREESTANDING INSTALL');
            serviceSKU.add('HOME DELIVERY');
            
        }
        
       system.debug('Services-===='+ServiceWrapper.services);
        for(String s:ServiceWrapper.services)
        {
             system.debug('Services-===='+s);
        }
      String mode=([SELECT Id, BWC_Delivery_Type__c,stockkeepingunit FROM Product2 where stockkeepingunit=:skuProduct ].BWC_Delivery_Type__c).toUpperCase();
   //  List<BWC_Product_Bundle_Services__mdt> mcodesServicesList=[SELECT Id,BWC_Member_Price__c, DeveloperName, MasterLabel, Product_SKU__c, Product_Sf_Id__c, Type__c, Price__c, Description__c, QualifiedApiName, Label FROM BWC_Product_Bundle_Services__mdt WHERE Product_SKU__c IN:ServiceWrapper.services AND Type__c='MCode'];
             List<String> moocodeList=new List<String>();
       BWC_DeliveryController.DeliveryResponseWrapper response= BWC_DeliveryController.getDeliveryService(zipCode,skuProduct,mode);
        
        List<BWC_DeliveryController.cls_services> services=response.services;
        system.debug(response.services);
        for(BWC_DeliveryController.cls_services mdt:services)
             {
                moocodeList.add(mdt.id);
             }
      
               system.debug('mcodesServicesList-===='+moocodeList);
        List<String> skuList=new List<String>();
        skuList.add(skuProduct);
       String adcOrgValue= getADC_Details(skuList,zipcode);
      //  String wrhs='9HL';
        String result= BWC_DeliveryServiceController.getDeliveryService(moocodeList,  adcOrgValue);
        //system.debug('result=='+result);
        AdditionalServicesWrapper wrapper=new AdditionalServicesWrapper();
        wrapper.addServices=response;
        wrapper.prices=result;
      //  wrapper.clsServices=response.services;
        return wrapper;
    }
    
      public class AdditionalServicesWrapper{
        @AuraEnabled
       public BWC_DeliveryController.DeliveryResponseWrapper addServices;
         @AuraEnabled
         public  List<BWC_DeliveryController.cls_services> clsServices;
        @AuraEnabled
        public String prices;
        
        public AdditionalServicesWrapper()
        {
            this.addServices=new BWC_DeliveryController.DeliveryResponseWrapper();
          this.clsServices=new List<BWC_DeliveryController.cls_services>();
            
        }
        
    }
    
    @AuraEnabled
    public static String getADC_Details(List<String> skuList, String postalCodeInstance){
        
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
            List<BWC_ADC_WrapperResponse> adc_WrapperResponseInstance = (List<BWC_ADC_WrapperResponse>) JSON.deserialize(res, List<BWC_ADC_WrapperResponse>.class);
            adcOrgValue = adc_WrapperResponseInstance[0].sdsOrg;
            System.debug('adcOrgValue-->'+adcOrgValue);
             return adcOrgValue;
        }
        Catch(Exception e){
            System.debug('Exception ADC message-->'+e.getMessage());
            System.debug('Exception ADC Line number-->'+e.getLineNumber());
            return null;
        } 
    }
    
    
    @AuraEnabled(cacheable=true)
    public static BundleProtectionWrapperNew getProductDetails(String modelSku,string accId,string communityId) {
        
        List<string> skus=modelSku.split('~');
      //  List<BWC_Product_Bundle_Services__mdt> monthlyPlanList=[SELECT Id,BWC_Member_Price__c, DeveloperName, MasterLabel, Product_SKU__c, Product_Sf_Id__c, Type__c, Price__c, Description__c, QualifiedApiName, Label FROM BWC_Product_Bundle_Services__mdt WHERE Product_SKU__c IN:skus AND Type__c='Subscription'];
       // List<BWC_Product_Bundle_Services__mdt> yearlyPlanList=[SELECT Id,BWC_Member_Price__c, DeveloperName, MasterLabel, Product_SKU__c, Product_Sf_Id__c, Type__c, Price__c, Description__c, QualifiedApiName, Label FROM BWC_Product_Bundle_Services__mdt WHERE Product_SKU__c IN:skus AND Type__c='Protection plan'];
        BundleProtectionWrapperNew newbpw=fetchProductAndPrices(skus);
        
       // BundleProtectionWrapper bpw=new BundleProtectionWrapper();
       // bpw.monthlyPlan=monthlyPlanList;
       // bpw.yearlyPlan=yearlyPlanList;
        
        return newbpw;
        
    }
    
    public class BundleProtectionWrapper{
        @AuraEnabled
        public List<BWC_Product_Bundle_Services__mdt> monthlyPlan ;
        @AuraEnabled
        public List<BWC_Product_Bundle_Services__mdt> yearlyPlan;
        
        public BundleProtectionWrapper()
        {
            this.monthlyPlan=new List<BWC_Product_Bundle_Services__mdt>();
            this.yearlyPlan=new List<BWC_Product_Bundle_Services__mdt>();
            
        }
        
    }
    
    
      @AuraEnabled
    public static List<BWC_Product_Service__c> addPlanAdLineItemcartCodes(String proId,string cartId,string cartItemId,String quantity,List<String> moocodeSelected,String zipCode) {
        BWC_Product_Service__c service=new BWC_Product_Service__c();
         List<BWC_Product_Service__c> serviceList=new List<BWC_Product_Service__c>();
                 List<BWC_DeliveryController.cls_services> serviceListMoocodes=new List<BWC_DeliveryController.cls_services>();

        for(String str:moocodeSelected)
        {
            BWC_DeliveryController.cls_services responseWrapper = new BWC_DeliveryController.cls_services();
            responseWrapper = (BWC_DeliveryController.cls_services)JSON.deserialize(str, BWC_DeliveryController.cls_services.class); 
            serviceListMoocodes.add(responseWrapper);
        }
     
                List<BWC_Product_Service__c> relatedItemOldMoocode=[Select Id, Name, BWC_SKU__c, BWC_Service_Type__c, BWC_Member_Price__c,Cart_Item__c, BWC_Service_Description__c, BWC_Service_Price__c FROM BWC_Product_Service__c where Cart_Item__c=:cartItemId  and BWC_Service_Type__c='Additional Mcode' ];
   if(relatedItemOldMoocode.size()>0)
        {
            
            delete relatedItemOldMoocode;
        } 
        if(moocodeSelected.size()>0)
        {
            
            for(BWC_DeliveryController.cls_services cls:serviceListMoocodes)
            {
                
                        BWC_Product_Service__c service1=new BWC_Product_Service__c();

             service1.Name=cls.description;
            service1.BWC_Service_Description__c=cls.description;
            
                 service1.BWC_Service_Price__c=(Decimal.valueOf(quantity)) * (Decimal.valueOf(cls.price));
                 service1.BWC_Member_Price__c=(Decimal.valueOf(quantity)) * (Decimal.valueOf(cls.price));
          
         
            service1.BWC_Service_Type__c='Additional Mcode';
            service1.BWC_SKU__c=cls.id;
            service1.Cart_Item__c=cartItemId;
            service1.BWC_Cart_Id__c=cartId;
                service1.BWC_ZipCode__c=zipCode;
            service1.BWC_Quantity__c=Decimal.valueOf(quantity);
            serviceList.add(service1);
           
            }
            if(serviceList.size()>0)
            {
                insert serviceList;
            }
            
        }
      
        
        return serviceList;
        
    }
    
    
    
    @AuraEnabled
    public static List<BWC_Product_Service__c> addPlanAdLineItem(String proId,string cartId,string cartItemId,String quantity,List<String> moocodeSelected,String zipCode) {
        BWC_Product_Service__c service=new BWC_Product_Service__c();
         List<BWC_Product_Service__c> serviceList=new List<BWC_Product_Service__c>();
                 List<BWC_DeliveryController.cls_services> serviceListMoocodes=new List<BWC_DeliveryController.cls_services>();

        for(String str:moocodeSelected)
        {
            BWC_DeliveryController.cls_services responseWrapper = new BWC_DeliveryController.cls_services();
            responseWrapper = (BWC_DeliveryController.cls_services)JSON.deserialize(str, BWC_DeliveryController.cls_services.class); 
            serviceListMoocodes.add(responseWrapper);
        }
        List<String> proIds=new List<String>();
        PricebookEntry pbm=new PricebookEntry();
        PricebookEntry pby=new PricebookEntry();
        Product2 pro=new Product2();
                List<BWC_Product_Service__c> relatedItemOldMoocode=[Select Id, Name, BWC_SKU__c, BWC_Service_Type__c, BWC_Member_Price__c,Cart_Item__c, BWC_Service_Description__c, BWC_Service_Price__c FROM BWC_Product_Service__c where Cart_Item__c=:cartItemId  and BWC_Service_Type__c='Additional Mcode' ];
   if(relatedItemOldMoocode.size()>0)
        {
            
            delete relatedItemOldMoocode;
        } 
        if(moocodeSelected.size()>0)
        {
            
            for(BWC_DeliveryController.cls_services cls:serviceListMoocodes)
            {
                
                        BWC_Product_Service__c service1=new BWC_Product_Service__c();

             service1.Name=cls.description;
            service1.BWC_Service_Description__c=cls.description;
            
                 service1.BWC_Service_Price__c=(Decimal.valueOf(quantity)) * (Decimal.valueOf(cls.price));
                 service1.BWC_Member_Price__c=(Decimal.valueOf(quantity)) * (Decimal.valueOf(cls.price));
          
         
            service1.BWC_Service_Type__c='Additional Mcode';
            service1.BWC_SKU__c=cls.id;
            service1.Cart_Item__c=cartItemId;
            service1.BWC_Cart_Id__c=cartId;
                 service1.BWC_ZipCode__c=zipCode;
            service1.BWC_Quantity__c=Decimal.valueOf(quantity);
            serviceList.add(service1);
           
            }
            if(serviceList.size()>0)
            {
                insert serviceList;
            }
            
        }
        if(proId!='Decline')
        {
                                pro=[Select id, StockKeepingUnit,BWC_Product_Marketing_Description__c  from product2 where Id=:proId];

        }

            memberPriceBookWrapper pbmMember =new memberPriceBookWrapper();
        memberPriceBookWrapper pbyMember=new memberPriceBookWrapper();
     //   BWC_Product_Bundle_Services__mdt mdt=new  BWC_Product_Bundle_Services__mdt();
        if(proId!='Decline')
            
        {
            proIds.add(pro.StockKeepingUnit);
           BundleProtectionWrapperNew bpwn= fetchProductAndPrices(proIds);
           // system.debug('test=='+bpwn.monthlyPlan[0]);
             // system.debug(bpwn.yearlyPlan[0]);
             // system.debug(bpwn.monthlyPlanMember[0]);
                  //  system.debug(bpwn.yearlyPlanMember[0]);
            if(bpwn.monthlyPlan.size()>0)
            {
                pbm=bpwn.monthlyPlan[0]; 
            }
             if(bpwn.yearlyPlan.size()>0)
            {
                pby=bpwn.yearlyPlan[0];
            }
               if(bpwn.monthlyPlanMember.size()>0)
            {
                pbmMember=bpwn.monthlyPlanMember[0];
            }
               if(bpwn.yearlyPlanMember.size()>0)
            {
              
              pbyMember=bpwn.yearlyPlanMember[0];
            }
           
           
     
      
          //  mdt=[SELECT Id,BWC_Member_Price__c, DeveloperName, MasterLabel, Product_SKU__c, Product_Sf_Id__c, Type__c, Price__c, Description__c, QualifiedApiName, Label FROM BWC_Product_Bundle_Services__mdt WHERE Product_Sf_Id__c=:proId];
        }
        List<BWC_Product_Service__c> relatedItemOld=[Select Id, Name, BWC_SKU__c, BWC_Service_Type__c, BWC_Member_Price__c,Cart_Item__c, BWC_Service_Description__c, BWC_Service_Price__c FROM BWC_Product_Service__c where Cart_Item__c=:cartItemId  and BWC_Service_Type__c='Protection Plan' ];
        if(relatedItemOld.size()>0)
        {
            
            delete relatedItemOld;
        }  
        if(proId!='Decline')
            
        {
            service.Name=pro.BWC_Product_Marketing_Description__c;
            service.BWC_Service_Description__c=pro.BWC_Product_Marketing_Description__c;
            String planPlus=System.Label.BWC_MonthlyPlusPlanSKU;
            if(pro.StockKeepingUnit==planPlus)
            {
                 service.BWC_Service_Price__c=(pbm.UnitPrice)* Decimal.valueOf(quantity);
                 service.BWC_Member_Price__c=(pbmMember.memberPrice)* Decimal.valueOf(quantity);
                
            }
            else
            {
              service.BWC_Service_Price__c=(pby.UnitPrice)* Decimal.valueOf(quantity);
                   service.BWC_Member_Price__c=(pbyMember.memberPrice)* Decimal.valueOf(quantity);
                
            }
           
            service.BWC_Service_Type__c='Protection Plan';
            service.BWC_SKU__c=pro.StockKeepingUnit;
            service.Cart_Item__c=cartItemId;
            service.BWC_Cart_Id__c=cartId;
            service.BWC_Quantity__c=Decimal.valueOf(quantity);
         
            insert service;
             serviceList.add(service);  
        }
        
        
        return serviceList;
        
    }
    
    @AuraEnabled
    public static List<BWC_Product_Service__c> addPartsShippingAsLineItem(String sku, String cartId, List<String> cartItemIdList) {
        BWC_Product_Bundle_Services__mdt partShipFeeMdt = [SELECT Id, BWC_Member_Price__c, DeveloperName, MasterLabel, Product_SKU__c, Type__c, Price__c, Description__c, QualifiedApiName, Label FROM BWC_Product_Bundle_Services__mdt WHERE Product_SKU__c = :sku];
        System.debug('partShipFeeMdt' + partShipFeeMdt);
        List<BWC_Product_Service__c> relatedItemOldPartShipFee = [SELECT Id, Name, BWC_SKU__c, BWC_Service_Type__c, BWC_Member_Price__c, Cart_Item__c, BWC_Service_Description__c, BWC_Service_Price__c FROM BWC_Product_Service__c WHERE Cart_Item__c IN :cartItemIdList AND BWC_Service_Type__c = 'Parts Ship Fee'];
        System.debug('relatedItemOldPartShipFee' + relatedItemOldPartShipFee);
        if (!relatedItemOldPartShipFee.isEmpty()) {
            delete relatedItemOldPartShipFee;
        }
        
        List<BWC_Product_Service__c> partShipFeeList = new List<BWC_Product_Service__c>();
        
        for (String cartItemId : cartItemIdList) {
            BWC_Product_Service__c partShipFee = new BWC_Product_Service__c();
            partShipFee.Name = partShipFeeMdt.Label;
            partShipFee.BWC_Service_Description__c = partShipFeeMdt.Description__c;
            partShipFee.BWC_Service_Price__c = partShipFeeMdt.Price__c;
            partShipFee.BWC_Service_Type__c = 'Parts Ship Fee';
            partShipFee.BWC_SKU__c = partShipFeeMdt.Product_SKU__c;
            partShipFee.Cart_Item__c = cartItemId;
            partShipFee.BWC_Cart_Id__c = cartId;
            partShipFee.BWC_Quantity__c = 1;
            
            partShipFeeList.add(partShipFee);
            System.debug('partShipFeeList' + partShipFeeList);
        }
        
        insert partShipFeeList;
        
        return partShipFeeList;
    }
    
    
    
    /*  @AuraEnabled
public static List<BWC_Product_Service__c> getRelatedProPanOld(string cartItemId) {

List<BWC_Product_Service__c> relatedItem=[Select Id, Name, BWC_SKU__c, BWC_Service_Type__c, BWC_Member_Price__c,Cart_Item__c, BWC_Service_Description__c, BWC_Service_Price__c FROM BWC_Product_Service__c where Cart_Item__c=:cartItemId  and BWC_Service_Type__c='Protection Plan' ];



return relatedItem;

}*/
    
    public class BundleProtectionWrapperPlan{
        @AuraEnabled
        public List<BWC_Product_Service__c> monthlyPlan ;
        @AuraEnabled
        public List<BWC_Product_Service__c> yearlyPlan;
        @AuraEnabled
        public List<BWC_Product_Service__c> partsShipFee;
        
        public BundleProtectionWrapperPlan()
        {
            this.monthlyPlan=new List<BWC_Product_Service__c>();
            this.yearlyPlan=new List<BWC_Product_Service__c>();
            this.partsShipFee=new List<BWC_Product_Service__c>();
            
            
        }
        
    }
    @AuraEnabled
    public static BundleProtectionWrapperPlan getRelatedProPan(string cartItemId,String quantity,String zipCode) {
                    String planPlus=System.Label.BWC_MonthlyPlusPlanSKU;

        List<BWC_Product_Service__c> relatedItemCarePlus=[Select Id, Name, BWC_SKU__c,BWC_Quantity__c, BWC_Service_Type__c,BWC_Cart_Id__c, BWC_Member_Price__c,Cart_Item__c, BWC_Service_Description__c, BWC_Service_Price__c FROM BWC_Product_Service__c where Cart_Item__c=:cartItemId  and BWC_Service_Type__c='Protection Plan' and  BWC_SKU__c=:planPlus];
        List<BWC_Product_Service__c> relatedItem=[Select Id, Name, BWC_SKU__c,BWC_Quantity__c, BWC_Service_Type__c,BWC_Cart_Id__c, BWC_Member_Price__c,Cart_Item__c, BWC_Service_Description__c, BWC_Service_Price__c FROM BWC_Product_Service__c where Cart_Item__c=:cartItemId  and BWC_Service_Type__c='Protection Plan' and  BWC_SKU__c!=:planPlus ];
        if(relatedItemCarePlus.size()>0)
        {
            for(BWC_Product_Service__c service:relatedItemCarePlus)
            {
                if(service.BWC_Quantity__c!=Decimal.valueOf(quantity))
                {
                   // BWC_Product_Bundle_Services__mdt plan=[SELECT Id,BWC_Member_Price__c, DeveloperName, MasterLabel, Product_SKU__c, Product_Sf_Id__c, Type__c, Price__c, Description__c, QualifiedApiName, Label FROM BWC_Product_Bundle_Services__mdt WHERE Product_SKU__c =:service.BWC_SKU__c AND Type__c='Subscription'];
                                        Product2 pro=[Select Id, StockKeepingUnit from product2 where StockKeepingUnit=:service.BWC_SKU__c LIMIT 1];

                    //String proId,string cartId,string cartItemId,String quantity
                    List<BWC_Product_Service__c> updatedPlan=addPlanAdLineItem(pro.id,service.BWC_Cart_Id__c,service.Cart_Item__c,quantity,new List<String>(),zipCode);
                }
            }
        }
        if(relatedItem.size()>0)
        {
            for(BWC_Product_Service__c service:relatedItem)
            {
                if(service.BWC_Quantity__c!=Decimal.valueOf(quantity))
                {
                   // BWC_Product_Bundle_Services__mdt plan=[SELECT Id,BWC_Member_Price__c, DeveloperName, MasterLabel, Product_SKU__c, Product_Sf_Id__c, Type__c, Price__c, Description__c, QualifiedApiName, Label FROM BWC_Product_Bundle_Services__mdt WHERE Product_SKU__c =:service.BWC_SKU__c AND Type__c='Protection plan'];
                    Product2 pro=[Select Id, StockKeepingUnit from product2 where StockKeepingUnit=:service.BWC_SKU__c LIMIT 1];
                    //String proId,string cartId,string cartItemId,String quantity
                    List<BWC_Product_Service__c> updatedPlan=addPlanAdLineItem(pro.id,service.BWC_Cart_Id__c,service.Cart_Item__c,quantity,new List<String>(),zipCode);
                }
            }
        }
        List<BWC_Product_Service__c> relatedItemCarePlusNew=[Select Id, Name, BWC_SKU__c,BWC_Quantity__c, BWC_Service_Type__c, BWC_Member_Price__c,Cart_Item__c, BWC_Service_Description__c, BWC_Service_Price__c FROM BWC_Product_Service__c where Cart_Item__c=:cartItemId  and BWC_Service_Type__c='Protection Plan' and  BWC_SKU__c=:planPlus];
        List<BWC_Product_Service__c> relatedItemNew=[Select Id, Name, BWC_SKU__c,BWC_Quantity__c, BWC_Service_Type__c, BWC_Member_Price__c,Cart_Item__c, BWC_Service_Description__c, BWC_Service_Price__c FROM BWC_Product_Service__c where Cart_Item__c=:cartItemId  and BWC_Service_Type__c='Protection Plan' and  BWC_SKU__c!=:planPlus ];
        
        BundleProtectionWrapperPlan bpw=new BundleProtectionWrapperPlan();
        bpw.monthlyPlan=relatedItemCarePlusNew;
        bpw.yearlyPlan=relatedItemNew;
        
        
        return bpw;
        
    }
    
    
    @AuraEnabled
    public static BundleProtectionWrapperNew fetchProductAndPrices(List<String> productIds) 
    {
        Map<String, Object> result = new Map<String, Object>();
                            String planPlus=System.Label.BWC_MonthlyPlusPlanSKU;

        try {
            Map<String, String> priceBookNameMap = new Map<String, String>();
            
            for (BWC_Price_Book_Configuration__mdt config : [SELECT DeveloperName, PriceBookName__c FROM BWC_Price_Book_Configuration__mdt]) {
                priceBookNameMap.put(config.DeveloperName, config.PriceBookName__c);
                System.debug('priceBookNameMap: ' + priceBookNameMap );
            }
            
            Map<Id, PricebookEntry> basePricebookEntriesMap = new Map<Id, PricebookEntry>();
            
            List<PricebookEntry> basePricebookEntriesMapMonthly = new  List<PricebookEntry>();    
            List<PricebookEntry> basePricebookEntriesMapYearly = new  List<PricebookEntry>();    
            
            for(PricebookEntry pb: [ SELECT BWC_Product_MSRP__c, UnitPrice,Product2.Id, Product2Id,Product2.StockKeepingUnit,Product2.BWC_Marketing_Description__c
                                    FROM PricebookEntry
                                    WHERE Product2.StockKeepingUnit IN :productIds
                                  //  AND Pricebook2.Name = :priceBookNameMap.get('BasePriceBook')])
             AND (Pricebook2.Name = 'Appliances - gea store - bodewell - Care Plans' OR Pricebook2.Name ='Appliances - gea store - bodewell - Subscriptions')])
 	

            {
                Product2 productInfo=[SELECT Id, Name, ProductCode, IsActive, StockKeepingUnit, Type, BWC_Marketing_Description__c FROM Product2 where Id=:pb.Product2Id];
                if(productInfo.StockKeepingUnit==planPlus)
                {
                    basePricebookEntriesMapMonthly.add(pb); 
                    basePricebookEntriesMap.put(pb.Product2Id,pb);
                }
                else
                {
                    
                    basePricebookEntriesMapYearly.add(pb);  
                    basePricebookEntriesMap.put(pb.Product2Id,pb);
                    
                }
                
            }
            
            System.debug('basePricebookEntriesMapYearly: ' + basePricebookEntriesMapYearly );
            
            System.debug('basePricebookEntriesMapMonthly: ' + basePricebookEntriesMapMonthly );
            List<memberPriceBookWrapper> memberPricebookEntriesMapMonthly = new  List<memberPriceBookWrapper>();    
            List<memberPriceBookWrapper> memberPricebookEntriesMapYearly = new  List<memberPriceBookWrapper>();    
            system.debug('monthly=='+[SELECT BWC_Product_MSRP__c, UnitPrice,Product2.Id, Product2Id,Product2.StockKeepingUnit,Product2.BWC_Marketing_Description__c
                                    FROM PricebookEntry
                                    WHERE Product2.StockKeepingUnit IN :productIds
                                  //  AND Pricebook2.Name = :priceBookNameMap.get('Member_Price_Book')]);
                     AND (Pricebook2.Name = 'Appliances - gea store - bodewell - Care Plans' OR Pricebook2.Name ='Appliances - gea store - bodewell - Subscriptions')]);

            for(PricebookEntry pb: [ SELECT BWC_Product_MSRP__c, UnitPrice,Product2.Id, Product2Id,Product2.StockKeepingUnit,Product2.BWC_Marketing_Description__c
                                    FROM PricebookEntry
                                    WHERE Product2.StockKeepingUnit IN :productIds
                                   // AND Pricebook2.Name = :priceBookNameMap.get('Member_Price_Book')])
    AND (Pricebook2.Name = 'Appliances - gea store - bodewell - Care Plans' OR Pricebook2.Name ='Appliances - gea store - bodewell - Subscriptions')])

            {
                Product2 productInfo=[SELECT Id, Name, ProductCode, IsActive, StockKeepingUnit, Type, BWC_Marketing_Description__c FROM Product2 where Id=:pb.Product2Id];
              
                if(productInfo.StockKeepingUnit==planPlus)
                {
                    // memberPricebookEntriesMapMonthly.add(pb); 
                    // basePricebookEntriesMap.put(pb.Product2Id,pb);
                    memberPriceBookWrapper mpbw=new memberPriceBookWrapper();
                    if((pb.UnitPrice)==0)
                    { 
                        mpbw.isFree=true;
                        
                    }
                    else
                    {
                        mpbw.isFree=false; 
                          if((basePricebookEntriesMap.get(pb.Product2Id)).UnitPrice==pb.UnitPrice)
                          {
                              mpbw.isSame=true;
                          }
                    }
                    
                    mpbw.marketingDescription=pb.Product2.BWC_Marketing_Description__c;
                    mpbw.nonmemberPrice=(basePricebookEntriesMap.get(pb.Product2Id)).UnitPrice;
                    mpbw.productId=pb.Product2Id;
                    mpbw.memberPrice=pb.UnitPrice;
                    memberPricebookEntriesMapMonthly.add(mpbw);
                    
                    
                    
                    
                }
                else
                {
                    
                    // memberPricebookEntriesMapYearly.add(pb);  
                    //basePricebookEntriesMap.put(pb.Product2Id,pb);
                    memberPriceBookWrapper mpbw=new memberPriceBookWrapper();
                    if((basePricebookEntriesMap.get(pb.Product2Id)).UnitPrice==0)
                    { 
                        mpbw.isFree=true;
                        
                    }
                    else
                    {
                        mpbw.isFree=false; 
                        if((basePricebookEntriesMap.get(pb.Product2Id)).UnitPrice==pb.UnitPrice)
                        {
                            mpbw.isSame=true;
                        }
                    }
                    
                    mpbw.marketingDescription=pb.Product2.BWC_Marketing_Description__c;
                    mpbw.nonmemberPrice=(basePricebookEntriesMap.get(pb.Product2Id)).UnitPrice;
                    mpbw.productId=pb.Product2Id; 
                    mpbw.memberPrice=pb.UnitPrice;
                    memberPricebookEntriesMapYearly.add(mpbw);
                    
                }
                
            }
            
            System.debug('memberPricebookEntriesMapMonthly: ' + memberPricebookEntriesMapMonthly);
            
            System.debug('memberPricebookEntriesMapYearly: ' + memberPricebookEntriesMapYearly );
            
            
            BundleProtectionWrapperNew bpw=new  BundleProtectionWrapperNew();
            bpw.monthlyPlan=basePricebookEntriesMapMonthly;
            bpw.yearlyPlan=basePricebookEntriesMapYearly;
            bpw.monthlyPlanMember=memberPricebookEntriesMapMonthly;
            bpw.yearlyPlanMember=memberPricebookEntriesMapYearly;
            return bpw;
            
        } catch (Exception e) {
            result.put('error', e.getMessage());
            return null;
        }
        
    }
    public class BundleProtectionWrapperNew{
        @AuraEnabled
        public List<PricebookEntry> monthlyPlan ;
        @AuraEnabled
        public  List<PricebookEntry> yearlyPlan;
        @AuraEnabled
        public List<memberPriceBookWrapper> monthlyPlanMember ;
        @AuraEnabled
        public  List<memberPriceBookWrapper> yearlyPlanMember;
        
        public BundleProtectionWrapperNew()
        {
            this.monthlyPlan=new  List<PricebookEntry>();
            this.yearlyPlan=new  List<PricebookEntry>();
            this.monthlyPlanMember=new  List<memberPriceBookWrapper>();
            this.yearlyPlanMember=new  List<memberPriceBookWrapper>();
            
        }
        
    }
    public class memberPriceBookWrapper{
        @AuraEnabled
        public Boolean isFree;
           @AuraEnabled
        public Boolean isSame;
        @AuraEnabled
        public String marketingDescription;
        @AuraEnabled
        public decimal memberPrice;
        @AuraEnabled
        public decimal nonmemberPrice;
        @AuraEnabled
        public String productId;
        
        
        
    }
    
    /*
@AuraEnabled(cacheable=true)
public static ConnectApi.ProductOverviewCollection getProductDetails(String modelSku,string accId,string communityId) {
try{

List<string> skus=modelSku.split('~');


String webStoreId=BWC_utils.resolveCommunityIdToWebstoreId(communityId);

return  ConnectApi.CommerceCatalog.getProducts(webStoreId, accId,null, skus, null, false, false);
}
catch(Exception e){
System.debug('Exception Message->'+e.getMessage()+'  at Line->'+e.getLineNumber());
return null;
}
}
*/
    
    
}