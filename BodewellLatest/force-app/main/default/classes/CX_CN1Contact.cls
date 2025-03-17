/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        17.06.2021
 * @description    Class that handles the CN1 Contact logic
 */
public with sharing class CX_CN1Contact {
    private static final CX_CN1Contact INSTANCE = new CX_CN1Contact();

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        17.06.2021
     * @description    Returns the singleton instance
     * @return         CX_CN1Contact - a CX_CN1Contact singleton instance
     */
	public static CX_CN1Contact getInstance() {
		return INSTANCE;
	}

    private CX_CN1Contact() {}

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        17.06.2021
     * @description    Uses a Case and an user (for the SSO ID) to create a new Contact Information entry in CN1   //Need to discuss Contact Information
     * @param          Case - A case related to a SF Contact
     * @param          User - The user who will create the entry in CN1
     * @return         Contact_Information__c - A new Contact Information entry containing the Customer Number from CN1
     */
    public Contact_Information__c processNewContactInfo(Case currentCase, User currentUser) {
        Contact_Information__c newContactInfo = new Contact_Information__c ();
        System.debug('in processNewContactInfo');
        //Contact currentContact = CX_ContactDAO.getInstance().getContact(currentCase.ContactId);
      
        Account currentPA = CX_ContactDAO.getInstance().getPersonAccount(currentCase.ContactId);
        Account location = CX_AccountDAO.getInstance().getLocationsById(new Set<Id> {currentCase.AccountId})[0];
        
        //CN1Response cn1Customer = CX_CN1Service.getInstance().getCN1CustomerNumber(currentContact, location, currentUser);
        CN1Response cn1Customer = CX_CN1Service.getInstance().getCN1CustomerNumber(currentPA, location, currentUser);
        
        newContactInfo.ID_Type__c = 'GE Consumer Number';
        newContactInfo.Contact__c = currentCase.ContactId;
        newContactInfo.Identifier__c = cn1Customer.ConsumerNo;

        return newContactInfo;
    }
}