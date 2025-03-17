@isTest
public class SpecialProgramsControllerTest {
	static testMethod void TestFuncSpecialProgramsController() {
        Case testAccount = new Case();
		testAccount.Subject ='Test Subject';
		insert testAccount;
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(new Case());
		SpecialProgramsController sp = new SpecialProgramsController(sc);
        Test.stopTest();
    }
    static testMethod void TestFuncSpecialProgramsController1() {
        Test.startTest();
        Concession_Code__c cc = new Concession_Code__c();
        cc.Code__c = 'A14';
        cc.Description__c = 'Fault';
        cc.Concession_Account__c = '123-123';
        insert cc;
        
        List<Account> accounts = TestDataFactory.createAccountsWithContacts(1, 1);
        account acc = accounts[0];
        //Contact con = [SELECT ID FROM Contact LIMIT 1];
        //Test class run was failing hence we added the below steps
        List<Contact> cons= new List<Contact>();
        cons.add(new Contact(firstName='First1',lastName = 'Last1',Phone='2322322321'));
        Insert cons;
        Contact con = cons[0];

        List<Asset> assets = new List<Asset>();
        for(Integer i=0;i<2;i++) {
            Asset a = new Asset( model_number__c = 'AAAA', SerialNumber = 'AM000000',accountid = acc.id,
                                             installdate = date.today());
            assets.add(a);
        }
        insert assets ;
        case case1 = TestDataFactory.createCase(con, assets[0]);
        
        Case_Asset__c caseAssetRecord = new Case_Asset__c();
        caseAssetRecord.name = 'test';
        caseAssetRecord.Case__c = case1.id;
        caseAssetRecord.Asset__c = assets[0].id;
        caseAssetRecord.Install_Date__c = date.today();
        caseAssetRecord.In_Warranty_CaseAsset__c = 'no';
        caseAssetRecord.Serial_Number__c = 'AM000000'; //'128912';
        caseAssetRecord.Model_Number__c = 'AAAA';
        caseAssetRecord.Age_Of_Product__c = 1;
        insert caseAssetRecord;
        Special_Programs_and_Recalls__c sp = new Special_Programs_and_Recalls__c();
        sp.Description__c = '2012 Dishwasher Heater Element Recall. This dishwasher MAY be in the affected population of the 2012 Dishwasher Recall.  To confirm if their unit is in the recall population, the consumer should visit www.geappliances/recall or call the recall hotline at 866-918-8760 (Encourage Website Usage over phone due to hold times)   AFFECTED MODELS begin with: EDW4, EDW5, EDW6, GHD4, GHD5, GHD6, GHDA4, GHDA6, GLC4, GLD4, GLD5, GLD6, GLDL, GSD61, GSD62, GSD63, GSD66, GSD67, GSD69, HLD4, PDW7, PDWF7.  AFFECTED SERIALS:  Produced from March to July of 2006 (FL - ML) and November 2006 to April 2008. (VL - ZL and AM-ZM and AR-GR) REMEDIATION OPTIONS FOR THIS RECALL: Though the web or recall hotline, choice of 2 options are available:      * Free repair to all consumers with units affected by the recall, OR,  * Rebate ($75 or $100 towards specific GE models) for consumers who wish to replace their dishwasher.  ACTION STEPS:     1.)  Ask the consumer if they have had the recall repair. If not, advise the consumer that they can view the recall details, schedule a free repair, or download a rebate for using the website (www.geappliances.com/recall) or call the Recall Hotline at 866-918-8760 for further assistance.     2.) For any potential safety reports up to and including fire, create a CS1049 prior to sending the consumer to the Recall website or hotline phone number.     3.)  If the consumer is already working with the special programs team, transfer them using 866-918-8757.';
        sp.Model_Number__c = 'AAAA';
        sp.Product_Line_Code__c = 41;
        sp.Program_Code__c = 'test';
        date dtStart = date.parse('08/09/2012'); //2012-08-09
        date dtExpiry = date.parse('05/11/2037'); //2037-05-16
        sp.Program_Start_Date__c = dtStart;
        sp.Program_Expiration_Date__c = dtExpiry;
        sp.Program_Title__c = 'test';
        sp.Program_Type__c = 'test';
        sp.Serial_Number_End__c = 'AM999999';
        sp.Serial_Number_Start__c = 'AM000000';
        insert sp;
        Special_Programs_Full_Cycle__c  spfc = new Special_Programs_Full_Cycle__c ();
        spfc.Sequence__c = 1;
        spfc.MO_YR__c  = 'AM';
        insert spfc;
        Concession__c c = testDataFactory.createConcession();
        ApexPages.StandardController sc = new ApexPages.StandardController(case1);
		SpecialProgramsController clssp = new SpecialProgramsController(sc);
        Test.stopTest();
    }
    static testMethod void TestFuncSpecialProgramsController2() {
        Test.startTest();
        Concession_Code__c cc = new Concession_Code__c();
        cc.Code__c = 'A14';
        cc.Description__c = 'Fault';
        cc.Concession_Account__c = '123-123';
        insert cc;
        
        List<Account> accounts = TestDataFactory.createAccountsWithContacts(2, 2);
        account a = accounts[0];
         //Contact con = [SELECT ID FROM Contact LIMIT 1];
        //Test class run was failing hence we added the below steps
        List<Contact> cons= new List<Contact>();
        cons.add(new Contact(firstName='First2',lastName = 'Last2',Phone='2322322321'));
        Insert cons;
        Contact con = cons[0];
        List<Asset> assets = TestDataFactory.createAssets(2, a);
        case case1 = TestDataFactory.createCase(con, assets[0]);
        
        Case_Asset__c caseAssetRecord = new Case_Asset__c();
        caseAssetRecord.name = 'test';
        caseAssetRecord.Case__c = case1.id;
        caseAssetRecord.Asset__c = assets[0].id;
        caseAssetRecord.Install_Date__c = date.today();
        caseAssetRecord.Serial_Number__c = '123';
        caseAssetRecord.In_Warranty_CaseAsset__c = 'no';
        caseAssetRecord.Model_Number__c = 'abcd';
        caseAssetRecord.Age_Of_Product__c = 1;
        insert caseAssetRecord;
        Special_Programs_and_Recalls__c sp = new Special_Programs_and_Recalls__c();
        sp.Description__c = '2012 Dishwasher Heater Element Recall.  This dishwasher MAY be in the affected population of the 2012 Dishwasher Recall.  To confirm if their unit is in the recall population, the consumer should visit www.geappliances/recall or call the recall hotline at 866-918-8760 (Encourage Website Usage over phone due to hold times)   AFFECTED MODELS begin with: EDW4, EDW5, EDW6, GHD4, GHD5, GHD6, GHDA4, GHDA6, GLC4, GLD4, GLD5, GLD6, GLDL, GSD61, GSD62, GSD63, GSD66, GSD67, GSD69, HLD4, PDW7, PDWF7.  AFFECTED SERIALS:  Produced from March to July of 2006 (FL - ML) and November 2006 to April 2008. (VL - ZL and AM-ZM and AR-GR) REMEDIATION OPTIONS FOR THIS RECALL: Though the web or recall hotline, choice of 2 options are available:      * Free repair to all consumers with units affected by the recall, OR,  * Rebate ($75 or $100 towards specific GE models) for consumers who wish to replace their dishwasher.  ACTION STEPS:     1.)  Ask the consumer if they have had the recall repair. If not, advise the consumer that they can view the recall details, schedule a free repair, or download a rebate for using the website (www.geappliances.com/recall) or call the Recall Hotline at 866-918-8760 for further assistance.     2.) For any potential safety reports up to and including fire, create a CS1049 prior to sending the consumer to the Recall website or hotline phone number.     3.)  If the consumer is already working with the special programs team, transfer them using 866-918-8757.';
        sp.Model_Number__c = 'abcd';
        sp.Product_Line_Code__c = 41;
        sp.Program_Code__c = 'test';
        date dtStart = date.parse('08/09/2012');
        date dtExpiry = date.parse('05/11/2037');
        sp.Program_Start_Date__c = dtStart;
        sp.Program_Expiration_Date__c = dtExpiry;
        sp.Program_Title__c = 'test';
        sp.Program_Type__c = 'test';
        sp.Serial_Number_End__c = 'DE';
        sp.Serial_Number_Start__c = 'FG';
        insert sp;
        Special_Programs_Full_Cycle__c  spfc = new Special_Programs_Full_Cycle__c ();
        spfc.Sequence__c = 1;
        spfc.MO_YR__c  = 'AA';
        insert spfc;
        Concession__c c = testDataFactory.createConcession();
        ApexPages.StandardController sc = new ApexPages.StandardController(case1);
		SpecialProgramsController clssp = new SpecialProgramsController(sc);
        Test.stopTest();
    }
    static testMethod void TestFuncSpecialProgramsController3() {
        Test.startTest();
        Concession_Code__c cc = new Concession_Code__c();
        cc.Code__c = 'A14';
        cc.Description__c = 'Fault';
        cc.Concession_Account__c = '123-123';
        insert cc;
        
        List<Account> accounts = TestDataFactory.createAccountsWithContacts(3, 3);
        account a = accounts[0];
         //Contact con = [SELECT ID FROM Contact LIMIT 1];
        //Test class run was failing hence we added the below steps
        List<Contact> cons= new List<Contact>();
        cons.add(new Contact(firstName='First3',lastName = 'Last3',Phone='2322322321'));
        Insert cons;
        Contact con = cons[0];
        List<Asset> assets = TestDataFactory.createAssets(3, a);

        Special_Programs_and_Recalls__c sp = new Special_Programs_and_Recalls__c();
        sp.Description__c = '2012 Dishwasher Heater Element Recall.  This dishwasher MAY be in the affected population of the 2012 Dishwasher Recall.  To confirm if their unit is in the recall population, the consumer should visit www.geappliances/recall or call the recall hotline at 866-918-8760 (Encourage Website Usage over phone due to hold times)   AFFECTED MODELS begin with: EDW4, EDW5, EDW6, GHD4, GHD5, GHD6, GHDA4, GHDA6, GLC4, GLD4, GLD5, GLD6, GLDL, GSD61, GSD62, GSD63, GSD66, GSD67, GSD69, HLD4, PDW7, PDWF7.  AFFECTED SERIALS:  Produced from March to July of 2006 (FL - ML) and November 2006 to April 2008. (VL - ZL and AM-ZM and AR-GR) REMEDIATION OPTIONS FOR THIS RECALL: Though the web or recall hotline, choice of 2 options are available:      * Free repair to all consumers with units affected by the recall, OR,  * Rebate ($75 or $100 towards specific GE models) for consumers who wish to replace their dishwasher.  ACTION STEPS:     1.)  Ask the consumer if they have had the recall repair. If not, advise the consumer that they can view the recall details, schedule a free repair, or download a rebate for using the website (www.geappliances.com/recall) or call the Recall Hotline at 866-918-8760 for further assistance.     2.) For any potential safety reports up to and including fire, create a CS1049 prior to sending the consumer to the Recall website or hotline phone number.     3.)  If the consumer is already working with the special programs team, transfer them using 866-918-8757.';
        sp.Model_Number__c = 'abcd';
        sp.Product_Line_Code__c = 41;
        sp.Program_Code__c = 'test';
        date dtStart = date.parse('08/09/2012'); //2012-08-09
        date dtExpiry = date.parse('05/11/2037'); //2037-05-16
        sp.Program_Start_Date__c = dtStart;
        sp.Program_Expiration_Date__c = dtExpiry;
        sp.Program_Title__c = 'test';
        sp.Program_Type__c = 'test';
        sp.Serial_Number_End__c = 'DE';
        sp.Serial_Number_Start__c = 'FG';
        insert sp;
        Special_Programs_Full_Cycle__c  spfc = new Special_Programs_Full_Cycle__c ();
        spfc.Sequence__c = 1;
        spfc.MO_YR__c  = 'AA';
        insert spfc;
        Concession__c c = testDataFactory.createConcession();
        Test.stopTest();
    }
    static testMethod void TestFuncSpecialProgramsController4() {
        Test.startTest();
        Concession_Code__c cc = new Concession_Code__c();
        cc.Code__c = 'A14';
        cc.Description__c = 'Fault';
        cc.Concession_Account__c = '123-123';
        insert cc;
        
        List<Account> accounts = TestDataFactory.createAccountsWithContacts(4, 4);
        account a = accounts[0];
        
         //Contact con = [SELECT ID FROM Contact LIMIT 1];
        //Test class run was failing hence we added the below steps
        List<Contact> cons= new List<Contact>();
        cons.add(new Contact(firstName='First4',lastName = 'Last4',Phone='2322322321'));
        Insert cons;
        Contact con = cons[0];
        List<Asset> assets = TestDataFactory.createAssets(4, a);
        case case1 = TestDataFactory.createCase(con, assets[0]);
        
        Case_Asset__c caseAssetRecord = new Case_Asset__c();
        caseAssetRecord.name = 'test';
        caseAssetRecord.Case__c = case1.id;
        caseAssetRecord.Asset__c = assets[0].id;
        caseAssetRecord.Install_Date__c = date.today();
        caseAssetRecord.Serial_Number__c = 'AAAA';
        caseAssetRecord.In_Warranty_CaseAsset__c = 'no';
        caseAssetRecord.Model_Number__c = 'AAAA';
        caseAssetRecord.Age_Of_Product__c = 1;
        insert caseAssetRecord;
        //
        Special_Programs_and_Recalls__c sp = new Special_Programs_and_Recalls__c();
        sp.Description__c = '2012 Dishwasher Heater Element Recall.  This dishwasher MAY be in the affected population of the 2012 Dishwasher Recall.  To confirm if their unit is in the recall population, the consumer should visit www.geappliances/recall or call the recall hotline at 866-918-8760 (Encourage Website Usage over phone due to hold times)   AFFECTED MODELS begin with: EDW4, EDW5, EDW6, GHD4, GHD5, GHD6, GHDA4, GHDA6, GLC4, GLD4, GLD5, GLD6, GLDL, GSD61, GSD62, GSD63, GSD66, GSD67, GSD69, HLD4, PDW7, PDWF7.  AFFECTED SERIALS:  Produced from March to July of 2006 (FL - ML) and November 2006 to April 2008. (VL - ZL and AM-ZM and AR-GR) REMEDIATION OPTIONS FOR THIS RECALL: Though the web or recall hotline, choice of 2 options are available:      * Free repair to all consumers with units affected by the recall, OR,  * Rebate ($75 or $100 towards specific GE models) for consumers who wish to replace their dishwasher.  ACTION STEPS:     1.)  Ask the consumer if they have had the recall repair. If not, advise the consumer that they can view the recall details, schedule a free repair, or download a rebate for using the website (www.geappliances.com/recall) or call the Recall Hotline at 866-918-8760 for further assistance.     2.) For any potential safety reports up to and including fire, create a CS1049 prior to sending the consumer to the Recall website or hotline phone number.     3.)  If the consumer is already working with the special programs team, transfer them using 866-918-8757.';
        sp.Model_Number__c = 'AAAA';
        sp.Product_Line_Code__c = 41;
        sp.Program_Code__c = 'test';
        date dtStart = date.parse('08/09/2012'); //2012-08-09
        date dtExpiry = date.parse('05/11/2037'); //2037-05-16
        sp.Program_Start_Date__c = dtStart;
        sp.Program_Expiration_Date__c = dtExpiry;
        sp.Program_Title__c = 'test';
        sp.Program_Type__c = 'test';
        sp.Serial_Number_End__c = 'AAAA';
        sp.Serial_Number_Start__c = 'AAAA';
        insert sp;
        Special_Programs_Full_Cycle__c  spfc = new Special_Programs_Full_Cycle__c ();
        spfc.Sequence__c = 1;
        spfc.MO_YR__c  = 'AA';
        insert spfc;
        Concession__c c = testDataFactory.createConcession();
        ApexPages.StandardController sc = new ApexPages.StandardController(case1);
		SpecialProgramsController clssp = new SpecialProgramsController(sc);
        Test.stopTest();
    }
}