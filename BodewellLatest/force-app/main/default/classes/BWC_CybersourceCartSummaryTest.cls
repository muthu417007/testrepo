@IsTest
public class BWC_CybersourceCartSummaryTest {
    /*
    {
        "accountId": "001Hn00001uFNzRIAW",
        "cartId": "0a6Hn000000PLKHIA4",
        "currencyIsoCode": "USD",
        "grandTotalAmount": "249.99",
        "isSecondary": false,
        "messagesSummary": {
            "errorCount": 0,
            "hasErrors": false,
            "limitedMessages": [],
            "relatedEntityId": "0a6Hn000000PLKHIA4",
            "totalLineItemsWithErrors": 0
        },
        "name": "Cart",
        "orderOwnerId": null,
        "ownerId": "005Hn00000HODpiIAH",
        "purchaseOrderNumber": null,
        "status": "Checkout",
        "taxType": "Net",
        "totalChargeAmount": "0.00",
        "totalListPrice": "259.99",
        "totalProductAmount": "249.99",
        "totalProductAmountAfterAdjustments": "249.99",
        "totalProductCount": "1.0",
        "totalPromotionalAdjustmentAmount": "0.00",
        "totalTaxAmount": "0.00",
        "type": "Cart",
        "uniqueProductCount": 1,
        "webstoreId": "0ZEHn0000008UgiOAE"
    }
    */
    @IsTest
    static void testParse() {
        String json = '{ "accountId": "001Hn00001uFNzRIAW", "cartId": "0a6Hn000000PLKHIA4", "currencyIsoCode": "USD", "grandTotalAmount": "249.99", "isSecondary": false, "messagesSummary": { "errorCount": 0, "hasErrors": false, "limitedMessages": [], "relatedEntityId": "0a6Hn000000PLKHIA4", "totalLineItemsWithErrors": 0 }, "name": "Cart", "orderOwnerId": null, "ownerId": "005Hn00000HODpiIAH", "purchaseOrderNumber": null, "status": "Checkout", "taxType": "Net", "totalChargeAmount": "0.00", "totalListPrice": "259.99", "totalProductAmount": "249.99", "totalProductAmountAfterAdjustments": "249.99", "totalProductCount": "1.0", "totalPromotionalAdjustmentAmount": "0.00", "totalTaxAmount": "0.00", "type": "Cart", "uniqueProductCount": 1, "webstoreId": "0ZEHn0000008UgiOAE" }';
		BWC_CybersourceCartSummary obj = BWC_CybersourceCartSummary.parse(json);
		System.assert(obj != null);
    }
}