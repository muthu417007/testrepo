public with sharing class PS_DocuSignHelper {

    private static final String SIGNER = Label.PS_SIGNER;
    private static final String SIGNER_MANAGER = Label.PS_MANAGER_SIGNER;
    private static final String SIGNER_ASM = Label.PS_ASM_SIGNER;

    private static final String AGREEMENT_SELECTION_REQUIRED = Label.PS_DOCUSIGN_AGREEMENT_SELECTION_REQUIRED;
    private static final String AGREEMENT_CONFIGURATION_MISSING = Label.PS_AGREEMENT_TEMPLATE_CONFIG_MISSING;

    private static dfsle.Recipient[] getRecipientsForAgreement(ID agreementID, Boolean isManagerSignatureRequired, Boolean isASMSignatureRequired){

        Customer_Agreement__c agreement = 
            [SELECT Id, Agreement_Signer_Name__c, Agreement_Signer_Email__c, Agreement_Signer_Job_Title__c, 
                    Manager__r.Email, Manager__r.Name, Manager__r.id, 
                    OwnerId,  Owner.Name, Owner.Email
            FROM Customer_Agreement__c
            WHERE id = :agreementID];

        dfsle.Recipient[] recipients = new List<dfsle.Recipient>();

        if(isManagerSignatureRequired){
            recipients.add(
                // Use the Recipient.fromSource method to create the Recipient
                dfsle.Recipient.fromSource(
                    agreement.Manager__r.Name, // Recipient name
                    agreement.Manager__r.Email, // Recipient email
                    null, // Optional phone number
                    SIGNER_MANAGER, // Role Name. Specify the exact role name from template
                    new dfsle.Entity(agreement.Manager__r.id) // Source object for the Recipient
                )
            );
        }

        recipients.add(
            // Use the Recipient.fromSource method to create the Recipient
            dfsle.Recipient.fromSource(
                agreement.Agreement_Signer_Name__c, // Recipient name
                agreement.Agreement_Signer_Email__c, // Recipient email
                null, // Optional phone number
                SIGNER, // Role Name. Specify the exact role name from template
                null // Source object for the Recipient
            )
        );

        if(isASMSignatureRequired){
            recipients.add(
                // Use the Recipient.fromSource method to create the Recipient
                dfsle.Recipient.fromSource(
                    agreement.Owner.Name, // Recipient name
                    agreement.Owner.Email, // Recipient email
                    null, // Optional phone number
                    SIGNER_ASM, // Role Name. Specify the exact role name from template
                    new dfsle.Entity(agreement.OwnerId) // Source object for the Recipient
                )
            );
        }
        return recipients;
    }

    private static PS_DocuSign_Template_Settings__mdt[] getSelectedAgreementTemplates(ID agreementID){

        Customer_Agreement__c agreement = [SELECT Id, Contract_Distributor_Agreement_Selection__c, Retail_Agreement_Selection__c, Agreement_Start_Date__c 
                                           FROM Customer_Agreement__c
                                           WHERE id = :agreementID];

        String year = String.valueOf(agreement.Agreement_Start_Date__c.year());
        String[] selection = null;

        if (!String.isBlank(agreement.Contract_Distributor_Agreement_Selection__c)){
            selection = agreement.Contract_Distributor_Agreement_Selection__c.split(';');
        }
        if (!String.isBlank(agreement.Retail_Agreement_Selection__c)){
            selection = agreement.Retail_Agreement_Selection__c.split(';');
        }
        if(selection == null || selection.size()==0){
            throw new SendToDocuSignActionException(AGREEMENT_SELECTION_REQUIRED);
        }
        
        List<PS_DocuSign_Template_Settings__mdt> templates = 
            [SELECT Id, Agreement_Type__c, DocuSign_Template_Id__c, DocuSign_Template_Name__c, DocuSign_Template_Id_RM__c, DocuSign_Template_Name_RM__c, Year__c, Requires_Manager_Signature__c, Requires_ASM_Signature__c
             FROM PS_DocuSign_Template_Settings__mdt
             WHERE Year__c = :year AND Agreement_Type__c = :selection];
        if(templates == null || templates.size() != selection.size()){
            throw new SendToDocuSignActionException(AGREEMENT_CONFIGURATION_MISSING);
        }
        return templates;
    }

    @InvocableMethod
    public static void sendForSignature(List<String> agreementIDs) {  

        Id mySourceId = agreementIDs[0]; // The ID of the initiating Salesforce object.

        // Create an empty envelope. With the initiating Salesforce entity.
        dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(mySourceId));

        List<dfsle.Document> documents = new List<dfsle.Document>();

        Boolean isManagerSignatureRequired = false;
        Boolean isASMSignatureRequired = false;

        // Loop once to check if manager siganture is required
        for(PS_DocuSign_Template_Settings__mdt template:getSelectedAgreementTemplates(mySourceId)){
            if(template.Requires_Manager_Signature__c == true){
                isManagerSignatureRequired = true;
            }
            if(template.Requires_ASM_Signature__c == true){
                isASMSignatureRequired = true;
            }
            
        }

        // Build the document list
        for(PS_DocuSign_Template_Settings__mdt template:getSelectedAgreementTemplates(mySourceId)){
            // myTemplateId contains the DocuSign ID of the DocuSign Template
            dfsle.UUID myTemplateId = isManagerSignatureRequired ? 
                dfsle.UUID.parse(template.DocuSign_Template_Id_RM__c) : dfsle.UUID.parse(template.DocuSign_Template_Id__c);
            String myTemplateName = isManagerSignatureRequired ? 
                template.DocuSign_Template_Name_RM__c : template.DocuSign_Template_Name__c;
            // Create a new document for the Envelope
            dfsle.Document myDocument = dfsle.Document.fromTemplate(
                myTemplateId, // The templateId in dfsle.UUID format
                myTemplateName); // Name of the template
            documents.add(myDocument);
        }

        List<dfsle.Recipient> myRecipients = getRecipientsForAgreement(mySourceId, isManagerSignatureRequired, isASMSignatureRequired);

        // Add Recipient to the Envelope
        myEnvelope = myEnvelope.withRecipients(myRecipients);
		dfsle.Notifications notifications = new dfsle.Notifications( true, 10, 10, true, 365, 30, false);
        myEnvelope = myEnvelope.withNotifications(notifications);
        String objectString = (String) mySourceId + '~Customer_Agreement__c';
        dfsle.CustomField myField = new dfsle.CustomField ('text', 'DSFSSourceObjectId', objectString, null, false, false);
		String writeBackString = (String) mySourceId + '~NamePDF~0~1';
		dfsle.CustomField myField2 = new dfsle.CustomField ('text', '##SFDocumentWriteBack', writeBackString, null, false, false);

        // Add document to the Envelope
        myEnvelope = myEnvelope.withDocuments(documents)
            .withCustomFields(new List<dfsle.CustomField> {myField,myField2});

        Customer_Agreement__c agreement = 
            [SELECT Id, Account_Name__r.Oracle_Account_Number__c   
               FROM Customer_Agreement__c
              WHERE id = :mySourceId];

        String mySubject = 'GE Appliances Customer Agreement';
        if(agreement.Account_Name__r.Oracle_Account_Number__c != null) {
            mySubject = mySubject +' - '+agreement.Account_Name__r.Oracle_Account_Number__c;
        }
        
        String myBody = 
	         'SENT TO YOU BY: '+UserInfo.getName()+' '+UserInfo.getUserEmail()+' with the DocuSign Electronic Signature Service'
			+'\n\n'
            +'Please click the “Review Document” button to access agreements that have been sent to you from GE Appliances, a Haier Company for signature.'
			+'\n\n'
			+'Please review and electronically sign all agreements by clicking on the link and following the instructions provided in the document to complete your portion for executing the agreement.'
            +'\n\n'
			+'Failure to execute Customer Agreements can result in your loss of ability to purchase products from GE Appliances.'
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
            true); // Send now
    }
    
    class SendToDocuSignActionException extends Exception {

    }
}