//******************************************************************************************
//Name : BDW_Knowledge_Articles 
//Requirement : To fetch knowledge articles for display on Desktop View and Mobile View
//******************************************************************************************
//History
//	Version				Author					Date				Detail
//  1.0					Yogesh Sharma			11/21/2022			Initial
//******************************************************************************************
//@description : To fetch knowledge articles for display on Desktop View and Mobile View
public without sharing class BDW_Knowledge_Articles 
{
    //@description : To fetch knowledge articles for display on Desktop View
    @AuraEnabled(Cacheable=true)
    public static Knowledge__kav getKnowledgeArticle(String urlname)
    {
       return [SELECT Id, Solution__c, KnowledgeArticleId, Title, UrlName, Overview__c, Related_Resource__c
               FROM Knowledge__kav 
               where UrlName =:urlname Limit 1];
    }
    
    //@description : To fetch URLs of Article for FAQ page
    @AuraEnabled(Cacheable=true)
    public static List<Knowledge__kav> getKnowledgeArticleURL(String resourceName)
    {
       return [SELECT Id, Related_Resource__c, Title, UrlName 
               FROM Knowledge__kav 
               WHERE Related_Resource__c =:resourceName];
    }
    
    //@description : To fetch knowledge articles for display on Mobile View
    @AuraEnabled(Cacheable=true)
    public static BW_KnowledgeArticleMobile getKnowledgeArticleMobile(String urlname)
    {
    	Knowledge__kav knowArticle= [SELECT Id, Solution__c, Overview__c, UrlName
                                     FROM Knowledge__kav 
                                     WHERE UrlName =:urlname Limit 1];
        String solution = knowArticle.Solution__c;
        List<String> overviewList = knowArticle.Overview__c.split(';');
        Integer count = (solution.countMatches('<h3 id='));
        
        BW_KnowledgeArticleMobile mobileArticle = new BW_KnowledgeArticleMobile();
        mobileArticle.heading = solution.substringBefore('<h3 id="section1">');
        List<BW_subItem> mobileSubItem = new List<BW_subItem>();
        for(integer i = 0 ; i < count ; i++)
        {
            BW_subItem subItem = new BW_subItem();
            if(i < (count-1))
            {
                subItem.subItemHeading = overviewList[i];
                subItem.subItemContent = solution.substringBetween('</h3>','<h3 id=');
                solution = solution.replaceFirst('<h3 id=', '');
                solution = solution.replaceFirst('</h3>', ''); 
            }
            else if(i == (count-1))
            {
                subItem.subItemHeading = overviewList[i];
                subItem.subItemContent = solution.substringBetween('</h3>','</span></p>');
            }
            mobileSubItem.add(subItem);
        }
        mobileArticle.subItemList = mobileSubItem;
        return mobileArticle;
    }
    
    //@description : Wrapper Class
   	public class BW_KnowledgeArticleMobile
    {
        @AuraEnabled public String heading;
        @AuraEnabled public List<BW_subItem> subItemList;
    }
    
    //@description : Wrapper Class
    public class BW_subItem
    {
        @AuraEnabled public String subItemHeading;
        @AuraEnabled public String subItemContent;
    }
}