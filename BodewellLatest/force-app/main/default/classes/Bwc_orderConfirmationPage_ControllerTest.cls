@isTest
public with sharing class Bwc_orderConfirmationPage_ControllerTest {
    @isTest
    public static void bwc_orderConfirmationPage_ControllerTestMethod() {
  //  OrderSummary orderSummaryInstance=[Select id from OrderSummary limit 1];
    System.Test.startTest();
    List<OrderItemSummary> orderidlist = Bwc_orderConfirmationPage_Controller.orderpricemethod('1Oe8B000000ElHVSA0');
    System.Test.stopTest();
        System.assertEquals(0,orderidlist.size());
    }
}