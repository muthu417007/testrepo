public class ExceptionHandler {
    public static void handleException(Exception e)
    {
            //Set variables for email
            List<String> toAddresses = new String[] {'SFDCITSupport@geappliances.com'};
            //List<String> toAddresses = new String[] {'Matthew.Schuhmann@ge.com'};

            //Set email parameters
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            mail.setReplyTo('SFDCITSupport@geappliances.com');
            mail.setSenderDisplayName('SFDC');
            mail.setSubject('SFDC Apex Trigger Error!');
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setPlainTextBody('APEX Trigger encountered this error: ' + e + ' \r\n\r\nCause\r\n ' + e.getCause() + ' \r\n\r\nLineNumber\r\n ' + e.getLineNumber() + ' \r\n\r\nMessage\r\n ' + e.getMessage() + ' \r\n\r\nStackTrace\r\n ' + e.getStackTraceString() + ' \r\n\r\nGetTypeName\r\n ' + e.getTypeName());
            
            //Send the email (but only if a test is not running)
            if (!Test.isRunningTest()) {
            	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }, false);
            }
        
    }
}