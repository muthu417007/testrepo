@istest
private class DeleteSharerecordsTest {
    @istest
    static void test1(){
    Account acc = new Account(Name = 'Account 1',Meet_Comp_Eligibility__c = 'National');
        insert acc; 
    Account acc2 = new Account(Name = 'Account 2',Meet_Comp_Eligibility__c = 'National');
        insert acc2;       
        Profile prof = [select Id from profile where name LIKE '%System Administrator%'];
        
        user user = new User( firstName = 'Abc',lastName = 'xyz',
                            Alias = 'abcbc',
                            profileId = prof.id,
                            username = 'abcabc.xyz@test.com',
                            email = 'test@test.com',
                            TimeZoneSidKey = 'America/Los_Angeles',
                            EmailEncodingKey = 'UTF-8',
                            LanguageLocaleKey = 'en_US',
                            LocaleSidKey = 'en_US');
                   insert user;
        
        user user1=new User(firstName = 'Abc',lastName = 'xyz',
                  Alias = 'abcbc',
                  profileId = prof.id,
                  username = 'abcabc.xyz1@test.com',
                  email = 'test1@test.com',
                  TimeZoneSidKey = 'America/Los_Angeles',
                  EmailEncodingKey = 'UTF-8',
                  LanguageLocaleKey = 'en_US',
                  LocaleSidKey = 'en_US');
              insert user1;
        
        user user2 = new User(firstName = 'Abcd',lastName = 'xyza',
                              Alias = 'abcbd',
                              profileId = prof.id,
                              username = 'abcabc.xyz2@test.com',
                              email = 'test2@test.com',
                              TimeZoneSidKey = 'America/Los_Angeles',
                              EmailEncodingKey = 'UTF-8',
                              LanguageLocaleKey = 'en_US',
                              LocaleSidKey = 'en_US');
               insert user2;
        
        AccountTeamMember atm1 =new AccountTeamMember(AccountId= acc.Id,UserId=user.id,
        TeamMemberRole='ASM');
        insert atm1;
        
        AccountTeamMember atm2 =new AccountTeamMember(AccountId= acc.Id,UserId=user1.id,
        TeamMemberRole='ASM');
        insert atm2;
            
            Contact cnt = new Contact(FirstName = 'Joe', LastName = 'Smith', Phone = '4155551212', AccountId = acc.id);
        insert cnt;
        Product2 prod1 = new Product2(Name = 'Product 1', Family = 'Hardware', Item_Number__c = '1');
        insert prod1;

        Meet_Comp__c meetComp1 = new Meet_Comp__c(
            GEA_Individual_who_received_the_data__c =user1.id,
            Account__c = acc.Id,
            Competitive_Inventory_Financing_pct__c = 5,
            Competitive_Invoice_Price__c = 5,
            Competitive_Other_Backside_pct__c = 5,
            Competitive_Price_Promotional_Diff__c = 5,
            Competitive_Sales_Campaigns_Promos__c = 5,
            Competitive_Volume_Rebate_PIF__c =  5,
            Contact_Name__c = cnt.Id,
            Date_Competitive_Data_Received__c = Date.today().addDays(-3),
            GEA_Inventory_Financing__c = 5,
            GEA_Meet_Comp_Price__c = 5,
            GEA_Other_Backside__c = 5,
            GEA_Price_Promotional_Difference_PPD__c = 5,
            GEA_Sales_Campaigns_and_Promotions__c = 5,
            GEA_Volume_Rebate_PIF__c = 5,
            MC_Type__c = 'MC',
            Effective_Date__c =  Date.today().addDays(1),
            Termination_Date__c =  Date.today().addDays(2),
            Termination_Date_of_Competitive_Data__c =  Date.today().addDays(3),
            GEA_Model__c = prod1.Id
        );
        insert meetComp1;
        
           Meet_Comp__c meetComp2 = new Meet_Comp__c(
            GEA_Individual_who_received_the_data__c = user2.Id,
            Account__c = acc2.Id,
            Competitive_Inventory_Financing_pct__c = 5,
            Competitive_Invoice_Price__c = 5,
            Competitive_Other_Backside_pct__c = 5,
            Competitive_Price_Promotional_Diff__c = 5,
            Competitive_Sales_Campaigns_Promos__c = 5,
            Competitive_Volume_Rebate_PIF__c =  5,
            Contact_Name__c = cnt.Id,
            Date_Competitive_Data_Received__c = Date.today().addDays(-3),
            GEA_Inventory_Financing__c = 5,
            GEA_Meet_Comp_Price__c = 5,
            GEA_Other_Backside__c = 5,
            GEA_Price_Promotional_Difference_PPD__c = 5,
            GEA_Sales_Campaigns_and_Promotions__c = 5,
            GEA_Volume_Rebate_PIF__c = 5,
            MC_Type__c = 'MC',
            Effective_Date__c =  Date.today().addDays(1),
            Termination_Date__c =  Date.today().addDays(2),
            Termination_Date_of_Competitive_Data__c =  Date.today().addDays(3),
            GEA_Model__c = prod1.Id
        );
        insert meetComp2;
        
        Meet_Comp__Share mcsh1 = new Meet_Comp__Share(
            RowCause = 'Account_Team__c',
            UserOrGroupId = user1.Id,
            AccessLevel = 'Edit',
            ParentId = meetComp1.Id);
        insert mcsh1;
        
        Meet_Comp__Share mcsh2 = new Meet_Comp__Share(
            RowCause = 'Account_Team__c',
            UserOrGroupId = user2.Id,
            AccessLevel = 'Edit',
            ParentId = meetComp1.Id);
        insert mcsh2;
        
        Meet_Comp__Share mcsh3 = new Meet_Comp__Share(
            RowCause = 'Account_Team__c',
            UserOrGroupId = user2.Id,
            AccessLevel = 'Edit',
            ParentId = meetComp2.Id);
        insert mcsh3;
        
         Program_Request__c request1 = new Program_Request__c(
            Account__c = acc.Id,
            Start_Date__c = System.today().addDays(-3),
            End_Date__c = System.today().addDays(3)
        );
        insert request1;
        
        Program_Request__c request2 = new Program_Request__c(
            Account__c = acc2.Id,
            Start_Date__c = System.today().addDays(-3),
            End_Date__c = System.today().addDays(3)
        );
        insert request2;
        
        Program_Request__Share prs1 =new Program_Request__Share(RowCause = 'Account_Team__c',
            UserOrGroupId = user1.Id,
            AccessLevel = 'Edit',
            ParentId = request1.Id
        );
        insert prs1;
        
        Program_Request__Share prs2 =new Program_Request__Share(RowCause = 'Account_Team__c',
            UserOrGroupId = user2.Id,
            AccessLevel = 'Edit',
            ParentId = request1.Id
        );
        insert prs2;
        
        Program_Request__Share prs3 =new Program_Request__Share(RowCause = 'Account_Team__c',
            UserOrGroupId = user2.Id,
            AccessLevel = 'Edit',
            ParentId = request2.Id
        );
        insert prs3;
        
    Customer_Agreement__c ca1 = new Customer_Agreement__c(
            Account_Name__c = acc.Id
        );
      insert ca1;
        
     Customer_Agreement__c ca2 = new Customer_Agreement__c(
            Account_Name__c = acc2.Id
        );    
        insert ca2;
        
     Customer_Agreement__Share cs1 = new Customer_Agreement__Share(
            RowCause = 'Account_Team__c',
            UserOrGroupId = user1.Id,
            AccessLevel = 'Edit',
            ParentId = ca1.Id
        );  
        insert cs1;
        
     Customer_Agreement__Share cs2 = new Customer_Agreement__Share(
            RowCause = 'Account_Team__c',
            UserOrGroupId = user2.Id,
            AccessLevel = 'Edit',
            ParentId = ca1.Id
        );  
        insert cs2;
        
      Customer_Agreement__Share cs3 = new Customer_Agreement__Share(
            RowCause = 'Account_Team__c',
            UserOrGroupId = user2.Id,
            AccessLevel = 'Edit',
            ParentId = ca2.Id
        );  
         insert cs3;
        
  Schema.Location testLocation = new Schema.Location(Name = 'test');
        insert testLocation;
        RetailStore rs1 = new RetailStore(Name = 'rs1', AccountId = acc.Id, LocationId = testLocation.Id);
        insert rs1;
        RetailStore rs2 = new RetailStore(Name = 'rs1', AccountId = acc2.Id, LocationId = testLocation.Id);
        insert rs2;
        StoreProduct sp1 = new StoreProduct(
            Account__c = acc.Id,
            ProductId = prod1.Id,
            RetailStoreId = rs1.Id,
            StartDate = System.today().addDays(-3),
            EndDate = System.today().addDays(3)
        );
        insert sp1;
        
        StoreProduct sp2 = new StoreProduct(
            Account__c = acc2.Id,
            ProductId = prod1.Id,
            RetailStoreId = rs2.Id,
            StartDate = System.today().addDays(-3),
            EndDate = System.today().addDays(3)
        );
        insert sp2; 
        
   StoreProductShare sps1 = new  StoreProductShare(
            RowCause = 'Manual',
            UserOrGroupId = user1.Id,
            AccessLevel = 'Edit',
            ParentId = sp1.Id
        );
        insert sps1;
        
       StoreProductShare sps2 = new  StoreProductShare(
            RowCause = 'Manual',
            UserOrGroupId = user2.Id,
            AccessLevel = 'Edit',
            ParentId = sp1.Id
        );
        insert sps2;  
        
        StoreProductShare sps3 = new  StoreProductShare(
            RowCause = 'Manual',
            UserOrGroupId = user2.Id,
            AccessLevel = 'Edit',
            ParentId = sp2.Id
        );
        insert sps3;
        
      Account_Sales_Performance__c asp1 = new Account_Sales_Performance__c(
            Account__c = acc.Id
        );
        insert asp1;
        
      Account_Sales_Performance__c asp2 = new Account_Sales_Performance__c(
            Account__c = acc2.Id
        );
        insert asp2;  
        
       Account_Sales_Performance__Share asps1 = new  Account_Sales_Performance__Share(
            RowCause = Schema.Account_Sales_Performance__Share.RowCause.Account_Team__c,
            UserOrGroupId = user1.Id,
            AccessLevel = 'Edit',
            ParentId = asp1.Id );
        insert asps1;
   Account_Sales_Performance__Share asps2 = new  Account_Sales_Performance__Share(
            RowCause = Schema.Account_Sales_Performance__Share.RowCause.Account_Team__c,
            UserOrGroupId = user2.Id,
            AccessLevel = 'Edit',
            ParentId = asp1.Id );
        insert asps2;  
        
    Account_Sales_Performance__Share asps3 = new  Account_Sales_Performance__Share(
            RowCause = Schema.Account_Sales_Performance__Share.RowCause.Account_Team__c,
            UserOrGroupId = user2.Id,
            AccessLevel = 'Edit',
            ParentId = asp2.Id );
        insert asps3;  
        
        
         System.runAs(user1) {
            DeleteMeetCompshare d = new DeleteMeetCompshare();
            Database.executeBatch(d);
             
        }
         System.runAs(user1) {
            DeleteCustomerAgreementshare d = new DeleteCustomerAgreementshare();
            Database.executeBatch(d);  
        }
        System.runAs(user1) {
            DeleteProgramRequestShare d = new DeleteProgramRequestShare();
            Database.executeBatch(d);  
        }
        System.runAs(user1) {
            DeleteStoreProductShare d = new DeleteStoreProductShare();
            Database.executeBatch(d);  
        }
        System.runAs(user1) {
            DeleteAccountSalesPerformance_Share d = new DeleteAccountSalesPerformance_Share();
            Database.executeBatch(d);  
        }
        
    }    
}