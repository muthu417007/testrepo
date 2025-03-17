/**
 * @author         Akhil Raj
 * @company        TCS
 * @created        03.08.2023
 * @description    Service class for navigation menu
 */
public class RG_NavigationMenuServices {
    public static List<NavigationLinkSet> getAllNavigationLinkSet() {
        List<NavigationLinkSet> navigationLinkSet = new List<NavigationLinkSet>();
        if(Schema.sObjectType.NavigationLinkSet.fields.Id.isAccessible() &&
            Schema.sObjectType.NavigationLinkSet.fields.MasterLabel.isAccessible() &&
            Schema.sObjectType.NavigationLinkSet.fields.DeveloperName.isAccessible())
        {            
        	 navigationLinkSet = [SELECT MasterLabel, DeveloperName FROM NavigationLinkSet];
        }
        return navigationLinkSet;
    }
    
    public static List<NavigationLinkSet> getNavigationLinkSetIdByDeveloperName(String name) {
        List<NavigationLinkSet> navigationLinkSet = [SELECT Id FROM NavigationLinkSet WHERE DeveloperName = :name];
        return navigationLinkSet;
    }
    
    public static List<NavigationMenuItem> getNavigationMenuItems(Id linkSetId, String status) {
        List<NavigationMenuItem> navigationMenuItems = [SELECT toLabel(Label), Target, Type, DefaultListViewId, AccessRestriction,
                        ParentId, Position, Status, TargetPrefs
                    FROM NavigationMenuItem
                    WHERE NavigationLinkSetId =: linkSetId AND Status =: status
                    ORDER BY Position];
        return navigationMenuItems;
    }
}