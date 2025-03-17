/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        01.06.2021
 * @description    Class that retrieves the GraphQL implementation of the CX_ContactSearch interface
 */
public class CX_ContactSearchRetrieverGraphQL implements CX_ContactSearchRetriever {
    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        01.06.2021
     * @description    Retrieves the GraphQL implementation of the CX_ContactSearch interface
     * @return         CX_ContactSearch - the GraphQL implementation of the CX_ContactSearch interface
     */
    public CX_ContactSearch retrieveImplementation() {
        return CX_ContactSearchGraphQL.getInstance();
    }
}