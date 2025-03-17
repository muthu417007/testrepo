/**
* @author Abhishek Bisht
* @date 27/08/2023
* @description The purpose of this class is to get the Id of current selected address into the checkout page and send back to the bwc_checkoutaddress lwc component.
* */
public class BWC_CheckoutAddressController {
    /*
* @description The purpose of this method to get the id of Contact point address by using address street.
* @param deliveryAddressStreet - It contains the address's street
* @return Id
*/
    @AuraEnabled(cacheable=true)
    public static Id setActiveAddress(String deliveryAddressStreet) {
        try{
            System.debug('Inside BWC_CheckoutAddressController apex class');
        System.debug('deliveryAddress>>>>'+deliveryAddressStreet);
        ContactPointAddress contactPointAddressActiveInstance=[SELECT Id,
                                                               BWC_isActive__c
                                                               FROM ContactPointAddress 
                                                               WHERE Street=:deliveryAddressStreet LIMIT 1];
        return contactPointAddressActiveInstance.Id;
        }
        catch(Exception e){
            System.debug('Error Message>>'+e.getMessage());
            return null;
        }
        
    }
}