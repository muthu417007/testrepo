public class ZonelinePDF_Controller {

    public Zoneline_Energy_Cost_Savings_Analysis__c zoneline { get; set; }
    public String zonelineID { get; set; }
    
    public List<Attachment> zonelinePDFs { get; set; }
    public Boolean pdfExists { get; set; }
    public String pdfMessage { get; set; }
    
    public Boolean allowPDF { get; set; }
    public Boolean allowEmail { get; set; }

    public String enteredEmail { get; set; }
    public String emailNote { get; set; }
    public String emailStatus { get; set; }
    
    public User curUser { get; set; }
    public String[] toAddresses { get; set; }
    
    public String disclaimer1 { get; set; }
    public String disclaimer2 { get; set; }
    public String disclaimer3 { get; set; }
    public String disclaimer4 { get; set; }

    public ZonelinePDF_Controller() {
    
        //Get logged-in user information for Email purposes
        curUser = [SELECT Name, Email, Title FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1];
    
        //Disclaimers are shown at the bottom of the PDF
        disclaimer1 = 'Analysis based upon average US Temperatures. Individual results will vary with geographic ' +
        'location, occupancy, usage, weather conditions, room temperature settings, heat loss/gain of room(s) in question, utility rates, etc.';
    
        disclaimer2 = 'Analysis based upon occupied room temperature setpoints of 70 degrees Fahrenheit heating' +
        ' and 75 degrees Fahrenheit cooling.';
        
        disclaimer3 = 'Usage is based on 9,000 BTU model per DOE Technical Support Document on Energy Use ' + 
        'Characterization published 9/30/2008.';
        
        disclaimer4 = 'Calculations based upon customer input and published product data.';
    
        //Get Zoneline ID from URL and check for validity
        zonelineID = ApexPages.currentPage().getParameters().get('Id');
        if (isValidId(zonelineID)) {
        
            //Get Zoneline information and PDF, if one exists
            zoneline = [SELECT Id, Project_Name__c, Analysis_Date__c, Number_of_Rooms__c, Energy_COST_per_month__c, PTAC_Energy_Contribution__c, BTU_Size_K__c, GE_EER__c, Current_EER__c, Better_EER__c, GE_COP__c, Current_COP__c, Better_COP__c, Estimated_Savings_per_Year__c,Estimated_Savings_per_Room_per_Year__c, Emailed_PDF__c FROM Zoneline_Energy_Cost_Savings_Analysis__c WHERE Id =:zonelineID];
            zonelinePDFs = [SELECT Id, Name, Body FROM Attachment WHERE ParentId =:zonelineId AND ContentType = 'application/pdf' ORDER BY CreatedDate DESC LIMIT 1];
            pdfExists = (zonelinePDFs.size() == 1);
            
            //Check to see if savings are negative. If negative, display error message and display link to edit values
            if (zoneline.Estimated_Savings_per_Year__c < 0) {
            
                pdfMessage = '<font color="red"><b>Estimated savings do not warrant being' +
                ' sent to customer. <a href="/' + zoneline.Id +
                '/e?retURL=' + zoneline.Id + '">Click here</a> to update analysis values.</b></font>';
                allowPDF = False;
                allowEmail = False;
            
            }
            
            //Check to see if PDF has been generated. If so, show link to view
            else if (pdfExists) {
                
                pdfMessage = '<b>PDF has been generated. <a href="/servlet/servlet.FileDownload?file=' + zonelinePDFs[0].Id + '" target="_blank">Click here</a> to view.</b>';
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
        
        //An invalid Zoneline is referenced
        else {pdfMessage = '<font color="red"><b>You have not selected a valid Zoneline.</b></font>';}
    }
    
    public Boolean isValidEmail(String s) {
    
        //Function returns a boolen that represents if an email meets the standard format
        
        //Email pattern
        return Pattern.matches('([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})', s);

    }
    
    public Boolean isValidId(String idString) {
    
        //Function returns True if a string is a valid Zoneline ID, False if not
        
        try {
        
           Zoneline_Energy_Cost_Savings_Analysis__c testZoneline = [SELECT Id FROM Zoneline_Energy_Cost_Savings_Analysis__c WHERE Id =:idString];
           return true;
           
       }
       
        catch (Exception ex) {
            return false;
        }
    }
    
    public void Send_Email() {
    
        //Method sends an email with Zoneline attachment to entered email address
        
        //Remove whitespace from email
        if (enteredEmail != null) {enteredEmail = enteredEmail.trim();}
        
        //Checking if email meets correct format
        if (isValidEmail(enteredEmail) ) {
            
            //Check if a Zoneline is loaded
            if (zoneline != null) {
            
                //Set the outgoing email address to the valid email entered
                toAddresses = new String[] {enteredEmail};
        
                //Create new mail object
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
                //Set mail values
                mail.setToAddresses(toAddresses);
                mail.setReplyTo(curUser.Email);
                mail.setSenderDisplayName(curUser.Name);
                mail.setSubject('GE Zoneline Energy Cost Savings Analysis');
                mail.setBccSender(false);
                mail.setUseSignature(false);
            
                if (emailNote != null && emailNote != '') {
            
                    //Set HTML mail body to email message and html tables without hyperlinks
                    mail.setHtmlBody(emailNote.replaceAll('\n','<br />'));
            
                }
                
                //Allow email if PDF exists
                if (pdfExists) {
                
                    //Attach PDF
                    Messaging.EmailFileAttachment pdfAttachment = new Messaging.EmailFileAttachment();
                    pdfAttachment.setFileName(zonelinePDFs[0].Name);
                    pdfAttachment.setBody(zonelinePDFs[0].Body);
                    mail.setFileAttachments(new Messaging.EmailFileAttachment[] {pdfAttachment});
                
                    //Send the email
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }, false);
                
                    //Create an activity in Activity History showing the Floor Display was emailed
                    Log_Email(enteredEmail);
                    
                    //Update Zoneline to indicated it has been emailed
                    if (!zoneline.Emailed_PDF__c) {
                    
                        zoneline.Emailed_PDF__c = True;
                        update zoneline;
                        
                    }
            
                    //Display email success message
                    emailStatus = '<b><font color="green">Zoneline PDF emailed to ' + enteredEmail +  '</font></b><br /><br />';
                
                }
                
                //Show error that PDF has not been generated (should never display because email button will be disabled)
                else {emailStatus = '<b><font color="red">You must generate the PDF before sending an email.</font></b><br /><br />';}
                
            }
            
            else {
                
                //Display invalid Zoneline error message message
                emailStatus = '<b><font color="red">You can only email a valid Zoneline PDF.</font></b><br /><br />';     
            }
        }
        
        else {
        
            //Email is not valid. Display email failure message
            emailStatus = '<b><font color="red">Email address is not valid. Correct it and try again.</font></b><br /><br />';
    
        } 

    
    }
    public void Log_Email(String email) {
    
        //Create a closed activity for the Zoneline showing the PDF was emailed

        Task emailTask = new Task();
        
        //Set task fields
        emailTask.WhatId = zoneline.Id;
        emailTask.ActivityDate = System.Today();
        emailTask.Status = 'Completed';
        emailTask.IsReminderSet = False;
        emailTask.Type = 'Emailed Zoneline PDF';
        emailTask.Subject = 'Emailed Zoneline PDF to ' + email;
        emailTask.Description = 'Emailed Zoneline PDF to ' + email;
            
        if (emailNote != null && emailNote != '') {emailTask.Description += '. MSG: ' + emailNote;}
            
        insert emailTask;
    
    }
    
    public PageReference Generate_PDF() {
    
        //Method will generate a customer-friendly PDF of the Zoneline values and output that can be emailed
    
        //Ensure Zoneline is valid
        if (zoneline != null) {
            
            //Open the PDF generation page with Zoneline ID
            PageReference GeneratedPDF = Page.GenerateZonelinePDF;
            GeneratedPDF.getParameters().put('Id',zonelineId);
 
            //pdf will hold the new Zoneline PDF
            Attachment pdf = new Attachment();
 
            //body will hold the body of the PDF
            Blob body;

            //Assign VisualForce output from PDF generator to the body 
            try {body = GeneratedPDF.getContent();}
            catch (Exception e) {body = Blob.valueOf('Test Text');}

            //Set PDF values and insert PDF
            pdf.Body = body;
            pdf.Name = zoneline.Project_Name__c + '.pdf';
            pdf.ContentType = 'application/pdf';
            pdf.IsPrivate = false;
            pdf.ParentId = zonelineId;
            insert pdf;
            
            //Refer user back to the page
            PageReference ref = new PageReference('/apex/ZonelinePDF?Id=' + zonelineId);
            ref.setRedirect(true);

            return ref;
        }
        
        else {return null;}
    }
    
    public PageReference btnCancel() {
    
        //If the user clicks Cancel, return them to the Zoneline record page.    
        PageReference page = null;
    
        try {
    
            page = new ApexPages.StandardController(zoneline).view();
            page.setRedirect(true);
            return page;
            
        }
        
        //If the Zoneline ID is invalid, send them to the home page   
        catch (Exception ex) {
        
            page = new PageReference('/home/home.jsp');
            page.setRedirect(true);
            return page;
            
        }
    }
}