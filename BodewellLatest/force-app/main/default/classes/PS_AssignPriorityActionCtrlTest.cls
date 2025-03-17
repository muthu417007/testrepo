@isTest
private class PS_AssignPriorityActionCtrlTest {

    private static final String LOCATION_TYPE_HEADQUARTERS_BUYING_OFFICE = 'Headquarters/Buying Office';
    private static final String LOCATION_TYPE_MODEL_HOME = 'Model Home';
    private static final String LOCATION_TYPE_OUTLET_CENTER = 'Outlet Center';
    private static final String LOCATION_TYPE_RESELL_LOCATION = 'Resell Location';
    private static final String LOCATION_TYPE_SELECTION_CENTER = 'Selection Center';
    private static final String LOCATION_TYPE_RESELL_WAREHOUSE = 'Warehouse';
    private static final String CUSTOMER_CLASS_AS_IS = 'As-Is';
    private static final String CUSTOMER_CLASS_COIN_OP_DIST = 'Coin Op Dist';
    private static final String CUSTOMER_CLASS_COMMERCIAL_DISTRIBUTOR = 'Commercial Distributor';
    private static final String BUYING_GROUP_NO_BUYING_GROUP = 'No Buying Group';
    private static final String BUYING_GROUP_AVB_GREAT_PLAINS = 'AVB - Great Plains';
    private static final String BUYING_GROUP_AVB_GREATER_MIDWEST = 'AVB - Greater Midwest';
    private static final String MARKET_EASTERN_CONTRACT_MIDEAST = 'Eastern Contract-Mideast';
    private static final String MARKET_EASTERN_RETAIL_MIDEAST = 'Eastern Retail-Mideast';
    private static final String MARKET_EASTERN_RETAIL_NORTHEAST = 'Eastern Retail-Northeast';

    private static final String MARKET_EASTERN_CONTRACT = 'Eastern Contract';
    private static final String MARKET_EASTERN_RETAIL = 'Eastern Retail';

    private static final String REGION_MIDEAST = 'Mideast';
    private static final String REGION_NORTHEAST = 'Northeast';
    
    private static final String National_Account_Store_Type_Best_Buy_core='Best Buy - Core';
    Private Static final String National_Account_Store_Best_Buy_PAC_SAS='Best Buy - Pac SAS';	
    Private Static final String National_Account_Store_Best_Buy_MASS='Best Buy - MASS';	
    Private Static final String National_Account_Store_Best_Buy_MASS_Plus='Best Buy - MASS Plus';
    Private Static final String National_Account_Store_Best_Buy_SWAS='Best Buy - SWAS';
    Private Static final String National_Account_Store_Best_Buy_Experimental='Best Buy - Experiential';
    Private Static final String National_Account_Store_Ferguson_AAA='Ferguson - AAA';
    Private static final String National_Account_Store_Ferguson_AA='Ferguson - AA';
    Private static final String National_Account_Store_Ferguson_A='Ferguson - A';
    Private static final String National_Account_Store_Home_Depot_Value='Home Depot – Value';
    Private static final String National_Account_Store_Home_Depot_Core='Home Depot – Core';
    Private static final String National_Account_Store_Home_Depot_Upscale='Home Depot – Upscale';
    Private static final String National_Account_Store_Home_Depot_Urgan='Home Depot – Urban';
    Private static final String National_Account_Store_Lowes_Value='Lowes – Value';
    Private static final String National_Account_Store_Lowes_Core=' Lowes – Core';
    Private static final String National_Account_Store_Lowes_Better='Lowes – Better';
    Private static final String National_Account_Store_Lowes_Mass_Premium='Lowes – Mass Premium	';

