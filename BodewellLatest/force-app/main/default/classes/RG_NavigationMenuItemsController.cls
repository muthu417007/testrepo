/**
 * @author         Akhil Raj
 * @company        TCS
 * @created        03.08.2023
 * @description    For getting menu items
 */
global with sharing class RG_NavigationMenuItemsController {
    
    public RG_NavigationMenuItemsController() {}
	// Method for getting menu items based on menu name
    @AuraEnabled(cacheable=true)
    public static RG_RequestResponse getNavigationMenuItems(String menuName, String publishedStatus) {     
        RG_RequestResponse response = new RG_RequestResponse();
        try {            
            List<RG_NavigationMenuItems> navMenuItems = new List<RG_NavigationMenuItems>();
            if(menuName != null) 
            {                
                // find the link set belonging to the navigation menuName and active networkId
                List<NavigationLinkSet> linkSets = RG_NavigationMenuServices.getNavigationLinkSetIdByDeveloperName(menuName);
                Id linkSetId;
                if(linkSets.size() > 0) 
                {
                    linkSetId = linkSets.get(0).Id;
                }
    
                List<NavigationMenuItem> navItems = RG_NavigationMenuServices.getNavigationMenuItems(linkSetId,publishedStatus);
                System.debug('navItems: ' + navItems);
                if(navItems.size()>0)
                {
                    for(NavigationMenuItem item:navItems)
                    {
                        if(item.ParentId == null && item.Type != 'MenuLabel')
                        {
                            RG_NavigationMenuItems menuItem = new RG_NavigationMenuItems();
                            menuItem.menuItemName = item.Label;
                            menuItem.menuItemTarget = item.Target;
                            menuItem.isMenu = false;
                            menuItem.menuItemId = string.valueOf(item.Id);
                            menuItem.hasChild = false;
                            navMenuItems.add(menuItem);
                        }
                        else if(item.ParentId == null && item.Type == 'MenuLabel')
                        {
                            
                            List<RG_NavigationSubMenuItems> subItems = new List<RG_NavigationSubMenuItems>();
                            
                            RG_NavigationMenuItems menuItem = new RG_NavigationMenuItems();
                            menuItem.menuItemName = item.Label;
                            menuItem.isMenu = true;
                            menuItem.menuItemId = string.valueOf(item.Id);
                            for(NavigationMenuItem subItem:navItems)
                            {
                                if(subItem.ParentId == item.Id)
                                {
                                    RG_NavigationSubMenuItems eachSubMenuItem = new RG_NavigationSubMenuItems();
                                    eachSubMenuItem.subMenuItemName = subItem.Label;
                                    eachSubMenuItem.subMenuItemId = string.valueOf(subItem.Id);
                                    eachSubMenuItem.subMenuItemParent = item.Label;
                                    eachSubMenuItem.subMenuItemTarget = subItem.Target;
                                    subItems.add(eachSubMenuItem);
                                }
                            }
                            menuItem.subMenuItemList = subItems;
                            menuItem.hasChild = menuItem.subMenuItemList.size() > 0 ? true : false;
                            navMenuItems.add(menuItem);
                        }
                        
                    }
                }
          	}
            response.success = true;
            response.result = navMenuItems;
            return response;
        } catch(Exception ex) {
            response.success = false;
            response.result = null;
            return response;
        }
    }
}