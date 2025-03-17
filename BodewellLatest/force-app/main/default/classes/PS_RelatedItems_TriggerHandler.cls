/**Class Name: PS_RelatedItems_TriggerHandler
 * Description: W-000227 - Populate NPI Fields Based on Related Items
 * Created By: PolSource
 * Author: Michał Warzecha
 * Created Date: 03.Dec.2020
*/
public class PS_RelatedItems_TriggerHandler implements PS_ITriggerHandler {

    public static Boolean TriggerDisabled = false;

    /*-----------------------------------------------------------
    Author: Michał Warzecha
    Company: PolSource
    Description: Check if triggers are disabled
    Created Date: 03.Dec.2020
    ------------------------------------------------------------*/
    public Boolean IsDisabled() {
        return TriggerDisabled;
    }

    /*-----------------------------------------------------------
    Author: Michał Warzecha
    Company: PolSource
    Description: Method overriden from PS_ITriggerHandler interface
    Created Date: 03.Dec.2020
    ------------------------------------------------------------*/
    public void beforeInsert(List<SObject> newItems) {}

    /*-----------------------------------------------------------
    Author: Michał Warzecha
    Company: PolSource
    Description: Method overriden from PS_ITriggerHandler interface
    Created Date: 03.Dec.2020
    ------------------------------------------------------------*/
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}

    /*-----------------------------------------------------------
    Author: Michał Warzecha
    Company: PolSource
    Description: Method required by PS_ITriggerHandler interface
    Created Date: 03.Dec.2020
    ------------------------------------------------------------*/
    public void beforeDelete(Map<Id, SObject> oldItems) {}


    /*-----------------------------------------------------------
    Author: Michał Warzecha
    Company: PolSource
    Description: Method required by PS_ITriggerHandler interface
    Created Date: 03.Dec.2020
    ------------------------------------------------------------*/
    public void afterDelete(Map<Id, SObject> oldItems) {
        updateProductNPITransition((List<Related_Items__c>) oldItems.values());
    }

    /*-----------------------------------------------------------
    Author: Michał Warzecha
    Company: PolSource
    Description: Method required by PS_ITriggerHandler interface
    Created Date: 03.Dec.2020
    ------------------------------------------------------------*/
    public void afterInsert(List<SObject> newItems) {
        updateProductNPITransition(newItems);
    }

    /*-----------------------------------------------------------
    Author: Michał Warzecha
    Company: PolSource
    Description: Method required by PS_ITriggerHandler interface
    Created Date: 03.Dec.2020
    ------------------------------------------------------------*/
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        if(newItems != null && newItems.size()>0) {
            updateProductNPITransition((List<Related_Items__c>)newItems.values());
        }
    }


    /*-----------------------------------------------------------
    Company: PolSource
    Description: W-000227 Populate NPI Fields Based on Related Items
                 This method has been copied from historical implementation
    Created Date: 03.Dec.2020
    ------------------------------------------------------------*/
    //Update Product NPI Transition Values
    private static void updateProductNPITransition(List<Related_Items__c> lstPRel){

        //Remaining Not Accessible Products Update
        Map<Id, Id> mapRemainPrd = new Map<Id, Id>();

        //Getting unique Products to update
        Set<id> parentProductIds = new Set<Id>();
        for (Related_Items__c tmpPRel : lstPRel) {
            if (tmpPRel.Product__c != null) {
                parentProductIds.add(tmpPRel.Product__c);
                mapRemainPrd.put(tmpPRel.Product__c, tmpPRel.Product__c);
            }
        }

        if (parentProductIds.isEmpty()) {
            return;
        }

        //Get All ProductRelationship of Associated Products
        List<Related_Items__c>  lstPrdPRel = [
            SELECT Product__c, Product__r.Name, Product__r.Retail_NPI_Transition__c, Product__r.Retail_NPI_Transition__r.Name,
                Product__r.Retail_Additional_NPI_Transitions__c, Product__r.Retail_Transition_Date__c,
                Product__r.Contract_NPI_Transition__c, Product__r.Contract_NPI_Transition__r.Name,
                Product__r.Contract_Additional_NPI_Transitions__c, Product__r.Contract_Transition_Date__c,
                Related_Product__c, Related_Product__r.Name, Channel__c, Sales_Relationship_Type__c , Start_Date__c, End_Date__c
            FROM Related_Items__c
            WHERE Product__c IN :parentProductIds
            ORDER BY Product__r.Name, CreatedDate
        ];

        //Logic to update NPI Transition values in Product Always
        Id prevPrdId = null;
        Id currPrdId = null;
        Product2 tmpPrd = null;
        List<Product2> lstUpdPrd = new List<Product2>();
        Integer retailPos = 0;
        Integer contractPos = 0;
        Boolean oneOfReleatedItemForCurrentProductHasBlankEndDate = false;
        Integer i = 0;

        //Looping through each Product Relationship and prepare Product NPI Transition Values
        for (Related_Items__c PRel : lstPrdPRel) {
            currPrdId = PRel.Product__c;

            if (prevPrdId != null && (prevPrdId != currPrdId)) {
                lstUpdPrd.add(tmpPrd);
                mapRemainPrd.remove(tmpPrd.Id);
                prevPrdId = null;
                retailPos = 0;
                contractPos = 0;
            }

            if (prevPrdId == null) {
                prevPrdId = currPrdId;
                tmpPrd = new Product2();
                tmpPrd.Id = PRel.Product__c;
                tmpPrd.Retail_NPI_Transition__c = NULL;
                tmpPrd.Retail_Additional_NPI_Transitions__c = '';
                tmpPrd.Retail_Transition_Date__c = NULL;

                tmpPrd.Contract_NPI_Transition__c = NULL;
                tmpPrd.Contract_Additional_NPI_Transitions__c = '';
                tmpPrd.Contract_Transition_Date__c = NULL;
            }

            //Checking relationship, accept only "Superseded" and End Date is blank
            String strRel = PRel.Sales_Relationship_Type__c;

            Boolean npiFieldsShouldBePopulated = (
                String.isNotBlank(strRel)
                && 'Superseded'.equalsIgnoreCase(strRel)
                && PRel.End_Date__c == null
            );
            if (npiFieldsShouldBePopulated) {
                String strChannel = String.isBlank(PRel.Channel__c)
                    ? 'Contract; Retail'
                    : PRel.Channel__c;

                //Retail
                if (strChannel.containsIgnoreCase('Retail')) {
                    if (retailPos == 0) {
                        tmpPrd.Retail_NPI_Transition__c = PRel.Related_Product__c;
                        tmpPrd.Retail_Transition_Date__c = PRel.Start_Date__c; //Need to check
                    }
                    if (retailPos == 1) {
                        tmpPrd.Retail_Additional_NPI_Transitions__c = PRel.Related_Product__r.Name;
                    }
                    if (retailPos > 1) {
                        tmpPrd.Retail_Additional_NPI_Transitions__c = tmpPrd.Retail_Additional_NPI_Transitions__c + ', '+PRel.Related_Product__r.Name;
                    }
                    retailPos++;
                }

                //Contract
                if (strChannel.containsIgnoreCase('Contract')) {
                    if (contractPos == 0) {
                        tmpPrd.Contract_NPI_Transition__c = PRel.Related_Product__c;
                        tmpPrd.Contract_Transition_Date__c = PRel.Start_Date__c; //Need to check
                    }
                    if (contractPos == 1) {
                        tmpPrd.Contract_Additional_NPI_Transitions__c = PRel.Related_Product__r.Name;
                    }
                    if (contractPos > 1) {
                        tmpPrd.Contract_Additional_NPI_Transitions__c = tmpPrd.Contract_Additional_NPI_Transitions__c + ', '+PRel.Related_Product__r.Name;
                    }
                    contractPos++;
                }
            }
            i++;

            if (i == lstPrdPRel.size()) {
                lstUpdPrd.add(tmpPrd);
                mapRemainPrd.remove(tmpPrd.Id);
            }
        }

        if (mapRemainPrd != null && !mapRemainPrd.isEmpty()) {
            List<Id> lstRemainPrd = (List<Id>) mapRemainPrd.values();
            for(Id idVal : lstRemainPrd){
                tmpPrd = new Product2();
                tmpPrd.Id = idVal;
                tmpPrd.Retail_NPI_Transition__c = NULL;
                tmpPrd.Retail_Additional_NPI_Transitions__c = '';
                tmpPrd.Retail_Transition_Date__c = NULL;

                tmpPrd.Contract_NPI_Transition__c = NULL;
                tmpPrd.Contract_Additional_NPI_Transitions__c = '';
                tmpPrd.Contract_Transition_Date__c = NULL;
                lstUpdPrd.add(tmpPrd);
            }
        }

        update lstUpdPrd;
    }

}