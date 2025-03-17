public class BWC_MemberPriceBookUpdate implements Database.Batchable<SObject>, Database.Stateful {
    Map<String, BWC_Price_Book_Configuration__mdt> configMap = new Map<String, BWC_Price_Book_Configuration__mdt>();
    List<BWC_Price_Book_Configuration__mdt> configs = [SELECT DeveloperName, PriceBookName__c, Discount_Percentage__c FROM BWC_Price_Book_Configuration__mdt];
            
            String memberPriceBookName = '';
            String memberPartsPriceBookName = '';
            String memberSubscriptionsCarePlanPriceBookName= '';
            String basePriceBookName = '';
            String basePartsPriceBookName = '';
            String subscriptionPriceBookName = '';
            String carePlansPriceBookName = '';
            String memberPriceBookId = '';
            String memberPartsPriceBookId = '';
            String memberSubscriptionsCarePlanPriceBookId = '';
            Decimal fgDiscount = 0.0;
            Decimal accessoryDiscount = 0.0;
            Decimal partsDiscount = 0.0;
            Decimal protectionPlanDiscount = 0.0;
                
        public Database.QueryLocator start(Database.BatchableContext context) 
        {      
                
                for (BWC_Price_Book_Configuration__mdt config : configs) 
            {
                String developerName = config.DeveloperName;
                String priceBookName = config.PriceBookName__c;     
    
                if (developerName == 'Member_Price_Book') {
                    memberPriceBookName = priceBookName;
                } else if (developerName == 'Member_Parts_Price_Book') {
                    memberPartsPriceBookName = priceBookName;
                } else if (developerName == 'MemberSubscriptionsCarePlans') {
                    memberSubscriptionsCarePlanPriceBookName = priceBookName;
                } else if (developerName == 'BasePriceBook') {
                    basePriceBookName = priceBookName;
                } else if (developerName == 'PartsBasePriceBook') {
                    basePartsPriceBookName = priceBookName;
                } else if (developerName == 'SubscriptionsBasePriceBook') {
                    subscriptionPriceBookName = priceBookName;
                } else if (developerName == 'CarePlanBasePriceBook') {
                    carePlansPriceBookName = priceBookName;
                } else if (developerName == 'FG_Discount') {
                    fgDiscount = config.Discount_Percentage__c / 100;
                }else if (developerName == 'Accessory_Discount') {
                    accessoryDiscount = config.Discount_Percentage__c / 100;
                }else if (developerName == 'Parts_Discount') {
                    partsDiscount = config.Discount_Percentage__c / 100;
                }else if (developerName == 'ProtectionPlanDiscount') {
                    protectionPlanDiscount = config.Discount_Percentage__c / 100;
                }
                    System.debug('@@@fgDiscount' +fgDiscount);
                    configMap.put(developerName, config);
                    System.debug('@@@configMap' +configMap);
            }
                
            Pricebook2 memberPriceBook = [SELECT Id, Name FROM Pricebook2 WHERE Name = :memberPriceBookName];
            memberPriceBookId = memberPriceBook.Id;

            Pricebook2 memberPartsPriceBook = [SELECT Id, Name FROM Pricebook2 WHERE Name = :memberPartsPriceBookName];
            memberPartsPriceBookId = memberPartsPriceBook.Id;

            Pricebook2 memberSubscriptionCarePlanPriceBook = [SELECT Id, Name FROM Pricebook2 WHERE Name = :memberSubscriptionsCarePlanPriceBookName];
            memberSubscriptionsCarePlanPriceBookId = memberSubscriptionCarePlanPriceBook.Id;
                
            return Database.getQueryLocator([
                SELECT Id, Name, UnitPrice,IsActive,Pricebook2.Name, Product2.StockKeepingUnit,Product2.Is_Accessory__c, Product2.Is_Finished_Good__c,Product2.BWC_Is_Part__c,Product2.Item_Type__c
                FROM PricebookEntry 
                WHERE Pricebook2.Name IN (:basePriceBookName, :basePartsPriceBookName, :subscriptionPriceBookName, :carePlansPriceBookName)]);
        }
        
        
        
        public void execute(Database.BatchableContext context, List<PricebookEntry> pricebookEntries) 
        {   
            System.debug('@@@Inside Execute');
            List<PricebookEntry> basepricebookEntries = new List<PricebookEntry>();
            List<PricebookEntry> basePartspricebookEntries = new List<PricebookEntry>();
            //List<PricebookEntry> subscriptionsPricebookEntries = new List<PricebookEntry>();
            //List<PricebookEntry> carePlansPricebookEntries = new List<PricebookEntry>();
            List<PricebookEntry> subscriptionAndCarePlansPricebookEntries = new List<PricebookEntry>();

            for (PricebookEntry entry : pricebookEntries) 
            {
                // Check the condition for basePriceBookName and basePartsPriceBookName
                if (entry.Pricebook2.Name == basePriceBookName) {
                    basepricebookEntries.add(entry);
                } else if (entry.Pricebook2.Name == basePartsPriceBookName) {
                    basePartspricebookEntries.add(entry);
                }else if ((entry.Pricebook2.Name == subscriptionPriceBookName)||(entry.Pricebook2.Name == carePlansPriceBookName)) {
                    subscriptionAndCarePlansPricebookEntries.add(entry);
                }
            }

            /*List<PricebookEntry> basepricebookEntries = [SELECT Id, Name, UnitPrice,IsActive, Product2.Is_Accessory__c, Product2.Is_Finished_Good__c,Product2.BWC_Is_Part__c,Product2.Status__c
            FROM PricebookEntry 
            WHERE Pricebook2.Name = :basePriceBookName];

            List<PricebookEntry> basePartspricebookEntries = [SELECT Id, Name, UnitPrice,IsActive, Product2.Is_Accessory__c, Product2.Is_Finished_Good__c,Product2.BWC_Is_Part__c,Product2.Status__c
            FROM PricebookEntry 
            WHERE Pricebook2.Name = :basePartsPriceBookName]; */

            Map<Id, Decimal> basePriceBookProductMap = new Map<Id, Decimal>();
            for (PricebookEntry entry : basepricebookEntries) {
                basePriceBookProductMap.put(entry.Product2Id, entry.UnitPrice);
                System.debug('basePriceBookProductMap' + basePriceBookProductMap);
            }
    
            Map<Id, Decimal> partsBasePriceBookProductMap = new Map<Id, Decimal>();
            for (PricebookEntry partsEntry : basePartspricebookEntries) {
                partsBasePriceBookProductMap.put(partsEntry.Product2Id, partsEntry.UnitPrice);
                System.debug('partsBasePriceBookProductMap' + partsBasePriceBookProductMap);
            }

            //Combined Map for Subscriptions & CarePlans
            Map<Id, Decimal> subscriptionsAndCarePlansPricebookProductMap = new Map<Id, Decimal>();
            for (PricebookEntry subAndcpEntry : subscriptionAndCarePlansPricebookEntries) {
                subscriptionsAndCarePlansPricebookProductMap.put(subAndcpEntry.Product2Id, subAndcpEntry.UnitPrice);
                System.debug('subscriptionsAndCarePlansPricebookProductMap SUB' + subscriptionsAndCarePlansPricebookProductMap);
            }    
          

            List<PricebookEntry> existingMemberEntries = [SELECT Id, Name, UnitPrice,BWC_BasePrice__c,BWC_Parts_Discount_Percentage__c,BWC_FG_Discount_Percentage__c,BWC_Accessory_Discount_Percentage__c,BWC_Protection_Plan_Discount_Percentage__c,IsActive, Product2.Is_Accessory__c, Product2.Is_Finished_Good__c,Product2.Item_Type__c,Product2.BWC_Is_Part__c, Product2Id FROM PricebookEntry WHERE Product2Id IN :basePriceBookProductMap.keySet() AND Pricebook2.Name = :memberPriceBookName];
            List<PricebookEntry> existingPartsMemberEntries = [SELECT Id, Name, UnitPrice,BWC_BasePrice__c,BWC_Parts_Discount_Percentage__c,BWC_FG_Discount_Percentage__c,BWC_Accessory_Discount_Percentage__c,BWC_Protection_Plan_Discount_Percentage__c,IsActive, Product2.Is_Accessory__c, Product2.Is_Finished_Good__c,Product2.BWC_Is_Part__c,Product2.Item_Type__c, Product2Id FROM PricebookEntry WHERE Product2Id IN :partsBasePriceBookProductMap.keySet() AND Pricebook2.Name = :memberPartsPriceBookName];
            List<PricebookEntry> existingSubscriptionsAndCarePlanMemberEntries = [SELECT Id, Name, UnitPrice,BWC_BasePrice__c,BWC_Parts_Discount_Percentage__c,BWC_FG_Discount_Percentage__c,BWC_Accessory_Discount_Percentage__c,BWC_Protection_Plan_Discount_Percentage__c,IsActive, Product2.Is_Accessory__c, Product2.Is_Finished_Good__c,Product2.BWC_Is_Part__c,Product2.Item_Type__c, Product2Id FROM PricebookEntry WHERE Product2Id IN :subscriptionsAndCarePlansPricebookProductMap.keySet() AND Pricebook2.Name = :memberSubscriptionsCarePlanPriceBookName];

            Map<Id,Decimal> existingMemberProductMap = new Map<Id,Decimal>();
            for (PricebookEntry memberEntry : existingMemberEntries) {  
                existingMemberProductMap.put(memberEntry.Product2Id, memberEntry.BWC_BasePrice__c);
                    System.debug('existingMemberProductMap' + existingMemberProductMap);
            }

            Map<Id,Decimal> existingMemberPartsProductMap = new Map<Id,Decimal>();
            for (PricebookEntry memberPartEntry : existingPartsMemberEntries) {     
                existingMemberPartsProductMap.put(memberPartEntry.Product2Id, memberPartEntry.BWC_BasePrice__c);
                    System.debug('existingMemberPartsProductMap' + existingMemberPartsProductMap);
             }

            Map<Id,Decimal> existingSubscriptionsAndCarePlanProductMap = new Map<Id,Decimal>();
            for (PricebookEntry memberSCPEntry : existingSubscriptionsAndCarePlanMemberEntries) {  
                existingSubscriptionsAndCarePlanProductMap.put(memberSCPEntry.Product2Id, memberSCPEntry.BWC_BasePrice__c);
                    System.debug('existingSubscriptionsAndCarePlanProductMap' + existingSubscriptionsAndCarePlanProductMap);
            }

            List<PricebookEntry> entriesToCreate = new List<PricebookEntry>();
            List<PricebookEntry> entriesToUpdate = new List<PricebookEntry>();
            for (PricebookEntry entry : basepricebookEntries) 
            {                    
                if (!existingMemberProductMap.containsKey(entry.Product2Id) ) 
                {                        
                    PricebookEntry memberEntry = new PricebookEntry();
                    memberEntry.BWC_BasePrice__c = entry.UnitPrice;
                        //System.debug('memberEntry.BWC_BasePrice__c' + memberEntry.BWC_BasePrice__c );
                    memberEntry.Product2Id = entry.Product2Id;
                        //System.debug('memberEntry.Product2Id ' + memberEntry.Product2Id);
                    memberEntry.IsActive = entry.IsActive;
                        //System.debug('memberEntry.IsActive ' + memberEntry.IsActive);
                    memberEntry.Pricebook2Id = memberPriceBookId;
                    if (entry.Product2.Is_Finished_Good__c == 'Yes' && entry.Product2.Is_Accessory__c == 'No') {
                        Decimal discountPercentage = fgDiscount;
                        memberEntry.BWC_FG_Discount_Percentage__c = discountPercentage;
                        memberEntry.UnitPrice = entry.UnitPrice * (1 - discountPercentage);
                        System.debug('@@@ Create Updated Unit Price (FG): ' + memberEntry.UnitPrice + ', discountPercentage: ' + memberEntry.BWC_FG_Discount_Percentage__c);
                    } else if (entry.Product2.Is_Finished_Good__c=='Yes' && entry.Product2.Is_Accessory__c=='Yes') {
                        Decimal discountPercentage = accessoryDiscount;
                        memberEntry.BWC_Accessory_Discount_Percentage__c = discountPercentage;
                        memberEntry.UnitPrice = entry.UnitPrice * (1 - discountPercentage);
                            System.debug('@@@Create Updated Unit Price (Accessory): ' + memberEntry.UnitPrice + ', discountPercentage: ' + memberEntry.BWC_Accessory_Discount_Percentage__c);
                    } 
                    /*else if (entry.Product2.Is_Finished_Good__c=='No' && entry.Product2.Is_Accessory__c=='No') {
                        Decimal discountPercentage = partsDiscount;
                        memberEntry.BWC_Parts_Discount_Percentage__c = discountPercentage;
                        memberEntry.UnitPrice = entry.UnitPrice * (1 - discountPercentage);                            
                            System.debug('@@@Create Updated Unit Price (Parts): ' + memberEntry.UnitPrice + ', discountPercentage: ' + memberEntry.BWC_Parts_Discount_Percentage__c);
                    }*/
                    else{
                        memberEntry.UnitPrice=entry.UnitPrice;
                        System.debug('@@@Created without any price condition' + memberEntry.UnitPrice);
                    }

                    entriesToCreate.add(memberEntry);
                    System.debug('@@@entriesToCreate: ' + entriesToCreate);

                } 
                
                else 
                {                       
                    for (PricebookEntry memberEntry : existingMemberEntries) {
                        if((existingMemberProductMap.get(memberEntry.Product2Id) != basePriceBookProductMap.get(entry.Product2Id)) || (memberEntry.BWC_FG_Discount_Percentage__c != fgDiscount || memberEntry.BWC_Accessory_Discount_Percentage__c != accessoryDiscount)){
                        memberEntry.BWC_BasePrice__c = entry.UnitPrice;    
                        memberEntry.IsActive = entry.IsActive;
                        if (memberEntry.Product2Id == entry.Product2Id) 
                    {   
                        if (entry.Product2.Is_Finished_Good__c == 'Yes' && entry.Product2.Is_Accessory__c == 'No') {
                            Decimal discountPercentage = fgDiscount;
                            memberEntry.BWC_FG_Discount_Percentage__c = discountPercentage;
                            memberEntry.UnitPrice = entry.UnitPrice * (1 - discountPercentage);
                        System.debug('@@@Updated Unit Price (FG): ' + memberEntry.UnitPrice + ', discountPercentage: ' + memberEntry.BWC_FG_Discount_Percentage__c);
                        } 
                        else if (entry.Product2.Is_Finished_Good__c=='Yes' && entry.Product2.Is_Accessory__c=='Yes') {
                            Decimal discountPercentage = accessoryDiscount;
                            memberEntry.BWC_Accessory_Discount_Percentage__c = discountPercentage;
                            memberEntry.UnitPrice = entry.UnitPrice * (1 - discountPercentage);
                            System.debug('@@@Updated Unit Price (Accessory): ' + memberEntry.UnitPrice+ ', discountPercentage: ' + memberEntry.BWC_Accessory_Discount_Percentage__c);
                        } 
                        /*else if (entry.Product2.Is_Finished_Good__c=='No' && entry.Product2.Is_Accessory__c=='No') {
                        Decimal discountPercentage = partsDiscount;
                        memberEntry.BWC_Parts_Discount_Percentage__c = discountPercentage;
                        memberEntry.UnitPrice = entry.UnitPrice * (1 - discountPercentage);
                            System.debug('@@@Updated Unit Price (Parts): ' + memberEntry.UnitPrice+ ', discountPercentage: ' + memberEntry.BWC_Parts_Discount_Percentage__c);
                        } */
                    
                        else
                        {
                                memberEntry.UnitPrice=entry.UnitPrice;
                                System.debug('@@@Updated without any price condition' + memberEntry.UnitPrice);
                        }

                            entriesToUpdate.add(memberEntry);
                            System.debug('@@@entriesToUpdate: ' + entriesToUpdate);                                                             
                            break;

                    }
                    }
                }
            }                   
        
            }

        //Parts Price Books
            for (PricebookEntry partsEntry : basePartspricebookEntries) 
            {                    
                if (!existingMemberPartsProductMap.containsKey(partsEntry.Product2Id) ) 
                {                        
                    PricebookEntry memberPartsEntry = new PricebookEntry();
                    memberPartsEntry.BWC_BasePrice__c = partsEntry.UnitPrice;
                        //System.debug('memberPartsEntry.BWC_BasePrice__c' + memberPartsEntry.BWC_BasePrice__c );
                        memberPartsEntry.Product2Id = partsEntry.Product2Id;
                        //System.debug('memberPartsEntry.Product2Id ' + memberPartsEntry.Product2Id);
                        memberPartsEntry.IsActive = partsEntry.IsActive;
                        //System.debug('memberPartsEntry.IsActive ' + memberPartsEntry.IsActive);
                        memberPartsEntry.Pricebook2Id = memberPartsPriceBookId;
                    //if (entry.Product2.Is_Finished_Good__c=='No' && entry.Product2.Is_Accessory__c=='No' && entry.Product2.Status__c != 'Obsolete' && entry.Product2.BWC_Is_Part__c == true) {
                    if (partsEntry.Product2.BWC_Is_Part__c == true) {
                        Decimal discountPercentage = partsDiscount;
                        memberPartsEntry.BWC_Parts_Discount_Percentage__c = discountPercentage;
                        memberPartsEntry.UnitPrice = partsEntry.UnitPrice * (1 - discountPercentage);                            
                            System.debug('@@@Create Updated Unit Price (Parts): ' + memberPartsEntry.UnitPrice + ', discountPercentage: ' + memberPartsEntry.BWC_Parts_Discount_Percentage__c);
                    }
                    else{
                        memberPartsEntry.UnitPrice=partsEntry.UnitPrice;
                    System.debug('@@@Created without any price condition' + memberPartsEntry.UnitPrice);
                    }
                    entriesToCreate.add(memberPartsEntry);
                        System.debug('@@@entriesToCreate: ' + entriesToCreate);
                } 
                else 
                {                       
                    for (PricebookEntry memberPartsEntry : existingPartsMemberEntries) 
                    {
                        if((existingMemberPartsProductMap.get(memberPartsEntry.Product2Id) != partsBasePriceBookProductMap.get(partsEntry.Product2Id)) || memberPartsEntry.BWC_Parts_Discount_Percentage__c != partsDiscount ){
                        memberPartsEntry.BWC_BasePrice__c = partsEntry.UnitPrice;    
                        memberPartsEntry.IsActive = partsEntry.IsActive;
                        if (memberPartsEntry.Product2Id == partsEntry.Product2Id) {   
                        //if (entry.Product2.Is_Finished_Good__c=='No' && entry.Product2.Is_Accessory__c=='No' && entry.Product2.Status__c != 'Obsolete' && entry.Product2.BWC_Is_Part__c == true) {
                         if (partsEntry.Product2.BWC_Is_Part__c == true) {
                        Decimal discountPercentage = partsDiscount;
                        memberPartsEntry.BWC_Parts_Discount_Percentage__c = discountPercentage;
                        memberPartsEntry.UnitPrice = partsEntry.UnitPrice * (1 - discountPercentage);
                        System.debug('@@@Updated Unit Price (Parts): ' + memberPartsEntry.UnitPrice+ ', discountPercentage: ' + memberPartsEntry.BWC_Parts_Discount_Percentage__c);
                        }
                    
                        else
                        {
                            memberPartsEntry.UnitPrice=partsEntry.UnitPrice;
                            System.debug('@@@Updated without any price condition' + memberPartsEntry.UnitPrice);
                        }
                            entriesToUpdate.add(memberPartsEntry);
                            System.debug('@@@entriesToUpdate: ' + entriesToUpdate);                                                               
                            break;
                        }
                    }
                }
            }   
            }
        //Subscription & CarePlans PriceBook
        for (PricebookEntry scpEntry : subscriptionAndCarePlansPricebookEntries) 
        {                    
            if (!existingSubscriptionsAndCarePlanProductMap.containsKey(scpEntry.Product2Id) ) 
            {                        
                PricebookEntry memberSCPEntry = new PricebookEntry();
                memberSCPEntry.BWC_BasePrice__c = scpEntry.UnitPrice;
                    //System.debug('memberPartsEntry.BWC_BasePrice__c' + memberPartsEntry.BWC_BasePrice__c );
                    memberSCPEntry.Product2Id = scpEntry.Product2Id;
                    //System.debug('memberPartsEntry.Product2Id ' + memberPartsEntry.Product2Id);
                    memberSCPEntry.IsActive = scpEntry.IsActive;
                    //System.debug('memberPartsEntry.IsActive ' + memberPartsEntry.IsActive);
                    memberSCPEntry.Pricebook2Id = memberSubscriptionsCarePlanPriceBookId;
                //if (entry.Product2.Is_Finished_Good__c=='No' && entry.Product2.Is_Accessory__c=='No' && entry.Product2.Status__c != 'Obsolete' && entry.Product2.BWC_Is_Part__c == true) {
                if ((scpEntry.Product2.Item_Type__c == 'SERVICE CONTRACT' || scpEntry.Product2.Item_Type__c == 'SW LIC') && (scpEntry.Product2.StockKeepingUnit.contains('PROTECTION PLAN') || scpEntry.Product2.StockKeepingUnit.contains('REPLACEMENT PLAN'))){
                    Decimal discountPercentage = protectionPlanDiscount;
                    memberSCPEntry.BWC_Protection_Plan_Discount_Percentage__c = discountPercentage;
                    memberSCPEntry.UnitPrice = scpEntry.UnitPrice * (1 - discountPercentage);                            
                    System.debug('@@@Create Updated Unit Price (SCP): ' + memberSCPEntry.UnitPrice + ', discountPercentage: ' + memberSCPEntry.BWC_Protection_Plan_Discount_Percentage__c);
                }
                else{
                    memberSCPEntry.UnitPrice=scpEntry.UnitPrice;
                System.debug('@@@Created without any price condition SCP' + memberSCPEntry.UnitPrice);
                }
                entriesToCreate.add(memberSCPEntry);
                    System.debug('@@@entriesToCreate SCP: ' + entriesToCreate);
            } 
            else 
            {                       
                for (PricebookEntry memberSandCPEntry : existingSubscriptionsAndCarePlanMemberEntries) 
                {
                    if((existingSubscriptionsAndCarePlanProductMap.get(memberSandCPEntry.Product2Id) != subscriptionsAndCarePlansPricebookProductMap.get(scpEntry.Product2Id)) || memberSandCPEntry.BWC_Protection_Plan_Discount_Percentage__c != protectionPlanDiscount ){
                        memberSandCPEntry.BWC_BasePrice__c = scpEntry.UnitPrice;    
                        memberSandCPEntry.IsActive = scpEntry.IsActive;
                    if (memberSandCPEntry.Product2Id == scpEntry.Product2Id) {   
                    if ((scpEntry.Product2.Item_Type__c == 'SERVICE CONTRACT' || scpEntry.Product2.Item_Type__c == 'Contracts - KIT') && (scpEntry.Product2.StockKeepingUnit.contains('PROTECTION PLAN') || scpEntry.Product2.StockKeepingUnit.contains('REPLACEMENT PLAN'))){
                    Decimal discountPercentage = protectionPlanDiscount;
                    memberSandCPEntry.BWC_Protection_Plan_Discount_Percentage__c = discountPercentage;
                    memberSandCPEntry.UnitPrice = scpEntry.UnitPrice * (1 - discountPercentage);
                    System.debug('@@@Updated Unit Price (SCP): ' + memberSandCPEntry.UnitPrice+ ', discountPercentage: ' + memberSandCPEntry.BWC_Protection_Plan_Discount_Percentage__c);
                    }
                
                    else
                    {
                        memberSandCPEntry.UnitPrice=scpEntry.UnitPrice;
                        System.debug('@@@Updated without any price condition SCP' + memberSandCPEntry.UnitPrice);
                    }
                        entriesToUpdate.add(memberSandCPEntry);
                        System.debug('@@@entriesToUpdate: SCP ' + entriesToUpdate);                                                               
                        break;
                    }
                }
            }
            }
        }  
    
          


if (!entriesToCreate.isEmpty())
    {
        try {
            Database.SaveResult[] insertResults = Database.insert(entriesToCreate, false);
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
                
    if (!entriesToUpdate.isEmpty()) 
    {
        try {
            Database.SaveResult[] updateResults = Database.update(entriesToUpdate, false);
                System.debug('updateResults' + updateResults);
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
        
        
    public void finish(Database.BatchableContext context) 
    {
            // Perform any post-processing if required
                            
    } 
    
}