/**
* @author Abhishek
* @date 08/08/2023
* @description This class is a controller of BWC_SocialLinks LWC component
* */
public class BWC_SocialLinksController {
    /*
* @description This method is used to fetch metadata record and send to the BWC_SocialLinks LWC component
* @param
* @return List<BWC_Links__mdt>
*/
    @AuraEnabled(cacheable=true)
    public static List<BWC_Links__mdt>  getSocialMediaLinks() {
            List<BWC_Links__mdt> links = [SELECT newUrl__c, 
                                          DeveloperName 
                                          FROM BWC_Links__mdt];
            return links; 
    }
}