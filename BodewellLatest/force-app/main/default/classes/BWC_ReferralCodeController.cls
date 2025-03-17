public without sharing class BWC_ReferralCodeController {

@AuraEnabled
public static String applyReferalCodeOnCart(String referralCode){
    String isSuccess = ''; 
    Boolean referralCodeisValid = FALSE;
    String buyerGroupName = 'Bodewell/ZD Loyalty Store (LYT)';
    System.debug('++++ Referral Id '+referralCode);
    String userId = UserInfo.getUserId();
    if(referralCode != NULL && String.isNotBlank(referralCode)){
        List<User> userList = [SELECT Id, Tech_Referral_Code__c, AccountId FROM User WHERE Id =: userId OR
                                Tech_Referral_Code__c =: referralCode];
        System.debug('++++ userList '+userList);
        Map<String,User> stringToUserMap = new Map<String,User>();
        for(User u: userList){
            stringToUserMap.put(u.Id,u);
            if(u.Tech_Referral_Code__c != NULL && String.isNotBlank(u.Tech_Referral_Code__c)){
                referralCodeisValid = TRUE;                
            }
        }
        System.debug('++++User Map '+stringToUserMap);
        System.debug('++++referralCodeisValid '+referralCodeisValid);
        /*
        if(referralCodeisValid){
            String accountId = stringToUserMap.get(userId).AccountId;
            if(accountId != NULL && String.isNotBlank(accountId)){
                List<BuyerGroup> buyerGroupList = [SELECT Id, Name FROM BuyerGroup WHERE Name =: buyerGroupName];
                if(buyerGroupList.size()>0){
                    List<BuyerGroupMember> bgmList = [SELECT Id FROM BuyerGroupMember WHERE BuyerId =: accountId AND 
                                                        BuyerGroupId =: buyerGroupList[0].Id ];
                    if(bgmList.size() == 0){ // Add the Membership when the Account in not a member already.
                        BuyerGroupMember bgm = new BuyerGroupMember();
                            bgm.BuyerId = accountId;
                            bgm.BuyerGroupId = buyerGroupList[0].Id;
                        insert bgm;
                    }
                    
                }
                List<WebCart> cart = [SELECT Id, Status, Referral_Id__c FROM WebCart WHERE AccountId =: accountId 
                                        AND Status = 'Active' ORDER BY CreatedDate DESC LIMIT 1];
                System.debug('++++ cart '+cart);
                if(cart.size() >0){
                    cart[0].Referral_Id__c = referralCode;
                    update cart;

                }
            }
        }*/

    }
    if(referralCodeisValid){
        isSuccess = 'TRUE';
    }
    else{
         isSuccess = 'FALSE';
    }
    System.debug('++++ return Resuld '+isSuccess);
    return isSuccess;
}
    
@AuraEnabled
    public static void removeReferralCodeOnCart(String referralCode){
        System.debug('++++ Inside Removal '+referralCode);
        if(referralCode != NULL && String.isNotBlank(referralCode)){
           	List<WebCart> cart = [SELECT Id, Status, Referral_Id__c FROM WebCart WHERE Referral_Id__c =: referralCode 
                                        AND Status = 'Active' ORDER BY CreatedDate DESC LIMIT 1];
           	System.debug('++++ cart '+cart);
            if(cart.size() >0){
            	cart[0].Referral_Id__c = '';
                update cart;
            } 
        }
        
    }
}