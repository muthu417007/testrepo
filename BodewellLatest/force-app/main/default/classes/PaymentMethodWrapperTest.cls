@isTest
private class PaymentMethodWrapperTest {
    @isTest
    static void testPaymentMethodWrapper() {
        PaymentMethodWrapper.Address address = new PaymentMethodWrapper.Address();
        address.city = 'City';
        address.country = 'Country';
        address.line1 = 'Address Line 1';
        address.line2 = 'Address Line 2';
        address.postal_code = '12345';
        address.state = 'State';
        
        PaymentMethodWrapper.Checks checks = new PaymentMethodWrapper.Checks();
        checks.address_line1_check = 'pass';
        checks.address_postal_code_check = 'pass';
        checks.cvc_check = 'pass';
        
        PaymentMethodWrapper.Networks networks = new PaymentMethodWrapper.Networks();
        networks.available = new List<String>{ 'Network1', 'Network2' };
        networks.preferred = 'Network1';
        
        PaymentMethodWrapper.ThreeDSecureUsage threeDSecureUsage = new PaymentMethodWrapper.ThreeDSecureUsage();
        threeDSecureUsage.supported = true;
        
        PaymentMethodWrapper.Card card = new PaymentMethodWrapper.Card();
        card.brand = 'Visa';
        card.checks = checks;
        card.country = 'US';
        card.exp_month = 12;
        card.exp_year = 2025;
        card.fingerprint = 'fingerprint123';
        card.funding = 'credit';
        card.generated_from = 'generatedFrom';
        card.last4 = '1234';
        card.networks = networks;
        card.three_d_secure_usage = threeDSecureUsage;
        card.wallet = 'walletType';
        
        PaymentMethodWrapper.BillingDetails billingDetails = new PaymentMethodWrapper.BillingDetails();
        billingDetails.address = address;
        billingDetails.email = 'test@example.com';
        billingDetails.name = 'John Doe';
        billingDetails.phone = '123-456-7890';
        
        PaymentMethodWrapper paymentMethod = new PaymentMethodWrapper();
        paymentMethod.id = 'paymentId123';
        paymentMethod.billing_details = billingDetails;
        paymentMethod.card = card;
        paymentMethod.created = 1647312000;
        paymentMethod.customer = 'customer123';
        paymentMethod.livemode = true;
        paymentMethod.metadata = new Map<String, Object>{ 'key1' => 'value1', 'key2' => 123 };
        paymentMethod.type = 'card';
        
        // Add your assertions here to test the PaymentMethodWrapper class
    }
}