@isTest
public with sharing class BWC_NavigationLinkSetPickListTest {
    @isTest
    public static void testGetDefaultValue() {
        BWC_NavigationLinkSetPickList navLinksPickList = new BWC_NavigationLinkSetPickList();
        VisualEditor.DataRow dataRow = navLinksPickList.getDefaultValue();
        System.assert(dataRow != null, 'VisualEditor.DataRow was null!');
    }

    @isTest
    public static void testGetValues() {
        BWC_NavigationLinkSetPickList navLinksPickList = new BWC_NavigationLinkSetPickList();
        VisualEditor.DynamicPickListRows dataRows = navLinksPickList.getValues();
        System.assert(dataRows != null, 'VisualEditor.DynamicPickListRows was null!');
    }
}