    @TestSetup
    static void makeData() {
        Account acc1 = new Account(
            Name = 'Account 1',
            Customer_Class__c = CUSTOMER_CLASS_AS_IS,
            Buying_Group__c = BUYING_GROUP_NO_BUYING_GROUP,
            Market_Area_Name__c = MARKET_EASTERN_CONTRACT,
            Region_Name__c = REGION_MIDEAST,
            Direct_Sales_Customer__c = 'Yes',
            Meet_Comp_Eligibility__c = 'National',
            Oracle_Account_Number__c='1234567',
            Status__c = 'A',
            Commercial_Consolidation_Relationship__c='aaaaaa'
        );
        Account acc2 = new Account(
            Name = 'Account 2',
            Customer_Class__c = CUSTOMER_CLASS_COIN_OP_DIST,
            Buying_Group__c = BUYING_GROUP_AVB_GREAT_PLAINS,
            Market_Area_Name__c = MARKET_EASTERN_RETAIL,
            Region_Name__c = REGION_MIDEAST,
            Meet_Comp_Eligibility__c = 'National',
            Status__c = 'A'
        );
        Account acc3 = new Account(
            Name = 'Account 3',
            Customer_Class__c = CUSTOMER_CLASS_COMMERCIAL_DISTRIBUTOR,
            Buying_Group__c = BUYING_GROUP_AVB_GREATER_MIDWEST,
            Market_Area_Name__c = MARKET_EASTERN_RETAIL,
            Region_Name__c = REGION_NORTHEAST,
            Meet_Comp_Eligibility__c = 'National',
            Status__c = 'A',
            Commercial_Consolidation_Relationship__c='aaa'

        );
        Account acc4 = new Account(
            Name = 'Account 4',
            Customer_Class__c = CUSTOMER_CLASS_COMMERCIAL_DISTRIBUTOR,
            Buying_Group__c = BUYING_GROUP_AVB_GREATER_MIDWEST,
            Market_Area_Name__c = MARKET_EASTERN_RETAIL,
            Region_Name__c = REGION_NORTHEAST,
            Meet_Comp_Eligibility__c = 'National',
            Status__c = 'I'
        );

        insert new List<Account>{acc1, acc2, acc3};

        Schema.Location testLocation = new Schema.Location(Name = 'Test Location');
        insert testLocation;

        RetailStore rs1 = new RetailStore(
            Name = 'rs1',
            AccountId = acc1.Id,
            LocationId = testLocation.Id,
            Location_Type__c = LOCATION_TYPE_HEADQUARTERS_BUYING_OFFICE + ';' + LOCATION_TYPE_MODEL_HOME + ';' + LOCATION_TYPE_RESELL_WAREHOUSE
        );
        RetailStore rs2 = new RetailStore(
            Name = 'rs2',
            AccountId = acc2.Id,
            LocationId = testLocation.Id,
            Location_Type__c = LOCATION_TYPE_OUTLET_CENTER + ';' + LOCATION_TYPE_SELECTION_CENTER
        );
        RetailStore rs3 = new RetailStore(
            Name = 'rs3',
            AccountId = acc3.Id,
            LocationId = testLocation.Id,
            Location_Type__c = LOCATION_TYPE_RESELL_LOCATION
        );
        insert new List<RetailStore>{rs1, rs2, rs3};
    }

    @isTest
    static void shouldFindAllRetailStores() {
        //GIVEN
        List<String> locationTypes = new List<String>{
            LOCATION_TYPE_HEADQUARTERS_BUYING_OFFICE,
            LOCATION_TYPE_MODEL_HOME,
            LOCATION_TYPE_OUTLET_CENTER,
            LOCATION_TYPE_RESELL_LOCATION,
            LOCATION_TYPE_SELECTION_CENTER,
            LOCATION_TYPE_RESELL_WAREHOUSE
        };
        List<String> customerClasses = new List<String>{
            CUSTOMER_CLASS_AS_IS,
            CUSTOMER_CLASS_COIN_OP_DIST,
            CUSTOMER_CLASS_COMMERCIAL_DISTRIBUTOR
        };
        List<String> buyingGroups = new List<String>{
            BUYING_GROUP_NO_BUYING_GROUP,
            BUYING_GROUP_AVB_GREAT_PLAINS,
            BUYING_GROUP_AVB_GREATER_MIDWEST
        };
        List<String> markets = new List<String>{
            MARKET_EASTERN_CONTRACT_MIDEAST,
            MARKET_EASTERN_RETAIL_MIDEAST,
            MARKET_EASTERN_RETAIL_NORTHEAST
        };
            List <String>nationalStoreTypes = new List<String>{
              National_Account_Store_Type_Best_Buy_core,
              National_Account_Store_Best_Buy_PAC_SAS,
              National_Account_Store_Best_Buy_MASS,
              National_Account_Store_Best_Buy_MASS_Plus    
            };

        //WHEN
        List<Id> foundRetailStoreIds = PS_AssignPriorityActionCtrl.searchRetailStores(
            locationTypes,
            customerClasses,
            buyingGroups,
            nationalStoreTypes,
            markets,
            null,
            null,
            null,
            false,
            null,
            null
        );

        //THEN
        Set<Id> allRetailStoreIds = new Map<Id, RetailStore>(
            [SELECT Id FROM RetailStore]
        ).keySet();

        System.assert(
            allRetailStoreIds.containsAll(foundRetailStoreIds),
            'Found Retail Stores should be: rs1, rs2, rs3'
        );
    }

