/**
* @author Abhishek
* @date 09/08/2023
* @description This test class of BWC_SocialLinksController
* */
@isTest
public class BWC_SocialLinksControllerTest {	
     /*
* @description This method is used to cover getSocialMediaLinks method
* @param
* @return
*/
    @isTest
    public static void getSocialMediaLinksTest(){
        test.startTest();
        List<BWC_Links__mdt> mdtLinks = BWC_SocialLinksController.getSocialMediaLinks();
        System.assertNotEquals(0, mdtLinks.size());
        test.stopTest();
    }
}