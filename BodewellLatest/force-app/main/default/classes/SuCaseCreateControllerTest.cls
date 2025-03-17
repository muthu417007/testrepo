@isTest
public with sharing class SuCaseCreateControllerTest {
  public static testmethod void fetchFieldsTest(){
      Case cs = new Case();
      cs.Subject = 'Test Case';
      cs.Description = 'Test Case';
      ContentVersion contentVersionInsert = new ContentVersion(Title = 'Test',PathOnClient = 'Test.jpg',VersionData = Blob.valueOf('Test Content Data'),IsMajorVersion = true);
      insert contentVersionInsert;
      List<ContentVersion> contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionInsert.Id LIMIT 1];
      Test.StartTest();
          suCaseCreateController.FetchFields('NewCase');
          if(!contentVersionSelect.isEmpty()){
              suCaseCreateController.SaveCase('NewCase', cs, new List<String>{contentVersionSelect[0].ContentDocumentId});
          }else{
              suCaseCreateController.SaveCase('NewCase', cs, new List<String>());
          }
      Test.StopTest();
  }
    
}