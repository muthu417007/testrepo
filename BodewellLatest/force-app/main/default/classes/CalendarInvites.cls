public class CalendarInvites {
	public static void sendinvite(String strEmail, String strStartDatetime, String strEndDatetime, String strSANumber, String strSAType, String strEmailSubject, String strTimezone, String strDescription) {    
        OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress where Address = 'PersonalShopper.User@geappliances.com' LIMIT 1];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        mail.setOrgWideEmailAddressId(owea.Id);
        mail.setToAddresses(new List<String>{strEmail});
        mail.setSubject(strEmailSubject);      
        mail.setPlainTextBody('');     
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();   
        attach.filename = 'reminder.ics'; 
        attach.ContentType = 'text/calendar';     
        attach.inline = true;     
        String startdatetime=strStartDatetime.mid(6, 4)+strStartDatetime.mid(0, 2)+''+strStartDatetime.mid(3, 2)+'T'+ checkLength(strStartDatetime.mid(11, 2)) +''+ checkLength(strStartDatetime.mid(14, 2)) +''+ checkLength(strStartDatetime.mid(17, 2));
       	String enddatetime=strEndDatetime.mid(6, 4)+strEndDatetime.mid(0, 2)+''+strEndDatetime.mid(3, 2)+'T'+ checkLength(strEndDatetime.mid(11, 2)) +''+ checkLength(strEndDatetime.mid(14, 2)) +''+ checkLength(strEndDatetime.mid(17, 2));
        attach.body = invite(startdatetime,enddatetime,strSAType, strTimezone, strEmailSubject, strDescription);   
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attach});   
        Messaging.SendEmailResult[] er = Messaging.sendEmail(new Messaging.Email[] { mail }); 
    }
    private static Blob invite(String startdatetime, String enddatetime, String strSAType, String strTimezone, String strEmailSubject, String strDescription) {
        strTimezone = 'GMT';
        String txtInvite = ''; 
        txtInvite += 'BEGIN:VCALENDAR\n';        
        txtInvite += 'PRODID:-//sample//sam Calendar//EN\n';
        txtInvite += 'VERSION:2.0\n';
        txtInvite += 'X-MS-OLK-FORCEINSPECTOROPEN:TRUE\n';
        txtInvite += 'X-WR-TIMEZONE:'+strTimezone+'\n';
        txtInvite += 'METHOD:PUBLISH\n';
        txtInvite += 'BEGIN:VEVENT\n';
        txtInvite += 'DTSTART;TZID='+strTimezone+':'+startdatetime+'\n';
        txtInvite += 'DTEND;TZID='+strTimezone+':'+enddatetime+'\n';        
        txtInvite += 'DESCRIPTION: '+strDescription+'\n';  
        txtInvite += 'LOCATION: '+strSAType+'\n';        
        txtInvite += 'SEQUENCE:0\n';
        txtInvite += 'PRIORITY:5\n';
        txtInvite += 'STATUS:CONFIRMED\n';
        txtInvite += 'SUMMARY:'+strEmailSubject+'\n';
        txtInvite += 'UID:X:11@sample\n';
        txtInvite += 'BEGIN:VALARM\n';
        txtInvite += 'TRIGGER:-PT15M\n';
        txtInvite += 'ACTION:DISPLAY\n';
        txtInvite += 'STATUS:CONFIRMED\n';
        txtInvite += 'DESCRIPTION:Reminder\n';
        txtInvite += 'END:VALARM\n';
        txtInvite += 'TRANSP:OPAQUE\n';
        txtInvite += 'END:VEVENT\n';
        txtInvite += 'END:VCALENDAR';
        return Blob.valueOf(txtInvite);
    }
    private static String checkLength(String val){
    if(String.isNotBlank(val) && val.length() == 1){
        val = '0' + val;
    }
    return val;
}
}