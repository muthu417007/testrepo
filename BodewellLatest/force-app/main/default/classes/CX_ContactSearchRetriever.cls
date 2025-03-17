/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        01.06.2021
 * @description    Interface to use when searching CX_ContactSearch implementations
 */
public interface CX_ContactSearchRetriever {
    CX_ContactSearch retrieveImplementation();
}