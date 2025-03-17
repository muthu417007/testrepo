@isTest
private class RG_MediaControllerTest {
	@isTest
    static void getMediaServiceCityTest()
    {
        RG_MediaControllerResponse getMediaTest = RG_MediaController.getMediaServiceCity('ge-dryer-repair','louisville');
        System.assert(getMediaTest.success,'Test Passed');
    }
}