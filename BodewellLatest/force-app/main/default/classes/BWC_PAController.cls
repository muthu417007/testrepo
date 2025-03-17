public without sharing class BWC_PAController {
    @AuraEnabled
    public static BuyerGroupMember updatePAMembershipDetails(String accId ) {  
        try
        {
            system.debug('accId===='+accId);
            
            //change Buyer Group
            //label for member buyer group id 
            String MemberBuyerGroupId=System.Label.BWC_Membership_Buyer_Group_Id;
            
            BuyerGroupMember member = new BuyerGroupMember();
            member.buyerId = accId; //Person Account ID
            member.BuyerGroupId = MemberBuyerGroupId; //Member Buyer Group Id
            //  member.OwnerId=accId;
            
            insert member;
            
            //delete existing buyer group
            BuyerGroupMember  oldBuyerGroup=[SELECT BuyerId, Name, OwnerId, IsDeleted, Id, BuyerGroupId FROM BuyerGroupMember where  BuyerId=:accId and BuyerGroupId!=:MemberBuyerGroupId];
            String prevBuyerId=oldBuyerGroup.BuyerGroupId;
            delete oldBuyerGroup;
            //update PA fields
            Account acc=[SELECT Id, Bodewell_Member_Expiration_Date__c,BWC_Previous_Buyer_Group__c, Bodewell_Member_Start_Date__c, Bodewell_Member__c FROM Account where id=:accId];
            acc.Bodewell_Member_Start_Date__c=System.today();
            acc.Bodewell_Member__c=true;
            acc.BWC_Previous_Buyer_Group__c=prevBuyerId;
            date myDate = System.Today();
            
            
            acc.Bodewell_Member_Expiration_Date__c=(myDate+Integer.valueOf(System.Label.BWC_Membership_Duration));
            update acc;
            
            return member;
        }
        catch(exception e)
        {
            System.debug('Exception Message->'+e.getMessage()+'  at Line->'+e.getLineNumber());
            return null;
        }
        
    }
    
    
    
    @AuraEnabled
    public static BuyerGroupMember revertMembership(String accId ) {  
        try
        {
            
            //update PA fields
            Account acc=[SELECT Id, Assurant_PTP_Coverage__pc, Bodewell_Member_Expiration_Date__c,BWC_Previous_Buyer_Group__c, Bodewell_Member_Start_Date__c, Bodewell_Member__c FROM Account where id=:accId];
            acc.Bodewell_Member_Start_Date__c=null;
            acc.Bodewell_Member__c=false;    
            acc.Bodewell_Member_Expiration_Date__c=null;
            acc.Assurant_PTP_Coverage__pc = false;
            // acc.BWC_Previous_Buyer_Group__c=null;
            update acc;
            
            
            //change Buyer Group
            
            BuyerGroupMember member = new BuyerGroupMember();
            member.buyerId = accId; //Person Account ID
            member.BuyerGroupId = acc.BWC_Previous_Buyer_Group__c; //Member Buyer Group Id
            insert member;
            
            //delete member buyer group
            
            delete[SELECT BuyerId, Name, OwnerId, IsDeleted, Id, BuyerGroupId FROM BuyerGroupMember where  BuyerId=:accId and BuyerGroupId!=:acc.BWC_Previous_Buyer_Group__c];
            system.debug(member);
            
            return member;
        }
        catch(exception e)
        {
            
             System.debug('Exception Message->'+e.getMessage()+'  at Line->'+e.getLineNumber());
            return null;
        }
        
    }
    
    @AuraEnabled
    public static BuyerGroupMember changeMembershipAfterPreservation(String effectiveAccountId,String cartId,String userId )
    {  
        
        //Shubhada Changes 
        // calls the buyer group change to member if BDMEM sku present in cart
        // Or if user  already belongs to member buyer group then delete the BDMEM cartItem 
        String accountId=[Select accountId, Id from user where Id=:userId].accountId;
        String cartCurrentId=[Select id,status from webcart where (status='Active' OR status='Checkout') AND isSecondary=false AND accountId=:accountId limit 1].Id;
        List<cartItem> newCartItems=[select Id,Product2Id from cartItem  where cartId=:cartCurrentId];
        system.debug('newCartItems'+newCartItems);
        String MemberBuyerGroupId=System.Label.BWC_Membership_Buyer_Group_Id;
        BuyerGroupMember buyerMember=new  BuyerGroupMember();
        
        String currentUserBuyerGroupId=[select buyerId, BuyerGroupId from BuyerGroupMember where buyerId=:effectiveAccountId].BuyerGroupId;
        if(currentUserBuyerGroupId!=MemberBuyerGroupId)
        {
            for (CartItem guestCartItem : newCartItems) {
                if(guestCartItem.Product2Id==System.Label.BWC_Product_Id_For_Member)
                {
                    buyerMember=updatePAMembershipDetails(accountId);
                    
                }
            }  
            // return buyerMember;
        }
        else
        {
            for (CartItem guestCartItem : newCartItems) {
                if(guestCartItem.Product2Id==System.Label.BWC_Product_Id_For_Member)
                {
                    delete guestCartItem;
                }
            }
        }
        return buyerMember;
        
    }
   
    
    
    
}