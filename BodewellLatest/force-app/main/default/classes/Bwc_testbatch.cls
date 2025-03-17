public class Bwc_testbatch implements Database.Batchable<SObject>, Database.Stateful {
Map<String, BWC_Price_Book_Configuration__mdt> configMap = new Map<String, BWC_Price_Book_Configuration__mdt>();
List<BWC_Price_Book_Configuration__mdt> configs = [SELECT DeveloperName, PriceBookName__c, Discount_Percentage__c FROM BWC_Price_Book_Configuration__mdt];
     
        String memberPriceBookName = '';
        String basePriceBookName = '';
        String memberPriceBookId = '';
        Decimal fgDiscount = 0.0;
        Decimal accessoryDiscount = 0.0;
        Decimal partsDiscount = 0.0;
    
     public Database.QueryLocator start(Database.BatchableContext context) {      
         
           for (BWC_Price_Book_Configuration__mdt config : configs) {
            String developerName = config.DeveloperName;
            String priceBookName = config.PriceBookName__c;		

            if (developerName == 'Member_Price_Book') {
                memberPriceBookName = priceBookName;
            } else if (developerName == 'BasePriceBook') {
                basePriceBookName = priceBookName;
            } else if (developerName == 'FG_Discount') {
              fgDiscount = config.Discount_Percentage__c / 100;
            }else if (developerName == 'Accessory_Discount') {
               accessoryDiscount = config.Discount_Percentage__c / 100;
            }else if (developerName == 'Parts_Discount') {
               partsDiscount = config.Discount_Percentage__c / 100;
            }
        
			 configMap.put(developerName, config);
             System.debug('@@@configMap' +configMap);
        }
         
        Pricebook2 memberPriceBook = [SELECT Id, Name FROM Pricebook2 WHERE Name = :memberPriceBookName];
        memberPriceBookId = memberPriceBook.Id;
         
        return Database.getQueryLocator([
            SELECT Id, Name, UnitPrice, Product2.Is_Accessory__c, Product2.Is_Finished_Good__c
            FROM PricebookEntry 
            WHERE Pricebook2.Name = :basePriceBookName]);
    }
    
 
    
    public void execute(Database.BatchableContext context, List<PricebookEntry> pricebookEntries) {   
       System.debug('@@@Inside Execute');
        Set<Id> basePriceBookProductIds = new Set<Id>();
        for (PricebookEntry entry : pricebookEntries) {
            basePriceBookProductIds.add(entry.Product2Id);
        }

        List<PricebookEntry> existingMemberEntries = [SELECT Id, Name, UnitPrice, Product2.Is_Accessory__c, Product2.Is_Finished_Good__c, Product2Id FROM PricebookEntry WHERE Product2Id IN :basePriceBookProductIds AND Pricebook2.Name = :memberPriceBookName];
        
        Set<Id> existingMemberProductIds = new Set<Id>();
        for (PricebookEntry memberEntry : existingMemberEntries) {
            existingMemberProductIds.add(memberEntry.Product2Id);
        }

        List<PricebookEntry> entriesToCreate = new List<PricebookEntry>();
        List<PricebookEntry> entriesToUpdate = new List<PricebookEntry>();
        for (PricebookEntry entry : pricebookEntries) {
            if (!existingMemberProductIds.contains(entry.Product2Id)) {
                PricebookEntry memberEntry = new PricebookEntry();
                memberEntry.Product2Id = entry.Product2Id;
                memberEntry.IsActive = entry.IsActive;
                memberEntry.Pricebook2Id = [SELECT Id FROM Pricebook2 WHERE Name = :memberPriceBookName LIMIT 1].Id;
                if (memberEntry.Product2.Is_Finished_Good__c == 'Yes' && memberEntry.Product2.Is_Accessory__c == 'No') {
                    Decimal discountPercentage = fgDiscount;
                    memberEntry.UnitPrice = entry.UnitPrice * (1 - discountPercentage);
                  System.debug('@@@ Create Updated Unit Price (FG): ' + memberEntry.UnitPrice);
                } else if (memberEntry.Product2.Is_Finished_Good__c=='Yes' && memberEntry.Product2.Is_Accessory__c=='Yes') {
                    Decimal discountPercentage = accessoryDiscount;
                    memberEntry.UnitPrice = entry.UnitPrice * (1 - discountPercentage);
                      System.debug('@@@Create Updated Unit Price (Accessory): ' + memberEntry.UnitPrice);
                } else if (memberEntry.Product2.Is_Finished_Good__c=='No' && memberEntry.Product2.Is_Accessory__c=='No') {
                    Decimal discountPercentage = partsDiscount;
                    memberEntry.UnitPrice = memberEntry.UnitPrice * (1 - discountPercentage);
                      System.debug('@@@Create Updated Unit Price (Parts): ' + memberEntry.UnitPrice);
                }
                else
                    memberEntry.UnitPrice=entry.UnitPrice;
                //memberEntry.UnitPrice = entry.UnitPrice;
                entriesToCreate.add(memberEntry);
                 System.debug('@@@entriesToCreate: ' + entriesToCreate);
            } else {
                for (PricebookEntry memberEntry : existingMemberEntries) {
                    if (memberEntry.Product2Id == entry.Product2Id) {   
                    if (memberEntry.Product2.Is_Finished_Good__c == 'Yes' && memberEntry.Product2.Is_Accessory__c == 'No') {
                    Decimal discountPercentage = fgDiscount;
                    memberEntry.UnitPrice = entry.UnitPrice * (1 - discountPercentage);
                  System.debug('@@@Updated Unit Price (FG): ' + memberEntry.UnitPrice);
                } else if (memberEntry.Product2.Is_Finished_Good__c=='Yes' && memberEntry.Product2.Is_Accessory__c=='Yes') {
                    Decimal discountPercentage = accessoryDiscount;
                    memberEntry.UnitPrice = entry.UnitPrice * (1 - discountPercentage);
                      System.debug('@@@Updated Unit Price (Accessory): ' + memberEntry.UnitPrice);
                } else if (memberEntry.Product2.Is_Finished_Good__c=='No' && memberEntry.Product2.Is_Accessory__c=='No') {
                    Decimal discountPercentage = partsDiscount;
                    memberEntry.UnitPrice = entry.UnitPrice * (1 - discountPercentage);
                      System.debug('@@@Updated Unit Price (Parts): ' + memberEntry.UnitPrice);
                }
                        else
                            memberEntry.UnitPrice=entry.UnitPrice;
                        entriesToUpdate.add(memberEntry);
                         System.debug('@@@entriesToUpdate: ' + entriesToUpdate);
                        break;
                    }
                }
            }
      }
   
  if (!entriesToCreate.isEmpty()) {
    try {
        Database.SaveResult[] insertResults = Database.insert(entriesToCreate, true);
        System.debug('insertResults' + insertResults);
        for (Database.SaveResult result : insertResults) {
            if (!result.isSuccess()) {
                System.debug('Error occurred while inserting entry with Id: ' + result.getId() + ' - ' + result.getErrors());
            }
        }
    } catch (Exception e) {
        System.debug('Error occurred while inserting entries: ' + e.getMessage());
    }
}
            
   if (!entriesToUpdate.isEmpty()) {
    try {
        Database.SaveResult[] updateResults = Database.update(entriesToUpdate, false);
        for (Database.SaveResult result : updateResults) {
            if (!result.isSuccess()) {
                System.debug('Error occurred while updating entry with Id: ' + result.getId() + ' - ' + result.getErrors());
            }
        }
    } catch (Exception e) {
        System.debug('Error occurred while updating entries: ' + e.getMessage());
    }
}
   }   
    
    public void finish(Database.BatchableContext context) {
        // Perform any post-processing if required
    } 

}