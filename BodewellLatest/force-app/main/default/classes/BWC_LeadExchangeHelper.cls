//******************************************************************************************
// Author:       Akhil M R
// Company:      TCS
// Created Date: 23/11/2023
//******************************************************************************************
//@description : Apex Class to handle helper methods for lead management
public without sharing class BWC_LeadExchangeHelper {	
    //@description : Apex method to get metadata configurations
    @AuraEnabled(cacheable=true) 
    public static Bodewell_Lead_Exchange__mdt getBodewellLeadExchangeMetaData() {
        String envName = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox ?
                Url.getOrgDomainUrl().getHost().split('--').get(1).split('\\.').get(0) :
                'prod'; 
        Bodewell_Lead_Exchange__mdt mc = Bodewell_Lead_Exchange__mdt.getInstance(envName);
        return mc;
    }
    //@description : Apex method to get encrypted text from an input string value
    public static string getEncrypetedText(String input){
        Blob key = Blob.valueOf('1234567890123456');
        Blob cipherText = Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(input));
        String encodedCipherText = EncodingUtil.base64Encode(cipherText);
        return encodedCipherText;
    }
    //@description : Apex method to get decrypted text from a cipher text
    public static string getDecrypetedText(String encodedCipherText){
        Blob key = Blob.valueOf('1234567890123456');
        Blob encodedEncryptedBlob = EncodingUtil.base64Decode(encodedCipherText);
        Blob decryptedBlob = Crypto.decryptWithManagedIV('AES128', key, encodedEncryptedBlob);
        String decryptedClearText = decryptedBlob.toString();
        return decryptedClearText;
    } 
    //@description : Apex method to get guid
    public static string getGuId(){
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8);
        return guid;
    } 
    //@description : Apex method to get distance between two lat long values
    public static Decimal calculateHaversineDistance(Decimal lat1, Decimal lon1, Decimal lat2, Decimal lon2) {
        // Earth's radius varies from 6356.752 km at the poles to 6378.137 km at the equator
        Double radius = 6371.00;
        Double dLat = toRadians(lat2-lat1);
        Double dLon = toRadians(lon2-lon1);
        Double a = Math.sin(dLat/2) * Math.sin(dLat/2) +
            Math.cos(toRadians(lat1)) * Math.cos(toRadians(lat2)) *
            Math.sin(dLon/2) * Math.sin(dLon/2);
        Double c = 2 * Math.asin(Math.sqrt(a));
    
        double kmToMiles = 0.621371;
        return radius * c * kmToMiles;
    }
    //@description : Apex method to get radian value for a double value
    private static Double toRadians(Decimal degree){
        return degree * 3.1415926 / 180;
    }
    //@description : Apex method to get formatted hour value for a integer value
    //private static String getFormattedHour(Integer input){
    //    return (input > 12) ? String.valueOf(math.mod(input,12)) : String.valueOf(input);
    //}
    //@description : Apex method to get formatted minutes value for a integer value
    //private static String getFormattedMinutes(Integer input){
    //    return (input < 10) ? '0' + input : String.valueOf(input);
    //}
    //@description : Apex method to get Meridiem for a integer value
    //private static String getMeridiem(Integer input){
    //    return (input < 12) ? 'AM' : 'PM';
    //}
}