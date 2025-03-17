@isTest
private class RG_BreadCrumbControllerTest {
	@isTest
    static void getBreadCrumbsTest()
    {
        RG_RequestResponse breadCrumbsTest = RG_BreadCrumbController.getBreadCrumbs();
        System.assert(breadCrumbsTest.success,'Test Passed');
    }
}