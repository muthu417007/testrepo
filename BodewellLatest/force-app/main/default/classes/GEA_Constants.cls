public class GEA_Constants {

    //Account Record Types
	public static final String RECORD_TYPE_ACCOUNT_CONTRACT_DIRECT = 'Contract_Direct';
    public static final String RECORD_TYPE_ACCOUNT_CONTRACT_DISTRIBUTOR = 'Contract_Distributor';
    public static final String RECORD_TYPE_ACCOUNT_RETAIL_NATIONAL = 'Retail_National';
    public static final String RECORD_TYPE_ACCOUNT_RETAIL = 'Retail';
    public static final String RECORD_TYPE_ACCOUNT_SITE = 'Site';
    public static final String RECORD_TYPE_ACCOUNT_PARTY = 'Party';
    public static final String RECORD_TYPE_ACCOUNT_PROSPECT = 'Prospect';
    public static final String RECORD_TYPE_ACCOUNT_RESELLER_PROSPECT = 'Reseller_Prospect';

    //Contact Record Types
	public static final String RECORD_TYPE_CONTACT_ARCHITECT_DESIGNER = 'Architect_Designer';
    public static final String RECORD_TYPE_CONTACT_INSTALLATION_CONTRACTOR = 'Installation_Contractor';
    public static final String RECORD_TYPE_CONTACT_ORACLE_SITE = 'Oracle_Site';
    public static final String RECORD_TYPE_CONTACT_STANDARD = 'Standard';

    //Oracle Types
	public static final String ORACLE_TYPE_PARTY = 'Party';
    public static final String ORACLE_TYPE_SITE = 'Site';
    public static final String ORACLE_TYPE_ACCOUNT = 'Account';

    //Account Channels
	public static final String ACCOUNT_CHANNEL_RETAIL = 'Retail';
    public static final String ACCOUNT_CHANNEL_CONTRACT = 'Contract';
    public static final String ACCOUNT_CHANNEL_PROCHANNEL = 'Pro Channel';
    public static final String ACCOUNT_CHANNEL_INTERNATIONAL = 'International';
    public static final String ACCOUNT_CHANNEL_NATIONAL = 'National';
    public static final String ACCOUNT_CHANNEL_HQ = 'HQ';

    //Program Request Stage Names
	public static final String PROGRAM_REQUEST_STAGE_NAME_DRAFT = 'Draft';
    public static final String PROGRAM_REQUEST_STAGE_NAME_AWAITING_APPROVAL = 'Awaiting Approval';
    public static final String PROGRAM_REQUEST_STAGE_NAME_APPROVED = 'Approved';
    public static final String PROGRAM_REQUEST_STAGE_NAME_REJECTED = 'Rejected';

    // Object API Names
    public static final String OBJECT_API_NAME_MEET_COMP = Schema.Meet_Comp__c.getSObjectType().getDescribe().getName();
    public static final String OBJECT_API_NAME_PROGRAM_REQUEST = Schema.Program_Request__c.getSObjectType().getDescribe().getName();
    public static final String OBJECT_API_NAME_STORE_PRODUCT = Schema.StoreProduct.getSObjectType().getDescribe().getName();
    public static final String OBJECT_API_NAME_CUSTOMER_AGREEMENT = Schema.Customer_Agreement__c.getSObjectType().getDescribe().getName();
    public static final String OBJECT_API_NAME_ACCOUNT_SALES_PERFORMANCE = Schema.Account_Sales_Performance__c.getSObjectType().getDescribe().getName();

    public static final String OBJECT_API_NAME_MEET_COMP_SHARE = Schema.Meet_Comp__Share.getSObjectType().getDescribe().getName();
    public static final String OBJECT_API_NAME_PROGRAM_REQUEST_SHARE = Schema.Program_Request__Share.getSObjectType().getDescribe().getName();
    public static final String OBJECT_API_NAME_STORE_PRODUCT_SHARE = Schema.StoreProductShare.getSObjectType().getDescribe().getName();
    public static final String OBJECT_API_NAME_CUSTOMER_AGREEMENT_SHARE = Schema.Customer_Agreement__Share.getSObjectType().getDescribe().getName();
    public static final String OBJECT_API_NAME_ACCOUNT_SALES_PERFORMANCE_SHARE = Schema.Account_Sales_Performance__Share.getSObjectType().getDescribe().getName();

    // Field API Names
    public static final String FIELD_API_NAME_MEET_COMP_ACCOUNT = Schema.Meet_Comp__c.Account__c.getDescribe().getName();
    public static final String FIELD_API_NAME_PROGRAM_REQUEST_ACCOUNT = Schema.Program_Request__c.Account__c.getDescribe().getName();
    public static final String FIELD_API_NAME_STORE_PRODUCT_ACCOUNT = Schema.StoreProduct.Account__c.getDescribe().getName();
    public static final String FIELD_API_NAME_CUSTOMER_AGREEMENT_ACCOUNT = Schema.Customer_Agreement__c.Account_Name__c.getDescribe().getName();
    public static final String FIELD_API_NAME_ACCOUNT_SALES_PERFORMANCE_ACCOUNT = Schema.Account_Sales_Performance__c.Account__c.getDescribe().getName();

    public static final String FIELD_API_NAME_MEET_COMP_SHARE_PARENT_ACCOUNT = 'Parent.Account__c';
    public static final String FIELD_API_NAME_PROGRAM_REQUEST_SHARE_PARENT_ACCOUNT = 'Parent.Account__c';
    public static final String FIELD_API_NAME_STORE_PRODUCT_SHARE_PARENT_ACCOUNT = 'Parent.Account__c';
    public static final String FIELD_API_NAME_CUSTOMER_AGREEMENT_SHARE_PARENT_ACCOUNT = 'Parent.Account_Name__c';
    public static final String FIELD_API_NAME_ACCOUNT_SALES_PERFORMANCE_SHARE_PARENT_ACCOUNT = 'Parent.Account__c';

}