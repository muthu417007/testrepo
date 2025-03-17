@IsTest
public class BWC_PartsSearchControllerTest {
    public static String productId;
    
    @TestSetup static void setup(){
            Product2 testProduct = new Product2(Name = 'Demo',BWC_Product_Marketing_Description__c = 'Dummy Product', BWC_MFG_SKU__c = 'ABC05LZQ1~ABC05LZQ2~ABC05LZW1', StockKeepingUnit = 'XYZ123', DisplayUrl = 'https://xyz.com', BWC_Exploded_Diagram_Images__c  = '', BWC_Main_Image__c = 'https://xyz.com', Item_Number__c = 'XYZ111', BWC_Exploded_Diagram_Available__c = true, Status__c = 'Active');
            insert testProduct;
            productId = testProduct.Id;
    }
    
    @isTest static void getMinKeyLengthForSearchTest(){
        Integer result = BWC_PartsSearchController.getMinKeyLengthForSearch();
        Assert.areEqual(3, result);
    }
    
    @isTest static void getProductBySearchKeyTest(){
        String searchKey = 'XYZ123';
        BWC_PartsSearchController.BWC_PartsSearchResultsWrapper response = BWC_PartsSearchController.getProductBySearchKey(searchKey);
        Assert.isFalse(response.showPDP, 'Product with Matching SKU should return');
        searchKey = 'ABC05LZQ1';
        response = BWC_PartsSearchController.getProductBySearchKey(searchKey);
        Assert.isTrue(response.showPDP, 'Product with Matching MFG_SKU should return');
    }
    
    @isTest static void getProductForExplodedDiagramTest(){
        Product2 product = [SELECT Id
                            FROM Product2 
                            LIMIT 1];
        List<Product2> productsToReutrn = BWC_PartsSearchController.getProductForExplodedDiagram(product.Id);
        Assert.isNotNull(productsToReutrn, 'Product with matching Id should be returned');
    }
    
    @isTest static void getProductForExplodedDiagramViaIdsTest(){
        List<Product2> productsToReutrn = BWC_PartsSearchController.getProductForExplodedDiagramViaIds(new List<String>{productId});
        Assert.isNotNull(productsToReutrn, 'Product with matching Id should be returned');
    }
    
    @isTest static void getPriceForProductsTest(){
        List<Product2> pdtResult = [SELECT Id FROM Product2 WHERE StockKeepingUnit = 'XYZ123'];
        PriceBook2 guestPb = new PriceBook2(Name = 'PARTS - CLASS - RFC AND RFG- CONSUMER DIRECT', IsActive = true);
        insert guestPb;
        String pdtId = pdtResult[0].Id;
        PricebookEntry stdPbEntry = new PricebookEntry(Product2Id = pdtId, UnitPrice = 20, Pricebook2Id = Test.getStandardPricebookId(), IsActive = true);
        PricebookEntry pbEntry = new PricebookEntry(Product2Id = pdtId, UnitPrice = 10, Pricebook2Id = guestPb.Id, IsActive = true);
        insert new List<PricebookEntry>{stdPbEntry, pbEntry};
            
            BWC_PartsSearchController.ProductsAndPricing productWithPricing = BWC_PartsSearchController.getPriceForProducts(new List<String>{productId}, true, false);
        Assert.isTrue(productWithPricing.isGuestPricing, 'Guest users should see guest pricing only');
        
        String accJSON = '{"Name":"Test Account", "IsBuyer":true}';
        Account acc = (Account)JSON.deserialize(accJSON, Account.class);
        //Account acc = new Account(Name = 'Test Account', IsBuyer = true);
        insert acc;
        BuyerAccount buyerAccount = new BuyerAccount();
        buyerAccount.BuyerId = acc.Id;
        buyerAccount.Name = 'Test Buyer Account (BA-AJ)';
        buyerAccount.IsActive = true;
        insert buyerAccount;
        Contact con = new Contact(FirstName = 'Dummy Contact', LastName = 'Last Name', AccountId = acc.Id);
        insert con;
        
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name='Bodewell Commerce D2C Login User'];
        String userJSON = '{"FirstName" : "Demo", "LastName" : "User", "IsActive" : true, "Email" : "testEmail111@gmail.com", "Username" : "bodewellTestUser129@gmail.com", "Alias" : "demo", "EmailEncodingKey":"UTF-8", "LanguageLocaleKey":"en_US", "LocaleSidKey":"en_US", "ProfileId" : "' + profiles[0].Id + '", "TimeZoneSidKey":"America/Los_Angeles", "ContactId" : "' + con.Id +'", "IsPortalEnabled" : true}';
        User loggedInUser = (User)JSON.deserialize(userJSON, User.class);
        //User loggedInUser = new User(FirstName = 'Demo', LastName = 'User', IsActive = true, Email = 'testEmail111@gmail.com', Username = 'bodewellTestUser129@gmail.com', Alias = 'demo', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = profiles[0].Id, TimeZoneSidKey='America/Los_Angeles', ContactId = con.Id, IsPortalEnabled = true);
        //System.runAs(loggedInUser){
        insert loggedInUser;
        // }
        
