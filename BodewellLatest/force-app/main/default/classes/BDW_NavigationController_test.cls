//******************************************************************************************
//Name : BDW_NavigationController_test
//Requirement : To test BDW_NavigationController
//******************************************************************************************
//History
//	Version				Author					Date				Detail
//  1.0					Yogesh Sharma			11/21/2022			Initial
//******************************************************************************************
//@description : To test BDW_NavigationController
@isTest(seeAllData = true)
private class BDW_NavigationController_test 
{
	//@description : To test BDW_NavigationController.getNavigationMenuItems()
    @isTest
    static void getNavigationMenuItems_test()
    {
        BDW_NavigationController.getNavigationMenuItems('BodewellStandardNavBar','Draft');
    }
}