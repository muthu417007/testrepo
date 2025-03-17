/**
 * Author:        Karlo Lorenzana
 * Company:       GE Appliances
 * Zone:          North America
 * Description:
 * History
 * 06.22.2021     Karlo Lorenzana     initial implementation
 */
trigger CX_FeedCommentTrigger on FeedComment (after insert, after update) {
    if(CX_TriggerSwitch.isTriggerActive('FeedComment')) {
        CX_TriggerHandler.execute(new CX_FeedCommentTriggerHandler());
    }
}