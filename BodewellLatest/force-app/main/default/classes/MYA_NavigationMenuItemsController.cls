/**
 * @author         Akhil Raj
 * @company        TCS
 * @created        01.05.2022
 * @description    For getting menu items
 */
global with sharing class MYA_NavigationMenuItemsController {
    public MYA_NavigationMenuItemsController() {}
    // Method for getting menu items based on menu name
    @AuraEnabled(cacheable=true)
    public static List<NavigationMenuItem> getNavigationMenuItems(String menuName, String publishedState) {                   
            if(menuName != null && publishedState != null) {                
                String networkId = Network.getNetworkId();
               
                // find the link set belonging to the navigation menuName and active networkId
                List<NavigationLinkSet> linkSets = [
                    SELECT Id 
                    FROM NavigationLinkSet
                    WHERE MasterLabel = :menuName AND NetworkId = :networkId
                ];
                
                Id linkSetId;
                if(linkSets.size() > 0) {
                    linkSetId = linkSets.get(0).Id;
                }
                // collect all the menu items belonging to the link set
                // published state is either Draft or Live
                return [SELECT toLabel(Label), Target, Type, DefaultListViewId, AccessRestriction,
                        ParentId,
                        Position,
                        Status,
                        TargetPrefs
                    FROM NavigationMenuItem
                    WHERE NavigationLinkSetId = :linkSetId
                    AND Status = :publishedState 
                    ORDER BY Position
                ];
            } else {
               return null;
            }
    }
}