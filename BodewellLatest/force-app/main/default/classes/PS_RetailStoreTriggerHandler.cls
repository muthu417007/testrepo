public class PS_RetailStoreTriggerHandler implements PS_ITriggerHandler {

    public static Boolean TriggerDisabled = false;
    public static final Integer NUMBER_OF_MONTH_TO_CHECK = 13;

    public Boolean IsDisabled () {
        return TriggerDisabled;
    }

    public void beforeInsert(List<SObject> newItems) {
    }

    public void afterInsert(List<SObject> newItems) {

    }

    public void beforeDelete(Map<Id, SObject> oldItems) {
        Map<Id, RetailStore> idToRetailStoreOldMap = (Map<Id, RetailStore>) oldItems;
        Set<Id> retailStoreIds = idToRetailStoreOldMap.keySet();
        Map<Id, PS_RetailStoreTriggerHandler.DeletedRetailStoreData> retailStoreIdToDeletedRetailStoreMap =
            new Map<Id, PS_RetailStoreTriggerHandler.DeletedRetailStoreData>();
        Set<Id> retialStoreIdsAreConfirmedToDelete = new Set<Id>();

        for (Id retailStoreId : idToRetailStoreOldMap.keySet()) {

            retailStoreIdToDeletedRetailStoreMap.put(
                retailStoreId,
                new PS_RetailStoreTriggerHandler.DeletedRetailStoreData(retailStoreId)
            );
        }

        String visitsCreatedInLastMonthsQuery = 'SELECT Name, PlaceId, Showroom_Display_Location__c, CreatedDate '
            + 'FROM Visit '
            + 'WHERE PlaceId IN :retailStoreIds '
                + 'AND CreatedDate >= LAST_N_MONTHS:' + String.valueOf(NUMBER_OF_MONTH_TO_CHECK);

        String storeProductsUpdatedInLastMonthsQuery = 'SELECT Name, RetailStoreId, Showroom_Display_Location__c, LastModifiedDate '
            + 'FROM StoreProduct '
            + 'WHERE RetailStoreId IN :retailStoreIds '
                + 'AND LastModifiedDate >= LAST_N_MONTHS:' + String.valueOf(NUMBER_OF_MONTH_TO_CHECK);

        for (Visit visitCreatedInLastMonths : Database.query(visitsCreatedInLastMonthsQuery)) {
            retailStoreIdToDeletedRetailStoreMap.get(
                visitCreatedInLastMonths.PlaceId
            ).hasVisitsHaveBeenCreatedInLastMonths = true;
        }

        for (StoreProduct storeProductUpdatedInLastMonths : Database.query(storeProductsUpdatedInLastMonthsQuery)) {
            retailStoreIdToDeletedRetailStoreMap.get(
                storeProductUpdatedInLastMonths.RetailStoreId
            ).hasStoreProductsHaveBeenUpdatedInLastMonths = true;
        }

        for (Id deletedRetailStoreId : retailStoreIdToDeletedRetailStoreMap.keySet()) {
            PS_RetailStoreTriggerHandler.DeletedRetailStoreData deletedRetailStoreData =
                retailStoreIdToDeletedRetailStoreMap.get(deletedRetailStoreId);

            String errorMessage = '';
            if (deletedRetailStoreData.hasVisitsHaveBeenCreatedInLastMonths) {
                errorMessage += String.format(
                    Label.PS_CANNOT_DELETE_RETAIL_STORE_WITH_ASSOCIATED_VISITS,
                    new List<String>{
                        Schema.RetailStore.getSObjectType().getDescribe().getLabel(),
                        Schema.Visit.getSObjectType().getDescribe().getLabelPlural(),
                        String.valueOf(NUMBER_OF_MONTH_TO_CHECK)
                    }
                );
            }
            if (deletedRetailStoreData.hasStoreProductsHaveBeenUpdatedInLastMonths) {
                if (String.isNotBlank(errorMessage)) {
                    errorMessage += ' ';
                }
                errorMessage += String.format(
                    Label.PS_CANNOT_DELETE_RETAIL_STORE_WITH_ASSOCIATED_STORE_PRODUCTS,
                    new List<String>{
                        Schema.RetailStore.getSObjectType().getDescribe().getLabel(),
                        Schema.StoreProduct.getSObjectType().getDescribe().getLabelPlural(),
                        String.valueOf(NUMBER_OF_MONTH_TO_CHECK)
                    }
                );
            }

            if (String.isNotBlank(errorMessage)) {
                idToRetailStoreOldMap.get(deletedRetailStoreId).addError(errorMessage);
            } else {
                retialStoreIdsAreConfirmedToDelete.add(deletedRetailStoreId);
            }
        }

        deleteAssociatedVisistsAndStoreProducts(retialStoreIdsAreConfirmedToDelete);
    }

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    }

    public void afterDelete(Map<Id, SObject> oldItems) {
    }

    private void deleteAssociatedVisistsAndStoreProducts(Set<Id> retialStoreIds) {
        if (retialStoreIds.isEmpty()) {
            return;
        }

        List<Visit> visitsToDelete = [
            SELECT Name, PlaceId, Showroom_Display_Location__c
            FROM Visit
            WHERE PlaceId IN :retialStoreIds
        ];

        List<StoreProduct> storeProductsToDelete = [
            SELECT Name, RetailStoreId, Showroom_Display_Location__c
            FROM StoreProduct
            WHERE RetailStoreId IN :retialStoreIds
        ];

        delete visitsToDelete;
        delete storeProductsToDelete;
    }

    class DeletedRetailStoreData {

        Id retailStoreId;
        Boolean hasVisitsHaveBeenCreatedInLastMonths = false;
        Boolean hasStoreProductsHaveBeenUpdatedInLastMonths = false;

        DeletedRetailStoreData(Id retailStoreId) {
            this.retailStoreId = retailStoreId;
        }

    }

}