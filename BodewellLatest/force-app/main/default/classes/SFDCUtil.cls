public class SFDCUtil {

	//Function returns a boolen that represents if an email meets the standard format
	public static boolean isValidEmail(String s) {
		return Pattern.matches('([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})', s);
	}
	
	// check if the id is a valid id. 
	public static Boolean isValidId(String tableName, String idStr) {
		String sql = 'SELECT Id FROM $TABLE$ WHERE Id =:idStr';
		sql=sql.replace('$TABLE$',tableName);
			List<sObject> objList = Database.query(String.escapeSingleQuotes(sql));
			return (objList!=null && objList.size()>0);
	}
	
    //Call this from the batch Jobs to finish job by sending the email.
    public static void batchMailer(Id batchId, String emailSubject){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:batchId];
      	String emailNote='The batch Apex job processed '+ a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures.';
        SFDCUtil.sendHTMLEmail(new String[] {a.CreatedBy.Email}, emailSubject+ a.Status, a.CreatedBy.Email, 'Batch', null, emailNote);
    }
	
	//Cancels the page and display the object page that is passed else shows the home page.
	public static PageReference cancelPage(sObject obj, String url){
		//If the user clicks Cancel, return them to the spf record page.    
		PageReference page = null;
		try {
			page = new ApexPages.StandardController(obj).view();
			page.setRedirect(true);
			return page;
		}
		//If the spf ID is invalid, send them to the home page   
		catch (Exception ex) {
			page = new PageReference(url);
			page.setRedirect(true);
			return page;
		}
	
	}
	
	//generates and attaches the pdf to the main object.
	public static PageReference attachPDF(PageReference p_pageRef, ID id, String pdfName, String url ) {
			PageReference pageRef=p_pageRef;
			
			if(pageRef==null)return pageRef;
			
			pageRef.getParameters().put('Id',id);
			//pdf will hold the new SPF PDF
			Attachment pdf = new Attachment();
			//body will hold the body of the PDF
			Blob body;
			//Assign VisualForce output from PDF generator to the body 
			try {body = pageRef.getContent();}
			catch (Exception e) {body = Blob.valueOf(' Text');}

			//Set PDF values and insert PDF
			pdf.Body = body;
			pdf.Name = pdfName + '.pdf';
			pdf.ContentType = 'application/pdf';
			pdf.IsPrivate = false;
			pdf.ParentId = id;
			insert pdf;

			//Refer user back to the page
			PageReference ref = new PageReference(url + id);
			ref.setRedirect(true);
			return ref;
	}

	//Method sends an email with Zoneline attachment to entered email address
	public static boolean sendEmail(String[] toAddresses, String[] ccAddresses, String subject, String replyTo, String displayName, boolean bccSender, boolean useSignature, Attachment attachment, boolean htmlBody, String emailBody) {

		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setToAddresses(toAddresses);
		OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = :displayName];
        if ( owea.size() > 0 ) {  
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        else {
            mail.setSenderDisplayName(displayName);
        }
		mail.setReplyTo(replyTo);
		//mail.setSenderDisplayName(displayName);
		mail.setSubject(subject);
		mail.setBccSender(bccSender);
		mail.setUseSignature(useSignature);
		
		if(htmlBody && String.isNotBlank(emailBody))
			mail.setHtmlBody(emailBody.replaceAll('\n','<br />'));
		
		//if attachment is there then add the attachment.
		if(attachment!=null){
			Messaging.EmailFileAttachment pdfAttachment = new Messaging.EmailFileAttachment();
			pdfAttachment.setFileName(attachment.Name);
			pdfAttachment.setBody(attachment.Body);
			mail.setFileAttachments(new Messaging.EmailFileAttachment[] {pdfAttachment});
		}
		 Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }, false);
		return true;
	}
	
	//Use this when you want to send the plain email with attachement - For future use.
	public static boolean sendEmail(String[] toAddresses, String subject, String replyTo, String displayName,Attachment attachment, String emailBody) {
		return sendEmail(toAddresses, null, subject, replyTo, displayName, false, false, attachment, false,  emailBody);
	}
	
	//Use this when you want to send the HTML email with attachement.
	public static boolean sendHTMLEmail(String[] toAddresses, String subject, String replyTo, String displayName,Attachment attachment, String emailBody) {
		return sendEmail( toAddresses, null, subject, replyTo, displayName,  false, false, attachment, true, emailBody);
	}
}