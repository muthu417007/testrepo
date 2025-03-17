@isTest
private class RG_NavigationMenuItemsControllerTest {
    @isTest
    static void getNavigationMenuItemsTest()
    {
        RG_RequestResponse response = RG_NavigationMenuItemsController.getNavigationMenuItems('BodewellStandardNavBar','Draft');
        System.assert(response.success,'Test Passed');
    }
}