public without sharing class PS_ContactTriggerHandlerHelper {

    private Long nowTime;
    private Integer counter;
    private Long randomLong;
    private Boolean useCreatedDate = false;

    public PS_ContactTriggerHandlerHelper() {
        initVariables(false);
    }

    public PS_ContactTriggerHandlerHelper(Boolean useCreatedDate) {
        initVariables(useCreatedDate);
    }

    public void setContactsGlobalIds(List<Contact> contacts) {
        for (Contact contact : contacts) {
            if (String.isBlank(contact.Global_Customer_Id__c)) {
                String globalId = (useCreatedDate ?Datetime.valueOf(contact.CreatedDate).getTime() : nowTime) + '-';
                globalId += counter++ + '-';
                globalId += randomLong;
                contact.Global_Customer_Id__c = globalId;
            }
        }
    }
    
     public String setGlobalIdForPersonContact(String globalId) {
         system.debug('in setGlobalIdForPersonContact');
            String globalIdvalue;
            if (String.isBlank(globalId)) {
                globalId = (useCreatedDate ? nowTime : nowTime ) + '-';
                globalId += counter++ + '-';
                globalId += randomLong;
                globalIdvalue = globalId;
              }
           return globalIdvalue;
     }

    private void initVariables(Boolean useCreatedDate) {
        nowTime = System.Datetime.now().getTime();
        counter = 100;
        randomLong = Crypto.getRandomLong();
        if (randomLong < 0) {
            randomLong *= -1;
        }
        this.useCreatedDate = useCreatedDate;
    }
}