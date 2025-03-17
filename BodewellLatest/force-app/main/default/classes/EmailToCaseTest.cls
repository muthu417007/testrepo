@isTest (SeeAllData=true) 
private class EmailToCaseTest {
    	static testMethod void nocontact() {
            Case c = new Case(Origin='Email',
                          SuppliedName = 'Madhuri Rao',                          
                          Status = 'New',
                          Subject = 'Test from testclass 1',
                          Description = 'Case Description',
                          SuppliedEmail='madhuri.rao@geappliances.com',
                          ContactId=null
                         );
        insert c;
            Account acc = new Account();
        acc.Name='Test Account' ;
        acc.BillingStreet='5579 S Van Gordon St';
        insert acc;
        
        Contact con = new Contact( FirstName = 'Maddy', 
                                  LastName = 'Rao',
                                  Phone = '7587710091',
                                  Email = 'madhurinew.rao@geappliances.com',
                                  accountId = acc.ID,
                                  MailingStreet='5579 S Van Gordon St',
                                  MailingCity='Littleton',
                                  CreatedDate = system.now());
        INSERT con;
            Case c1 = new Case(
                			Origin='Email',
                          SuppliedName = 'Madhuri Rao',                          
                          Status = 'New',
                          Subject = 'Test from testclass 1',
                          Description = 'Case Description',
                          SuppliedEmail='madhurinew.rao@geappliances.com',
                          ContactId=null
                         );
        insert c1;
            Case c2 = new Case(Origin='Email',
                          SuppliedName = 'Danielle Steinman',                          
                          Status = 'New',
                          Subject = 'Test from testclass 2',
                          Description = 'Case Description',
                          SuppliedEmail='danielle.steinman@geappliances.com',
                          ContactId=null
                         );
        insert c2;
            Contact con1 = new Contact( FirstName = 'Maddyy', 
                                  LastName = 'Rao',
                                  Phone = '7587710091',
                                  Email = 'madhurineww.rao@geappliances.com',
                                  accountId = acc.ID,
                                  MailingStreet='5579 S Van Gordon St',
                                  MailingCity='Littleton',
                                  CreatedDate = system.now());
        INSERT con1;
            Contact con2 = new Contact( FirstName = 'Maddy', 
                                  LastName = 'Rao',
                                  Phone = '7587710091',
                                  Email = 'madhurineww.rao@geappliances.com',
                                  accountId = acc.ID,
                                  MailingStreet='5579 S Van Gordon St',
                                  MailingCity='Littleton',
                                  CreatedDate = system.now());
        INSERT con2;
            Case c3 = new Case(Origin='Email',
                          SuppliedName = 'Maddyy Rao',                          
                          Status = 'New',
                          Subject = 'Test from testclass 4',
                          Description = 'Case Description',
                          SuppliedEmail='madhurineww.rao@geappliances.com',
                          ContactId=null
                         );
        insert c3;
           /* List<Case> lstOpp = new List<Case> ();
                    For(Integer i=1 ;i<=100 ; i++)
                    {
                        Case cc = new Case(Web_To_Case_Origin__c='geappliances.com',
                           First_Name__c='Madhuu'+i,
                           Last_Name__c='Rao',
                           Status = 'New',
                           Subject = 'Test from testclass 5',
                           Description = 'Case Description',
                           City__c='Littleton',
                                           Origin='WebToCase',
                           State__c='Colorado',
                           Zip_Postal_Code__c='801274587',
                           Country__c='United States (US)',
                           Street_Address__c='5579 S Van Gordon St Rd1',
                           SuppliedEmail='madhuri.rao@geappliances.com');
                        lstOpp.add(cc);	   
                    }
			insert lstOpp;*/
        }
		
}