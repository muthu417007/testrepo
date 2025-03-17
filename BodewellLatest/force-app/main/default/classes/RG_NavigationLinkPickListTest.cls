@isTest
private class RG_NavigationLinkPickListTest {
	@isTest
    static void getDefaultValueTest()
    {
        RG_NavigationLinkPickList picklist = new RG_NavigationLinkPickList();
        VisualEditor.DataRow data = picklist.getDefaultValue();
        System.assertEquals(data.getValue(),'Default Navigation');
    }
    
    @isTest
    static void getValuesTest()
    {
        RG_NavigationLinkPickList picklist = new RG_NavigationLinkPickList();
        VisualEditor.DynamicPickListRows data = picklist.getValues();
        System.assert(data.size() > 0, 'Test Passed');
    }
}