        BuyerGroup buyerGrp = new BuyerGroup(Name = 'Member');
        insert buyerGrp;
        
        BuyerGroupMember buyerGpMem = new BuyerGroupMember();
        buyerGpMem.BuyerId = acc.Id;
        buyerGpMem.BuyerGroupId = buyerGrp.Id;
        insert buyerGpMem;
        
        PriceBook2 priceBook = new PriceBook2(Name = 'PARTS - CLASS - RFC AND RFG- CONSUMER DIRECT');
        insert priceBook;
        
        PricebookEntry memberPriceBookEntry = new PricebookEntry(Product2Id = pdtId, UnitPrice = 10, Pricebook2Id = priceBook.Id, IsActive = true);
        insert memberPriceBookEntry;
        
        BuyerGroup buyerGrp1 = new BuyerGroup(Name = 'Registered Owner Account');
        insert buyerGrp1;
        
        BuyerGroupMember buyerGpMem1 = new BuyerGroupMember();
        buyerGpMem1.BuyerId = acc.Id;
        buyerGpMem1.BuyerGroupId = buyerGrp1.Id;
        insert buyerGpMem1;
        
        PriceBook2 priceBook1 = new PriceBook2(Name = 'Non-Member Registered Owner');
        insert priceBook1;
        
        PricebookEntry memberPriceBookEntry1 = new PricebookEntry(Product2Id = pdtId, UnitPrice = 10, Pricebook2Id = priceBook1.Id, IsActive = true);
        insert memberPriceBookEntry1;
        
        BWC_PartsSearchController.ProductsAndPricing productWithPricing2;
        System.runAs(loggedInUser){
            productWithPricing2 = BWC_PartsSearchController.getPriceForProducts(new List<String>{pdtId}, false, false);
            BWC_PartsSearchController.getPriceForProducts(new List<String>{pdtId}, false, true);
        }
        Assert.isNotNull(productWithPricing2);
    }
    
    @isTest static void getPriceForProductsTest_Exception(){
        List<Product2> pdtResult = [SELECT Id FROM Product2 WHERE StockKeepingUnit = 'XYZ123'];
        String pdtId = pdtResult[0].Id;
        BWC_PartsSearchController.getPriceForProducts(new List<String>{pdtId}, false, true);
    }
    
    @isTest static void getSupersededPartBySkuTest(){
        List<Product2> productsToReutrn = BWC_PartsSearchController.getSupersededPartBySku('XYZ123');
        Assert.isNotNull(productsToReutrn, 'Product with matching sku should be returned');
    }
    
    @isTest static void getRelatedItemsByProductTest(){
        Product2 pdt = new Product2(Name = 'Dummy',StockKeepingUnit = 'CDT845P2123', Item_Number__c = '1234');
        insert pdt;
        System.Test.startTest();
        List<Related_Items__c> products = BWC_PartsSearchController.getRelatedItemsByProduct(new List<Product2>{ pdt }, 'Superseded');
        System.Test.stopTest();
    }
    
    @isTest static void getNetworkIdTest(){
        String networkId = BWC_PartsSearchController.getNetworkId();
        Assert.isNotNull(networkId);
    }
    
    @isTest static void getCartItemsTest(){
        ConnectApi.CartItemCollection cart = BWC_PartsSearchController.getCartItems('xxxx', 'xxxxx', 'xxxxx');
        Assert.isNull(cart);
    }
    
    @isTest static void getPicklistLabelValueTest(){
        Map<String, String> picklistApiNameLabelMap = BWC_PartsSearchController.getPicklistLabelValue('Order','Status');
        Assert.isNotNull(picklistApiNameLabelMap);
    }
    
    @isTest static void getPicklistLabelValueTest_Exception(){
        Map<String, String> picklistApiNameLabelMap = BWC_PartsSearchController.getPicklistLabelValue('Oer','Status');
        Assert.isNull(picklistApiNameLabelMap);
    }
    
    @isTest static void getOrderStatusExceptionTest(){
        System.Test.startTest();
        List<OrderSummary> orderSummaryList = BWC_PartsSearchController.getOrderStatus('123');
        System.Test.stopTest();
        System.AssertEquals(orderSummaryList.size(),0);
    }
}