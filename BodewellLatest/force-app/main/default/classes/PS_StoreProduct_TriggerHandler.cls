public class PS_StoreProduct_TriggerHandler implements PS_ITriggerHandler {
    
    public static Boolean TriggerDisabled = false;
    
    public Boolean IsDisabled() {
        return TriggerDisabled;
    }

    public void beforeInsert(List<SObject> newItems) {
    }

    public void afterInsert(List<SObject> newItems) {
        Set<Id> parentShowroomIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> storeProductIds = new Set<Id>();
        for (StoreProduct sp : (List<StoreProduct>) newItems) {
            parentShowroomIds.add(sp.Showroom_Display_Location__c);
            accountIds.add(sp.Account__c);
            storeProductIds.add(sp.Id);
        }
        updateRetailStoreCounts(parentShowroomIds);
    }
   
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    }
    
    public void beforeDelete(Map<Id, SObject> oldItems) {      
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Set<Id> parentShowroomIds = new Set<Id>();
        Map<Id, StoreProduct> triggerOld = (Map<Id, StoreProduct>)oldItems;
        Map<Id, StoreProduct> triggerNew = (Map<Id, StoreProduct>)newItems;
        List<bypassTrigger__mdt> mcs = bypassTrigger__mdt.getall().values();
        for (StoreProduct sp : triggerNew.values()) {
            if(sp.Showroom_Display_Location__c != triggerOld.get(sp.Id).Showroom_Display_Location__c
                || sp.ProductId != triggerOld.get(sp.Id).ProductId
                || sp.IsActive__c != triggerOld.get(sp.Id).IsActive__c || mcs[0].bypassCriteria__c ==True)//Added metadata check for mass updating the historical records without modifying any data in those records.
            {
                   parentShowroomIds.add(sp.Showroom_Display_Location__c);
               }
        }
        updateRetailStoreCounts(parentShowroomIds);        
    }
    
    public void afterDelete(Map<Id, SObject> oldItems) {
        Set<Id> parentShowroomIds = new Set<Id>();
        Map<Id, StoreProduct> triggerOld = (Map<Id, StoreProduct>)oldItems;
        for (StoreProduct sp : triggerOld.values()) {
            parentShowroomIds.add(sp.Showroom_Display_Location__c);   
        }
        updateRetailStoreCounts(parentShowroomIds);        
    }
    
    private void updateRetailStoreCounts (Set<Id> retailStoreIds) {
        Integer competitiveProducts;
        Integer geaProducts;
        RetailStore[] retailStoresToUpdate = new List<RetailStore>();
        for (RetailStore rs : [SELECT Count_All_Products__c, Count_Competitive_Products__c, Count_GEA_Products__c, (SELECT Product.Is_GEA_Product__c FROM Store_Products__r WHERE IsActive__c = true) FROM RetailStore WHERE Id IN :retailStoreIds]) {
 
            competitiveProducts = 0;
            geaProducts = 0;
            
            for (StoreProduct sp : rs.Store_Products__r) {
                if(sp.Product.Is_GEA_Product__c == 'Yes') {
                    geaProducts++;
                } else {
                    competitiveProducts++;
                }
            }
            

            if (rs.Count_All_Products__c != geaProducts + competitiveProducts
               || rs.Count_Competitive_Products__c != competitiveProducts
               || rs.Count_GEA_Products__c != geaProducts) {
                rs.Count_All_Products__c = geaProducts + competitiveProducts;
                rs.Count_Competitive_Products__c = competitiveProducts;
                rs.Count_GEA_Products__c = geaProducts;
                retailStoresToUpdate.add(rs);
            }
        }
        
        if(!retailStoresToUpdate.isEmpty()) {
            update retailStoresToUpdate;    
        }  
    }
}