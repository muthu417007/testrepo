@isTest
private class TestMeetCompsController {
    public TestMeetCompsController() {

    }
    @TestSetup
    static void createMeetComps(){
        Account acc = new Account( Name ='TestAccount',
        BillingStreet = 'Test Street',
        BillingCity = 'AIEA',
        BillingState = 'HI',
        BillingPostalCode = '96701',
        Region__c = 125,
        Zone__c = '09',
        Meet_Comp_Eligibility__c = 'National'
        );
        insert acc;
        Contact con = new Contact(firstName='test', lastName = 'last' , phone = '9986140140',
        AccountId=acc.Id);
        insert con;
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = new User(Alias = 'newUser', Email='TestTest1234@User.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName = 'TestTest1234@User.com');
        insert testUser;
        List<Meet_Comp__c> mcs = new List<Meet_Comp__c>{
            new Meet_Comp__c(Termination_Date__c=Date.newInstance(2022,07,15), Account__c=acc.Id, Effective_Date__c=Date.newInstance(2022,07,11),
                                MC_Type__C='MC', Contact_Name__c=con.Id, GEA_Individual_who_received_the_data__c = testUser.Id),
            new Meet_Comp__c(Termination_Date__c=Date.newInstance(2022,07,15), Account__c=acc.Id, Effective_Date__c=Date.newInstance(2022,07,11),
                                MC_Type__C='MC', Contact_Name__c=con.Id, Stage_Name__c='Awaiting Approval', GEA_Individual_who_received_the_data__c = testUser.Id)
        };
        insert mcs;
    }

    
    @isTest static void testScenario1(){
        List<Meet_Comp__c> mcIds = [Select id from Meet_Comp__c];
        List<String> Ids = new List<String>();
        for(Meet_Comp__c mc: mcIds){
            Ids.add(mc.Id);
        }
        test.StartTest();
        //MeetCompsController obj = new MeetCompsController();
        MeetCompsController.fetchMeetComps(Ids);
        MeetCompsController.getMeetComps(Ids);
        test.stopTest();
    }
    
     @isTest static void testScenario2(){
        List<Meet_Comp__c> mcIds = [Select id from Meet_Comp__c where Stage_Name__c!='Awaiting Approval'];
        List<String> Ids = new List<String>();
        for(Meet_Comp__c mc: mcIds){
            Ids.add(mc.Id);
        }
        test.StartTest();
        //MeetCompsController obj = new MeetCompsController();
        MeetCompsController.fetchMeetComps(Ids);
        MeetCompsController.getMeetComps(Ids);
        test.stopTest();
    }
}