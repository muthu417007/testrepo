@isTest
public class testTriggerCountClasses {
    
    static testMethod void testTriggerCounts() {
        for (integer i=0;i<=2;i++) {
            system.debug('i: '+i);
            triggerCountContactLocation.setRunTimes();
            triggerCountAccount.setRunTimes();
            triggerCountContact.setRunTimes();
            triggerCountContactInfo.setRunTimes();
            triggerCountGEAAsset.setRunTimes();

            system.debug('triggerCountContactLocation.getRunTimes(): '+triggerCountContactLocation.getRunTimes());

            system.debug('triggerCountGEAAsset.getRunTimes(): '+triggerCountGEAAsset.getRunTimes());
 
            system.debug('triggerCountContact.getRunTimes(): '+triggerCountContact.getRunTimes());

            system.debug('triggerCountAccount.getRunTimes(): '+triggerCountAccount.getRunTimes());

            system.debug('triggerCountContactInfo.getRunTimes(): '+triggerCountContactInfo.getRunTimes());
        }
    }    
}