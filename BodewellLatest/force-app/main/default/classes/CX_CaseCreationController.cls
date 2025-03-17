/**
 * @author         Gabriel Alves
 * @company        PolSource
 * @created        18.06.2021
 * @description    Class for handling the creation of Cases of the cx_caseCreation component
 * @testClass      CX_CaseCreationControllerTest
 */
public with sharing class CX_CaseCreationController {

    @AuraEnabled
    public static Id createCase (String subject, String type, Id contactId, Account location, List<Asset> geaAssets) {
        try {
            system.debug('@@@@ CX_CaseCreationController CreateCase - contactId: ' +contactId);
            location = createLocation(location);
            Case cs = createCaseRecord(subject, type, contactId, location);
            system.debug('@@@@ CX_CaseCreationController after  CreateCase - contactId: ' +contactId);
            geaAssets = createAssets(geaAssets, cs);
            createAssetJunctions(cs.Id, geaAssets);
            return cs.Id;
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage('Error creating Case: ' + ex.getMessage());
            throw ex;
        }
    }

    private static Account createLocation (Account location) {
        if (location != null && location.Id == null) {
            return CX_CreateLocationController.createLocation(location);
        } else {
            return location;
        }
    }

    private static List<Asset> createAssets (List<Asset> geaAssets, Case cs) {
        List<Asset> updatedGeaAssets = new List<Asset>();
        if (geaAssets != null) {
            for (Asset asset : geaAssets) {
                if (asset.Id == null) {
                    CX_AssetVerification.getInstance().createAsset(asset.Model_Number__c, asset.SerialNumber, asset.InstallDate, cs, null,null);
                } else {
                    updatedGeaAssets.add(asset);
                }
            }
        }
        return updatedGeaAssets;
    }

    private static Case createCaseRecord (String subject, String type, Id contactId, Account location) {
        Case cs = new Case(
            Subject = subject,
            Type = type,
            ContactId = contactId,
            AccountId = location == null ? null : location.Id
        );
        upsert cs;
        system.debug('@@@@ CX_CaseCreationController createCaseRecord - contactId: ' +contactId);
        system.debug('@@@@ CX_CaseCreationController createCaseRecord - cs: ' +cs);
        return cs;
    }

    private static void createAssetJunctions (Id caseId, List<Asset> geaAssets) {
        List<Case_Asset__c> caseAssets = new List<Case_Asset__c>();
        for (Asset asset : geaAssets == null ? new List<Asset>() : geaAssets) {
            caseAssets.add(new Case_Asset__c(
                Case__c = caseId,
                Asset__c = asset.Id,
                Model_Number__c = asset.Model_Number__c
            ));
        }
        insert caseAssets;
    }
}