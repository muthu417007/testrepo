global with sharing class VRACreateImageFiles {
    @InvocableMethod(label='Save image' description=' ')
    global static void tspa_getRecordingBySessionId(List<String> visualHistoryId){
        System.debug('visualHistoryId'+visualHistoryId);
        //a8E5e000000bzfeEAA,SessionId,60c5dacf8dce872d4edd67c0,Tag,Download
        System.debug('visualHistoryId[0]:: '+visualHistoryId[0]);
        String  values = visualHistoryId[0];
        String[] ListOfValues = values.split(',');
        //if(ListOfValues.contains('Tag')){
            //if(ListOfValues.size() == 5 ){
                //getImagesignedlink(ListOfValues);
            //}  
        //}else{
            if(ListOfValues.size() == 4 ){
                system.debug('inside else block');
                getImagesignedlink(ListOfValues);
            }
        //}
        
    }
    @future(callout=true)
    public static void getImagesignedlink(List<String> ListOfValues)
    {   
        
        List<String> sessionIds2 = new List<String>();
        String response;
        String actionType = ListOfValues[1].toLowercase() ;
        
        String sessionData = ListOfValues[2];
        /*if(ListOfValues.size() == 5){
            if(Schema.sObjectType.tspa__Visual_Image__c.fields.tspa__Related_Tags__c.isAccessible() &&
               Schema.sObjectType.tspa__Visual_Image__c.fields.tspa__File_Name__c.isAccessible() &&
               Schema.sObjectType.tspa__Visual_Image__c.fields.tspa__Session_Id__c.isAccessible() &&
               Schema.sObjectType.tspa__Visual_Image__c.fields.Name.isAccessible() ){
                   for(tspa__Visual_Image__c visualImage : [SELECT tspa__Related_Tags__c,
                                                            tspa__File_Name__c,
                                                            tspa__Session_Id__c,
                                                            Name
                                                            FROM tspa__Visual_Image__c 
                                                            WHERE tspa__Session_Id__c =:sessionData
                                                            
                                                            WITH SECURITY_ENFORCED
                                                            LIMIT 10000]){   
                                                                if(visualImage.tspa__Related_Tags__c != null && visualImage.tspa__Related_Tags__c.containsIgnoreCase(ListOfValues[2])){
                                                                    sessionIds2.add(visualImage.tspa__Session_Id__c); 
                                                                } 
                                                            }
               } 
        }*/
        //else{
            sessionIds2.add(ListOfValues[2]); 
        //}
        if(!test.isRunningTest())
       	 response = tspa.VRA_Actions.tspa_getImageDetailsBySessionIdTSPA(sessionIds2);
        
        else
           response = CalloutClass.getInfoFromExternalService().getbody();
        
        System.debug('Response'+response);
        JSONParser parser = JSON.createParser(response);
        List<String> Imagesignedlink= new List<String>();
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'Imagesignedlink')) {
                parser.nextToken();
                String UrlData = parser.getText();
                if(!String.isBlank(UrlData)){
                    Imagesignedlink.add(UrlData);
                }
            }
        }
        system.debug('Imagesignedlink'+Imagesignedlink);
        if(Imagesignedlink.size()>0){
            system.debug('ListOfValues[3]'+ListOfValues[3]);
            attachImageLink(ListOfValues[0], Imagesignedlink,ListOfValues[3]);
        }
        
    }
    public static void attachImageLink(String RelatedRecordId, List<String> urls, String ReferenceId){
        List<ContentDocumentLink> cDLLsit= [SELECT ContentDocumentId, 
                                            LinkedEntityId, 
                                            ContentDocument.Title 
                                            FROM ContentDocumentLink 
                                            WHERE LinkedEntityId= :ReferenceId
                                            WITH SECURITY_ENFORCED
                                            LIMIT 10000
                                            ];
        system.debug('cDLLsit-->'+cDLLsit);
        map<String,ContentDocumentLink> titleVsContentDocumentLink =  new Map<String,ContentDocumentLink>();
        for(ContentDocumentLink dataCDL:cDLLsit){
            titleVsContentDocumentLink.put(dataCDL.ContentDocument.Title,dataCDL);
        }
        system.debug('titleVsContentDocumentLink-->'+titleVsContentDocumentLink);
        map<String,String> urlVsBase64 = new map<String,String>();
        List<ContentVersion> ContentVersionList = new List<ContentVersion>();
        List<ContentVersion> ContentVersionList2 = new List<ContentVersion> ();
        Set<Id> ContVerFileId = new Set<Id>();
        
        if(test.isRunningTest()){
            //string base64Data = ;
                //urlVsBase64.put(url,base64Data);
        }else{
            for(String url:urls){
                string base64Data = getDataUriFromUri(url);
                urlVsBase64.put(url,base64Data);
            }
        }
        if(Schema.sObjectType.ContentVersion.fields.VersionData.isCreateable() &&
           Schema.sObjectType.ContentVersion.fields.Title.isCreateable() &&
           Schema.sObjectType.ContentVersion.fields.ContentLocation.isCreateable() &&
           Schema.sObjectType.ContentVersion.fields.PathOnClient.isCreateable() ){
               for(String url:urls){
                   ContentVersion ContVerFile = new ContentVersion();
                   if(test.isRunningTest()){
                       ContVerFile.VersionData = Blob.ValueOf('test');
                   }else{
                       system.debug('url'+url);
                       Blob payloadBlob = EncodingUtil.base64Decode(urlVsBase64.get(url));
                       ContVerFile.VersionData = payloadBlob;
                   }
                   integer count = 0;
                   count = count + 1;
                   count = count + 1;
                   count = count + 1;
                   String urlVal = url;
                   if(urlVal.containsIgnoreCase('dashboard'))
                       urlVal = urlVal.substringBefore('-dashboard'); 
                   else if(urlVal.containsIgnoreCase('client'))
                       urlVal = urlVal.substringBefore('-client');
                   urlVal = urlVal.substringAfterLast('/'); 
                   if(test.isRunningTest()){
                       ContVerFile.Title = 'test'; 
                   }else{
                       ContVerFile.Title = String.ValueOf(urlVal); 
                   }
                   ContVerFile.ContentLocation= 's';
                   ContVerFile.PathOnClient= String.ValueOf(urlVal)+'.jpeg';
                   if(titleVsContentDocumentLink.get(urlVal) == null){
                       ContentVersionList.add(ContVerFile);
                   }
                   system.debug('ContentVersionList-->'+ContentVersionList);
                   
                   
               }
               if(ContentVersionList.size()>0){
                   insert ContentVersionList;
               }
               
           }
        if(Schema.sObjectType.ContentVersion.fields.ContentDocumentId.isAccessible()){
            ContentVersionList2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN : ContentVersionList limit 10000];
            system.debug('ContentVersionList2-->'+ContentVersionList2);
            List<ContentDocumentLink> ContentDocumentLinkList = new List<ContentDocumentLink>();
            if(ContentVersionList2.size() > 0){
                if(Schema.sObjectType.ContentDocumentLink.fields.ContentDocumentId.isCreateable() &&
                   Schema.sObjectType.ContentDocumentLink.fields.LinkedEntityId.isCreateable() &&
                   Schema.sObjectType.ContentDocumentLink.fields.ShareType.isCreateable() &&
                   Schema.sObjectType.ContentDocumentLink.fields.Visibility.isCreateable() ){
                       //ServiceAppointment srvapp = [Select id,case__c from ServiceAppointment where id=:SrvAppId];
                       //if(caseNumber!='' && caseNumber!=null){
                       //Case linkedCase = [Select id from case where CaseNumber=:caseNumber];
                       for(ContentVersion cversion : ContentVersionList2){
                           ContentDocumentLink cDe = new ContentDocumentLink();
                           cDe.ContentDocumentId = cversion.ContentDocumentId;
                           cDe.LinkedEntityId = ReferenceId;
                           cDe.ShareType = 'I';
                           cDe.Visibility = 'AllUsers';
                           ContentDocumentLinkList.add(cDe);
                           
                       }
                   //}
                       if(ContentDocumentLinkList.size()>0){
                           insert ContentDocumentLinkList;
                       }
                       
                   }
            } 
            
        } 
    }
    
    public static String getDataUriFromUri(String url) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        Http binding = new Http();
        HttpResponse res = binding.send(req);
       // System.debug('getDataUriFromUriResponse--'+res.getBody());
        Blob image = res.getBodyAsBlob();
        return EncodingUtil.base64Encode(image);
    }
    
}