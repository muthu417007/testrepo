public without sharing class GenerateFgAndPartsAvailabilityJSON{
    /**
   * @description created by : Satya Reddy
   * This class is to call generate the JSON structure forGOP FG AND Parts Availability
   * Test class : GenerateFgAndPartsAvailabilityJSONTest
	*/
    
    public class FgAndPartsAvailabilityItem {
        @AuraEnabled
        public Integer orderLineIdentifier { get; set; }
        @AuraEnabled
        public String inventoryItemName { get; set; }
        @AuraEnabled
        Public Integer quantityOrdered { get; set; }
        @AuraEnabled
        public String requestDate { get; set; }
        @AuraEnabled
        public String quantityUOM { get; set; }
        @AuraEnabled
        public String zipCode { get; set; }
        @AuraEnabled
        public String accountNumber { get; set; }
        @AuraEnabled
        public String itemType { get; set; }
        @AuraEnabled
        public String shipSetName { get; set; }
        
        public FgAndPartsAvailabilityItem(){
            
        }        
       
    }

    @AuraEnabled
    public static String generateFgAndPartsJSON(List<FgAndPartsAvailabilityItem> lstFgParts) {
        List<FgAndPartsAvailabilityItem> fgPartsItems = new List<FgAndPartsAvailabilityItem>();
        if(lstFgParts.size()>0){
            for(Integer i = 0;i<lstFgParts.size();i++){
                fgPartsItems.add(lstFgParts[i]);
            }
        }
        system.debug('jsonData serialize='+JSON.serialize(fgPartsItems));
        
        return JSON.serialize(fgPartsItems);
    }
}