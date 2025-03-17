trigger PS_StoreProduct on StoreProduct (after insert, after update, after delete) {
    PS_TriggerDispatcher.run(new PS_StoreProduct_TriggerHandler());
}