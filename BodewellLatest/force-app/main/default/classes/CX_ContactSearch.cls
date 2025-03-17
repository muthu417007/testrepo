/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        31.05.2021
 * @description    Interface to use when searching for a contact in external systems
 */
public interface CX_ContactSearch {
    Map<String, CX_ContactSearchWrapper> searchContact(String email, String phone);
    CX_ContactSearchWrapper searchContactByPhone(String phone);
    CX_ContactSearchWrapper searchContactByEmail(String email);
}