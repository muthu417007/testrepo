public class Bwc_orderConfirmationPage_Controller {
    @AuraEnabled(cacheable=true)
    public static List<OrderItemSummary> orderpricemethod(Id orderSummaryId){
        List<OrderItemSummary> orderidlist = new List<OrderItemSummary>();
        orderidlist = [select id, TotalPrice from OrderItemSummary Where orderSummaryId=:orderSummaryId];
        return orderidlist;
    }
}