    @isTest
    static void shouldFindTwoRetailStoresByLocationTypes() {
        //GIVEN
        List<String> locationTypes = new List<String>{
            LOCATION_TYPE_HEADQUARTERS_BUYING_OFFICE,
            LOCATION_TYPE_MODEL_HOME,
            LOCATION_TYPE_OUTLET_CENTER,
            LOCATION_TYPE_RESELL_WAREHOUSE
        };

        //WHEN
        List<Id> foundRetailStoreIds = PS_AssignPriorityActionCtrl.searchRetailStores(
            locationTypes,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            false,
            null,
            null
        );

        //THEN
        Set<Id> retailStores = new Map<Id, RetailStore>(
            [SELECT Id FROM RetailStore WHERE Name IN ('rs1','rs2')]
        ).keySet();

        System.assert(
            retailStores.size() == foundRetailStoreIds.size() && retailStores.containsAll(foundRetailStoreIds),
            'Found Retail Stores should be: rs1, rs2'
        ); 
    }

    @isTest
    static void shouldFindTwoRetailStoresByCustomerClasses() {
        //GIVEN
        List<String> locationTypes = new List<String>{
            LOCATION_TYPE_HEADQUARTERS_BUYING_OFFICE,
            LOCATION_TYPE_OUTLET_CENTER
        };

        List<String> customerClasses = new List<String>{
            CUSTOMER_CLASS_AS_IS,
            CUSTOMER_CLASS_COIN_OP_DIST
        };

        //WHEN
        List<Id> foundRetailStoreIds = PS_AssignPriorityActionCtrl.searchRetailStores(
            locationTypes,
            customerClasses,
            null,
            null,
            null,
            null,
            null,
            null,
            false,
            null,
            null
        );

        //THEN
        Set<Id> retailStores = new Map<Id, RetailStore>(
            [SELECT Id FROM RetailStore WHERE Name IN ('rs1','rs2')]
        ).keySet();

        System.assert(
            retailStores.size() == foundRetailStoreIds.size() && retailStores.containsAll(foundRetailStoreIds),
            'Found Retail Stores should be: rs1, rs2'
        );
    }

    @isTest
    static void shouldFindTwoRetailStoresByBuyingGroups() {
        //GIVEN
        List<String> buyingGroups = new List<String>{
            BUYING_GROUP_AVB_GREAT_PLAINS,
            BUYING_GROUP_AVB_GREATER_MIDWEST
        };

        //WHEN
        List<Id> foundRetailStoreIds = PS_AssignPriorityActionCtrl.searchRetailStores(
            null,
            null,
            buyingGroups,
            null,
            null,
            null,
            null,
            null,
            false,
            null,
            null
        );

        //THEN
        Set<Id> retailStores = new Map<Id, RetailStore>(
            [SELECT Id FROM RetailStore WHERE Name IN ('rs2','rs3')]
        ).keySet();

        System.assert(
            retailStores.size() == foundRetailStoreIds.size() && retailStores.containsAll(foundRetailStoreIds),
            'Found Retail Stores should be: rs2, rs3'
        );
    }

    @isTest
    static void shouldFindTwoRetailStoresByMarkets() {
        //GIVEN
        List<String> markets = new List<String>{
            MARKET_EASTERN_CONTRACT_MIDEAST,
            MARKET_EASTERN_RETAIL_NORTHEAST
        };

        //WHEN
        List<Id> foundRetailStoreIds = PS_AssignPriorityActionCtrl.searchRetailStores(
            null,
            null,
            null,
            null,
            markets,
            null,
            null,
            null,
            false,
            null,
            null
        );

        //THEN
        Set<Id> retailStores = new Map<Id, RetailStore>(
            [SELECT Id FROM RetailStore WHERE Name IN ('rs1','rs3')]
        ).keySet();

         System.assert(
            retailStores.size() == foundRetailStoreIds.size() && retailStores.containsAll(foundRetailStoreIds),
            'Found Retail Stores should be: rs1, rs3'
        );
        
    }

