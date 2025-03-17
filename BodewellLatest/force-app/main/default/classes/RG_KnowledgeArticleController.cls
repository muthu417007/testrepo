//******************************************************************************************
// Author:       Yogesh Sharma
// Company:      TCS
// Created Date: 27/03/2023
//******************************************************************************************
//@description : Apex Class to handle knowledge article requests
public with sharing class RG_KnowledgeArticleController 
{
    //@description : Apex method to handle knowledge article list request for a RESOURCE
    @AuraEnabled(cacheable=true)
    public static List<Knowledge__kav> getKnowledgeArticleListFAQ(String relatedResource) 
    {
        List<Knowledge__kav> knowledgeArticleListFAQ = New List<Knowledge__kav>();
        if(Schema.sObjectType.Knowledge__kav.fields.Id.isAccessible() &&
        Schema.sObjectType.Knowledge__kav.fields.Title.isAccessible() &&
        Schema.sObjectType.Knowledge__kav.fields.UrlName.isAccessible() &&
        Schema.sObjectType.Knowledge__kav.fields.Summary.isAccessible() &&
        Schema.sObjectType.Knowledge__kav.fields.Related_Resource__c.isAccessible() &&
        Schema.sObjectType.Knowledge__kav.fields.FAQ_Description__c.isAccessible())
        {
            knowledgeArticleListFAQ = [SELECT Id, Title, UrlName, Summary, PublishStatus
                                        FROM Knowledge__kav
                                        WHERE (Related_Resource__c =: relatedResource AND FAQ_Description__c != Null
                                               AND RecordType.Name = 'Repair' AND PublishStatus = 'Online')];
        }
        return knowledgeArticleListFAQ;
    }

    //@description : Apex method to handle knowledge article request for an article URL
    @AuraEnabled(cacheable=true)
    public static Knowledge__kav getKnowledgeArticle(String articleURL) 
    {
        Knowledge__kav knowledgeArticle = New Knowledge__kav();
        if(Schema.sObjectType.Knowledge__kav.fields.Id.isAccessible() &&
        Schema.sObjectType.Knowledge__kav.fields.Title.isAccessible() &&
        Schema.sObjectType.Knowledge__kav.fields.UrlName.isAccessible() &&
        Schema.sObjectType.Knowledge__kav.fields.Question__c.isAccessible() &&
        Schema.sObjectType.Knowledge__kav.fields.Overview__c.isAccessible() &&
        Schema.sObjectType.Knowledge__kav.fields.Summary.isAccessible() &&
        Schema.sObjectType.Knowledge__kav.fields.Solution__c.isAccessible())
        {
            knowledgeArticle = [SELECT Id, Title, UrlName, Question__c, Solution__c, Overview__c, Summary, PublishStatus
                                        FROM Knowledge__kav
                                        WHERE (UrlName =: articleURL AND RecordType.Name = 'Repair' AND PublishStatus = 'Online')
                                        LIMIT 1];
        }
        return knowledgeArticle;
    }
    /* Knowledge Article for Mobile */
    @AuraEnabled(cacheable=true)
    public static RG_mobileContent getKnowledgeArticleMobile(String articleURL)
    {
        Knowledge__kav knowArticle = New Knowledge__kav();
        if(Schema.sObjectType.Knowledge__kav.fields.Id.isAccessible() &&
        Schema.sObjectType.Knowledge__kav.fields.Title.isAccessible() &&
        Schema.sObjectType.Knowledge__kav.fields.UrlName.isAccessible() &&
        Schema.sObjectType.Knowledge__kav.fields.Solution__c.isAccessible() &&
        Schema.sObjectType.Knowledge__kav.fields.FAQ_Description__c.isAccessible())
        {
            knowArticle = [SELECT Id, Title, UrlName, Solution__c, PublishStatus
                                        FROM Knowledge__kav
                                        WHERE (UrlName =: articleURL AND RecordType.Name = 'Repair' AND PublishStatus = 'Online')
                          				LIMIT 1];
        }
        String know = knowArticle.Solution__c;
        String disclText = Label.RG_Disclaimer_Text;
		disclText = disclText.remove('\\*');        
        Integer count = know.countMatches('</h2>');
        RG_mobileContent mobileArticle = New RG_mobileContent();
        if(know.substringBetween('','<h2') != null)
        {
            mobileArticle.startText = know.substringBetween('','<h2');
        }
        else
        {
            mobileArticle.startText = null;
        }
        
        if(know.containsIgnoreCase(disclText))
        {
            mobileArticle.isDisclaimerText = true;
            know = know.replaceFirst('\\*'+disclText,'');
        }
        else
        {
            mobileArticle.isDisclaimerText = false;
        }
        List<RG_mobileSubItem> subItem = New List<RG_mobileSubItem>();
        know = know.replaceFirst(mobileArticle.startText,'');
        for(Integer i = 0 ; i < count ; i++)
        {
            RG_mobileSubItem mobileSubItem = New RG_mobileSubItem();
            if(know.substringBetween('<h2','>') == '')
            {
                mobileSubItem.subItemHeading = know.substringBetween('<h2>','</h2>');
                know = know.replaceFirst('<h2>','');
                know = know.removeStart(mobileSubItem.subItemHeading);
                if(know.contains('<h2'))
                {
                    mobileSubItem.subItemContent = know.substringBetween('</h2>','<h2');
                    know = know.replaceFirst('</h2>','');
                    know = know.removeStart(mobileSubItem.subItemContent);
                }
                else
                {
                    mobileSubItem.subItemContent = know.replaceFirst('</h2>','');
                }
                subItem.add(mobileSubItem);
            }
            else
            {
                mobileSubItem.subItemHeading = know.substringBetween('<h2'+know.substringBetween('<h2','>')+'>','</h2>');
                know = know.replaceFirst('<h2'+know.substringBetween('<h2','>')+'>','');
                know = know.removeStart(mobileSubItem.subItemHeading);
                if(know.contains('<h2'))
                {
                    mobileSubItem.subItemContent = know.substringBetween('</h2>','<h2');
                    know = know.replaceFirst('</h2>','');
                    know = know.removeStart(mobileSubItem.subItemContent);
                }
                else
                {
                    mobileSubItem.subItemContent = know.replaceFirst('</h2>','');
                }
                subItem.add(mobileSubItem);
            }
        }
        mobileArticle.subItem = subItem;
        System.debug(mobileArticle.subItem);
        return mobileArticle;
    }
    
    //@description : Apex Wrapper Class for Knowledge Article Mobile View
    public with sharing class RG_mobileContent
    {
        @AuraEnabled public String startText;
        @AuraEnabled public Boolean isDisclaimerText;
        @AuraEnabled public List<RG_mobileSubItem> subItem;
    }
    //@description : Apex Wrapper Class for Knowledge Article Sub-Item Mobile View
    public with sharing class RG_mobileSubItem
    {
        @AuraEnabled public String subItemHeading;
        @AuraEnabled public String subItemContent;
    }
}