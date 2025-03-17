//******************************************************************************************
//Name : BDW_Knowledge_Articles_test 
//Requirement : To fetch knowledge articles for display on Desktop View and Mobile View
//******************************************************************************************
//History
//	Version				Author					Date				Detail
//  1.0					Yogesh Sharma			11/21/2022			Initial
//******************************************************************************************
//@description : To test fetchecd knowledge articles
@isTest
private class BDW_Knowledge_Articles_test 
{
	@isTest
    static void getKnowledgeArticle_test()
    { 
        Knowledge__kav knowledgeArt = New Knowledge__kav();
        knowledgeArt.Title = 'Why is my refrigerator making noises?';
        knowledgeArt.UrlName = 'Why-is-my-refrigerator-making-noises';
        knowledgeArt.Overview__c = 'Buzzing or humming;Squeaking or rattling;Clicking;Rapid tapping;Ask an expert';
        knowledgeArt.Related_Resource__c = 'Refrigerator';
        knowledgeArt.Solution__c = '<h2><span style="font-size: 36px;"><strong>Identify what refrigerator sounds are a real problem</strong></span></h2><p><span style="font-size: 18px;">The low-grade hum and occasional clicking of a refrigerator is regular background noise in your home. But when you hear uncommon noises, it could be a sign your refrigerator needs maintenance or even repair. Our experts can tell the difference, and with their knowledge we&rsquo;ll help you identify what the different refrigerator sounds mean.</span></p><p>&nbsp;</p><h3 id="section1"><strong><span style="font-size: 28px;">1. Buzzing or humming</span></strong></h3><p><span style="font-size: 18px;">The regular buzz or hum of a refrigerator is generally unobtrusive. If you notice noises louder than usual, there could be a few causes. Check for smaller issues first like a warning light. Hearing a combination or buzzing and knocking? It could be an issue with your refrigerator&rsquo;s compressor.</span></p><p>&nbsp;</p><h3 id="section2"><span style="font-size: 28px;"><strong>2. Squeaking or rattling</strong></span></h3><p><span style="font-size: 18px;">The first place to check when you hear squeaking or rattling is the fridge&rsquo;s circulation fan. This fan can be affected by built-up debris, corrosion, or wear and tear over time. The circulator fan is accessible behind an interior panel in the back of your fridge. Restore your fan to clean condition on your own or with professional service as part of your refrigerator&rsquo;s routine maintenance.</span></p><p>&nbsp;</p><h3 id="section3"><span style="font-size: 28px;"><strong>3. Clicking</strong></span></h3><p><span style="font-size: 18px;">It&rsquo;s not unusual for fridges to occasionally make clicking noises. However, if your fridge makes loud clicks often, that&rsquo;s a sign of trouble. If it sounds like it&rsquo;s coming from the interior, the issue could be small, like an improperly installed icemaker. But you may want to call an expert to review your refrigerator for more complicated causes, like a malfunctioning condenser coil or starter relay.</span></p><p>&nbsp;</p><h3 id="section4"><span style="font-size: 26px;"><strong>4. Rapid tapping</strong></span></h3><p><span style="font-size: 18px;">Hear continuous tapping from the refrigerator? Often this points to a temperature issue, usually ice build-up near your fridge&rsquo;s fan. You can temporarily fix this at home, but an expert service appointment will be better for your refrigerator long-term.</span></p><p>&nbsp;</p><h3 id="section5"><strong><span style="font-size: 26px;">Need an expert diagnosis of your refrigerator?</span></strong></h3><p><span style="font-size: 18px;">When your refrigerator goes from a gentle hum to a wall of noise, it&rsquo;s an indication of a real problem. If you need more assistance beyond home troubleshooting, reach out to the experts at Bodewell. Call or schedule a virtual appointment for appliance care today, so you can get back to enjoying the comforts of home.</span></p>';
        insert knowledgeArt;
        BDW_Knowledge_Articles.getKnowledgeArticle('Why-is-my-refrigerator-making-noises');
        BDW_Knowledge_Articles.getKnowledgeArticleMobile('Why-is-my-refrigerator-making-noises');
        BDW_Knowledge_Articles.getKnowledgeArticleURL('Refrigerator');
    }
}