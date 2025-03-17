public with sharing class PS_MeetCompService {
    
    public void setOriginalMeetCompWhenCloned (List<Meet_Comp__c> meetComps) {

        for (Meet_Comp__c meetComp : meetComps) {
            if (meetComp.isClone()) {
                meetComp.Originating_Meet_Comp__c = meetComp.getCloneSourceId();
            }
        }
    }
}