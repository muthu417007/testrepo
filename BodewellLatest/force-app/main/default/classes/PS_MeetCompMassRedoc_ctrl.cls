public class PS_MeetCompMassRedoc_ctrl {

    public String submitResultMsg {get; set;}
    public String result {get; set;}
    public Boolean containsSelectedRequests {get; set;}
    private Set<Id> selected {get; set;}
    public Meet_Comp__c mcInput {get; set;}
    ApexPages.StandardSetController ssc {get; set;}
    public boolean meetCompIsEligible { get; set; }

    public PS_MeetCompMassRedoc_ctrl() {}

    public PS_MeetCompMassRedoc_ctrl(ApexPages.StandardSetController controller) {
        selected = new Set<Id>();
        mcInput = new Meet_Comp__c();
        containsSelectedRequests = controller.getSelected().size() > 0;
        for (Meet_Comp__c mc : (List<Meet_Comp__c>)controller.getSelected()) {
            selected.add(mc.Id);
        }
        meetCompIsEligible = isMeetCompsEligible(selected);
        ssc = controller;
        controller.setPageSize(controller.getResultSize());
    }

    public void saveRecords () {
        List<Meet_Comp__c> clonedMeetComps = new List<Meet_Comp__c>();
        Map<String, Schema.SObjectField> fieldMap = Meet_Comp__c.sObjectType.getDescribe().fields.getMap();

        List<String> fieldNames = new List<String>();
        for(String fieldName : fieldMap.keySet()) {
            if(fieldMap.get(fieldName).getDescribe().isUpdateable()) {
                fieldNames.add(fieldName);
            }
        }

        Savepoint sp = Database.setSavepoint();

        try {
            Map<Id, Meet_Comp__c> currentMcById = new Map<Id, Meet_Comp__c>();
            for (Meet_Comp__c mc : (List<Meet_Comp__c>)ssc.getSelected()) {
                currentMcById.put(mc.Id, mc);
            }

            List<Meet_Comp__c> oldMeetComps = Database.query('SELECT ' + string.join(fieldNames, ',') + ' FROM Meet_Comp__c WHERE Id IN :selected');

            for (Meet_Comp__c oldMc : oldMeetComps) {
                Meet_Comp__c mcClone = new Meet_Comp__c();
                for(String fieldName : fieldMap.keySet()) {
                   if(fieldMap.get(fieldName).getDescribe().isUpdateable()) {
                       mcClone.put(fieldName, oldMc.get(fieldName));
                   }
                }

                if(mcInput.Contact_Name__c != null) {
                    mcClone.Contact_Name__c = mcInput.Contact_Name__c;
                }
                if(mcInput.Termination_Date_of_Competitive_Data__c != null) {
                    mcClone.Termination_Date_of_Competitive_Data__c = mcInput.Termination_Date_of_Competitive_Data__c;
                }

                if(mcInput.Termination_Date__c != null) {
                    mcClone.Termination_Date__c = mcInput.Termination_Date__c;
                }

                if(mcInput.Date_Competitive_Data_Received__c != null) {
                    mcClone.Date_Competitive_Data_Received__c = mcInput.Date_Competitive_Data_Received__c;
                }

                if(mcInput.GEA_Individual_who_received_the_data__c != null) {
                    mcClone.GEA_Individual_who_received_the_data__c = mcInput.GEA_Individual_who_received_the_data__c;
                }

                mcClone.Effective_Date__c = mcInput.Effective_Date__c != null
                    ? mcInput.Effective_Date__c :
                        mcClone.MC_Type__c == 'Promotional MC'
                            ? oldMc.Effective_Date__c
                                : oldMc.Termination_Date__c.addDays(1);

                mcClone.GEA_Prior_Invoice_Price__c = oldMc.GEA_Meet_Comp_Price__c;
                mcClone.Originating_Meet_Comp__c = oldMc.Id;
                mcClone.Created_by_Redoc__c = true;
                mcClone.Stage_Name__c = 'Draft';
                mcClone.Operator__c = 'Insert';
                mcClone.Transferred_to_Oracle__c = false;
                mcClone.GEA_Meet_Comp_Price__c = currentMcById.get(oldMc.Id).GEA_Meet_Comp_Price__c;
                mcClone.Competitive_Invoice_Price__c = currentMcById.get(oldMc.Id).Competitive_Invoice_Price__c;
                mcClone.Redoced_Count__c = null;
                mcClone.OwnerId = userinfo.getUserId();
                clonedMeetComps.add(mcClone);
                oldMc.Redoced_Count__c = oldMc.Redoced_Count__c == null ? 1 : oldMc.Redoced_Count__c + 1;
                oldMc.Redoced__c = true;
            }

            insert clonedMeetComps;
            update oldMeetComps;
            result = 'warning';
            submitResultMsg = 'You are Almost Done - Complete Your Redoc by Submitting Your Records for Approval.';
        } catch (DmlException ex) {
            Database.rollback(sp);
            result = 'error';
            submitResultMsg = 'Redoc failed with the following message: ' + ex.getDmlMessage(0);
        }
    }

    @TestVisible
    private Boolean isMeetCompsEligible(Set<Id> meetCompIds) {
        Boolean isEligible = true;

        Date today = Date.today();
        List<Meet_Comp__c> meetComps = [
            SELECT Termination_Date__c, Stage_Name__c, Redoced__c
            FROM Meet_Comp__c
            WHERE Id IN :meetCompIds
        ];

        for (Meet_Comp__c mc : meetComps) {
            isEligible = (
                (
                    mc.Stage_Name__c == 'Approved' || mc.Stage_Name__c == 'Approved and Transferred'
                ) && (
                    mc.Redoced__c == false
                ) && (
                    mc.Termination_Date__c >= today && mc.Termination_Date__c <= today.addDays(30)
                )
            );
            if (!isEligible) {
                break;
            }
        }

        return isEligible;
    }

}