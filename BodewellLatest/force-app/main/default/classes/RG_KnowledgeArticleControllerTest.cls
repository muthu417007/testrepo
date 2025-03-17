//******************************************************************************************
// Author:       Yogesh Sharma
// Company:      TCS
// Created Date: 11/04/2023
//******************************************************************************************
//@description : Apex Class to test knowledge article requests
@isTest
private class RG_KnowledgeArticleControllerTest 
{
    //@description : Apex method to test knowledge article requests
    @isTest
    static void knowledgeArticleControllerTest() 
    {
        Profile p = [select Id from profile where name='System Administrator'];
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';        
        User u1 = new User(
            Alias = 'standt',
            Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName=uniqueUserName);
        u1.UserPermissionsKnowledgeUser = true;
        insert u1;
        
        System.runAs(u1)
        {
            RecordType RT = [SELECT Id, Name FROM RecordType WHERE Name = 'Repair' LIMIT 1];
            
            Knowledge__kav knowledgeArt = New Knowledge__kav();
            knowledgeArt.Title = 'Why is my refrigerator making noises123?';
            knowledgeArt.UrlName = 'Why-is-my-refrigerator-making-noises123';
            knowledgeArt.Summary = 'Why is my refrigerator making noises123';
            knowledgeArt.FAQ_Description__c = 'FAQ';
            knowledgeArt.Related_Resource__c = '123';
            knowledgeArt.Question__c = 'Why is my refrigerator making noises?';
            knowledgeArt.Overview__c = 'Buzzing or humming;Squeaking or rattling;Clicking;Rapid tapping;Ask an expert';
            knowledgeArt.Solution__c = '<p>If moisture has accumulated on the outside surface of your freezer, it may simply be due to a change in the weather—or it could be a sign of other issues. Let’s explore the most common causes of a wet freezer exterior—and when to take action.</p><h2>COMMON CAUSES OF CONDENSATION ON FREEZER EXTERIOR </h2> <h3 id="Humidity">1. HUMIDITY</h3><p>If you live in a humid area—or summer weather has arrived—it’s normal for some condensation to appear on the outside of your freezer. Similar to the way a cold can of soda “sweats” on a hot summer day, condensation forms when warm, moist air comes into contact with the cold surface of your freezer. As this air cools, it forms small droplets of condensation on the freezer’s exterior. This is a common occurrence and generally shouldn’t be cause for concern, especially on muggy days or in homes without air conditioning.</p><h3 id="DamagedDoorSeal">2. DAMAGED DOOR SEAL</h3><p>If condensation is forming near or around the perimeter of the freezer door, the door seal may be damaged and allowing cold air to leak out. Inspect the seal for cracks or tears and feel around for areas where cool air may be escaping. Replace the seal if you find any damage.</p><h3 id="Energy-SavingFeature">3. ENERGY-SAVING FEATURE</h3><p>If your freezer or refrigerator unit has an energy-saving feature and it’s switched on, you may notice condensation forming on your freezer’s exterior walls. This is because, in order to cut costs, the energy-saving feature turns off the anti-sweat heaters that prevent moisture from building up on the outside of your appliance. You might consider switching this energy-saving feature off to help eliminate excess moisture on the walls.</p><h3 id="ImproperClearance">4. IMPROPER CLEARANCE</h3><p>As a general rule of thumb, your freezer or refrigerator unit should have a minimum of one inch of clearance on all sides in order to ensure proper air circulation. Poor air circulation and blocked air vents can lead to temperature and moisture problems. Consult your appliance’s installation manual for proper clearances and adjust the unit as necessary.</p><h2 id="GetExpertHelp">FREEZER ISSUES? WE’RE HERE TO HELP </h2> <p>If you’re still experiencing problems and you’ve tried <a href="https://repair.geappliances.com/resources/ge-freezer/troubleshooting-guide" target="_blank">troubleshooting your freezer</a> to no avail, it may be time to enlist expert help. Our local technicians know GE Appliances inside and out, and often diagnose and resolve most issues on the first visit.* <a href="https://genet.geappliances.com/eService/Service/productSelection?Login=Guest" target="_blank">Schedule service online now</a> and we’ll get to the root of the issue.</p><br>*GE Appliances technicians carry an extensive parts inventory on their service trucks. In the event a part is not available on the service truck, a follow-up service call may be required.';
            knowledgeArt.RecordTypeId = RT.id;
            insert knowledgeArt;
            
            Knowledge__kav obj1 = [SELECT Id, Title, KnowledgeArticleId FROM Knowledge__kav WHERE Id =: knowledgeArt.Id LIMIT 1];
            system.debug(obj1);
            KbManagement.PublishingService.publishArticle(obj1.KnowledgeArticleId, true);

            List<Knowledge__kav> knowledgeArticleListFAQ = RG_KnowledgeArticleController.getKnowledgeArticleListFAQ('Refrigerator');
            Knowledge__kav knowledgeArticle = RG_KnowledgeArticleController.getKnowledgeArticle('Why-is-my-refrigerator-making-noises123');
            RG_KnowledgeArticleController.RG_mobileContent mobileContent = RG_KnowledgeArticleController.getKnowledgeArticleMobile('Why-is-my-refrigerator-making-noises123');
        }
    }
}