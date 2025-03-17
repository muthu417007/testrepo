/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        25.05.2021
 * @description    Class used to keep Contact queries
 */
public inherited sharing class CX_ContactDAO {
    private static final CX_ContactDAO INSTANCE = new CX_ContactDAO();

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        25.05.2021
     * @description    Returns the singleton instance
     * @return         CX_ContactDAO - a CX_ContactDAO singleton instance
     */
	public static CX_ContactDAO getInstance() {
		return INSTANCE;
	}

    private CX_ContactDAO() { }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        25.05.2021
     * @description    Returns a list of contacts, using the email or phone fields
     * @param          String - an email
     * @param          String - a phone number
     * @return         List<Contact> - A list of contacts
     */
    public List<Contact> getContactByEmailOrPhone(String email, String phone) {
        Set<Contact> contactsSet = new Set<Contact>();
        system.debug('in getContactByEmailOrPhone');
        String fields = 'RETURNING Contact(Id, Name, FirstName, LastName, Email, Phone, MobilePhone, OtherPhone, VOIP_Phone__c, PersonId__c)';

        if(String.isNotBlank(email)) {
            String query = 'FIND \''+ email.trim() + '\'IN EMAIL FIELDS ';

            List<List<SObject>> result = Search.query(query + fields);
            contactsSet.addAll((List<Contact>) result[0]);
        }

        if(String.isNotBlank(phone)) {
            String query = 'FIND \''+ phone.trim() + '\'IN PHONE FIELDS ';

            List<List<SObject>> result = Search.query(query + fields);
            contactsSet.addAll((List<Contact>) result[0]);
        } 

        return new List<Contact>(contactsSet);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        14.06.2021
     * @description    Returns a Contact record
     * @param          Id - a contact Id
     * @return         Contact - A Contact record
     */
    public Contact getContact(Id contactId) {
        return [
            SELECT 
                FirstName,
                LastName,
                Phone,
                Email
            FROM 
                Contact
            WHERE 
                Id = :contactId
        ];
    }
    
    public Account getPersonAccount(Id contactId) {
        return [
            SELECT 
                FirstName,
                LastName,
                Phone,
                PersonEmail
            FROM 
                Account
            WHERE 
                Id = :contactId
        ];
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        14.06.2021
     * @description    Returns a list of contact information
     * @param          Id - a contact Id
     * @return         List<Contact_Information__c> - A list of contact information
     */
    public List<Contact_Information__c> getContactInformation(Id contactId) {
        return [
            SELECT 
                Identifier__c,
                ID_Type__c
            FROM 
                Contact_Information__c
            WHERE 
                Contact__c = :contactId
                AND Identifier__c != NULL
                AND (NOT Identifier__c like '999999%')
                AND ID_Type__c ='GE Consumer Number'
        ];
    }
}