//******************************************************************************************
//Name : Mya_LineItems
//Requirement : To display Line Item data on My Orders and Order Details Page 
//EPIC/US/TASK : IDMSF- 31, IDMSF- 37, IDMSF- 1032, IDMSF- 1033
//******************************************************************************************
//History
//	Version				Author					Date				Detail
//  1.0					Yogesh Sharma			07/11/2022			Initial
//******************************************************************************************
//@description : Wrapper Class to handle Order Line Item data after Deserializing
public without sharing class Mya_LineItems 
{
    @AuraEnabled Public String LineItemURL;
    @AuraEnabled Public String LineItemDescrp;
    @AuraEnabled Public String ItemModelNo;
    @AuraEnabled Public String SourceType;
    @AuraEnabled Public Decimal ItemTax;
    @AuraEnabled Public Decimal ItemUnitPrice;
    @AuraEnabled Public String ItemUnitPriceString;
    @AuraEnabled Public Decimal ItemActualUnitPrice;
    @AuraEnabled Public String ProdDescription;
    @AuraEnabled Public String LineItemStatus;
    @AuraEnabled Public Date RequestDate;
    @AuraEnabled Public Date ItemArrivalDate;
    @AuraEnabled Public Integer ItemQuantity;
    @AuraEnabled Public String ItemOrderType;
    @AuraEnabled Public String ItemShipMethod = null;
    @AuraEnabled Public List<String> LineItemSerialList;
    @AuraEnabled Public Boolean ShowLineItemFlag;
    @AuraEnabled Public Boolean ShowLineItemFlagDetail;
    @AuraEnabled Public Boolean ShipHomDelFlag;
    @AuraEnabled Public Boolean ShipFedexFlag;
    @AuraEnabled Public Boolean ItemDiscountFlag;
    @AuraEnabled Public Boolean ItemImageFlag;
    @AuraEnabled Public Boolean StandInstallFlag;
    @AuraEnabled Public Boolean isServiceFlag;
    //@AuraEnabled Public String serviceText;
    @AuraEnabled Public String serviceRelatedToLineItem;
}