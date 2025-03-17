//******************************************************************************************
//Name : BDW_CreateLead 
//Requirement : To Test BDW_CreateLead
//******************************************************************************************
//History
//	Version				Author					Date				Detail
//  1.0					Yogesh Sharma			11/29/2022			Initial
//******************************************************************************************
//@description : To Test BDW_CreateLead
@isTest
private class BDW_CreateLead_Test 
{
	//@description : To Test BDW_CreateLead
    @isTest
    static void createLead_test()
    {
        Lead LD = New Lead();
        LD.FirstName = 'firstName';
        LD.LastName = 'LastName';
        LD.Email = 'test@test.com';
        LD.Phone = '1234567890';
        LD.Company = 'Company';
        LD.I_would_like_to_be_contacted__c = 'Scheduling service for my appliance';
        LD.Contact_Preference__c =  'Phone';
        LD.Comments_from_Lead__c = 'my comment';
        BDW_CreateLead.createLead(LD);
    }
}