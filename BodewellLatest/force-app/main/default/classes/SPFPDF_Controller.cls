public class SPFPDF_Controller {

    public Seasonal_Performance_Factor__c spf { get; set; }
    public String spfId { get; set; }
    public List<SPFCalculation__c> spfCalclst {get; set;}
    public List<Heat_Pump_Payback_Analysis__c> spfHeatPA {get; set;}

    public List<Attachment> SpfPDFs { get; set; }
    public Boolean pdfExists { get; set; }
    public String pdfMessage { get; set; }

    public Boolean allowPDF { get; set; }
    public Boolean allowEmail { get; set; }

    public String enteredEmail { get; set; }
    public String emailNote { get; set; }
    public String emailStatus { get; set; }

    public User curUser { get; set; }

    public  String disclaimer1 { get; set; }
    public  String disclaimer2 { get; set; }
    public  String disclaimer3 { get; set; }

    public SPFPDF_Controller() {

        //Get SPFID from URL and check for validity
        spfId = ApexPages.currentPage().getParameters().get('Id');
        //Get logged-in user information for Email purposes
        curUser = [SELECT Name, Email, Title FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1];

        //Disclaimers are shown at the bottom of the PDF
        disclaimer1 ='Utility rates should be verified locally.';
        disclaimer2 ='Years heating payback per unit equals incremental cost per unit divided by KWHR savings per unit times the cost per KWH.';
        disclaimer3 = 'Operating KWH Hours are estimates only and should be verified locally by the operating engineers of the project.';


        if (SFDCUtil.isValidId('Seasonal_Performance_Factor__c',spfId)) 
        {
            //Get spf information and PDF, if one exists
            spf = [SELECT Id,Name, Job_Name__c,Model_Number__c,Total_PTAC_Resistance_Heating_Kwh__c ,City_and_state__c,Indoor_Design_Temperature__c,Cooling_Cost_per_KWH_in_cents__c,Heat_Pump_initial_cost_over_resist_heat__c,Out_Door_design_Temperature__c,Hours_Above_75_70_or_80__c,Heat_Loss__c,Electricity_cost_per_KWH_in_cents__c,Drain_line_Installation_Cost__c,Annual_KWH_Required_For_Resistance_Ht65F__c,Annual_KWH_Required_For_Resistance_Ht75F__c,Annual_KWH_Required_For_Resistance_Ht70F__c,Annual_KWH_Saved_With_Heat_Pump_Sys65F__c,Annual_KWH_Saved_With_Heat_Pump_Sys75F__c,Annual_KWH_Saved_With_Heat_Pump_Sys70F__c,Annual_KWH_Required_For_Heat_Pump_Sys75F__c,Annual_KWH_Required_For_Heat_Pump_Sys70F__c,SPF_of_Heat_Pump_65F__c,SPF_of_Heat_Pump_75F__c,SPF_of_Heat_Pump_70F__c,Energy_Savings_65F__c,Energy_Savings_75F__c,Energy_Savings_70F__c,Heat_Gain_in_BTUH__c,Estimated_Cooling_KWHR_Per_Year__c,Estimated_Cooling_Costs__c,Total_KWHR_Per_Year__c,Total_KWHR_Per_YearPTAC__c,Total_KWHR_Per_YearKilowattHr__c,Total_KWHR_Per_YearPTHP__c,Energy_For_Cooling__c,Energy_For_Cooling_PTAC__c,Energy_For_Cooling_KiloWatt_Hrs__c,Energy_For_Cooling_PTHP__c,Energy_For_Heating__c,Energy_For_Heating_PTAC__c,Energy_For_Heating_KiloWatt_Hrs__c,Energy_For_Heating_PTHP__c,Hours_Above_70F_75F_80F__c,Heat_Gain_in_BTUH_HeatPump__c,Annual_KWH_Required_For_Heat_Pump_Sys65F__c,Heat_Pump_Cost_Over_Comparable_System__c,Drain_Line_Cost_Per_Unit__c,Annual_KWH_Savings__c,Annual_KWH_Required_For_Resistance_Ht_HP__c,Annual_KWH_Required_For_Heat_Pump_Sys_HP__c,Total_Incremental_Cost_Per_Unit__c,X3rd_Temparature_HDN__c,Total_Heat_Pump_Kwh__c,Heat_gain_BTUH__c,Emailed_PDF__c   From Seasonal_Performance_Factor__c WHERE Id =:spfId];
            SpfPDFs = [SELECT Id, Name, Body FROM Attachment WHERE ParentId =:spf.Id AND ContentType = 'application/pdf' ORDER BY CreatedDate DESC LIMIT 1];
            pdfExists = (SpfPDFs.size() == 1);
            
            if(spfId!=Null){
                spfCalclst =[select Id,Outdoor_Temp__c,Heat_Loss_Watts_Formula__c,Heating_Hours__c,PTAC_Resistance_Heating_KWH__c,Additional_Heat_Required_Heat_Hr_Watts__c,Coefficient_of_Performance__c,Heat_Pump_Kwh__c from SPFCalculation__c where SPF__c=:spfId ORDER BY Outdoor_Temp__c desc];
                spfHeatPA =[select Id,Annual_Savings_With_Heat_Pump__c,Total_Annual_Cost_Heat_Pump__c,Total_Annual_Cost_Resistance_Heat__c,Utility_Cost_Per_KWHR__c, Years_for_Payback__c from Heat_Pump_Payback_Analysis__c where  SPF_Calculations__c=:spfId];
            }
            //Check to see if PDF has been generated. If so, show link to view
            if (pdfExists) {               
                pdfMessage = '<b>PDF has been generated. <a href="/servlet/servlet.FileDownload?file=' + SpfPDFs[0].Id + '" target="_blank">Click here</a> to view.</b>';
                allowPDF = False;
                allowEmail = True;               
                emailNote = '\n\n\n' + curUser.Name;
                if (curUser.Title != null) {emailNote += '\n' + curUser.Title;}
            }
            //PDF has not been generated. Show message to generate
            else {
                pdfMessage = '<font color="red"><b>Click the button below to generate a PDF.</b></font>';
                allowPDF = True;
                allowEmail = False;
            }
        }
        else 
            pdfMessage = '<font color="red"><b>You have not selected a valid SPF.</b></font>';
    }

    //Method sends an email with SPF attachment to entered email address
    public void Send_Email() {
        
        if (spf == null) {
            emailStatus = '<b><font color="red">You can only email a valid SPF PDF.</font></b><br /><br />';return; 
        }
        if (!pdfExists) {
            emailStatus = '<b><font color="red">You must generate the PDF before sending an email.</font></b><br /><br />';return;
        }
        if (String.isBlank(enteredEmail) || !SFDCUtil.isValidEmail(enteredEmail) ) {
            emailStatus = '<b><font color="red">Email address is not valid. Correct it and try again.</font></b><br /><br />';return;
        }
        
        SFDCUtil.sendHTMLEmail(new String[]{enteredEmail}, 'Seasonal Performance Factor', curUser.Email, curUser.Name, SPFPDFs[0], emailNote);
        emailStatus = '<b><font color="green">SPF PDF emailed to ' + enteredEmail +'</font></b><br /><br />';
        
         if (!spf.Emailed_PDF__c) {                    
                        spf.Emailed_PDF__c = True;
                        update spf;
         }
    }
    
    // For generate PDF button
    public PageReference Generate_PDF() {
        if (spf != null) 
            return SFDCUtil.attachPDF(Page.SPFpdf, spfId, spf.Name,  '/apex/SendSpfPDF?id=' );
        else return null;
    }

    // For cancel button on the page
    public PageReference btnCancel() {
        return SFDCUtil.cancelPage(spf,'/home/home.jsp');
    }
}