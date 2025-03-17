@isTest
public class BWC_MYA_Configurations_Controller_Test {
    
    @isTest
    public static void getSocialMediaLinksTest(){
        test.startTest();
         BWC_MYA_Configurations__mdt mdtLinks = BWC_MYA_Configurations_Controller.getBwcMyaMetaData();
         System.assertEquals(True, mdtLinks!=null);
        test.stopTest();
    }

}