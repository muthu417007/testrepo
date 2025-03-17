/**
 * @author         Akhil Raj
 * @company        TCS
 * @created        03.08.2023
 * @description    For getting navigation menu links
 */
global class RG_NavigationLinkPickList extends VisualEditor.DynamicPickList {
    
    global override VisualEditor.DataRow getDefaultValue() {
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('Default Navigation','Default Navigation');
        return defaultValue;
    }
	
    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows pickListValues = new VisualEditor.DynamicPickListRows();
        List<NavigationLinkSet> navigationLinklList = RG_NavigationMenuServices.getAllNavigationLinkSet();
        for(NavigationLinkSet navLink: navigationLinklList) {
            VisualEditor.DataRow rowValue = new VisualEditor.DataRow(navLink.MasterLabel,navLink.DeveloperName);
            pickListValues.addRow(rowValue);
        }
        return pickListValues;
    }    
}