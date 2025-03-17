//******************************************************************************************
//Name : BDWPagedirections_Test
//Requirement : To test BDWPagedirections
//******************************************************************************************
//History
//	Version				Author					Date				Detail
//  1.0					Akhil M R			12/14/2022			Initial
//******************************************************************************************
//@description : To test BDWPagedirections
@isTest
public class BDWPagedirections_Test {
//@description Test Successful request
    @IsTest
    static void testPageRedirection() {
    	Test.startTest();
        BDWPagedirections pgr = new BDWPagedirections();
        PageReference reference = pgr.urlRedirection();
        System.assert(reference != null);
        Test.stopTest();      
    }
}