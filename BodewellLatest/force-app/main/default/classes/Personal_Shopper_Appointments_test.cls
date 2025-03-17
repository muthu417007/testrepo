@isTest(SeeAllData=true)
public class Personal_Shopper_Appointments_test {
	static testMethod void testPersonal_Shopper_Appointments1()
	{
        //
        String strName = 'Gowsic';
		//List<ServiceResource> ListResource = [SELECT Id,RelatedRecordId, Name FROM ServiceResource WHERE Name = :strName or Name='test' or Name='Ankita'];
		List<ServiceResource> ListResource = [SELECT Id,RelatedRecordId, Name FROM ServiceResource where RelatedRecordId != null LIMIT 1];
        //
        String strName1 = 'Personal Shopper';
		//List<ServiceTerritory> ListServiceTerritory = [SELECT Id FROM ServiceTerritory WHERE Name = :strName1 or Name='NewYork' or Name='Personal Shopper'];
		List<ServiceTerritory> ListServiceTerritory = [SELECT Id FROM ServiceTerritory LIMIT 1];
        //

       
        serviceResource sr= new serviceResource();
        sr.Name='test';
        sr.IsActive=true;
       // insert sr;
        
        //insert sr;
        
        //AssignedResource ar= new AssignedResource();
        //ar.IsPrimaryResource=true;
       // ar.ServiceResourceId=sr.Id;
       //insert ar;
        
        OperatingHours op= new OperatingHours();
        op.name='New';
       insert op;
        
        ServiceTerritory st= new ServiceTerritory();
        st.name='Test';
        st.OperatingHoursId=op.id;
        st.IsActive=true;
        
        Personal_Shopper_Appointments__c recPSA = new Personal_Shopper_Appointments__c();
    	recPSA.Phone__c  = '1111111111';
        recPSA.Email__c  = 'test@test.com';
        recPSA.Description__c  = '40218';
        recPSA.Appointment_Type__c  = 'Phone';
        recPSA.Subject__c  = 'Personal Shopper Appointment';
        DateTime dtStartDatetime = DateTime.newInstance(datetime.now().year(), datetime.now().month(), datetime.now().day(), datetime.now().hour(), datetime.now().minute(), datetime.now().second());
        DateTime dtEndDatetime = DateTime.newInstance(datetime.now().year(), datetime.now().month(), datetime.now().day(), datetime.now().hour(), datetime.now().minute(), datetime.now().second());
        recPSA.SchedStartTime__c = DateTime.newInstance(datetime.now().year(), 01, datetime.now().day(), datetime.now().hour(), datetime.now().minute(), datetime.now().second());
        recPSA.SchedEndTime__c = DateTime.newInstance(datetime.now().year(), 01, datetime.now().day(), datetime.now().hour()+1, datetime.now().minute(), datetime.now().second());
		recPSA.Customer_Name__c  = 'test';
        //created by me to avoid null error
        if(ListResource.size()>0){
		recPSA.AssignedResource__c  = ListResource[0].Id;
        }else{
           recPSA.AssignedResource__c  = ListResource[0].Id ;        }
		recPSA.Consumer_Time_zone__c  = 'America/New_York';
        recPSA.OTP_for_Cancellation__c  = '11111';
        recPSA.Service_Resource_Name__c  = '1111111111';
        recPSA.City__c  = 'Rapid city';
        recPSA.Country__c  = 'United States';
         if(ListServiceTerritory.size()>0){
		recPSA.Service_Territory_Id__c  = ListServiceTerritory[0].Id;
        }else{
           recPSA.Service_Territory_Id__c  = st.Id ;        }
        //recPSA.Service_Territory_Id__c   = ListServiceTerritory[0].Id;//commented by Monu due to license issue.
        recPSA.PostalCode__c   = '40218';
        recPSA.State__c   = 'KY';
        recPSA.FirstName__c   = 'test1';
        recPSA.LastName__c    = 'test2';
        recPSA.Street__c   = '4000 Buechel Bank Road';
        insert recPSA;
	}
}