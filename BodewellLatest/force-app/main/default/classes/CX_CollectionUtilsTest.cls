/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        27.05.2021
 * @description    Collection utils class tests
 */
@IsTest(IsParallel = true)
public with sharing class CX_CollectionUtilsTest {

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        27.05.2021
     * @description    
     * Test case:
     *  1. Creates a list of contacts simulating some scenarios
     *  2. Creates the set to be loaded
     *  3. Calls the loadSet method
     *  4. Asserts the expected size and if it contains one of the expected values
     */
    @IsTest
    static void loadSetTest() {
        List<Contact> testContacts = new List<Contact> { new Contact(LastName = 'Test1'), new Contact(LastName = 'Test1'), new Contact(LastName = 'Test2'), new Contact() };

        Set<String> testSet = new Set<String>();

        Test.startTest();
        CX_CollectionUtils.loadSet(testSet, 'LastName', testContacts);
        Test.stopTest();

        System.assertEquals(2, testSet.size());
        System.assertEquals(true, testSet.contains('Test1'));
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        27.05.2021
     * @description    
     * Test case:
     *  1. Creates 2 accounts to be used in the loaded map
     *  1. Creates a list of contacts simulating some scenarios and relating the accounts to them
     *  2. Creates the map to be loaded
     *  3. Calls the loadMap method
     *  4. Asserts the expected size of the map and of the internal lists
     */
    @IsTest
    static void loadMapListTest() {
        Account testAccount1 = new Account(Name = 'Test Account 1');
        Account testAccount2 = new Account(Name = 'Test Account 2');

        List<Contact> testContacts = new List<Contact> { new Contact(Account = testAccount1, LastName = 'Test1'), new Contact(Account = testAccount1, LastName = 'Test2'), new Contact(Account = testAccount2, LastName = 'Test2'), new Contact(Account = new Account()) };

        Map<String, List<Contact>> testMap = new Map<String, List<Contact>>();

        Test.startTest();
        CX_CollectionUtils.loadMap(testMap, 'Account.Name', testContacts);
        Test.stopTest();

        List<Contact> test1List = testMap.get('Test Account 1');
        List<Contact> test2List = testMap.get('Test Account 2');

        System.assertEquals(2, testMap.size());
        System.assertEquals(2, test1List.size());
        System.assertEquals(1, test2List.size());
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        08.06.2021
     * @description    
     * Test case:
     *  1. Creates 2 accounts to be used in the loaded map
     *  1. Creates a list of contacts simulating some scenarios and relating the accounts to them
     *  2. Creates the map to be loaded
     *  3. Calls the loadMap method
     *  4. Asserts the expected size of the map and of the internal lists
     */
    @IsTest
    static void loadMapObjectTest() {
        Account testAccount1 = new Account(Name = 'Test Account 1');
        Account testAccount2 = new Account(Name = 'Test Account 2');

        List<Contact> testContacts = new List<Contact> { new Contact(Account = testAccount1, LastName = 'Test1'), new Contact(Account = testAccount2, LastName = 'Test2'), new Contact(Account = new Account()) };

        Map<String, Contact> testMap = new Map<String, Contact>();

        Test.startTest();
        CX_CollectionUtils.loadMap(testMap, 'Account.Name', testContacts);
        Test.stopTest();

        System.assertEquals(2, testMap.size());
        System.assertEquals(true, testMap.containsKey(testAccount1.Name));
        System.assertEquals(true, testMap.containsKey(testAccount2.Name));
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        01.06.2021
     * @description    
     * Test case:
     *  1. Creates a list of contacts
     *  2. Calls the splitToSubList method
     *  3. Asserts the quantity of sub lists
     */
    @IsTest
    static void splitToSubListTest() {
        List<Contact> testContacts = new List<Contact> { new Contact(LastName = 'Test1'), new Contact(LastName = 'Test2'), new Contact(LastName = 'Test2'), new Contact() };

        Test.startTest();
        List<List<Contact>> newList = CX_CollectionUtils.splitToSubList(testContacts, 3);
        Test.stopTest();

        System.assertEquals(2, newList.size());
        System.assertEquals(3, newList[0].size());
        System.assertEquals(1, newList[1].size());
    }
}