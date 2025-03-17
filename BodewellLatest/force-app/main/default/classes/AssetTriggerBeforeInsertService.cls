/**
 * @author         Sukumar Venkatesan
 * @company        GEA
 * @created        06.Nov.2022
 * @description    This is service class for Asset trigger on Before Insert trigger event.
					It contains all the methods which are called in before insert trigger event
 */
public class AssetTriggerBeforeInsertService {
    
    Public static void invokeReferenceObject(List<Asset> newAssets){
    	List<Asset> assetItems = (List<Asset>) newAssets;
        set<string> originalModelNumber = new set<string>();
        set<string> uniqueModel = new set<string>();
        for(Asset asset: assetItems) 
        {
         originalModelNumber.add(asset.OriginalModelNumber__c);   
        }
        //Prod_Rel table query logic starts
        List <Model_Rel__c> mnModelRelList1 = [SELECT Id, MN__c, MR_PKMOD__c FROM Model_Rel__c WHERE MN__c in:originalModelNumber];
        List <Model_Rel__c> mrModelRelList2 = [SELECT Id, MN__c, MR_PKMOD__c FROM Model_Rel__c WHERE MR_PKMOD__c in:originalModelNumber];

        for(Asset asset:assetItems){
            Boolean mnMatchFound = false;
            Boolean mrMatchFound = false;
            for(Model_Rel__c mr:mnModelRelList1){
                if (mr.MN__c == asset.OriginalModelNumber__c){
                    asset.OriginalEngineeringModelNumber__c = asset.OriginalModelNumber__c;
                    asset.Model_Number__c = mr.MR_PKMOD__c;
                    asset.ModelValidityFlag__c = true;
                    mnMatchFound = true;
                }
            }//end of mn match criteria
            if(!mnMatchFound){
            	for(Model_Rel__c mr:mrModelRelList2){
                    if (mr.MR_PKMOD__c == asset.OriginalModelNumber__c){
                        asset.Model_Number__c = asset.OriginalModelNumber__c;
                        asset.ModelValidityFlag__c = true;
                        mrMatchFound = true;
                   	}
            	}//end of mr match criteria   
                if(!mnMatchFound && !mrMatchfound){
                	asset.ModelValidityFlag__c = false;    
                }	
            if(asset.Model_Number__c != ''){
                uniqueModel.add(asset.Model_Number__c);
            }
			            
            }
            //end of Prod_Rel table logic
            //SMC table query logic starts
            String ModelNumberStr = asset.OriginalModelNumber__c;            
            Boolean isFound = false;
            do 
            {
            	List <SMCModelCA__c> SMCModelList = [SELECT Id, Brand_Code__c, Product_Line_Code__c FROM SMCModelCA__c WHERE Model_No__c=:ModelNumberStr];
                if(SMCModelList.size() > 0) 
                {
                	asset.BrandName__c = SMCModelList[0].Brand_Code__c;
                    asset.Product_Line__c = SMCModelList[0].Product_Line_Code__c;
                    isFound = true;
                 }
                    ModelNumberStr = ModelNumberStr.left(ModelNumberStr.length()-1);
             } while (!isFound && ModelNumberStr.length() > 2);
            //end of SMC table logic
            
        }
        //Start logic to populate Product based on model_number
        if(uniqueModel.size()>0){
        	List <Product2> productList = [SELECT Id, stockKeepingUnit,isActive FROM Product2 WHERE stockKeepingUnit in:uniqueModel and isActive = true];
            	for(Asset ass:assetItems){
		        	for(Product2 Pl:productList){
                    	if(ass.Model_Number__c == pl.stockKeepingUnit){
                        	ass.Product2Id = pl.Id;    
                        }
                    }
                }
            }//End of Product population
            
}
}