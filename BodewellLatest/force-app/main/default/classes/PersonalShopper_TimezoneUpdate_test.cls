@isTest(SeeAllData=true)
public class PersonalShopper_TimezoneUpdate_test {
	static testMethod void testPersonalShopperRecordCreate1()
	{
        Lead recLead = new Lead();
        recLead.LastName ='Test Firstname';
        recLead.FirstName = 'Test Lastname';
        recLead.Company = 'N/A';
        insert recLead;
        //
        String strName = 'Gowsic';
		List<ServiceResource> ListResource = [SELECT Id,RelatedRecordId, Name FROM ServiceResource WHERE Name = :strName];
        //
        String strName1 = 'Personal Shopper';
		List<ServiceTerritory> ListServiceTerritory = [SELECT Id FROM ServiceTerritory WHERE Name = :strName1];
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
        recSA.Email = 'Gowsic.S@geappliances.com';
        recSA.Phone = '1111111111';
        recSA.ConsumerTimezone__c = 'America/New_York';
        recSA.ServiceResourceUserId__c = '0054P00000BptNBQAZ';
        insert recSA;
    }
    static testMethod void testPersonalShopperRecordCreate2()
	{
        Lead recLead = new Lead();
        recLead.LastName ='Test Firstname';
        recLead.FirstName = 'Test Lastname';
        recLead.Company = 'N/A';
        insert recLead;
        //
        String strName = 'Gowsic';
		List<ServiceResource> ListResource = [SELECT Id,RelatedRecordId, Name FROM ServiceResource WHERE Name = :strName];
        //
        String strName1 = 'Personal Shopper';
		List<ServiceTerritory> ListServiceTerritory = [SELECT Id FROM ServiceTerritory WHERE Name = :strName1];
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
        recSA.SchedStartTime = DateTime.newInstance(datetime.now().year(), 02, datetime.now().day(), datetime.now().hour(), datetime.now().minute(), datetime.now().second());
        recSA.SchedEndTime = DateTime.newInstance(datetime.now().year(), 02, datetime.now().day(), datetime.now().hour()+1, datetime.now().minute(), datetime.now().second());
		recSA.ParentRecordId = recLead.Id;
		recSA.Description = 'test';
		recSA.AssignedResource__c = ListResource[0].Id;
        recSA.Email = 'Gowsic.S@geappliances.com';
        recSA.Phone = '1111111111';
        recSA.ConsumerTimezone__c = 'America/New_York';
        recSA.ServiceResourceUserId__c = '0054P00000BptNBQAZ';
        insert recSA;
    }
    static testMethod void testPersonalShopperRecordCreate3()
	{
        Lead recLead = new Lead();
        recLead.LastName ='Test Firstname';
        recLead.FirstName = 'Test Lastname';
        recLead.Company = 'N/A';
        insert recLead;
        //
        String strName = 'Gowsic';
		List<ServiceResource> ListResource = [SELECT Id,RelatedRecordId, Name FROM ServiceResource WHERE Name = :strName];
        //
        String strName1 = 'Personal Shopper';
		List<ServiceTerritory> ListServiceTerritory = [SELECT Id FROM ServiceTerritory WHERE Name = :strName1];
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
        recSA.SchedStartTime = DateTime.newInstance(datetime.now().year(), 03, datetime.now().day(), datetime.now().hour(), datetime.now().minute(), datetime.now().second());
        recSA.SchedEndTime = DateTime.newInstance(datetime.now().year(), 03, datetime.now().day(), datetime.now().hour()+1, datetime.now().minute(), datetime.now().second());
		recSA.ParentRecordId = recLead.Id;
		recSA.Description = 'test';
		recSA.AssignedResource__c = ListResource[0].Id;
        recSA.Email = 'Gowsic.S@geappliances.com';
        recSA.Phone = '1111111111';
        recSA.ConsumerTimezone__c = 'America/New_York';
        recSA.ServiceResourceUserId__c = '0054P00000BptNBQAZ';
        insert recSA;
    }
    static testMethod void testPersonalShopperRecordCreate4()
	{
        Lead recLead = new Lead();
        recLead.LastName ='Test Firstname';
        recLead.FirstName = 'Test Lastname';
        recLead.Company = 'N/A';
        insert recLead;
        //
        String strName = 'Gowsic';
		List<ServiceResource> ListResource = [SELECT Id,RelatedRecordId, Name FROM ServiceResource WHERE Name = :strName];
        //
        String strName1 = 'Personal Shopper';
		List<ServiceTerritory> ListServiceTerritory = [SELECT Id FROM ServiceTerritory WHERE Name = :strName1];
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
        recSA.SchedStartTime = DateTime.newInstance(datetime.now().year(), 04, datetime.now().day(), datetime.now().hour(), datetime.now().minute(), datetime.now().second());
        recSA.SchedEndTime = DateTime.newInstance(datetime.now().year(), 04, datetime.now().day(), datetime.now().hour()+1, datetime.now().minute(), datetime.now().second());
		recSA.ParentRecordId = recLead.Id;
		recSA.Description = 'test';
		recSA.AssignedResource__c = ListResource[0].Id;
        recSA.Email = 'Gowsic.S@geappliances.com';
        recSA.Phone = '1111111111';
        recSA.ConsumerTimezone__c = 'America/New_York';
        recSA.ServiceResourceUserId__c = '0054P00000BptNBQAZ';
        insert recSA;
    }
    static testMethod void testPersonalShopperRecordCreate5()
	{
        Lead recLead = new Lead();
        recLead.LastName ='Test Firstname';
        recLead.FirstName = 'Test Lastname';
        recLead.Company = 'N/A';
        insert recLead;
        //
        String strName = 'Gowsic';
		List<ServiceResource> ListResource = [SELECT Id,RelatedRecordId, Name FROM ServiceResource WHERE Name = :strName];
        //
        String strName1 = 'Personal Shopper';
		List<ServiceTerritory> ListServiceTerritory = [SELECT Id FROM ServiceTerritory WHERE Name = :strName1];
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
        recSA.SchedStartTime = DateTime.newInstance(datetime.now().year(), 05, datetime.now().day(), datetime.now().hour(), datetime.now().minute(), datetime.now().second());
        recSA.SchedEndTime = DateTime.newInstance(datetime.now().year(), 05, datetime.now().day(), datetime.now().hour()+1, datetime.now().minute(), datetime.now().second());
		recSA.ParentRecordId = recLead.Id;
		recSA.Description = 'test';
		recSA.AssignedResource__c = ListResource[0].Id;
        recSA.Email = 'Gowsic.S@geappliances.com';
        recSA.Phone = '1111111111';
        recSA.ConsumerTimezone__c = 'America/New_York';
        recSA.ServiceResourceUserId__c = '0054P00000BptNBQAZ';
        insert recSA;
    }
    static testMethod void testPersonalShopperRecordCreate6()
	{
        Lead recLead = new Lead();
        recLead.LastName ='Test Firstname';
        recLead.FirstName = 'Test Lastname';
        recLead.Company = 'N/A';
        insert recLead;
        //
        String strName = 'Gowsic';
		List<ServiceResource> ListResource = [SELECT Id,RelatedRecordId, Name FROM ServiceResource WHERE Name = :strName];
        //
        String strName1 = 'Personal Shopper';
		List<ServiceTerritory> ListServiceTerritory = [SELECT Id FROM ServiceTerritory WHERE Name = :strName1];
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
        recSA.SchedStartTime = DateTime.newInstance(datetime.now().year(), 06, datetime.now().day(), datetime.now().hour(), datetime.now().minute(), datetime.now().second());
        recSA.SchedEndTime = DateTime.newInstance(datetime.now().year(), 06, datetime.now().day(), datetime.now().hour()+1, datetime.now().minute(), datetime.now().second());
		recSA.ParentRecordId = recLead.Id;
		recSA.Description = 'test';
		recSA.AssignedResource__c = ListResource[0].Id;
        recSA.Email = 'Gowsic.S@geappliances.com';
        recSA.Phone = '1111111111';
        recSA.ConsumerTimezone__c = 'America/New_York';
        recSA.ServiceResourceUserId__c = '0054P00000BptNBQAZ';
        insert recSA;
    }
    static testMethod void testPersonalShopperRecordCreate7()
	{
        Lead recLead = new Lead();
        recLead.LastName ='Test Firstname';
        recLead.FirstName = 'Test Lastname';
        recLead.Company = 'N/A';
        insert recLead;
        //
        String strName = 'Gowsic';
		List<ServiceResource> ListResource = [SELECT Id,RelatedRecordId, Name FROM ServiceResource WHERE Name = :strName];
        //
        String strName1 = 'Personal Shopper';
		List<ServiceTerritory> ListServiceTerritory = [SELECT Id FROM ServiceTerritory WHERE Name = :strName1];
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
        recSA.SchedStartTime = DateTime.newInstance(datetime.now().year(), 07, datetime.now().day(), datetime.now().hour(), datetime.now().minute(), datetime.now().second());
        recSA.SchedEndTime = DateTime.newInstance(datetime.now().year(), 07, datetime.now().day(), datetime.now().hour()+1, datetime.now().minute(), datetime.now().second());
		recSA.ParentRecordId = recLead.Id;
		recSA.Description = 'test';
		recSA.AssignedResource__c = ListResource[0].Id;
        recSA.Email = 'Gowsic.S@geappliances.com';
        recSA.Phone = '1111111111';
        recSA.ConsumerTimezone__c = 'America/New_York';
        recSA.ServiceResourceUserId__c = '0054P00000BptNBQAZ';
        insert recSA;
    }
    static testMethod void testPersonalShopperRecordCreate8()
	{
        Lead recLead = new Lead();
        recLead.LastName ='Test Firstname';
        recLead.FirstName = 'Test Lastname';
        recLead.Company = 'N/A';
        insert recLead;
        //
        String strName = 'Gowsic';
		List<ServiceResource> ListResource = [SELECT Id,RelatedRecordId, Name FROM ServiceResource WHERE Name = :strName];
        //
        String strName1 = 'Personal Shopper';
		List<ServiceTerritory> ListServiceTerritory = [SELECT Id FROM ServiceTerritory WHERE Name = :strName1];
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
        recSA.SchedStartTime = DateTime.newInstance(datetime.now().year(), 08, datetime.now().day(), datetime.now().hour(), datetime.now().minute(), datetime.now().second());
        recSA.SchedEndTime = DateTime.newInstance(datetime.now().year(), 08, datetime.now().day(), datetime.now().hour()+1, datetime.now().minute(), datetime.now().second());
		recSA.ParentRecordId = recLead.Id;
		recSA.Description = 'test';
		recSA.AssignedResource__c = ListResource[0].Id;
        recSA.Email = 'Gowsic.S@geappliances.com';
        recSA.Phone = '1111111111';
        recSA.ConsumerTimezone__c = 'America/New_York';
        recSA.ServiceResourceUserId__c = '0054P00000BptNBQAZ';
        insert recSA;
    }
    static testMethod void testPersonalShopperRecordCreate9()
	{
        Lead recLead = new Lead();
        recLead.LastName ='Test Firstname';
        recLead.FirstName = 'Test Lastname';
        recLead.Company = 'N/A';
        insert recLead;
        //
        String strName = 'Gowsic';
		List<ServiceResource> ListResource = [SELECT Id,RelatedRecordId, Name FROM ServiceResource WHERE Name = :strName];
        //
        String strName1 = 'Personal Shopper';
		List<ServiceTerritory> ListServiceTerritory = [SELECT Id FROM ServiceTerritory WHERE Name = :strName1];
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
        recSA.SchedStartTime = DateTime.newInstance(datetime.now().year(), 09, datetime.now().day(), datetime.now().hour(), datetime.now().minute(), datetime.now().second());
        recSA.SchedEndTime = DateTime.newInstance(datetime.now().year(), 09, datetime.now().day(), datetime.now().hour()+1, datetime.now().minute(), datetime.now().second());
		recSA.ParentRecordId = recLead.Id;
		recSA.Description = 'test';
		recSA.AssignedResource__c = ListResource[0].Id;
        recSA.Email = 'Gowsic.S@geappliances.com';
        recSA.Phone = '1111111111';
        recSA.ConsumerTimezone__c = 'America/New_York';
        recSA.ServiceResourceUserId__c = '0054P00000BptNBQAZ';
        insert recSA;
    }
    static testMethod void testPersonalShopperRecordCreate10()
	{
        Lead recLead = new Lead();
        recLead.LastName ='Test Firstname';
        recLead.FirstName = 'Test Lastname';
        recLead.Company = 'N/A';
        insert recLead;
        //
        String strName = 'Gowsic';
		List<ServiceResource> ListResource = [SELECT Id,RelatedRecordId, Name FROM ServiceResource WHERE Name = :strName];
        //
        String strName1 = 'Personal Shopper';
		List<ServiceTerritory> ListServiceTerritory = [SELECT Id FROM ServiceTerritory WHERE Name = :strName1];
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
        recSA.SchedStartTime = DateTime.newInstance(datetime.now().year(), 10, datetime.now().day(), datetime.now().hour(), datetime.now().minute(), datetime.now().second());
        recSA.SchedEndTime = DateTime.newInstance(datetime.now().year(), 10, datetime.now().day(), datetime.now().hour()+1, datetime.now().minute(), datetime.now().second());
		recSA.ParentRecordId = recLead.Id;
		recSA.Description = 'test';
		recSA.AssignedResource__c = ListResource[0].Id;
        recSA.Email = 'Gowsic.S@geappliances.com';
        recSA.Phone = '1111111111';
        recSA.ConsumerTimezone__c = 'America/New_York';
        recSA.ServiceResourceUserId__c = '0054P00000BptNBQAZ';
        insert recSA;
    }
    static testMethod void testPersonalShopperRecordCreate11()
	{
        Lead recLead = new Lead();
        recLead.LastName ='Test Firstname';
        recLead.FirstName = 'Test Lastname';
        recLead.Company = 'N/A';
        insert recLead;
        //
        String strName = 'Gowsic';
		List<ServiceResource> ListResource = [SELECT Id,RelatedRecordId, Name FROM ServiceResource WHERE Name = :strName];
        //
        String strName1 = 'Personal Shopper';
		List<ServiceTerritory> ListServiceTerritory = [SELECT Id FROM ServiceTerritory WHERE Name = :strName1];
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
        recSA.SchedStartTime = DateTime.newInstance(datetime.now().year(), 11, datetime.now().day(), datetime.now().hour(), datetime.now().minute(), datetime.now().second());
        recSA.SchedEndTime = DateTime.newInstance(datetime.now().year(), 11, datetime.now().day(), datetime.now().hour()+1, datetime.now().minute(), datetime.now().second());
		recSA.ParentRecordId = recLead.Id;
		recSA.Description = 'test';
		recSA.AssignedResource__c = ListResource[0].Id;
        recSA.Email = 'Gowsic.S@geappliances.com';
        recSA.Phone = '1111111111';
        recSA.ConsumerTimezone__c = 'America/New_York';
        recSA.ServiceResourceUserId__c = '0054P00000BptNBQAZ';
        insert recSA;
    }
    static testMethod void testPersonalShopperRecordCreate12()
	{
        Lead recLead = new Lead();
        recLead.LastName ='Test Firstname';
        recLead.FirstName = 'Test Lastname';
        recLead.Company = 'N/A';
        insert recLead;
        //
        String strName = 'Gowsic';
		List<ServiceResource> ListResource = [SELECT Id,RelatedRecordId, Name FROM ServiceResource WHERE Name = :strName];
        //
        String strName1 = 'Personal Shopper';
		List<ServiceTerritory> ListServiceTerritory = [SELECT Id FROM ServiceTerritory WHERE Name = :strName1];
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
        recSA.SchedStartTime = DateTime.newInstance(datetime.now().year(), 12, datetime.now().day(), datetime.now().hour(), datetime.now().minute(), datetime.now().second());
        recSA.SchedEndTime = DateTime.newInstance(datetime.now().year(), 12, datetime.now().day(), datetime.now().hour()+1, datetime.now().minute(), datetime.now().second());
		recSA.ParentRecordId = recLead.Id;
		recSA.Description = 'test';
		recSA.AssignedResource__c = ListResource[0].Id;
        recSA.Email = 'Gowsic.S@geappliances.com';
        recSA.Phone = '1111111111';
        recSA.ConsumerTimezone__c = 'America/New_York';
        recSA.ServiceResourceUserId__c = '0054P00000BptNBQAZ';
        insert recSA;
    }
    static testMethod void testPersonalShopperRecordCreate13()
	{
        Lead recLead = new Lead();
        recLead.LastName ='Test Firstname';
        recLead.FirstName = 'Test Lastname';
        recLead.Company = 'N/A';
        insert recLead;
        //
        String strName = 'Gowsic';
		List<ServiceResource> ListResource = [SELECT Id,RelatedRecordId, Name FROM ServiceResource WHERE Name = :strName];
        //
        String strName1 = 'Personal Shopper';
		List<ServiceTerritory> ListServiceTerritory = [SELECT Id FROM ServiceTerritory WHERE Name = :strName1];
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
        recSA.SchedStartTime = DateTime.newInstance(datetime.now().year(), 12, 01, datetime.now().hour(), datetime.now().minute(), datetime.now().second());
        recSA.SchedEndTime = DateTime.newInstance(datetime.now().year(), 12, 01, datetime.now().hour()+1, datetime.now().minute(), datetime.now().second());
		recSA.ParentRecordId = recLead.Id;
		recSA.Description = 'test';
		recSA.AssignedResource__c = ListResource[0].Id;
        recSA.Email = 'Gowsic.S@geappliances.com';
        recSA.Phone = '1111111111';
        recSA.ConsumerTimezone__c = 'America/New_York';
        recSA.ServiceResourceUserId__c = '0054P00000BptNBQAZ';
        insert recSA;
    }
    static testMethod void testPersonalShopperRecordCreate14()
	{
        Lead recLead = new Lead();
        recLead.LastName ='Test Firstname';
        recLead.FirstName = 'Test Lastname';
        recLead.Company = 'N/A';
        insert recLead;
        //
        String strName = 'Gowsic';
		List<ServiceResource> ListResource = [SELECT Id,RelatedRecordId, Name FROM ServiceResource WHERE Name = :strName];
        //
        String strName1 = 'Personal Shopper';
		List<ServiceTerritory> ListServiceTerritory = [SELECT Id FROM ServiceTerritory WHERE Name = :strName1];
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
        recSA.SchedStartTime = DateTime.newInstance(datetime.now().year(), 12, 02, datetime.now().hour(), datetime.now().minute(), datetime.now().second());
        recSA.SchedEndTime = DateTime.newInstance(datetime.now().year(), 12, 02, datetime.now().hour()+1, datetime.now().minute(), datetime.now().second());
		recSA.ParentRecordId = recLead.Id;
		recSA.Description = 'test';
		recSA.AssignedResource__c = ListResource[0].Id;
        recSA.Email = 'Gowsic.S@geappliances.com';
        recSA.Phone = '1111111111';
        recSA.ConsumerTimezone__c = 'America/New_York';
        recSA.ServiceResourceUserId__c = '0054P00000BptNBQAZ';
        insert recSA;
    }
    static testMethod void testPersonalShopperRecordCreate15()
	{
        Lead recLead = new Lead();
        recLead.LastName ='Test Firstname';
        recLead.FirstName = 'Test Lastname';
        recLead.Company = 'N/A';
        insert recLead;
        //
        String strName = 'Gowsic';
		List<ServiceResource> ListResource = [SELECT Id,RelatedRecordId, Name FROM ServiceResource WHERE Name = :strName];
        //
        String strName1 = 'Personal Shopper';
		List<ServiceTerritory> ListServiceTerritory = [SELECT Id FROM ServiceTerritory WHERE Name = :strName1];
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
        recSA.SchedStartTime = DateTime.newInstance(datetime.now().year(), 12, 03, datetime.now().hour(), datetime.now().minute(), datetime.now().second());
        recSA.SchedEndTime = DateTime.newInstance(datetime.now().year(), 12, 03, datetime.now().hour()+1, datetime.now().minute(), datetime.now().second());
		recSA.ParentRecordId = recLead.Id;
		recSA.Description = 'test';
		recSA.AssignedResource__c = ListResource[0].Id;
        recSA.Email = 'Gowsic.S@geappliances.com';
        recSA.Phone = '1111111111';
        recSA.ConsumerTimezone__c = 'America/New_York';
        recSA.ServiceResourceUserId__c = '0054P00000BptNBQAZ';
        insert recSA;
    }
}