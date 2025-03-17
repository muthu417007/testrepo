trigger PS_AccountTeamMember on AccountTeamMember (after insert, after delete) {
    PS_TriggerDispatcher.run(new PS_AccountTeamMember_TriggerHandler());
}