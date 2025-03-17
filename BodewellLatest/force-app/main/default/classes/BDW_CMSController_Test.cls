/**
*@description : Class has been created to test 'BDW_CMSController' Class created for Bodewell project.
Name: Kanishtika Gupta
Copyright: © 2021 GE Appliances
**********************************************

History
---------------------------------------------
Version    Author    Date    Details
-------    -------    -------    -------
1.0      Kanishtika Gupta 19/11/2022   Created
**********************************************
**********************************************/
@isTest(seeAllData = true)
public class BDW_CMSController_Test {
   @isTest
    static void getContent_Test()
    {
        BDW_CMSController.getContent('MCLQAO2C7ASNBAVEARKLFTABUUFM',0,1,'en_US','cms_image');
        BDW_CMSController.getContentList(0,1,'en_US','cms_image');
    }
}