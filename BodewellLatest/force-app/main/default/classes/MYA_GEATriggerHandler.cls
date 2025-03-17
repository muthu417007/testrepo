/**
 * @author         Akhil Raj
 * @company        TCS
 * @created        08.08.2022
 * @description    Apex trigger handler for GEA Asset Object
 */
public class MYA_GEATriggerHandler implements PS_ITriggerHandler {  
    
    public static Boolean TriggerDisabled = false;
    
    public Boolean IsDisabled() {
        return TriggerDisabled;
    }
    
    public void beforeInsert(List<SObject> newItems) 
    {
        List<GEA_Asset__c> assetItems = (List<GEA_Asset__c>) newItems;
        for(GEA_Asset__c asset: assetItems) 
        {
            if(asset.OriginalModelNumber__c != Null)
            {
                List <Model_Rel__c> MnModelRelList = [SELECT Id, MN__c, MR_PKMOD__c FROM Model_Rel__c WHERE MN__c=:asset.OriginalModelNumber__c];
                if(MnModelRelList.size() > 0) 
                {
                    asset.OriginalEngineeringModelNumber__c = asset.OriginalModelNumber__c;
                    asset.Model_Number__c = MnModelRelList[0].MR_PKMOD__c;
                    asset.ModelValidityFlag__c = true;
                } 
                else 
                {
                    List <Model_Rel__c> MrModelRelList = [SELECT Id, MN__c, MR_PKMOD__c FROM Model_Rel__c WHERE MR_PKMOD__c=:asset.OriginalModelNumber__c];
                    if(MrModelRelList.size() > 0) 
                    {
                        asset.Model_Number__c = asset.OriginalModelNumber__c;
                        asset.ModelValidityFlag__c = true;
                    } 
                    else 
                    {
                        asset.ModelValidityFlag__c = false;
                    }
                } 
                String ModelNumberStr = asset.OriginalModelNumber__c; 
                asset.BrandName__c = System.Label.MYA_Unknown_BrandCode;
                asset.Product_Line__c = System.Label.MYA_Unknown_Product_Line_Code;
                Boolean IsFound = false;
                do 
                {
                    List <SMCModelCA__c> SMCModelList = [SELECT Id, Brand_Code__c, Product_Line_Code__c FROM SMCModelCA__c WHERE Model_No__c=:ModelNumberStr];
                    if(SMCModelList.size() > 0) 
                    {
                        asset.BrandName__c = SMCModelList[0].Brand_Code__c;
                        asset.Product_Line__c = SMCModelList[0].Product_Line_Code__c;
                        IsFound = true;
                    }
                    ModelNumberStr = ModelNumberStr.left(ModelNumberStr.length()-1);
                } while (!IsFound && ModelNumberStr.length() > 2);
            }
        }
    }

    public void afterInsert(List<SObject> newItems) {}

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}

    public void beforeDelete(Map<Id, SObject> oldItems) {}

    public void afterDelete(Map<Id, SObject> oldItems) {}
}