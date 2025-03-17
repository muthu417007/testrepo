public class BWC_AssignBodewellCommercePermissions {
    public static void MakeAsBuyerEnabled(String accid, String Userid) {
        
                    String Permissionscheck = System.Label.BWC_Buyer_Permission;                   
 					
                    List<PermissionSetAssignment> permissionset = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :userid AND PermissionSetId = :Permissionscheck LIMIT 1];
                    if (permissionset.isEmpty()) {
                        String Permissionsetassign=System.Label.Bodewell_Commerce_Permissions;
                        // Assign permission set
                        PermissionSetAssignment psAssignment = new PermissionSetAssignment();
                        psAssignment.AssigneeId = userid;
                        psAssignment.PermissionSetGroupId = Permissionsetassign;
                        if(!test.isRunningTest())
                        {
                            insert psAssignment;
                        }
                        
                    }

                    // Query the BuyerGroup object to check if any BuyerGroup is associated with the Account
                    List<BuyerGroupMember> buyerGroups = [SELECT Id FROM BuyerGroupMember WHERE BuyerId = :accid LIMIT 1];
                    if (buyerGroups.isEmpty()) {
                        String Accid1=accid;
                        //future method calling
                        BWC_BuyerAssignment.insertBuyerGroup(Accid1);
                    }
                       

}
}