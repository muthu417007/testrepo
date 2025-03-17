@isTest
private class DisplayCaseControllerTest {
    @isTest static void testtruecase() {
        List<Case> celsius = DisplayCaseController.getCaseFromId('03343792');
        System.debug('res is'+celsius);
        
    }    
    @isTest static void testfalsecase() {
        List<Case> celsius = DisplayCaseController.getCaseFromId('03343791');
        System.debug('res false is'+celsius);
    }
    
    @isTest static void testgetcaseOSCtrue() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Map < String, Object > res = DisplayCaseController.getCalloutResponseContents('https://m553135n3h.execute-api.us-east-1.amazonaws.com/Prod/RPCconnectmain?casenum=191206-003900');
		System.debug('res value'+res);
    }    
    @isTest static void testgetcaseOSCfalse() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Map < String, Object > res = DisplayCaseController.getCalloutResponseContents('https://m553135n3h.execute-api.us-east-1.amazonaws.com/Prod/RPCconnectmain?casenum=191206-003901');
        System.debug(res);
    }
    @isTest static void testgetcallhistorytrue() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Map < String, Object > celsius = DisplayCaseController.getCalloutResponseContents('https://m553135n3h.execute-api.us-east-1.amazonaws.com/Prod/RPCconnect?phoneNumber=7036156677');
        System.debug(celsius);
    }
    
    @isTest static void testgetcallhistoryfalse() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
       Map < String, Object > celsius = DisplayCaseController.getCalloutResponseContents('https://m553135n3h.execute-api.us-east-1.amazonaws.com/Prod/RPCconnect?phoneNumber=7036156670');
        System.debug(celsius);
    }
   @isTest static void testOSCphone() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Map < String, Object > res = DisplayCaseController.getCalloutResponseContents('https://m553135n3h.execute-api.us-east-1.amazonaws.com/Prod/RPCconnectmain?phoneNumber=6184553470');
        System.debug(res);
    }    
    @isTest static void testSFDCPhone() {
        List<case> celsius = DisplayCaseController.getCaseFromPhone('6184553470');
        System.debug(celsius);
    }
     @isTest static void testSFDCPhonefalse() {
        List<case> celsius = DisplayCaseController.getCaseFromPhone('6184553471');
        System.debug(celsius);
    }
    @isTest static void testSFDCzip() {
        List<case> celsius = DisplayCaseController.getCaseFromzipcode('Arlene','Mcgee','20132');
        System.debug(celsius);
    }
    @isTest static void testSFDCzipfalse() {
        List<case> celsius = DisplayCaseController.getCaseFromzipcode('Arlene','Mcgee','20131');
        System.debug(celsius);
    }
    @isTest static void testSFDCstreet() {
        List<case> celsius = DisplayCaseController.getCaseFromstreet('310 W Main St','Mcgee','20132');
        System.debug(celsius);
    }
    @isTest static void testSFDCstreetfalse() {
        List<case> celsius = DisplayCaseController.getCaseFromstreet('310 W Main St','Mcgee','20131');
        System.debug(celsius);
    }
    
      
}