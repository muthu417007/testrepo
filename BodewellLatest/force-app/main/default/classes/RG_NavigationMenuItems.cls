public class RG_NavigationMenuItems {
		@AuraEnabled public String menuItemName;
        @AuraEnabled public boolean isMenu;
    	@AuraEnabled public boolean hasChild;
        @AuraEnabled public String menuItemId;
        @AuraEnabled public String menuItemTarget;
        @AuraEnabled public List<RG_NavigationSubMenuItems> subMenuItemList;
}