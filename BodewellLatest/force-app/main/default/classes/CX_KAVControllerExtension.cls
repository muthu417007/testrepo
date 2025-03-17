public with sharing class CX_KAVControllerExtension {
    private Knowledge__kav knowledge;
    public List<SelectOption> languages { get; set; }
    public String selectedLanguage { get; set; }

    public void setKnowledge(Knowledge__kav knowledge) {
        this.knowledge = knowledge;
    }
    
    public CX_KAVControllerExtension(ApexPages.StandardSetController stdSetController){
        setKnowledge((Knowledge__kav)stdSetController.getRecord());
        loadLanguages();
    }
 
    public PageReference save() {
        try
        {
            Knowledge__kav newKav = new Knowledge__kav(
                Title = knowledge.Title,
                Summary = knowledge.Summary,
                Keywords__c = knowledge.Keywords__c,
                Language = selectedLanguage,
                UrlName = knowledge.UrlName
            );
            insert newKav;
            PageReference pageRef = new PageReference('/'+newKav.Id);
            return pageRef;
        } catch (Exception ex)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage());
            ApexPages.addMessage(msg);
            return null;
        }  
    }

    public void loadLanguages() {
        languages = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Knowledge__kav.Language.getDescribe();
		List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();

		for(Schema.PicklistEntry entry : entries){
			languages.add(new SelectOption(entry.getValue(), entry.getLabel()));
		}     
    }
}