trigger PersonalShopperAppointments on Personal_Shopper_Appointments__c (after insert) {
	Switch on Trigger.operationType{
        //when AFTER_INSERT{
        when AFTER_INSERT{
           for (Personal_Shopper_Appointments__c PSA : Trigger.new) {
                //
                if(PSA != null)
                {
                    if(PSA.Subject__c == 'Personal Shopper Appointment')
                    {
                        String strContactId;
                        List<Event> lstNewEvents = new List<Event>();
    					String strEmailSubject;
                        
                        Lead recLead = new Lead (FirstName=PSA.FirstName__c,LastName=PSA.LastName__c,Company='N/A',Phone=PSA.Phone__c,Email=PSA.Email__c, RecordTypeId = System.Label.LeadConsumerRecordTypeID, LeadSource = System.Label.LeadHaierChatbotLeadSource); //tempOwnerID__c=testGroup2.id, 
                      //  Lead recLead = new Lead (FirstName=PSA.FirstName__c,LastName=PSA.LastName__c,Company='N/A',Phone=PSA.Phone__c, RecordTypeId = System.Label.LeadConsumerRecordTypeID, LeadSource = System.Label.LeadHaierChatbotLeadSource); //tempOwnerID__c=testGroup2.id, 
                        insert recLead;
                        /////////////////////////
                        System.debug('EMAIL:' + PSA.Email__c);
                        System.debug('PHONE:' + PSA.Phone__c);
                        List<Contact> listContactsemailphone = [Select Id from Contact where Email =:PSA.Email__c and Phone =:PSA.Phone__c Order By CreatedDate desc LIMIT 1];
                        if (listContactsemailphone.size() >= 1)
                        {
                            strContactId = listContactsemailphone[0].Id;
                        }
                        else
                        {
                            Contact recContact = new Contact (First_Name__c=PSA.FirstName__c,Last_Name__c=PSA.LastName__c,FirstName=PSA.FirstName__c,LastName=PSA.LastName__c,Email=PSA.Email__c,Phone=PSA.Phone__c); //tempOwnerID__c=testGroup2.id, 
                        	insert recContact;
                            /////////////////////////
                            strContactId = recContact.Id;
                        }
      					////////////////////////////////////////////////////////////////////////
      					Set<Id> srId = new Set<Id>();
                        srId.add(PSA.AssignedResource__c);
                        ServiceResource sr = [Select RelatedRecordId from ServiceResource where id in :srId];
                        ////////
                        Case recCase = new Case (subject='Personal Shopper Appointment',Description='Personal Shopper Appointment',ContactId=strContactId,RecordTypeId='0124P0000015hYRQAY',OwnerId=sr.RelatedRecordId); //tempOwnerID__c=testGroup2.id, 
                        insert recCase;
                        System.debug(recCase.Id);
                        ////////commented this line due to licensing issue in Production due to Slaeforce Scehular
                        ////ServiceAppointment recSA = new ServiceAppointment (ParentRecordId=recLead.Id,Email=PSA.Email__c,Phone=PSA.Phone__c,Description=PSA.Description__c,Subject=PSA.Subject__c,Customer_Name__c=PSA.Customer_Name__c,AssignedResource__c=PSA.AssignedResource__c,ConsumerTimezone__c=PSA.Consumer_Time_zone__c,OTP_for_Cancellation__c=PSA.OTP_for_Cancellation__c,Service_Resource_Name__c=PSA.Service_Resource_Name__c,AppointmentType=PSA.Appointment_Type__c,City=PSA.City__c,Street=PSA.Street__c,State=PSA.State__c,Country=PSA.Country__c,SchedStartTime=PSA.SchedStartTime__c,SchedEndTime=PSA.SchedEndTime__c,ContactId=strContactId,ServiceTerritoryId=PSA.Service_Territory_Id__c,PostalCode=PSA.PostalCode__c,Case__c=recCase.Id,ServiceResourceUserId__c=sr.RelatedRecordId); //tempOwnerID__c=testGroup2.id, 
                       // ServiceAppointment recSA = new ServiceAppointment (ParentRecordId=recLead.Id,Phone=PSA.Phone__c,Description=PSA.Description__c,Subject=PSA.Subject__c,Customer_Name__c=PSA.Customer_Name__c,AssignedResource__c=PSA.AssignedResource__c,ConsumerTimezone__c=PSA.Consumer_Time_zone__c,OTP_for_Cancellation__c=PSA.OTP_for_Cancellation__c,Service_Resource_Name__c=PSA.Service_Resource_Name__c,City=PSA.City__c,Street=PSA.Street__c,State=PSA.State__c,Country=PSA.Country__c,SchedStartTime=PSA.SchedStartTime__c,SchedEndTime=PSA.SchedEndTime__c,ContactId=strContactId,ServiceTerritoryId=PSA.Service_Territory_Id__c,PostalCode=PSA.PostalCode__c,Case__c=recCase.Id,ServiceResourceUserId__c=sr.RelatedRecordId); //tempOwnerID__c=testGroup2.id, ServiceAppointment recSA = new ServiceAppointment (ParentRecordId=recLead.Id,Email=PSA.Email__c,Phone=PSA.Phone__c,Description=PSA.Description__c,Subject=PSA.Subject__c,Customer_Name__c=PSA.Customer_Name__c,AssignedResource__c=PSA.AssignedResource__c,ConsumerTimezone__c=PSA.Consumer_Time_zone__c,OTP_for_Cancellation__c=PSA.OTP_for_Cancellation__c,Service_Resource_Name__c=PSA.Service_Resource_Name__c,AppointmentType=PSA.Appointment_Type__c,City=PSA.City__c,Street=PSA.Street__c,State=PSA.State__c,Country=PSA.Country__c,SchedStartTime=PSA.SchedStartTime__c,SchedEndTime=PSA.SchedEndTime__c,ContactId=strContactId,ServiceTerritoryId=PSA.Service_Territory_Id__c,PostalCode=PSA.PostalCode__c,Case__c=recCase.Id,ServiceResourceUserId__c=sr.RelatedRecordId); //tempOwnerID__c=testGroup2.id, 
                      //  insert recSA;
                        //
                        //ServiceAppointment[] SAQuery = [Select Id,AppointmentNumber from ServiceAppointment where Id in (:recSA.Id)];
						//ServiceAppointment[] SAQuery = [Select Id,AppointmentNumber,ParentRecordId from ServiceAppointment where Id =:recSA.Id];
      					/////////
                        //Event e = new Event();
                        //e.StartDateTime = recSA.SchedStartTime;
                        //e.EndDateTime = recSA.SchedEndTime;
                        //e.Subject = 'Personal Shopper Appointment: ' + '- ' + SAQuery.Id;
                        //e.Description = 'Personal Shopper Appointment: ' + '- ' + SAQuery.ParentRecordId;
                        //e.Location = recSA.AppointmentType;
                        //e.WhatId = recSA.Id;
                        //e.OwnerId = sr.RelatedRecordId;	
                        //lstNewEvents.add(e);
                        //insert lstNewEvents;
                        //DateTime dtStartDatetime = DateTime.newInstance(recSA.SchedStartTime.year(), recSA.SchedStartTime.month(), recSA.SchedStartTime.day(), recSA.SchedStartTime.hour(), recSA.SchedStartTime.minute(), recSA.SchedStartTime.second());
                        //DateTime dtEndDatetime = DateTime.newInstance(recSA.SchedEndTime.year(), recSA.SchedEndTime.month(), recSA.SchedEndTime.day(), recSA.SchedEndTime.hour(), recSA.SchedEndTime.minute(), recSA.SchedEndTime.second());
                        //strEmailSubject = 'Meet with our Haier Appliances expert! Appointment No: ' + SAQuery.AppointmentNumber;
                        //CalendarInvites.sendinvite(recSA.Email,dtStartDatetime.format('MM-dd-yyyy HH:mm:ss', 'GMT'),dtEndDatetime.format('MM-dd-yyyy HH:mm:ss', 'GMT'), recSA.AppointmentNumber, recSA.AppointmentType, strEmailSubject, recSA.ConsumerTimezone__c,'Please add the attached meeting invition in our calendar as reminder. Thanks!');   
                       	//
                        /////////////////////////////
                    }
                }
            }
        }
    }
}