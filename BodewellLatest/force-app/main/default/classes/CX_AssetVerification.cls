/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        14.06.2021
 * @description    Class that handles the Asset verification logic
 * @testClass      CX_AssetVerificationTest
 */
public inherited sharing class CX_AssetVerification {
    private static final CX_AssetVerification INSTANCE = new CX_AssetVerification();
    private final CX_Logger logger = new CX_Logger(CX_Logger.LogMode.MODE_PLATFORM_EVENT);

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        14.06.2021
     * @description    Returns the singleton instance
     * @return         CX_AssetVerification - a CX_AssetVerification singleton instance
     */
	public static CX_AssetVerification getInstance() {
		return INSTANCE;
	}

    private CX_AssetVerification() {}

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        14.06.2021
     * @description    Method that handles the whole Asset verification logic and returns the Assets for the Case and Contact
     * @param          String - The asset model number
     * @param          String - The asset serial number
     * @param          Date - The installation date
     * @param          Case - The current case to which the Asset will be assigned
     * @return         List<CX_AssetVerificationWrapper> - A list containing records with Assets for the Case and Contact
     */
    public List<CX_AssetVerificationWrapper> createAsset(String modelNumber, String serialNumber, Date installDate, Case currentCase, ModelNumberResponse assetInfo,String inWarranty) {
        List<CX_AssetVerificationWrapper> assetWrappers;
        Savepoint sp;
        try {
            checkModelNumber(modelNumber);
            modelNumber = modelNumber.toUpperCase();
            serialNumber = serialNumber.toUpperCase();

            if(assetInfo == null) {
                assetInfo = CX_AssetVerificationService.getInstance().getAssetInfo(modelNumber);
            }

            Map<String, SObject> newRecords = new Map<String, SObject>();

            Asset newAsset = processGeaAsset(modelNumber, serialNumber, installDate, currentCase, assetInfo);

            newRecords.put('asset', newAsset);
            newRecords.put('caseAsset', processCaseAsset(modelNumber, serialNumber, installDate, currentCase,inWarranty));

            User currentUser = [SELECT SSO_ID__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

            Long consumerNumber = getHighestConsumerNumber(CX_ContactDAO.getInstance().getContactInformation(currentCase.ContactId));

            if(consumerNumber == 0) {
                Contact_Information__c newContactInfo = CX_CN1Contact.getInstance().processNewContactInfo(currentCase, currentUser);
                newRecords.put('contactInfo', newContactInfo);
                consumerNumber = Long.valueOf(newContactInfo.Identifier__c);
            }

            createSiebelAsset(newAsset, currentUser, consumerNumber);

            sp = Database.setSavepoint();
            insertNewRecords(newRecords);
            assetWrappers = getAssets(currentCase);
        } catch(CalloutException ex) {
			rollback(sp);
            throw ex;
        } catch(CX_AssetVerificationException ex) {
            rollback(sp);
            throw ex;
        } catch(Exception ex) {
            rollback(sp);
            logger.logError(ex, 'CX_AssetVerification', 'verifyAsset');
            throw ex;
        }
        
        return assetWrappers;
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        14.06.2021
     * @description    Method that checks if the model number is valid
     * @param          String - The asset model number
     */
    private void checkModelNumber(String modelNumber) {
        if(String.isBlank(modelNumber)) {
            throw new CX_AssetVerificationException('Please enter model number.');
        }

        if(String.isNotBlank(modelNumber) && !modelNumber.isAlphanumeric()) {
            throw new CX_AssetVerificationException('Model Number can only contain alphanumeric characters.');
        }
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        14.06.2021
     * @description    Method that transforms the external callout response in a Asset SObject record
     * @param          String - The asset model number
     * @param          String - The asset serial number
     * @param          Date - The installation date
     * @param          Case - The current case
     * @param          ModelNumberResponse - The Asset information check response
     * @return         Asset - A GEA Asset record
     */
    private Asset processGeaAsset(String modelNumber, String serialNumber, Date installDate, Case currentCase, ModelNumberResponse assetInfo) {
        return new Asset(
            AccountId = currentCase.AccountID,
            Model_Number__c = modelNumber,
            InstallDate = installDate,
            SerialNumber = serialNumber,
            BrandName__c = assetInfo.BrandCode,
            Product_Type__c = assetInfo.ProductTypeCode,
            Product_Line__c = assetInfo.ProductLineCode,
            Product_Line_Desc__c = assetInfo.ProductLineDesc,
            Product_Type_Desc__c = assetInfo.ProductTypeDesc
        );
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        14.06.2021
     * @description    Method that creates the relation between Case and Asset
     * @param          String - The asset model number
     * @param          String - The asset serial number
     * @param          String - The installation date
     * @param          Case - The current case to which the Asset will be assigned
     * @return         Case_Asset__c - A Case Asset record
     */
    private Case_Asset__c processCaseAsset(String modelNumber, String serialNumber, Date installDate, Case currentCase,String inWarranty) {
        return new Case_Asset__c(
            Case__c = currentCase.Id,
            Model_Number__c = modelNumber,
            Install_Date__c = installDate,
            Serial_Number__c = serialNumber,
            In_Warranty_CaseAsset__c = inWarranty   
        );
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        14.06.2021
     * @description    Method that finds the highest Consumer Number for the List of Contact Information records
     * @param          List<Contact_Information__c> - The Contact Information records for the Case Contact
     * @return         Long - The highest Consumer Number that the records have
     */
    private Long getHighestConsumerNumber(List<Contact_Information__c> contactInfoList) {
        Long consumerNumber = 0;
        for(Contact_Information__c contactInfo : contactInfoList){
            Long identifier = Long.valueOf(contactInfo.Identifier__c);
            consumerNumber = identifier > consumerNumber ? identifier : consumerNumber;
        }

        return consumerNumber;
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        14.06.2021
     * @description    Method that call the callout method to relate Asset and Consumer in Siebel
     * @param          Asset - The new asset
     * @param          User - The current user
     * @param          Long - The last Consumer Number for the Consumer
     */
    private void createSiebelAsset(Asset newAsset, User currentUser, Long consumerNumber) {
        String installDate = '';

        if(newAsset.InstallDate != null){
            Date dateObj = newAsset.InstallDate;
            DateTime tempDate = DateTime.newInstance(dateObj.year(), dateObj.month(), dateObj.day());
            installDate = tempDate.format('yyyyMMdd');
        }  

        CX_AssetVerificationService.getInstance().createNewAsset(newAsset, currentUser, installDate, consumerNumber);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        16.06.2021
     * @description    Method that inserts the SF records after the whole process
     * @param          Map<String, SObject> - The SF records by their type
     */
    private void insertNewRecords(Map<String, SObject> newRecords) {
        Asset newAsset = (Asset) newRecords.remove('asset');
        insert newAsset;
system.debug(newRecords);
        newRecords.get('caseAsset').put('Asset__c', newAsset.Id);
        insert newRecords.values();
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        16.06.2021
     * @description    Method that queries for the Case's and other consumer assets
     * @param          Case - the current Case
     * @return         List<CX_AssetVerificationWrapper> - A list containing records with Assets for the Case and Contact
     */
    private List<CX_AssetVerificationWrapper> getAssets(Case currentCase) {
        CX_AssetVerificationWrapper caseAssetsWrapper = new CX_AssetVerificationWrapper();
        caseAssetsWrapper.assetType = 'case';
        caseAssetsWrapper.caseAssets = CX_AssetDAO.getInstance().getCaseAssetByCaseId(currentCase.Id);
        
        Set<ID> locationIds = new Set<ID>();
        CX_CollectionUtils.loadSet(locationIds, 'Account__c', CX_AccountDAO.getInstance().getLocationRelationsByContactId(currentCase.ContactId));

        Set<ID> caseAssetIds = new Set<ID>();
        CX_CollectionUtils.loadSet(caseAssetIds, 'Asset__c', caseAssetsWrapper.caseAssets);

        CX_AssetVerificationWrapper otherAssetsWrapper = new CX_AssetVerificationWrapper();
        otherAssetsWrapper.assetType = 'others';
        otherAssetsWrapper.assets = CX_AssetDAO.getInstance().getAssetsByLocationId(locationIds, caseAssetIds);

        return new List<CX_AssetVerificationWrapper> { caseAssetsWrapper, otherAssetsWrapper };
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        21.06.2021
     * @description    Method that rollback all transactions if a savepoint is not null
     * @param          Savepoint - a savepoint
     */
    private void rollback(Savepoint sp) {
        if(sp != null) {
            Database.rollback(sp);
        }
    }

    public class CX_AssetVerificationException extends Exception {}
}