    @isTest
    static void shouldFindOneRetailStoresWithDirectSalesCustomer() {
        //GIVEN
        List<String> customerClasses = new List<String>{
            CUSTOMER_CLASS_AS_IS,
            CUSTOMER_CLASS_COIN_OP_DIST,
            CUSTOMER_CLASS_COMMERCIAL_DISTRIBUTOR
        };
        List<String> buyingGroups = new List<String>{
            BUYING_GROUP_NO_BUYING_GROUP,
            BUYING_GROUP_AVB_GREAT_PLAINS,
            BUYING_GROUP_AVB_GREATER_MIDWEST
        };
        List<String> markets = new List<String>{
            MARKET_EASTERN_CONTRACT_MIDEAST,
            MARKET_EASTERN_RETAIL_MIDEAST,
            MARKET_EASTERN_RETAIL_NORTHEAST
        };

        //WHEN
        List<Id> foundRetailStoreIds = PS_AssignPriorityActionCtrl.searchRetailStores(
            null,
            customerClasses,
            buyingGroups,
            null,
            markets,
            null,
            null,
            null,
            true,
            null,
            null
        );

        //THEN
        Set<Id> retailStores = new Map<Id, RetailStore>(
            [SELECT Id FROM RetailStore WHERE Name IN ('rs1')]
        ).keySet();

     System.assert(
            retailStores.size() == foundRetailStoreIds.size() && retailStores.containsAll(foundRetailStoreIds),
            'Found Retail Stores should be: rs1'
        );
    }

    @isTest
    static void shouldNotFindAnyRetailStores() {
        //WHEN
        List<Id> foundRetailStoreIds = PS_AssignPriorityActionCtrl.searchRetailStores(
            null,
            null,
            new List<String>(),
            null,
            null,
            'Test Commercial Consolidation',
            'Test Relationship Name',
            'Test Relationship Role',
            false,
            '234576, 785889',
            null
        );

        //THEN
        Set<Id> retailStores = new Map<Id, RetailStore>(
            [SELECT Id FROM RetailStore WHERE Name IN ('rs1','rs3')]
        ).keySet();

        System.assert(
            foundRetailStoreIds.isEmpty(),
            'Found Retail Store ID List should be empty'
        );
    }

    @isTest
    static void shouldCreateShowroomDisplayLocationActions() {
        //GIVEN
        Priority_and_Action__c action1 = new Priority_and_Action__c();
        insert new List<Priority_and_Action__c>{action1};

        Set<Id> allRetailStoreIds = new Map<Id, RetailStore>(
            [SELECT Id FROM RetailStore]
        ).keySet();

        //WHEN
        Test.startTest();
        PS_AssignPriorityActionCtrl.createActions(new List<Id>(allRetailStoreIds), action1.Id);
        Test.stopTest();

        //THEN
        List<Showroom_Display_Location_Action__c> locationActions = [
            SELECT Id FROM Showroom_Display_Location_Action__c
        ];

        System.assertEquals(
            3,
            locationActions.size(),
            'Number of created Showroom Display Location Actions should be equal 3'
        );
    }

    @isTest
    static void shouldNotCreateShowroomDisplayLocationActions() {
        //GIVEN
        Set<Id> allRetailStoreIds = new Map<Id, RetailStore>(
            [SELECT Id FROM RetailStore]
        ).keySet();

        //WHEN
        Test.startTest();
        PS_AssignPriorityActionCtrl.createActions(new List<Id>(allRetailStoreIds), null);
        Test.stopTest();

        //THEN
        List<Showroom_Display_Location_Action__c> locationActions = [
            SELECT Id FROM Showroom_Display_Location_Action__c
        ];

        System.assert(
            locationActions.isEmpty(),
            'Number of created Showroom Display Location Actions should be equal 0'
        );
    }

    @isTest
    static void shouldCoverGetPriorityActionValuesMethod() {
        //WHEN
        Map<String, Map<String, String>> optionsByLabel = PS_AssignPriorityActionCtrl.getPriorityActionValues();

        //THEN
        System.assert(
            optionsByLabel != null,
            'Options By Label map should not be equal null'
        );
    }

}