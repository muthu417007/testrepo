@isTest(seeAllData = true)
public class BWC_CustomWishListTest {
    
     static testMethod void test1() {
        Account a=new Account();
          a.Name='testName';
          a.BillingStreet='test street';
          a.BillingCity='test City';
          a.BillingState='OH';
          a.BillingPostalCode='12345';
          a.Country_Code__c='United States Of America';   
          insert a; 
          String accId = String.valueOf(a.Id);
        
           WebStoreNetwork w = [select id,WebStoreId,NetworkId from WebStoreNetwork LIMIT 1];
         
          Wishlist wList = new Wishlist();
          wList.AccountId  = a.Id;
          wList.Name = 'My Lists';
          wList.WebStoreId  = w.WebStoreId;
          insert wList;
          String wishListId = String.valueOf(wList.Id);
         
            Product2 p = new Product2();
            p.Name = 'test';
            p.ProductCode = '124';
            p.Item_Number__c = '123';
            p.StockKeepingUnit = 'sf3';
            p.BWC_Delivery_Type__c = 'sds';
            p.ProductCode = '541501';
            insert p;
          
          WishListItem listItem = new WishListItem();
          listItem.wishlistId = wList.Id;
          listItem.Product2Id = p.Id;
          listItem.Name = p.Name;
          insert listItem;
          String wishlistItemId = String.valueOf(listItem.Id);
          
         
          
        Test.startTest();
         BWC_CustomWishList.removeItemFromWishlist(w.NetworkId,accId,wishListId,wishlistItemId);
       Test.stopTest();
      }   
    
      @isTest
    public static void getWishlistItemsTest(){
         Test.startTest();
        BWC_CustomWishList.getWishlistItems();
         Test.stopTest();
    }
}
   
   /* @isTest
    public static void removeItemFromWishlistTest(){
        Account accountInstance = [SELECT Id FROM Account LIMIT 1];
        Product2 productInstance = [SELECT Id FROM Product2 LIMIT 1];
        Network networkInstance = [SELECT Id FROM Network LIMIT 1];
        WebStoreNetwork w = [select id,WebStoreId,NetworkId from WebStoreNetwork LIMIT 1];
        
        
      //  String wishListId = [SELECT Id FROM Wishlist LIMIT 1][0].Id;
       // String wishlistItemId = [SELECT Id,product2.Id FROM WishListItem WHERE wishlistId = :wishListId LIMIT 1][0].Id;
        
           ConnectApi.WishlistInput wishlistInput = new ConnectApi.WishlistInput();
    
          ConnectApi.WishlistItemInput wishlistItemInput = new ConnectApi.WishlistItemInput();          
         wishlistItemInput.productId =productInstance.id ;
        
        Test.startTest();
        BWC_CustomWishList.removeItemFromWishlist(w.NetworkId,String.ValueOf(accountInstance.Id),String.valueOf(wishlistInput.id),String.ValueOf(wishlistItemInput.id);
        Test.stopTest();
    } 
    }
} */