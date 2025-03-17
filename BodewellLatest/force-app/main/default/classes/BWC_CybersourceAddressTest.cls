@IsTest
public class BWC_CybersourceAddressTest {
    /*
    {
        "city": "Round Rock",
        "country": "US",
        "firstName": "",
        "lastName": "",
        "name": "Shipping",
        "postalCode": "78681",
        "region": "TX",
        "street": "218 Carrack Dr"
    };
    */
    @IsTest
    static void testParse() {
		String json = '{"city":"Round Rock","country":"US","firstName":"","lastName":"","name":"Shipping","postalCode":"78681","region":"TX","street":"218 Carrack Dr"}';
		BWC_CybersourceAddress obj = BWC_CybersourceAddress.parse(json);
		System.assert(obj != null);
	}
}