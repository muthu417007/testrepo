@isTest
public with sharing class BWC_addItemToCartMemberTest {
      @isTest
    public static void bWC_CreateCartItemTestMethod() {
        
        
        Id p = [select id from profile where name='Bodewell Commerce D2C Login User'].id;
       
        Account ac = new Account(name ='Grazitti') ;
        insert ac; 
       
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
        insert con;  
                  
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = con.Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;

        // Start the test context and set the current user
        
        Test.startTest();
        System.runAs(user) {
            // Create a test product
            Product2 testProduct = new Product2(Name = 'Test Product', Item_Number__c = '123456',stockKeepingUnit='TestProductMember' );
            insert testProduct;
            WebStore testWebStore = new WebStore(Name='Bodewell Store');
        insert testWebStore;

            // Call the method to test
            BWC_addItemToCartMember.bwc_CreateCartItemMethod(
                testProduct.Id,
                '1', // Quantity
                10.0 // Unit Price
         
            );

            // Add assertions to verify the results
            // You can check if the CartItem and CartDeliveryGroup were created
            // and any other assertions based on your specific requirements.

            // Example assertion:
            List<CartItem> cartItems = [SELECT Id FROM CartItem];
            System.assertEquals(1, cartItems.size());

            // Optionally, you can also assert other conditions as needed.
        }
        Test.stopTest();

    }
}