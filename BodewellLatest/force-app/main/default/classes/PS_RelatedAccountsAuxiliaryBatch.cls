public class PS_RelatedAccountsAuxiliaryBatch implements Database.Batchable<sObject>, Database.Stateful {

    public Set<Id> siteParentIds;
    public String query;
    public Map<Id, PS_RelatedAccountsPropagator.PopulatedParentAccountInfo> populatedParentAccountIdToInfoMap =
        new Map<Id, PS_RelatedAccountsPropagator.PopulatedParentAccountInfo>();

    public PS_RelatedAccountsAuxiliaryBatch(
        Set<Id> parentIds
    ) {
        this.siteParentIds = parentIds;
        String queryString = 'SELECT ';

        for (PS_AccountSiteLogic__mdt asl : [SELECT FieldName__c, RtToProcess__c FROM PS_AccountSiteLogic__mdt]) {
            queryString += asl.FieldName__c + ', ';
        }

        queryString += 'Id, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, ShippingStreet, ShippingCity, '
            + 'ShippingState, Identifying_Address__c, ShippingPostalCode, ShippingCountry, ShippingLatitude, ShippingLongitude, Brands_Not_Allowed__c, LastModifiedDate, '
            + 'Where_To_Buy_Locator__c, RecordType.DeveloperName, RecordType.Name, ParentId, Parent.RecordTypeId, BillingAddress, Purpose__c, Purpose_Primary_Flag__c, Status__c, CreatedDate '
            + 'FROM Account WHERE ParentId IN :siteParentIds OR Id IN :siteParentIds ORDER BY LastModifiedDate DESC, Id DESC';

        this.query = queryString;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(this.query);
    }

    public void execute(Database.BatchableContext bc, List<Account> scope) {
        if (scope.isEmpty()) {
            return;
        }
        PS_RelatedAccountsPropagator.populateAddressesOnParentAccount(
            new Map<Id, Account>(scope),
            populatedParentAccountIdToInfoMap
        );
    }

    public void finish(Database.BatchableContext bc) {}

}