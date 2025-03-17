public with sharing class PA_SyncAccountAddressTriggerHandler {
    public static void updateContactPointAddressOnAccountChanges(List<Account> newList, Map<Id, Account> oldMapAccList){
	
        // Create lists to store the updated Account records and ContactPointAddress records
        List<Account> updatedAccounts = new List<Account>();
        List<ContactPointAddress> updatedBillingAddresses = new List<ContactPointAddress>();
        List<ContactPointAddress> updatedShippingAddresses = new List<ContactPointAddress>();
    
        for (Account acc : newList) {
            Account oldAccount = oldMapAccList.get(acc.Id);
    
            // Check if the Billing Address has changed
            if (acc.BillingStreet != oldAccount.BillingStreet ||
                acc.BillingCity != oldAccount.BillingCity ||
                acc.BillingState != oldAccount.BillingState ||
                acc.BillingPostalCode != oldAccount.BillingPostalCode ||
                acc.BillingCountry != oldAccount.BillingCountry) {
    
                // Query for related ContactPointAddress records with AddressType = 'Billing'
                List<ContactPointAddress> billingAddresses = [
                    SELECT Id, ParentId, AddressType
                    FROM ContactPointAddress
                    WHERE ParentId = :acc.Id AND AddressType = 'Billing'
                ];
    
    
                // Update the Billing ContactPointAddress records
                for (ContactPointAddress cpAddress : billingAddresses) {
                    cpAddress.Street = acc.BillingStreet;
                    cpAddress.City = acc.BillingCity;
                    cpAddress.State = acc.BillingState;
                    cpAddress.PostalCode = acc.BillingPostalCode;
                    cpAddress.Country = acc.BillingCountry;
                    updatedBillingAddresses.add(cpAddress);
                }
            }
    
    
            // Check if the Shipping Address has changed
            if (acc.ShippingStreet != oldAccount.ShippingStreet ||
                acc.ShippingCity != oldAccount.ShippingCity ||
                acc.ShippingState != oldAccount.ShippingState ||
                acc.ShippingPostalCode != oldAccount.ShippingPostalCode ||
                acc.ShippingCountry != oldAccount.ShippingCountry) {
    
                // Query for related ContactPointAddress records with AddressType = 'Shipping'
                List<ContactPointAddress> shippingAddresses = [
                    SELECT Id, ParentId, AddressType
                    FROM ContactPointAddress
                    WHERE ParentId = :acc.Id AND AddressType = 'Shipping'
                ];
    
    
                // Update the Shipping ContactPointAddress records
                for (ContactPointAddress cpAddress : shippingAddresses) {
                    cpAddress.Street = acc.ShippingStreet;
                    cpAddress.City = acc.ShippingCity;
                    cpAddress.State = acc.ShippingState;
                    cpAddress.PostalCode = acc.ShippingPostalCode;
                    cpAddress.Country = acc.ShippingCountry;
                    updatedShippingAddresses.add(cpAddress);
                }
            }
    
            // Add the Account to the list for update if any address has changed
            if (!updatedBillingAddresses.isEmpty() || !updatedShippingAddresses.isEmpty()) {
                updatedAccounts.add(acc);
            }
        }
    
    
        // Update the ContactPointAddress records and trigger an Account update
        if (!updatedBillingAddresses.isEmpty() || !updatedShippingAddresses.isEmpty()) {
            update updatedBillingAddresses;
            //update updatedShippingAddresses;
            update updatedAccounts;
        }
    }    
}