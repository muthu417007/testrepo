/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        02.06.2021
 * @description    Class for handling the duplicated case check
 * @testClass      CX_CheckDuplicatedCasesControllerTest
 */
public without sharing class CX_CheckDuplicatedCasesController {

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        02.06.2021
     * @description    Queries the current case and possible duplicates and calls a method to validate them, depending on the team persona
     * @param          Id - The current case Id
     * @param          String - The team persona
     * @return         List<Case> - A list of possible duplicate cases
     */
    @AuraEnabled
    public static List<Case> getDuplicatedCases(Id caseId, String persona) {
        List<Case> duplicatedCases = new List<Case>();

        try {
            Case currentCase = CX_CaseDAO.getInstance().getCase(caseId);

            Boolean validCase = String.isNotBlank(currentCase.Subject) && String.isNotBlank(currentCase.ContactId) && !currentCase.IsClosed;
            
            if('ASM'.equals(persona) && validCase){
                duplicatedCases = filterDuplicateCasesASM(currentCase);
            }
            else if('FS CSP'.equals(persona) && validCase){
                duplicatedCases = filterDuplicateCasesFSCSP(currentCase);
            }
            else if('GE Store'.equals(persona) && validCase){
                duplicatedCases = filterDuplicateCasesGEStore(currentCase);
            }
            else if('PSS'.equals(persona) || 'Innovation'.equals(persona)){
                duplicatedCases = filterDuplicateCasesPSS(currentCase);
            }
            
        } 
        catch (Exception ex) {
            system.debug('Error:'+ ex.getMessage());
            CX_Utils.throwHandledException(ex, 'An error occurred while checking for duplicates');
        }
        
        return duplicatedCases;
    }

    /**
     * @author         Gunhan Gualtekin
     * @company        PolSource
     * @created        15.06.2021
     * @description    Check the list of cases for possible duplicates for ASM Specialists
     * @param          Case - The current case
     * @param          List<Case> - The possible duplicates
     * @return         List<Case> - A filtered list of possible duplicate cases
     */
    private static List<Case> filterDuplicateCasesASM(Case currentCase){
        List<Case> duplicatedCases = new List<Case>();
        Set<Id> assetIds = new Set<Id>();

        CX_CollectionUtils.loadSet(assetIds, 'Asset__c', currentCase.Case_ID__r);
        List<Case> suspectedCases = CX_CaseDAO.getInstance().getSuspectedDuplicateCases(currentCase.ContactId, assetIds);
        
        for(Case suspectedCase : suspectedCases) {
            if(currentCase.Id == suspectedCase.Id || suspectedCase.Case_ID__r?.size() == 0 ) {
                continue;
            }

            Boolean isDuplicatedSubject = validateDuplicitySubject(currentCase.Subject, suspectedCase.Subject);
            if(isDuplicatedSubject) {
                duplicatedCases.add(suspectedCase);
            }
        }

        return duplicatedCases;
    }
    /**
     * @author         Gunhan Gualtekin
     * @company        PolSource
     * @created        15.06.2021
     * @description    Check the list of cases for possible duplicates for FSCSP Specialists
     * @param          Case - The current case
     * @param          List<Case> - The possible duplicates
     * @return         List<Case> - A filtered list of possible duplicate cases
    */
    private static List<Case> filterDuplicateCasesFSCSP(Case currentCase){
        List<Case> duplicatedCases = new List<Case>();

        Set<Id> assetIds = new Set<Id>();
        List<Case> suspectedCases = CX_CaseDAO.getInstance().getSuspectedDuplicateCases(currentCase.ContactId, assetIds);

        for(Case suspectedCase : suspectedCases) {
            
            if(currentCase.Id == suspectedCase.Id) {
                continue;
            }

            Boolean isDuplicatedSubject = validateDuplicitySubject(currentCase.Subject, suspectedCase.Subject);
            if(isDuplicatedSubject) {
                duplicatedCases.add(suspectedCase);
            }
        }

        return duplicatedCases;
    }
    /**
     * @author         Gunhan Gualtekin
     * @company        PolSource
     * @created        15.06.2021
     * @description    Check the list of cases for possible duplicates for GE Store
     * @param          Case - The current case
     * @param          List<Case> - The possible duplicates
     * @return         List<Case> - A filtered list of possible duplicate cases
    */
    private static List<Case> filterDuplicateCasesGEStore(Case currentCase){
        List<Case> duplicatedCases = new List<Case>();

        Set<Id> assetIds = new Set<Id>();
        List<Case> suspectedCases = CX_CaseDAO.getInstance().getSuspectedDuplicateCases(currentCase.ContactId, assetIds);

        for(Case suspectedCase : suspectedCases) {
            
            if(currentCase.Id == suspectedCase.Id) {
                continue;
            }

            Boolean isDuplicatedSubject = validateDuplicitySubject(currentCase.Subject, suspectedCase.Subject);
            if(isDuplicatedSubject) {
                duplicatedCases.add(suspectedCase);
            }
        }

        return duplicatedCases;
    }
     /**
     * @author         Gunhan Gualtekin
     * @company        PolSource
     * @created        15.06.2021
     * @description    Check the list of cases for possible duplicates for PSS Specialists
     * @param          Case - The current case
     * @param          List<Case> - The possible duplicates
     * @return         List<Case> - A filtered list of possible duplicate cases
     */
    private static List<Case> filterDuplicateCasesPSS(Case currentCase){
        Integer sensitivity = 4;

        List<Case> duplicatedCases = new List<Case>();
        List<CX_CheckDuplicatedModelSerialWrapper> modelSerialWrapped = convertToModerSerialWrappedList(currentCase.Case_ID__r);
                
        List<Case> suspectedCases = CX_CaseDAO.getInstance().getSuspectedDuplicateCasesCaseAssetsFuzzy(currentCase.ContactId);
        
        for(Case suspectedCase : suspectedCases) {
            
            Boolean addItemFlag = false;

            if(currentCase.Id == suspectedCase.Id || suspectedCase.Case_ID__r?.size() == 0 ) {
                continue;
            }

            for(Case_Asset__c cAsset:  suspectedCase.Case_ID__r){
                for(CX_CheckDuplicatedModelSerialWrapper tItem : modelSerialWrapped){
                    if(checkStringSimilarity(tItem.modelNumber,cAsset.Model_Number__c) < sensitivity){
                        if(checkStringSimilarity(tItem.serialNumber,cAsset.Serial_Number__c) < sensitivity){
                            addItemFlag = true;
                            break;
                        }
                    }
                }
                if(addItemFlag){
                    break;
                }
            }

            if(addItemFlag) {
                duplicatedCases.add(suspectedCase);
            }
        }

        return duplicatedCases;
    }
    /**
     * @author         Gunhan Gualtekin
     * @company        PolSource
     * @created        17.06.2021
     * @description    Returns a wrapped List<CX_CheckDuplicatedModelSerialWrapper>
     * @param          tCaseAssets - CaseAssets List
     * @return          List<CX_CheckDuplicatedModelSerialWrapper> - A wrapped list of model and serial numbers of case assets.
     */
    private static List<CX_CheckDuplicatedModelSerialWrapper> convertToModerSerialWrappedList(List<Case_Asset__c> tCaseAssets){
        List<CX_CheckDuplicatedModelSerialWrapper> modelSerialWrapped = new List<CX_CheckDuplicatedModelSerialWrapper>();
        for(Case_Asset__c tCaseAsset : tCaseAssets){
            CX_CheckDuplicatedModelSerialWrapper wrap = new CX_CheckDuplicatedModelSerialWrapper();
            wrap.serialNumber = tCaseAsset.Serial_Number__c;
            wrap.modelNumber = tCaseAsset.Model_Number__c;
            
            modelSerialWrapped.add(wrap); 
        }
        return modelSerialWrapped;
    }
    /**
     * @author         Gunhan Gultekin
     * @company        PolSource
     * @created        15.06.2021
     * @description    Checks the similarity between two strings.
     * @param          String - similarity string
     * @param          String - similarity
     * @return         Double - the point that reflects the difference.
     */
    public static Integer checkStringSimilarity(String s1,String s2){
        Integer distance = 0;
        Integer loopCount = 0;

        loopCount = s1.length() < s2.length() ? s1.length() :s2.length();

        String s1Up =  s1.toUpperCase();
        String s2Up = s2.toUpperCase();

        for (Integer i = 0; i < loopCount; i++) {
            if (s1Up.charAt(i)  != s2Up.charAt(i)){
                distance++;
            }
        }

        return distance + Math.abs(s1.length() - s2.length());
    }
    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        02.06.2021
     * @description    Check if the 2 subjects are the same, removing some parts like "FW:"
     * @param          String - The current case subject
     * @param          String - The possible duplicated case subject
     * @return         Boolean - Is the subject the same?
     */
    private static Boolean validateDuplicitySubject(String currentSubject, String suspectedSubject) {
        final List<String> partsIgnore = new List<String> { 'FW:', 'FW :' };
        for(String partIgnore : partsIgnore) {
            currentSubject = currentSubject?.replace(partIgnore, '');
            suspectedSubject = suspectedSubject?.replace(partIgnore, '');
        }
        
        return currentSubject?.toUpperCase() == suspectedSubject?.toUpperCase();
    }
}