@isTest
private class RG_NavigationMenuServicesTest {
	@isTest
    static void getAllNavigationLinkSetTest()
    {
        List<NavigationLinkSet> data = RG_NavigationMenuServices.getAllNavigationLinkSet();
        System.assert(data.size() > 0,'Test Passed');
    }
    @isTest
    static void getNavigationLinkSetIdByDeveloperNameTest()
    {
        List<NavigationLinkSet> data = RG_NavigationMenuServices.getNavigationLinkSetIdByDeveloperName('BodewellStandardNavBar');
        System.assert(data.size() > 0,'Test Passed');
    }
}