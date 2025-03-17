global class PS_MeetCompReminder_Batch implements Database.Batchable<sObject>, Database.Stateful {
    @TestVisible static Set<String> emailsSent;
    global Exception[] errors = new Exception[0];
    global Database.QueryLocator start(Database.BatchableContext bc) {

        List<Date> terminationDates = new List<Date> { System.today().addDays(7), System.today().addDays(15), System.today().addDays(30)};
        return Database.getQueryLocator(
            'SELECT Name, OwnerId, Account__r.OwnerId, Effective_Date__c, Termination_Date__c, Account__c, Account__r.Name, GEA_Model__c, GEA_Model__r.Name, GEA_Meet_Comp_Price__c '
            + 'FROM Meet_Comp__c WHERE Termination_Date__c IN :terminationDates AND Redoced__c = false ORDER BY Account__c');
    }

    global void execute(Database.BatchableContext bc, List<Meet_Comp__c> scope) {
        List<Messaging.SingleEmailMessage> masterListMails = new List<Messaging.SingleEmailMessage>();
        Map<Id, List<Meet_Comp__c>> mcByOwnerId = new Map<Id, List<Meet_Comp__c>>();
        String baseUrl = String.valueOf(URL.getSalesforceBaseUrl().toExternalForm());
        Map<Date, EmailTemplate> emailTemplatesByDate = new Map<Date, EmailTemplate>();
        Map<Date, String> meetCompsByTerminationDate;
        PS_MC_Notification_Config__c notificationConfig = PS_MC_Notification_Config__c.getOrgDefaults();

        EmailTemplate[] emailTemplates = [
            SELECT htmlValue, DeveloperName
            FROM EmailTemplate
            WHERE DeveloperName IN ('MC_Expiration_Notification_7_days', 'MC_Expiration_Notification_15_days', 'MC_Expiration_Notification_30_days')
        ];

        for (EmailTemplate et : emailTemplates) {
            if (et.htmlValue == null) {
                et.htmlValue = '<html><body>';

                // TODO: need to understand why htmlValue is being recieving as null and don't use harcoded text.
                // Consider using the Markup field instead of htmlValue or using an email template with a different type
                if (et.DeveloperName == 'MC_Expiration_Notification_7_days') {
                    et.htmlValue += '<p style="color:red; font-weight: bold;">This is the last email notification you will receive concerning the MCs below.</p>'
                        + '<p>The following MCs will expire within the next 7 days. If the competitive situation still exists, and you need the price to continue after the termination date shown, please REDOC the MC prior to the termination date. </p>'
                        + '<p style="color:red; font-weight: bold;">If you do not redoc now, these MCs will EXPIRE and you will need to create new MCs one at a time. You will be unable to use the "Mass Redoc" feature. Save time...REDOC NOW if these MCs are still needed!</p>';
                } else if (et.DeveloperName == 'MC_Expiration_Notification_15_days') {
                    et.htmlValue += '<p>The following MCs will expire within the next 15 days. If the competitive situation still exists, and you need the price to continue after the termination date shown, please REDOC the MC prior to the termination date.</p>';
                } else if (et.DeveloperName == 'MC_Expiration_Notification_30_days') {
                    et.htmlValue += '<p>The following MCs will expire within the next 30 days. If the competitive situation still exists, and you need the price to continue after the termination date shown, please REDOC the MC prior to the termination date.</p>';
                }
                et.htmlValue +=
                    '<table border="1px solid black;><tr bgcolor="lightgrey"><th>Meet Comp Number</th><th>Account</th><th>GEA Model</th><th>Price</th><th>Current Eff Date</th><th>Current Term Date</th></tr>tabletoreplace</table></body></html>';
            }
        }
        update emailTemplates;

        for (EmailTemplate  et : [SELECT HtmlValue, DeveloperName, Subject FROM EmailTemplate WHERE DeveloperName IN ('MC_Expiration_Notification_7_days', 'MC_Expiration_Notification_15_days', 'MC_Expiration_Notification_30_days')]) {
            switch on et.DeveloperName {
            when 'MC_Expiration_Notification_7_days' {
                emailTemplatesByDate.put(System.today().addDays(7), et);
                }
                when 'MC_Expiration_Notification_15_days' {
                    emailTemplatesByDate.put(System.today().addDays(15), et);
                }
                when 'MC_Expiration_Notification_30_days' {
                    emailTemplatesByDate.put(System.today().addDays(30), et);
                }
            }
        }

        if (emailTemplatesByDate.isEmpty()) {
            return;
        }

        Set<Id> ownerIds = new Set<Id>();
        for (Meet_Comp__c mc : scope) {
            ownerIds.add(mc.OwnerId);
            if (mc.Account__c != null) {
                ownerIds.add(mc.Account__r.OwnerId);
            }
        }

        Map<Id, Boolean> ownersById = new Map<Id, Boolean>();
        for (User u : [SELECT isActive FROM User WHERE Id IN :ownerIds]) {
            ownersById.put(u.Id, u.IsActive);
        }

        for (Meet_Comp__c mc : scope) {
            Id ownerId = ownersById.get(mc.OwnerId) ? mc.OwnerId :
                mc.Account__c != null && ownersById.get(mc.Account__r.OwnerId) ? mc.Account__r.OwnerId :
                notificationConfig.Default_Notification_User__c ;

            if (mcByOwnerId.containsKey(ownerId)) {
                mcByOwnerId.get(ownerId).add(mc);
            } else {
                mcByOwnerId.put(ownerId, new List<Meet_Comp__c> {mc});
            }
        }

        try {
            for (Id ownId : mcByOwnerId.keySet()) {
                meetCompsByTerminationDate = new Map<Date, String>();
                for (Meet_Comp__c mc : mcByOwnerId.get(ownId)) {
                    if (!meetCompsByTerminationDate.containsKey(mc.Termination_Date__c)) {
                        meetCompsByTerminationDate.put(mc.Termination_Date__c, '');
                    }

                    EmailTemplateDate etd = formatTemplateData(mc, baseUrl);
                    String nextRow = '<tr>'
                        + etd.mcUrl
                        + etd.accountUrl
                        + etd.geaModelUrl
                        + etd.compPrice
                        + etd.effectiveDate
                        + etd.terminationDate
                        + '</tr>';
                    meetCompsByTerminationDate.put(mc.Termination_Date__c, meetCompsByTerminationDate.get(mc.Termination_Date__c) + nextRow);

                    if (Test.isRunningTest()) {
                        emailsSent.add(ownId + ':' + mc.name);
                    }
                }
                OrgWideEmailAddress orgEmailId= [SELECT Id FROM OrgWideEmailAddress where displayName='No Reply'];
                for (Date expDate : meetCompsByTerminationDate.keySet()) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setTemplateId(emailTemplatesByDate.get(expDate).Id);
                    email.setTargetObjectId(ownId);
                    email.setOrgWideEmailAddressId(orgEmailId.Id);
                    email.saveAsActivity = false;
                    email.setSubject(emailTemplatesByDate.get(expDate).Subject);
                    email.setHtmlBody(emailTemplatesByDate.get(expDate).HtmlValue.replace('tabletoreplace', meetCompsByTerminationDate.get(expDate)));
                    masterListMails.add(email);
                }
            }

            Messaging.sendEmail(masterListMails);
        } catch (Exception e) {
            errors.add(e);
        }
    }

    global void finish(Database.BatchableContext bc) {
        if (!errors.isEmpty()) {
            AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                FROM AsyncApexJob WHERE Id = :BC.getJobId()];

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Scheduled Job: Service Appointment Reminder ' + a.Status);
            mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with ' + a.NumberOfErrors + ' failures.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }

    private EmailTemplateDate formatTemplateData (Meet_Comp__c mc, String baseUrl) {
        EmailTemplateDate etd = new EmailTemplateDate();
        etd.mcUrl = '<td>' + '<a href="' + baseUrl + '/' + mc.id + '">' + mc.name + '</a></td>';
        etd.geaModelUrl = mc.GEA_Model__c == null ? '<td>-</td>' : '<td>' + '<a href="' + baseUrl + '/' + mc.GEA_Model__c + '">' + mc.GEA_Model__r.Name + '</a></td>';
        etd.accountUrl = mc.Account__c == null ? '<td>-</td>' : '<td>' + '<a href="' + baseUrl + '/' + mc.Account__c + '">' + mc.Account__r.Name + '</a></td>';
        etd.effectiveDate = mc.Effective_Date__c == null ? '<td>-</td>'
            : '<td>' + DateTime.newInstance(mc.Effective_Date__c.year(), mc.Effective_Date__c.month(), mc.Effective_Date__c.day()).format('MM/dd/yyyy') + '</td>';
        etd.terminationDate = mc.Termination_Date__c == null ? '<td>-</td>'
            : '<td>' + DateTime.newInstance(mc.Termination_Date__c.year(), mc.Termination_Date__c.month(), mc.Termination_Date__c.day()).format('MM/dd/yyyy') + '</td>';
        etd.compPrice = '<td>' + '$' + String.valueOf(mc.GEA_Meet_Comp_Price__c).replace('.0', '.00') + '</td>';

        return etd;
    }

    private class EmailTemplateDate {
        String mcUrl {get; set;}
        String accountUrl {get; set;}
        String geaModelUrl {get; set;}
        String effectiveDate {get; set;}
        String terminationDate {get; set;}
        String compPrice {get; set;}
    }
}