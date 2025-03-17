@isTest(seealldata=true)
public class BWC_GuestCartControllerTest {
    
    public static String guestUUID = '279031ca-1a07-4427-ac07-5f7cbc045175';
    
    @isTest
    public static void testPreserveGuestCart() {
        Account loggedInAcccount = [SELECT Id FROM Account LIMIT 1];
        User loggedInUser = [SELECT Id FROM User LIMIT 1];
        WebCart cart = [SELECT Id, Name, AccountId, BWC_GuestUUID__c, IsSecondary, Status, WebStoreId FROM WebCart LIMIT 1];
        cart.BWC_GuestUUID__c = loggedInUser.Id;
        update cart;
        WebStoreNetwork w = [select id,WebStoreId,NetworkId from WebStoreNetwork LIMIT 1];
        
        BWC_GuestCartController.preserveGuestCart(loggedInAcccount.Id, loggedInUser.Id, guestUUID, w.NetworkId);
        
        List<WebCart> carts = [SELECT Id, Name, Status, IsSecondary, BWC_GuestUUID__c, AccountId, OwnerId FROM WebCart];
        
    }
    
    
    @isTest
    public static void testPreserveGuestCart_WithPreExistingCart() {
        
        // Update existing guest cart
        WebCart guestCart = [SELECT Id,CreatedById FROM WebCart LIMIT 1];
        System.debug('guestCart-->'+guestCart);
        guestCart.BWC_GuestUUID__c = guestUUID;
        //update guestCart;
        
        // Create pre-existing logged-in cart
        WebStore webStore = [SELECT Id FROM WebStore LIMIT 1];
        Account loggedInAcccount = [SELECT Id FROM Account LIMIT 1];
        User loggedInUser = [SELECT Id FROM User LIMIT 1];
        WebStoreNetwork webNetwork = [select id,WebStoreId,NetworkId from WebStoreNetwork LIMIT 1];
        
        WebCart loggedInCart = new WebCart(Name='Pre-existing Logged In Cart', WebStoreId=webStore.Id, AccountId=loggedInAcccount.Id, 
                                           OwnerId = loggedInUser.Id, BWC_GuestUUID__c = guestUUID, Status = 'Active',IsSecondary = False);
        insert loggedInCart;
        System.debug('loggedInCart-->'+loggedInCart);
        System.debug('loggedInCart-->'+loggedInCart.CreatedById);
        /*List<WebCart> cartList = [SELECT Id, CreatedDate,CreatedById,
                                  Status 
                                  FROM WebCart 
                                  where
                                  Id=:loggedInCart.Id];
        System.debug('cartList6-->'+cartList);
        List<WebCart> cartList1 = [SELECT Id, 
                                   Status 
                                   FROM WebCart 
                                   WHERE (Status = 'Checkout' 
                                          OR Status = 'Active')
                                   AND CreatedById = :UserInfo.getUserId()
                                   AND IsSecondary = False
                                   Order By CreatedDate desc 
                                   LIMIT 1];
        System.debug('cartList7-->'+UserInfo.getUserId());*/
        //
        Product2 productRecord=new Product2();
        productRecord.StockKeepingUnit='ABCSE';
        productRecord.Item_Number__c='4567';
        productRecord.Name='TEST product';
        insert productRecord;
         CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=loggedInCart.Id, Name='Default Delivery');
        insert cartDeliveryGroup;
        CartItem ctItem=new CartItem();
        ctItem.Name=productRecord.Name;
        ctItem.Product2Id=productRecord.Id;
        ctItem.CartId=loggedInCart.Id;
        ctItem.Sku=productRecord.StockKeepingUnit;    
        ctItem.Type='Product';
        ctItem.CartDeliveryGroupId=cartDeliveryGroup.Id;
        ctItem.Quantity=1;
        ctItem.SalesPrice=20;
        ctItem.TotalPrice=30;
        
        
        insert ctItem;
        //
        BWC_GuestCartController.preserveGuestCart(loggedInAcccount.Id, loggedInUser.Id, guestUUID, webNetwork.NetworkId);
        
        //List<WebCart> carts = [SELECT Id, Name, Status, IsSecondary, BWC_GuestUUID__c, AccountId, OwnerId FROM WebCart];
    }
    @isTest
    public static void updateGuestCartCatch() {
        List<WebCart> carts = [SELECT Id, Name, Status, IsSecondary, BWC_GuestUUID__c, AccountId, OwnerId FROM WebCart];
        BWC_GuestCartController.updateGuestCart(carts[0].Id,'testtttttttttttttttttttttttttttttttttttttttttttttt11');
    }
    
    
}