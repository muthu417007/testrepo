//******************************************************************************************
//Name : BDW_NavigationController
//Requirement : To display Navigation Bar for Bodewell Website
//******************************************************************************************
//History
//	Version				Author					Date				Detail
//  1.0					Yogesh Sharma			11/21/2022			Initial
//******************************************************************************************
//@description : To display Navigation Bar for Bodewell Website
global class BDW_NavigationController 
{
	//@description : Fetches Navigation Menu items for Bodewell Website
    @AuraEnabled(cacheable=true)
    public static List<BW_menuItems> getNavigationMenuItems(String menuName, String publishedStatus) 
    {                   
    	List<BW_menuItems> navMenuItems = new List<BW_menuItems>();
        if(menuName != null) 
        {                
            // find the link set belonging to the navigation menuName and active networkId
            List<NavigationLinkSet> linkSets = [SELECT Id FROM NavigationLinkSet
                                                WHERE MasterLabel = :menuName];
            Id linkSetId;
            if(linkSets.size() > 0) 
            {
            	linkSetId = linkSets.get(0).Id;
            }

            List<NavigationMenuItem> nav = [SELECT toLabel(Label), Target, Type, DefaultListViewId, AccessRestriction,
                        ParentId, Position, Status, TargetPrefs
                    FROM NavigationMenuItem
                    WHERE NavigationLinkSetId =: linkSetId AND Status =: publishedStatus
                    ORDER BY Position];
            if(nav.size()>0)
            {
                for(NavigationMenuItem EN:nav)
                {
                    if(EN.ParentId == null && EN.Type != 'MenuLabel')
                    {
                        BW_menuItems menuItem = new BW_menuItems();
                        menuItem.menuItemName = EN.Label;
                        menuItem.menuItemTarget = EN.Target;
                        menuItem.isMenu = false;
                        menuItem.menuItemId = string.valueOf(EN.Id);
                        navMenuItems.add(menuItem);
                    }
                    else if(EN.ParentId == null && EN.Type == 'MenuLabel')
                    {
                        
                        List<BW_subMenuItems> subItems = new List<BW_subMenuItems>();
                        
                        BW_menuItems menuItem = new BW_menuItems();
                        menuItem.menuItemName = EN.Label;
                        menuItem.isMenu = true;
                        menuItem.menuItemId = string.valueOf(EN.Id);
                        for(NavigationMenuItem ES:nav)
                        {
                            if(ES.ParentId == EN.Id)
                            {
                                BW_subMenuItems eachSubMenuItem = new BW_subMenuItems();
                                eachSubMenuItem.subMenuItemName = ES.Label;
                                eachSubMenuItem.subMenuItemId = string.valueOf(ES.Id);
                                eachSubMenuItem.subMenuItemParent = EN.Label;
                                eachSubMenuItem.subMenuItemTarget = ES.Target;
                                subItems.add(eachSubMenuItem);
                            }
                        }
                        menuItem.subMenuItemList = subItems;
                        navMenuItems.add(menuItem);
                    }
                    
                }
            }
            return navMenuItems;
            } 
        else 
        {
        	return null;
        }
    }
    //@description : Wrapper Class
    Public class BW_menuItems
    {
        @AuraEnabled public String menuItemName;
        @AuraEnabled public boolean isMenu;
        @AuraEnabled public String menuItemId;
        @AuraEnabled public String menuItemTarget;
        @AuraEnabled public List<BW_subMenuItems> subMenuItemList;
    }
    //@description : Wrapper Class
    Public class BW_subMenuItems
    {
        @AuraEnabled public String subMenuItemId;
        @AuraEnabled public String subMenuItemName;
        @AuraEnabled public String subMenuItemParent;
        @AuraEnabled public String subMenuItemTarget;        
    }
}