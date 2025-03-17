/**
* @author Abhishek Bisht
* @date 22/08/2023
* @description The purpose of this class is to add the products into cart
* */
public class BWC_CreateCartItem {
      /*
* @description The purpose of this method is to create the cart Item
* @param productId - It contains the productId coming from Lwc Component 
* @param quantity - It contains the quantity of the product
* @param unitPrice - It contains the price of product.
* @param sku - It contains the product StockKeepingUnit
* @return void
*/
    @AuraEnabled
    public static void bwc_CreateCartItemMethod(String productId,String quantity,Decimal unitPrice,String sku) {
        try{
            List<WebCart> cartList=[Select Id from WebCart where Status='Active' OR Status='Checkout' limit 1];
            System.debug('cartList>>'+cartList);
            Product2 productRecord=[Select Id,Name from Product2 where Id=:productId limit 1];
            if(cartList.isEmpty()){
                System.debug('insideIf');
                Id accountIdInstance = [Select AccountId from User where Id =:UserInfo.getUserId() LIMIT 1][0].AccountId;
                System.debug('accId>>'+accountIdInstance);
                WebStore webStore = [SELECT Id FROM WebStore WHERE Name = 'Bodewell Store' LIMIT 1];
                WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=accountIdInstance);
                insert cart;
                
                cartList.add(cart);
            }
            CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cartList[0].Id, Name='Default Delivery');
            insert cartDeliveryGroup;
            if(productId!=null && quantity!=null && unitPrice!=null && sku!=null){
                CartItem ctItem=new CartItem();
                ctItem.Name=productRecord.Name;
                ctItem.Product2Id=productId;
                ctItem.CartId=cartList[0].Id;
                ctItem.Sku=sku;    
                ctItem.Type='Product';
                ctItem.CartDeliveryGroupId=cartDeliveryGroup.Id;
                ctItem.Quantity=Integer.valueOf(quantity);
                ctItem.SalesPrice=unitPrice;
                ctItem.ListPrice=unitPrice;    
                ctItem.UnitAdjustedPrice=unitPrice;
                ctItem.TotalPrice=unitPrice;
                
                
                insert ctItem;
                System.debug('ctItem>>'+ctItem);
            }
        }
        catch(DMLException e){
            System.debug('Error>>'+e.getMessage()+'   >>>LineNumber>>'+e.getLineNumber());
        }
        
    }
}