public class TagPortalController{
    
    public String username{get;set;}
    public String password{get;set;}
    public String token1 {get;set;}
    public String token2 {get;set;}
    public String token3 {get;set;}
    public String token4 {get;set;} 
    
    public PageReference login() {
        TagPortal__mdt settings = [SELECT Id,Key__c, GETech__c, NonGeTech__c, GeTechName__c, NonGeTechName__c, Label 
                                 FROM TagPortal__mdt
                                 WHERE Label = 'TagPortal'
                                 LIMIT 1];
        token1 = ApexPages.currentPage().getParameters().get('t');
        String startUrl = ApexPages.currentPage().getParameters().get('su');
        String searchString = ApexPages.currentPage().getParameters().get('search');
        token2 = token1.replaceAll('_','+');
        token3 = token2.replace('*','=');
        token4 = token3.replaceAll('~', '/');
      
        String iv = '                ';
        Blob test1;
        try{
            test1 =  Crypto.decrypt('AES128', blob.valueOf(settings.key__c), blob.valueOf(iv), EncodingUtil.base64Decode(token4));
        } catch(exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid Token'));
            return null;
        }
        
        system.debug(test1);
        String test2 = test1.toString();
        Integer sIndexValue = test2.indexOf('passwd=');
        if(sIndexValue < 1){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid Token'));
            return null;
        }
        system.debug(test2);
        system.debug(test2.contains('NON'));
        String connectString='';
        /*if(test2.contains('NON')){
            connectString = 'https://appliances.force.com/TAG/login?pw=' + settings.NonGeTech__c + '&un=' + settings.NonGeTechName__c;
        } else {
            connectString = 'https://appliances.force.com/TAG/login?pw=' + settings.GETech__c + '&un=' + settings.GeTechName__c; 
        }*/
//String testStart = 'https://appliances.force.com/TAG/s/article/Factory-Service-Monthly-Technical-Training-2017-Index-36908?language=en_US';
//connectString = 'https://appliances.force.com/TAG/login?pw=' + settings.GETech__c + '&un=' + settings.GeTechName__c + '&startURL=' + testStart; 
// https://appliances.force.com/TAG/s/search-result#searchString=XDF300PSN4SS&  
  
       /* if(string.isBlank(startUrl)){
            connectString =  '&startURL=' + startUrl; 
        } else */

	/*	if(!string.isBlank(searchString)){
            String encodedSearch =   EncodingUtil.urlEncode('https://uatfull-appliances.cs172.force.com/TAG/s/search-result#searchString='+searchString,'UTF-8'); 
            //connectString = connectString + '&startURL=' + 'https://appliances.force.com/TAG/s/search-result#searchString=' +searchString; 
            startUrl = encodedSearch ; 
        }*/
        
         System.debug('This SITE NAME: startUrl..>>>>>>> '+startUrl);
        
              List<String> pathPrefixSplit = Site.getPathPrefix().split('/');
        String siteName = pathPrefixSplit.size() >= 2 ? pathPrefixSplit.get(1) : null;
            
        System.debug('This SITE NAME: ..>>>>>>> '+siteName);
        //siteName.isLoginEnabled();
        //System.debug('This SITE NAME: isLoginEnabled()..>>>>>>> '+siteName.isLoginEnabled());
        
        System.debug('This SITE NAME: ..settings.NonGeTechName__c >>>>>>> '+settings.NonGeTechName__c);
        System.debug('This SITE NAME: ..settings.NonGeTech__c>>>>>>> '+settings.NonGeTech__c);
            
        PageReference siteLogin = null;
        if(test2.contains('NON')){
             siteLogin = Site.login( settings.NonGeTechName__c ,settings.NonGeTech__c,startUrl);
        } else {
             siteLogin = Site.login( settings.GeTechName__c ,settings.GETech__c,startUrl);
        }

        if(!Test.isRunningTest()) {
            System.debug('This SITE NAME: . URL path>>>>>> '+siteLogin.getUrl());
            siteLogin.setRedirect(true);
        }
         
        return siteLogin;
       
  }
    
}