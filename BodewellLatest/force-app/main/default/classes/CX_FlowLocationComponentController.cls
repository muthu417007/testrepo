/**
 * @author         Gunhan Gultekin
 * @company        PolSource
 * @created        05.07.2021(dd.mm.yyyy) 
 * @description    Controller Class for cx_flowLocationComponent LWC component
 * @testClass      TODO
 */
public without sharing class CX_FlowLocationComponentController {

    /**
     * @author         Gunhan Gultekin
     * @company        PolSource
     * @created        05.07.2021 (dd.mm.yyyy)
     * @description    gets the assets of a case default location
     * @param          String - contactId Id value of the contact
     * @param          String - currentLocationId Id of the location currently attached to case
     * @return         List<Account> - returns Locations that are related to the contact 
     */
    @AuraEnabled
    public static List<Account> selectContactLocations(String contactId,String currentLocationId){
        List<Account> returnList = new List<Account>();
        try {
            returnList = CX_AccountDAO.getInstance().getLocationsByContactId(Id.valueOf(contactId),currentLocationId);
        } 
        catch (Exception ex) {
            CX_Utils.throwHandledException(ex, 'An error occurred while getting the contact locations!');
        }
        system.debug('@@@@ inside selectContactLocations -returnList:  '+returnList);
        return returnList;
    }
    /**
     * @author         Gunhan Gultekin
     * @company        PolSource
     * @created        05.07.2021 (dd.mm.yyyy)
     * @description    sets case location 
     * @param          String - caseId Id value of the transaction case
     * @param          String - locationId value of the location that user selects 
     * @param          String - contactId Id valu of the contact
     * @return         List<Account> - returns Locations that are related to the contact 
     */
    @AuraEnabled
    public static List<Account> setSelectedLocation(String caseId,String locationId,String contactId){
        try {
            Case currentCase = CX_CaseDAO.getInstance().getCase(Id.valueOf(caseId));
            currentCase.AccountId = Id.valueOf(locationId);
            currentCase.ContactId = Id.valueOf(contactId);
            system.debug('@@@@ Inside setSelectedLocation contactId: ' +contactId);
            update currentCase;

        } catch (Exception ex) {
            CX_Utils.throwHandledException(ex, 'An error occurred while setting the location!');
        }
        return  CX_AccountDAO.getInstance().getLocationsByContactId(contactId,locationId);
    }
    /**
     * @author         Gunhan Gultekin
     * @company        PolSource
     * @created        05.07.2021 (dd.mm.yyyy)
     * @description    Creates and sets a new location for the case and contact 
     * @param          String - contactId Id value of the current contact
     * @param          String - street  street value of the new location 
     * @param          String - zipCode zip value of the new location
     * @param          String - caseId Id value of the transaction case
     * @return         List<Account> - returns Locations that are related to the contact 
     */
    @AuraEnabled
    public static CX_FlowLocationWrapper createAndSetCaseLocation(String contactId,String street,String zipCode,String caseId){
        CX_FlowLocationWrapper returnWrapper = new CX_FlowLocationWrapper();
        List<Account> returnList = new List<Account>();
        CX_ContactCreationWrapper wrapper = new CX_ContactCreationWrapper();

        wrapper.zip = zipCode;
        wrapper.street = street;

        try {
            Case currentCase = CX_CaseDAO.getInstance().getCase(caseId);
            Account newAccount = CX_ContactCreation.getInstance().processNewLocation(wrapper);
            insert newAccount;
            returnWrapper.selectedLocationId = newAccount.Id; 
            system.debug('@@@@ inside createAndSetCaseLocation -newAccount:  '+newAccount);
            system.debug('@@@@ inside createAndSetCaseLocation - returnWrapper.selectedLocationId:  '+ returnWrapper.selectedLocationId);
            GEA_AccountContactRelation__c relation = new GEA_AccountContactRelation__c(
                Contact__c = Id.valueOf(contactId),
                Account__c = newAccount.Id
            );
            insert relation;
		
            currentCase.AccountId = newAccount.Id;
            currentCase.ContactId = Id.valueOf(contactId);
            system.debug('@@@@ inside createAndSetCaseLocation -currentCase.AccountId:  '+currentCase.AccountId);
            system.debug('@@@@ inside createAndSetCaseLocation -currentCase.ContactId:  '+contactId);
            
            update currentCase;

        } 
        catch (Exception ex) {
            CX_Utils.throwHandledException(ex, 'An error occurred while creating the location!');
        }
        returnList = CX_AccountDAO.getInstance().getLocationsByContactId(contactId,returnWrapper.selectedLocationId);
        returnWrapper.locationInformation = returnList;
          system.debug('@@@@ inside createAndSetCaseLocation -returnWrapper:  '+returnWrapper);
        return returnWrapper;
    }
}