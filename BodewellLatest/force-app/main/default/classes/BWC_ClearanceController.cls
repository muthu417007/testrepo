/**
* @author Abhishek Bisht
* @date 22/02/2024
* @description The purpose of this class is to get the clearance tag information 
* */
public class BWC_ClearanceController {
    
   static final String MEMBER_PRICE_BOOK = 'Member_Price_Book';
   static final String NON_MEMBER_PRICE_BOOK = 'BasePriceBook';
   static final String MEMBER_BUYER_GROUP_NAME = 'Member';
    
    /*
* @description This method is used to get the price book entry details
* @param productId - This param contains the product Id for which pricebook entry details needed
* @return PriceBookEntry
*/
    @AuraEnabled(cacheable = true)
    public static List<PriceBookEntry> getPriceBookEntryDetails(Id productId){
        try{
            Map<String, String> priceBookNameMap = new Map<String, String>();
            List<PriceBookEntry> priceBookEntryList = new List<PriceBookEntry>();
            String priceBookName;
            
            for (BWC_Price_Book_Configuration__mdt config : [SELECT DeveloperName, PriceBookName__c FROM BWC_Price_Book_Configuration__mdt]) {
                priceBookNameMap.put(config.DeveloperName, config.PriceBookName__c);
            }
            
            List<BuyerGroupMember> buyerGroupMemberList = [SELECT Id,
                                                           BuyerGroup.Name
                                                           FROM BuyerGroupMember
                                                           WHERE BuyerId =: [SELECT AccountId
                                                                             FROM User
                                                                             WHERE Id =: UserInfo.getUserId()
                                                                             LIMIT 1][0].AccountId
                                                           LIMIT 1];
            
            if(!buyerGroupMemberList.isEmpty()){
                if(MEMBER_BUYER_GROUP_NAME.equals(buyerGroupMemberList[0].BuyerGroup.Name)){
                    priceBookName = priceBookNameMap.get(MEMBER_PRICE_BOOK);
                }
                else{
                    priceBookName = priceBookNameMap.get(NON_MEMBER_PRICE_BOOK);
                }
                
                priceBookEntryList = [SELECT Id,
                                      BWC_NET_NET_CLOSEOUT_IND__c
                                      FROM PriceBookEntry
                                      WHERE Product2Id =: productId
                                      AND PriceBook2.Name =: priceBookName
                                      LIMIT 1];
            }
            
            return priceBookEntryList;
        }catch(Exception e){
            System.debug('Exception occured:'+e.getMessage()+'at line number:'+e.getLineNumber());
            return null;
        }
    }
}