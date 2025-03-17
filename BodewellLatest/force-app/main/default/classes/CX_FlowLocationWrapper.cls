/**
 * @author         Gunhan Gultekin
 * @company        PolSource
 * @created        05.07.2021(dd.mm.yyyy)
 * @description    Wrapper class for the FlowLocation information returs
 */
public with sharing class CX_FlowLocationWrapper {
    @AuraEnabled
    public List<Account> locationInformation { get; set; }
    @AuraEnabled
    public String selectedLocationId { get; set; }
}