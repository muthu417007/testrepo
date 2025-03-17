/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        25.05.2021
 * @description    Class used to keep Case queries
 */
public inherited sharing class CX_CaseDAO {
    private static final CX_CaseDAO INSTANCE = new CX_CaseDAO();

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        25.05.2021
     * @description    Returns the singleton instance
     * @return         CX_CaseDAO - a CX_CaseDAO singleton instance
     */
	public static CX_CaseDAO getInstance() {
		return INSTANCE;
	}

    private CX_CaseDAO() { }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        25.05.2021
     * @description    Returns a case querying with it's Id
     * @param          Id - Case Id
     * @return         Case - A case
     */
    public Case getCase(Id caseId) {
        return [
            SELECT 
                CX_Contact_Email__c, 
                CX_Contact_Phone__c,
                Subject,
                IsClosed,
                ContactId,
                AccountID,
                (
                    SELECT
                        Asset__c,
                        Serial_Number__c,
                        Model_Number__c
                    FROM
                        Case_ID__r
                )
            FROM 
                Case 
            WHERE 
                Id = :caseId
        ];
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        02.06.2021
     * @description    Returns a list of cases that may be duplicated
     * @param          Id - Contact Id
     * @param          Set<Id> - Assets ids (GEA Assets)
     * @return         List<Case> - A list of cases suspected of duplicity
     */
    public List<Case> getSuspectedDuplicateCases(Id contactId, Set<Id> assetIds) {
        String query = '';
        query += 'SELECT ';
        query += '    Subject, ';

        if(!assetIds.isEmpty()) {
            query += '    ( ';
            query += '        SELECT ';
            query += '            Asset__c ';
            query += '        FROM ';
            query += '            Case_ID__r ';
            query += '        WHERE  ';
            query += '            Asset__c IN :assetIds ';
            query += '    ), ';
        }
        
        query += '    CaseNumber ';
        query += 'FROM  ';
        query += '    Case  ';
        query += 'WHERE  ';
        query += '    ContactId = :contactId ';
        query += '    AND IsClosed = false ';

        return Database.query(query);
    }
    /**
     * @author         Gunhan Gultekin
     * @company        PolSource
     * @created        15.06.2021
     * @description    Returns a list of cases that may be duplicated. 
     * @param          Id - Contact Id
     * @param          Set<Id> - Assets ids (GEA Assets)
     * @return         List<Case> - A list of cases suspected of duplicity
     */
    public List<Case> getSuspectedDuplicateCasesCaseAssetsFuzzy(Id contactId) {
        
        String query = '';
        query += 'SELECT ';
        query += '    Subject, ';
        query += '    ( ';
        query += '        SELECT ';
        query += '            Asset__c,Serial_Number__c,Model_Number__c,Id ';
        query += '        FROM ';
        query += '            Case_ID__r ';
        query += '    ), ';
        query += '    CaseNumber ';
        query += 'FROM  ';
        query += '    Case  ';
        query += 'WHERE  ';
        query += '    ContactId = :contactId ';
        query += 'and ContactId != null ';
        return Database.query(query);
    }
}