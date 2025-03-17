/**
 * @author         Monu Samrat
 * @company        GEA
 * @created        03/01/2022
 * @description    Class used to send Docusign credit application
 */
public with sharing class DocuSignSender {
    
     private static final String AGREEMENT_SELECTION_REQUIRED = Label.PS_DOCUSIGN_AGREEMENT_SELECTION_REQUIRED;
    private static final String AGREEMENT_CONFIGURATION_MISSING = Label.PS_AGREEMENT_TEMPLATE_CONFIG_MISSING;
   
    private static PS_DocuSign_Template_Settings__mdt[] getSelectedAgreementTemplates(ID agreementID){

       Credit_Application__c agreement1= [select Id, GEA_Sales_Representative_Name__c,GEA_Sales_Representative_Email__c,
                                              Credit_Application_Forms__c from Credit_Application__c where id =: agreementID];
        
        system.debug(agreement1);
        String selection = null;
        
        if (!String.isBlank(agreement1.Credit_Application_Forms__c)){
            selection = agreement1.Credit_Application_Forms__c;
            system.debug(selection);
            
        }
        if(selection == null){
            throw new SendToDocuSignActionException(AGREEMENT_SELECTION_REQUIRED);
        }

        List<PS_DocuSign_Template_Settings__mdt> templates = 
            [SELECT Id, Agreement_Type__c, DocuSign_Template_Id__c, DocuSign_Template_Name__c, DocuSign_Template_Id_RM__c, DocuSign_Template_Name_RM__c, Year__c, Requires_Manager_Signature__c, Requires_ASM_Signature__c
             FROM PS_DocuSign_Template_Settings__mdt WHERE Agreement_Type__c = :selection and Year__c =: system.label.Custom_label_for_Year_in_docusign_credit_App];
        system.debug(templates);
        system.debug(templates.size());
        
        if(templates == null){
            throw new SendToDocuSignActionException(AGREEMENT_CONFIGURATION_MISSING);
        }
        return templates;
    }

    
    
     @InvocableMethod
    public static void sendEnvelopeMethod(List<String> agreementIDs) {
        sendEnvelopeMethod1(agreementIDs);
    }   
    
  // The ID of the DocuSign template
       @future(callout=true)
    public static void sendEnvelopeMethod1(List<String> agreementIDs){
        Id mySourceId =agreementIDs[0];  
        system.debug(mySourceId);
        

        Credit_Application__c crdlist= [select GEA_Sales_Representative_Name__c,GEA_Sales_Representative_Email__c,Customer_Name__c,
                                        Customer_Email__c, Customer_Contact__c, Credit_Application_Forms__c,
                                        Name from Credit_Application__c where id =: agreementIDs[0]];
             
        system.debug(crdlist);
        

        // Create an empty envelope
        dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(
        new dfsle.Entity(mySourceId));
        // The initiating Salesforce entity

        // Use myEnvelope for later 
        //use the Recipient.fromSource method to create the Recipient
        dfsle.Recipient myRecipient = dfsle.Recipient.fromSource(
           crdlist.Customer_Contact__c, // Recipient name
           crdlist.Customer_Email__c,   // Recipient email
            null, // Optional phone number
            'Customer', // Role Name. Specify the exact role name from template
           null); // Source object for the recipient
        system.debug(myRecipient);
         system.debug(crdlist.Customer_Email__c);
        system.debug(crdlist.Customer_Contact__c);
         
        
        dfsle.Recipient myRecipient3 = dfsle.Recipient.fromSource(
          // Recipient name
          // Recipient email
           'GEA Risk Team',
           System.Label.Custom_label_for_Risk_team_DL_docusign_credit_App,
            null, // Optional phone number
            'Risk_Team', // Role Name. Specify the exact role name from template
            null);
        
        // Add a recipient to the envelope
        myEnvelope = myEnvelope.withRecipients(new List<dfsle.Recipient> { myRecipient,myRecipient3 });
          List<dfsle.Document> documents = new List<dfsle.Document>();
        
        // Build the document list
        for(PS_DocuSign_Template_Settings__mdt template:getSelectedAgreementTemplates(mySourceId)){
            // myTemplateId contains the DocuSign ID of the DocuSign Template
            dfsle.UUID myTemplateId = dfsle.UUID.parse(template.DocuSign_Template_Id__c);
            String myTemplateName = template.DocuSign_Template_Name__c;
            // Create a new document for the Envelope
            dfsle.Document myDocument = dfsle.Document.fromTemplate(
                myTemplateId, // The templateId in dfsle.UUID format
                myTemplateName); // Name of the template
            documents.add(myDocument);
        }

       myEnvelope = myEnvelope.withDocuments(documents);
        dfsle.Notifications notifications = new dfsle.Notifications( true, 10, 10, true, 365, 30, false);
        myEnvelope = myEnvelope.withNotifications(notifications);
        system.debug(notifications);
        system.debug(myEnvelope);

        Credit_Application__c crdlist1= [select Customer_Name__c, Account__r.Name, Account__r.Party_Name__c,
                                         Account__r.Record_Type_Name__c,
                                        Customer_Email__c, Credit_Application_Forms__c,
                                        Name from Credit_Application__c where id =: mySourceId];
       system.debug(crdlist1);
       
        String mySubject = 'GE Appliances Credit App/Project Sheet for';
        
           mySubject = mySubject +' '+crdlist.Customer_Name__c;
          // mySubject = mySubject +' '+ 'from GE Appliances';

 
       String myBody = 
             'SENT TO YOU BY: '+UserInfo.getName()+' '+UserInfo.getUserEmail()+' with the DocuSign Electronic Signature Service'
            +'\n\n'
            +'Please click the “Review Document” button to complete the credit application/project sheet and submit to us for review. We will contact you back if we have any additional questions regarding the processing of your application.'
            +'\n\n'
            +'Thank You,'
            +'\n' + UserInfo.getName()+'\n'
            +'GE Appliances'+'\n'
            +'\n\n'
            +'****Please do not respond directly to this email. It is an unmonitored inbox. If you have questions or concerns, please contact your ASM, contact details are listed above****';
        
        myEnvelope.withEmail(mySubject, myBody); 
        // Send the envelope
        myEnvelope = dfsle.EnvelopeService.sendEnvelope(
            myEnvelope, // The envelope to send
            true); // True to send the envelope now
    } 
    

     class SendToDocuSignActionException extends Exception {

    }
}