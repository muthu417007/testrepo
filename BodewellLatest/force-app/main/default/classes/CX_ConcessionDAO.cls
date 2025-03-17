/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        09.07.2021
 * @description    Class used to keep Concession queries
 */
public inherited sharing class CX_ConcessionDAO {
    private static final CX_ConcessionDAO INSTANCE = new CX_ConcessionDAO();

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        09.07.2021
     * @description    Returns the singleton instance
     * @return         CX_ConcessionDAO - a CX_ConcessionDAO singleton instance
     */
	public static CX_ConcessionDAO getInstance() {
		return INSTANCE;
	}

    private CX_ConcessionDAO() { }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        09.07.2021
     * @description    Returns the Concessions for a list of case assets
     * @param          Set<Id> - case asset ids
     * @return         List<Concession__c> - A list of Concessions
     */
    public List<Concession__c> getConcessionsByCaseAssetId(Set<Id> caseAssetIds, String concessionType) {
        String query = '';
        query += 'SELECT  ';
        query += '    Case__c, ';
        query += '    Case_Asset__c, ';
        query += '    Type_of_Concession__c ';
        query += 'FROM  ';
        query += '    Concession__c  ';
        query += 'WHERE  ';
        query += '    Case_Asset__c IN :caseAssetIds ';

        if(String.isNotBlank(concessionType)) {
            query += '    AND Type_of_Concession__c = :concessionType ';
        }
        
        return Database.query(query);
    }
}