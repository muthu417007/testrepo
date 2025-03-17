@isTest
private class Test_SPFPDF_Controller   {

    static testMethod void SPF(){
        //Create a SPF Record    
        Seasonal_Performance_Factor__c  sp = new  Seasonal_Performance_Factor__c(Job_Name__c = 'Testspf',Model_Number__c='GE-AZ38H07***',Use_Heat_Pump_Balance_Point__c=True,Calculate_PayBack__c=True,Indoor_Design_Temperature__c=70,Cooling_Cost_per_KWH_in_cents__c=7.50,Hours_Above_75_70_or_80__c=75,Heat_Pump_initial_cost_over_resist_heat__c=100,Drain_line_Installation_Cost__c=0,Electricity_cost_per_KWH_in_cents__c=0);           
        insert sp;
        //Update  SPF Record
        sp.Model_Number__c='GE-AZ38H09***';
        sp.City_and_state__c='ENTERPRISE, AL';
        sp.Indoor_Design_Temperature__c=100;
        update sp;
        //Create a Attachment
        Attachment atch = new Attachment();
        atch.Name='sp.Name.pdf';
        atch.Body=Blob.valueOf('some text');
        atch.ContentType='application/pdf'; 
        atch.ParentId=sp.Id;
        Insert atch;
        //Set the Page Reference to the VisualForce page
        PageReference pref = Page.SendSpfPDF;
        pref.getParameters().Put('Id',sp.Id);
        Test.setCurrentPage(pref);

        SPFPDF_Controller cntlr = new SPFPDF_Controller();

        cntlr.Generate_PDF();
        cntlr.enteredEmail = 'some.junk';
        cntlr.Send_Email();
        
        cntlr.enteredEmail = 'saikrishna.tandra@ge.com';
        cntlr.Send_Email();
        
        cntlr.btnCancel();
    } 
    
    
    static testMethod void CSPF(){
        //Create  list of records           
        Seasonal_Performance_Factor__c  sp = new  Seasonal_Performance_Factor__c(Job_Name__c = 'Testspf',Model_Number__c='GE-AZ38H07***',Use_Heat_Pump_Balance_Point__c=True,Calculate_PayBack__c=True,Indoor_Design_Temperature__c=70,Cooling_Cost_per_KWH_in_cents__c=7.50,Hours_Above_75_70_or_80__c=75,Heat_Pump_initial_cost_over_resist_heat__c=100,Drain_line_Installation_Cost__c=0,Electricity_cost_per_KWH_in_cents__c=0);           
        insert sp;        
        //Set the Page Reference to the VisualForce page
        PageReference pref = Page.SendSpfPDF;
        pref.getParameters().Put('Id',sp.Id);
        Test.setCurrentPage(pref);

        SPFPDF_Controller cntlr = new SPFPDF_Controller();

        cntlr.Generate_PDF();
        cntlr.enteredEmail = 'saikrishna.tandra@ge.com';
        //cntlr.Send_Email();
        cntlr.btnCancel();
    } 
        static testMethod void NSPF(){
        //Create a SPF Record    
        Seasonal_Performance_Factor__c  sp = new  Seasonal_Performance_Factor__c(Job_Name__c = 'Testspf',Model_Number__c='GE-AZ38H07***',Use_Heat_Pump_Balance_Point__c=True,Calculate_PayBack__c=True,Indoor_Design_Temperature__c=70,Cooling_Cost_per_KWH_in_cents__c=7.50,Hours_Above_75_70_or_80__c=75,Heat_Pump_initial_cost_over_resist_heat__c=100,Drain_line_Installation_Cost__c=0,Electricity_cost_per_KWH_in_cents__c=0);           
        insert sp;
        //Create a Attachment
        Attachment atch = new Attachment();
        atch.Name='sp.Name.pdf';
        atch.Body=Blob.valueOf('some text');
        atch.ContentType='application/pdf'; 
        atch.ParentId=sp.Id;
        Insert atch;
        //Set the Page Reference to the VisualForce page
        PageReference pref = Page.SendSpfPDF;
        pref.getParameters().Put('Id',sp.Id);
        If(sp==null)
        Test.setCurrentPage(pref);
              
        SPFPDF_Controller cntlr = new SPFPDF_Controller();
        If(sp==null)
        cntlr.Generate_PDF();
        cntlr.enteredEmail = 'saikrishna.tandra@ge.com';
        cntlr.Send_Email();
        
        If(sp!=null)
        cntlr.Generate_PDF();
        cntlr.enteredEmail = 'saikrishna.tandra@ge.com';
        cntlr.Send_Email(); 
              
        cntlr.btnCancel();
              
    }
       static testMethod void SPFnotattach(){
        //Create a SPF Record    
        Seasonal_Performance_Factor__c  sp = new  Seasonal_Performance_Factor__c(Job_Name__c = 'Testspf',Model_Number__c='GE-AZ38H07***',Use_Heat_Pump_Balance_Point__c=True,Calculate_PayBack__c=True,Indoor_Design_Temperature__c=70,Cooling_Cost_per_KWH_in_cents__c=7.50,Hours_Above_75_70_or_80__c=75,Heat_Pump_initial_cost_over_resist_heat__c=100,Drain_line_Installation_Cost__c=0,Electricity_cost_per_KWH_in_cents__c=0);           
        insert sp;
              
        PageReference pref = Page.SendSpfPDF;
        pref.getParameters().Put('Id',sp.Id);
        Test.setCurrentPage(pref);

        SPFPDF_Controller cntlr = new SPFPDF_Controller();

        cntlr.Generate_PDF();
        cntlr.enteredEmail = 'saikrishna.tandra@ge.com';        
        cntlr.Send_Email();
        
        cntlr.btnCancel();
        }
        
         static testMethod void inValidTest(){
        //Create a SPF Record    
       
              
        PageReference pref = Page.SendSpfPDF;
        pref.getParameters().Put('Id','001');
        Test.setCurrentPage(pref);

        SPFPDF_Controller cntlr = new SPFPDF_Controller();
        }
        
}