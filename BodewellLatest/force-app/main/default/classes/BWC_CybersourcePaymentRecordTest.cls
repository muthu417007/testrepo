@IsTest
public class BWC_CybersourcePaymentRecordTest {
    /*
    {
        "cartId": "0a6Hn000000PLKHIA4",
        "webstoreId": "0ZEHn0000008UgiOAE",
        "accountId": "001Hn00001uFNzR",
        "currencyIsoCode": "USD",
        "signed_date_time": "2023-09-19T21:38:32Z",
        "request_token": "Axj/7wSTeNjDEiJn9lKmABsY4sV5U6bQhSXNSYojmhjARABURzQxgIhpA/dDGX0MmkmWLr4HuYQJybxsYYkRM/spUwAAQEBe",
        "transaction_id": "6951595119586424804006",
        "auth_code": "831000",
        "auth_time": "2023-09-19T213832Z",
        "payment_token": "9909000391537209",
        "req_card_expiry_date": "09-2029",
        "req_bill_to_forename": "Lauren",
        "req_bill_to_surname": "Boyle",
        "req_bill_to_street": "218 Carrack Dr",
        "req_bill_to_city": "Round Rock",
        "req_bill_to_state": "TX",
        "req_bill_to_postal_code": "78681",
        "req_bill_to_country": "US",
        "req_card_type": "001",
        "req_card_number": "xxxxxxxxxxxx1111",
        "auth_amount": "282.94",
        "cardNumber": "xxxxxxxxxxxx1111",
        "card_type_name": "Visa",
        "expiryYear": "2029",
        "expiryMonth": "09"
    }
    */
    @IsTest
    static void testParse() {
        String json = '{ "cartId": "0a6Hn000000PLKHIA4", "webstoreId": "0ZEHn0000008UgiOAE", "accountId": "001Hn00001uFNzR", "currencyIsoCode": "USD", "signed_date_time": "2023-09-19T21:38:32Z", "request_token": "Axj/7wSTeNjDEiJn9lKmABsY4sV5U6bQhSXNSYojmhjARABURzQxgIhpA/dDGX0MmkmWLr4HuYQJybxsYYkRM/spUwAAQEBe", "transaction_id": "6951595119586424804006", "auth_code": "831000", "auth_time": "2023-09-19T213832Z", "payment_token": "9909000391537209", "req_card_expiry_date": "09-2029", "req_bill_to_forename": "Lauren", "req_bill_to_surname": "Boyle", "req_bill_to_street": "218 Carrack Dr", "req_bill_to_city": "Round Rock", "req_bill_to_state": "TX", "req_bill_to_postal_code": "78681", "req_bill_to_country": "US", "req_card_type": "001", "req_card_number": "xxxxxxxxxxxx1111", "auth_amount": "282.94", "cardNumber": "xxxxxxxxxxxx1111", "card_type_name": "Visa", "expiryYear": "2029", "expiryMonth": "09" }';
		BWC_CybersourcePaymentRecord obj = BWC_CybersourcePaymentRecord.parse(json);
		System.assert(obj != null);
    }
}