public without sharing class PS_BigCommerceConnectionConfigHelper {

    public static BigCommerce_Connection__c getBigCommerceConnectionConfig(String domain) {
        return [
                SELECT Id,Auth_Client__c,Auth_Token__c,API_Base_Url__c,Client_Id__c,Connected_App_Id__c,
                        Client_Secret__c,Connected_App_Name__c,Domain__c,Store_Hash__c,Preview_Key__c
                FROM BigCommerce_Connection__c
                WHERE Domain__c = :domain
                LIMIT 1
        ];
    }

    public static List<BigCommerce_Connection__c> getAllBigCommerceConnectionConfig() {
        return [
                SELECT Id,Auth_Client__c,Auth_Token__c,API_Base_Url__c,Client_Id__c,Connected_App_Id__c,
                        Client_Secret__c,Connected_App_Name__c,Domain__c,Store_Hash__c,Preview_Key__c
                FROM BigCommerce_Connection__c
        ];
    }
}