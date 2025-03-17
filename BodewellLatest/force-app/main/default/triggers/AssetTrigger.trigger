/**
 * @author         Sukumar Venkatesan
 * @company        GEA
 * @created        06.Nov.2022
 * @description    Apex trigger for Asset Object
 */
trigger AssetTrigger on Asset (
    before insert,
    after insert,
    before update,
    after update,
    after delete,
    before delete) {
		PS_TriggerDispatcher.run(new AssetTriggerHandler());
}