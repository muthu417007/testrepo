public class Related_products {
@AuraEnabled
public static String getproductsFromSku(String accessories,String optionalCharge,String pairingModels){
    
    String sku = accessories;
        System.debug('skufromproduct'+ sku );
    return sku;
    

}
}