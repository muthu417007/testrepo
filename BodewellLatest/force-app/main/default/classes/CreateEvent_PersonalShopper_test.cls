@isTest(seeAllData=true)
public class CreateEvent_PersonalShopper_test {
	public static testMethod void CreateServiceAppointments(){
        Test.startTest();
        Lead recLead = new Lead();
        recLead.LastName ='Test Firstname';
        recLead.FirstName = 'Test Lastname';
        recLead.Company = 'N/A';
        insert recLead;
        //
        String strName = 'Gowsic';
		//List<ServiceResource> ListResource = [SELECT Id,RelatedRecordId, Name FROM ServiceResource WHERE Name = :strName or Name='test' or Name='Ankita'];
		List<ServiceResource> ListResource = [SELECT Id,RelatedRecordId, Name FROM ServiceResource where RelatedRecordId != null LIMIT 1];
        //
        String strName1 = 'Personal Shopper';
		//List<ServiceTerritory> ListServiceTerritory = [SELECT Id FROM ServiceTerritory WHERE Name = :strName1 or Name='NewYork' or Name='Personal Shopper'];
		List<ServiceTerritory> ListServiceTerritory = [SELECT Id FROM ServiceTerritory LIMIT 1];
        //
		ServiceAppointment recSA = new ServiceAppointment();
    	recSA.Country = 'United States';
        recSA.City = 'Louisville';
        recSA.Street = '4000 Buechel Bank Road';
        recSA.ServiceTerritoryId = ListServiceTerritory[0].Id;
        recSA.PostalCode = '40218';
        recSA.State = 'KY';
        recSA.Subject = 'Personal Shopper Appointment';
        DateTime dtStartDatetime = DateTime.newInstance(datetime.now().year(), datetime.now().month(), datetime.now().day(), datetime.now().hour(), datetime.now().minute(), datetime.now().second());
        DateTime dtEndDatetime = DateTime.newInstance(datetime.now().year(), datetime.now().month(), datetime.now().day(), datetime.now().hour(), datetime.now().minute(), datetime.now().second());
        recSA.SchedStartTime = DateTime.newInstance(datetime.now().year(), 01, datetime.now().day(), datetime.now().hour(), datetime.now().minute(), datetime.now().second());
        recSA.SchedEndTime = DateTime.newInstance(datetime.now().year(), 01, datetime.now().day(), datetime.now().hour()+1, datetime.now().minute(), datetime.now().second());
		recSA.ParentRecordId = recLead.Id;
		recSA.Description = 'test';
		recSA.AssignedResource__c = ListResource[0].Id;
      //  recSA.Email = 'Gowsic.S@geappliances.com';
       // recSA.Phone = '1111111111';
        recSA.ConsumerTimezone__c = 'America/New_York';
        recSA.ServiceResourceUserId__c = ListResource[0].RelatedRecordId;
        insert recSA;
        Test.stopTest();
    }
}