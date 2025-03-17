public class BWC_ProductDataLoadHelper {

    //routeCalls based on the of load
   
    public static void routeCalls(List<sObject> scope, String target) {
        
        
        if (target.equals('ProductAttributeSetProduct')) {
            loadProductAttributeSetProduct(scope);
        }
        else if (target.equals('ProductAttribute')) {
            linkProductAttribute(scope);
        }
        else if (target.equals('ProductCategoryProduct')) {
            linkProductCategories(scope);
        }
        else if (target.equals('CommerceEntitlementProduct')) {
            linkCommerceEntitlementProduct(scope);
        }
    }
   
         
//	SELECT ID from product2 where type='Base' AND LASTMODIFIEDDATE=TODAY 
//	Use HardCoded ProductAttributeSetId= '0iY8B00000000E3UAI' - DEV for QA and PRD. Use Property file.
// 	create custom field BWC_ProductAttributeSetId
       
   public static void loadProductAttributeSetProduct(List<sObject> scope) {        
       List<ProductAttributeSetProduct> attrList = new List<ProductAttributeSetProduct>();
       for (sObject obj : scope) {
           ProductAttributeSetProduct attributeSetProduct = new ProductAttributeSetProduct(
               ProductId = (Id) obj.get('Id'),
               ProductAttributeSetId = Label.BWC_ProductAttributeSetId,
               External_ID__c = (String) obj.get('Id')+'-'+Label.BWC_ProductAttributeSetId
           );
           attrList.add(attributeSetProduct);
        }
       
       if (!attrList.isEmpty()) {
           Database.upsert(attrList, false); // Set allOrNone to false for partial success handling
        }
    }

//   SELECT ID, BWC_APPEARANCE__C, BWC_BASE_MODEL__C, STOCKKEEPINGUNIT, BWC_PARENT_MODEL__C FROM PRODUCT2
//  	WHERE 
//  BWC_BASE_MODEL__C<>'' AND BWC_PARENT_MODEL__C <>'' AND LASTMODIFIEDBY.NAME='DEVOPS USER' AND LASTMODIFIEDDATE=TODAY 
//  create custom field for where clause.
//   SELECT Id, ProductId, VariantParentId, Color__c FROM ProductAttribute

    public static void linkProductAttribute(List<sObject> scope) {        
       List<ProductAttribute> attrList = new List<ProductAttribute>();
       for (sObject obj : scope) {
           ProductAttribute attribute = new ProductAttribute(
               ProductId = (Id) obj.get('Id'),
               VariantParentId = (String) obj.get('BWC_Base_model__C'),
           	   Color__c=(String) obj.get('BWC_Appearance__c'),
               External_ID__c = (String) obj.get('BWC_Parent_Model__c')+'-'+(String) obj.get('stockkeepingunit')
           );
           	   attrList.add(attribute);
        }
       
       if (!attrList.isEmpty()) {
           Database.upsert(attrList, false); // Set allOrNone to false for partial success handling
        }
    }
 
    
//	SELECT Id FROM Product2 WHERE LASTMODIFIEDDATE=TODAY 
//  create custom field for where clause.   
//  SELECT Id, ProductCategoryId, ProductId, CatalogId FROM ProductCategoryProduct 
    
    public static void linkProductCategories(List<sObject> scope) { 
        
       Map<String, String> catMap = getSobjectMap('ProductCategory','');
       List<ProductCategoryProduct> pcpList = new List<ProductCategoryProduct>();
       
        for (sObject obj : scope) 
        {
            String bwcPCP=(String)obj.get('BWC_Product_Category__c');
            if(bwcPCP!=null) 
            {
                  for(String hierarchy : splitCategoryName(bwcPCP))
                  {
                      if (hierarchy!=null && catMap.containsKey(hierarchy)) 
                      {
                         ProductCategoryProduct pcp = new ProductCategoryProduct(
                           ProductId = (Id) obj.get('Id'),
                           ProductCategoryId = catMap.get(hierarchy),
                           External_ID__c = (Id) obj.get('Id') +'-'+catMap.get(hierarchy)
                           );
                           pcpList.add(pcp);
                    }
                }
            }
        }
        
        if(!pcpList.isEmpty()) {
           Database.upsert(pcpList, false);
        }
       
    }
    
  
//	SELECT Id FROM Product2 WHERE LASTMODIFIEDDATE=TODAY 
//  create custom field for where clause.
//  SELECT Id, Name, IsActive, Description FROM CommerceEntitlementPolicy 
//    where Name in 
//  ('All Access for Bodewell Commerce','Member','Non-Member Registered Owner','Bodewell/ZD Loyalty Store (LYT)','Guest')


    public static void linkCommerceEntitlementProduct(List<sObject> scope) {  
       Map<String, String> catMap = getSobjectMap('CommerceEntitlementPolicy', 'where IsActive=true');
       List<CommerceEntitlementProduct> epsList = new List<CommerceEntitlementProduct>();
       
        if(catMap!=null) 
            {
                  for(String key : catMap.keySet())
                  { 
                      String value = catMap.get(key);
                       
                       for (sObject obj : scope) {
                           CommerceEntitlementProduct ep = new CommerceEntitlementProduct(
                               ProductId = (Id) obj.get('Id'),
                               PolicyId = value,
                                External_ID__c = (Id) obj.get('Id') +'-'+value
                           );
                               epsList.add(ep);
        				}
               		}
            }
                      
               
       if (!epsList.isEmpty()) {
           Database.upsert(epsList, false); // Set allOrNone to false for partial success handling
        }
    }
     

   //Utility Method to get the Salesforce entitlement policies and hierarchies.
   public static Map<String, String> getSobjectMap(String sobjectName, String whereClause) 
   {
       String soqlQuery = 'SELECT Id, Name FROM ' + sObjectName;
       if(!String.isBlank(whereClause))
           soqlQuery =soqlQuery+' '+whereClause;

       Map<String, String> namesList = new Map<String, String>();
       List<sObject> sobjList = Database.query(soqlQuery);
       for(sObject obj : sobjList) {
           namesList.put((String)obj.get('Name'), (Id)obj.get('Id'));
        }
       return namesList;
    }
   
   public static List<String>  splitCategoryName(String inputString){
       List<String> parts = inputString.split('\\|');
       List<String> lastEntries = new List<String>();
       for (String part : parts) {
           List<String> subParts = part.split('>');
           String lastEntry = subParts[subParts.size() - 1
            ];
           lastEntries.add(lastEntry);
        }
       return lastEntries;
    }
    
    public static void SendEmail(Id batchId){
    
         AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                FROM AsyncApexJob WHERE Id = :batchId];
    
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Scheduled Job: Salsify Prouct Attributes Load ' + a.Status);
            mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with ' + a.NumberOfErrors + ' failures.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
}




