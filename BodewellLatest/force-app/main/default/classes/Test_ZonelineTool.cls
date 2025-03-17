@isTest
public class Test_ZonelineTool {

    //Test class for ZonelinePDF_Controller class and DeleteZonelinePDFAfterUpdate trigger

    static testMethod void testZoneline() {
        
        //Create a new Zoneline
        Zoneline_Energy_Cost_Savings_Analysis__c zoneline = new Zoneline_Energy_Cost_Savings_Analysis__c(Project_Name__c='Test', Analysis_Date__c = System.Today(), Number_of_Rooms__c = 100, Energy_COST_per_month__c = 5000, PTAC_Energy_Contribution__c = 85, BTU_Size_K__c = 9, GE_EER__c = 12, Current_EER__c = 11, GE_COP__c = 3.8, Current_COP__c = 3);
        insert zoneline;
         
         zoneline.Project_Name__c = 'Test2';
         update zoneline;
        
        Attachment testPDF = new Attachment(Name='Test.pdf', Body=Blob.valueOf('some text'), ContentType='application/pdf', ParentId=zoneline.Id);
        insert testPDF;
        
        //Set the Page Reference to the VisualForce page
        PageReference pageRef = Page.ZonelinePDF;
        
        //Open visualforce page for the Floor Plan
        pageRef.getParameters().Put('Id',zoneline.Id);
        Test.setCurrentPage(pageRef);
        
        ZonelinePDF_Controller controller = new ZonelinePDF_Controller();
        
        controller.Generate_PDF();
        
        controller.enteredEmail = 'mike.burns';
        controller.Send_Email();
        
        controller.enteredEmail = 'mike.burns@ge.com';
        controller.Send_Email();
        
        controller.btnCancel();
             
    }
    
    static testMethod void testZoneline2() {
        
        //Create a new Zoneline
        Zoneline_Energy_Cost_Savings_Analysis__c zoneline = new Zoneline_Energy_Cost_Savings_Analysis__c(Project_Name__c='Test', Analysis_Date__c = System.Today(), Number_of_Rooms__c = 100, Energy_COST_per_month__c = 5000, PTAC_Energy_Contribution__c = 85, BTU_Size_K__c = 9, GE_EER__c = 10, Current_EER__c = 11, GE_COP__c = 3.8, Current_COP__c = 5);
        insert zoneline;
        
        //Set the Page Reference to the VisualForce page
        PageReference pageRef = Page.ZonelinePDF;
        
        //Open visualforce page for the Floor Plan
        pageRef.getParameters().Put('Id',zoneline.Id);
        Test.setCurrentPage(pageRef);
        
        ZonelinePDF_Controller controller = new ZonelinePDF_Controller();
        
        controller.Generate_PDF();
        
        controller.enteredEmail = 'mike.burns@ge.com';
        
        //controller.Send_Email();
        controller.btnCancel();

    }
    
    static testMethod void testZoneline3() {
        
        //Create a new Zoneline
        Zoneline_Energy_Cost_Savings_Analysis__c zoneline = new Zoneline_Energy_Cost_Savings_Analysis__c(Project_Name__c='Test', Analysis_Date__c = System.Today(), Number_of_Rooms__c = 100, Energy_COST_per_month__c = 5000, PTAC_Energy_Contribution__c = 85, BTU_Size_K__c = 9, GE_EER__c = 12, Current_EER__c = 11, GE_COP__c = 3.8, Current_COP__c = 3);
        insert zoneline;
        
        //Set the Page Reference to the VisualForce page
        PageReference pageRef = Page.ZonelinePDF;
        
        //Open visualforce page for the Floor Plan
        pageRef.getParameters().Put('Id',zoneline.Id);
        Test.setCurrentPage(pageRef);
        
        ZonelinePDF_Controller controller = new ZonelinePDF_Controller();
        
        controller.Generate_PDF();
        
        controller.enteredEmail = 'mike.burns@ge.com';
        
        controller.Send_Email();
        controller.btnCancel();

    }
    
    static testMethod void testZoneline4() {
        
        //Set the Page Reference to the VisualForce page
        PageReference pageRef = Page.ZonelinePDF;
        
        //Open visualforce page for the Floor Plan
        Test.setCurrentPage(pageRef);
        
        ZonelinePDF_Controller controller = new ZonelinePDF_Controller();
        
        controller.Generate_PDF();
        
        controller.enteredEmail = 'mike.burns@ge.com';
        
        controller.Send_Email();
        controller.btnCancel();
        
    }
    
    static testMethod void testZonelineFailure() {
        
        //Create a new Zoneline
        Zoneline_Energy_Cost_Savings_Analysis__c zoneline = new Zoneline_Energy_Cost_Savings_Analysis__c(Project_Name__c='Test', Analysis_Date__c = System.Today(), Number_of_Rooms__c = 100, Energy_COST_per_month__c = 5000, PTAC_Energy_Contribution__c = 85, BTU_Size_K__c = 9, GE_EER__c = 12, Current_EER__c = 11, GE_COP__c = 3.8, Current_COP__c = 3);
        insert zoneline;
        
        //Attachment testPDF = new Attachment(Name='Test.pdf', Body=Blob.valueOf('some text'), ContentType='application/pdf', ParentId=zoneline.Id);
        //insert testPDF;
        System.debug('Email PDF '+zoneline.Emailed_PDF__c);
        zoneline.Project_Name__c = 'Test2';
        update zoneline;
        
        
    }
 }