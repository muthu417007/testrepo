/**
 * @author         Gunhan Gultekin
 * @company        PolSource
 * @created        08.07.2021(dd.mm.yyyy)
 * @description    Wrapper class for the FlowLocationAssets 
 */
public with sharing class CX_FlowLocationAssetsWrapper {
    @AuraEnabled
    public List<Asset> locationAssets { get; set; }
    @AuraEnabled
    public String messageIndicator{ get; set; }
}