/*
 * Use HardCoded ProductAttributeSetId= '0iY8B00000000E3UAI'
 String Query = 'SELECT Id FROM Product2 WHERE TYPE='Base'; 
		BWC_ProducDataLoadBatch batch = new BWC_ProducDataLoadBatch(Query,'ProductAttributeSetProduct'); 
        database.executebatch(batch, 2000);



String query = 'SELECT ID, BWC_APPEARANCE__C, BWC_BASE_MODEL__C, STOCKKEEPINGUNIT, BWC_PARENT_MODEL__C FROM PRODUCT2 WHERE BWC_BASE_MODEL__C <> \'\' AND BWC_PARENT_MODEL__C <> \'\' AND LASTMODIFIEDBY.NAME = \'DEVOPS USER\' AND LASTMODIFIEDDATE = TODAY';
		BWC_ProducDataLoadBatch batch = new BWC_ProducDataLoadBatch(Query,'ProductAttribute'); 
        database.executebatch(batch, 2000);


String Query = 'SELECT Id, BWC_Product_Category__c FROM Product2 WHERE LastModifiedDate = TODAY'; 
		BWC_ProducDataLoadBatch batch = new BWC_ProducDataLoadBatch(Query,'ProductCategoryProduct'); 
        database.executebatch(batch, 2000);

String Query = 'SELECT Id FROM Product2 ; 
		BWC_ProducDataLoadBatch batch = new BWC_ProducDataLoadBatch(Query,'CommerceEntitlementProduct'); 
        database.executebatch(batch, 2000);


*/