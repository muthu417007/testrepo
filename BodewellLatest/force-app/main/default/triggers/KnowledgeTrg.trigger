trigger KnowledgeTrg on Knowledge__kav (before delete,before insert) {
    if(trigger.isBefore){
        if(trigger.isDelete){
            KnowledgeTrgHandler.onBeforeDelete(trigger.old);
        }
    }
}