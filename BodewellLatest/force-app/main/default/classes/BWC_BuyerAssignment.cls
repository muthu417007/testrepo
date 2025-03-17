public class BWC_BuyerAssignment {
      @future
    public static void insertBuyerGroup(String accid) {
         String MemberBuyerGroupId=System.Label.BWC_NonMember_Buyer_Group_Id;
                    Account acc=[select Id,FirstName From Account where Id=:accid LIMIT 1];
      				// Enable as Buyer Account
                    BuyerAccount BAassign= new BuyerAccount();
                    BAassign.BuyerId=accid;
                    BAassign.Name=acc.FirstName;
                    BAassign.IsActive=True;
                    insert BAassign;
                   
                    // Assign Buyer Group 
                    BuyerGroupMember member = new BuyerGroupMember();
                    member.buyerId = accid; //Person Account ID
                    member.BuyerGroupId = MemberBuyerGroupId; //Member Buyer Group Id
                    insert member;
                    system.debug('sucessfully assigned the buyergroup');        
	}
}