/**
 * Author:        Karlo Lorenzana
 * Company:       GE Appliances
 * Zone:          North America
 * Description:
 * History
 * 06.22.2021     Karlo Lorenzana     initial implementation
 */
trigger CX_KnowledgeArticleVersionTrigger on Knowledge__kav (after insert, after update, before insert, before update) {
    if(CX_TriggerSwitch.isTriggerActive('KnowledgeTrigger')) {
        CX_TriggerHandler.execute(new CX_KnowledgeArticleVersionTriggerHandler());
    }
}