public with sharing class BWC_addMemberSKUToCart {
    @AuraEnabled
    Public Static CartItem  addmemberSkuToCart(String cartId,String accId,String webstoreid,String proId )
    {
       // ConnectApi.CartItemInput input=new ConnectApi.CartItemInput();
       // input.productId=proId;
       // input.quantity='1';
       // input.type=ConnectApi.CartItemType.PRODUCT;
        
       // return ConnectApi.CommerceCart.addItemToCart(webstoreid, accId,'0a68B00000008uDQAQ' , input);
      CartItem item=new CartItem();
       item.Product2Id=proId;
        insert item;
       return item;
       
    }
}