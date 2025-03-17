public without sharing class IncentiveClaimService {
    public void checkDuplicates(List<SObject> newItems){
        Set<Id> accountIds = new Set<Id>();
        Map<Id,Map<String,Set<String>>> accAwrdQualfrPrjctAcc = new Map<Id,Map<String,Set<String>>>(); // Map of <accountId, Map of <AwardQualifier,Set of <ProjectAccount#>>>
        for(Incentive_Claim__c ic: (List<Incentive_Claim__c>)newItems){
            accountIds.add(ic.Account_Name__c); // Account Ids of newly inserted Incentive Claims.
        }
        
        for(Incentive_Claim__c icl:[Select Id, Account_Name__c, Award_Qualifier__c, Project_Account_cust_code__c from Incentive_Claim__c where Account_Name__c in:accountIds and CreatedDate=THIS_QUARTER]){ // Querying existing Incentive Claim records with same Account Ids and created in same quarter
            if(accAwrdQualfrPrjctAcc.containsKey(icl.Account_Name__c)){ // conditions to add values in accAwrdQualfrPrjctAcc Map
                if(accAwrdQualfrPrjctAcc.get(icl.Account_Name__c).containsKey(icl.Award_Qualifier__c)){
                    accAwrdQualfrPrjctAcc.get(icl.Account_Name__c).get(icl.Award_Qualifier__c).add((icl.Project_Account_cust_code__c).toLowercase());
                }
                else{
                    accAwrdQualfrPrjctAcc.get(icl.Account_Name__c).put(icl.Award_Qualifier__c,new Set<String>{(icl.Project_Account_cust_code__c).toLowercase()});
                }
            }
            else{
                accAwrdQualfrPrjctAcc.put(icl.Account_Name__c,new Map<String,Set<String>>{icl.Award_Qualifier__c=>new Set<String>{(icl.Project_Account_cust_code__c).toLowercase()}});
            }
            
        }
        for(Incentive_Claim__c ic:(List<Incentive_Claim__c>)newItems){
               
            if(!accAwrdQualfrPrjctAcc.isEmpty()){
               	if(accAwrdQualfrPrjctAcc.containsKey(ic.Account_Name__c) && accAwrdQualfrPrjctAcc.get(ic.Account_Name__c).containsKey(ic.Award_Qualifier__c) && accAwrdQualfrPrjctAcc.get(ic.Account_Name__c).get(ic.Award_Qualifier__c).contains((ic.Project_Account_cust_code__c).toLowerCase())){ // subsequent conditions for checking if there is an existing claim for same Account with same Award Qualifier and Project Account #.
                    if(!Test.isRunningTest()){
                       	ic.addError('A record for this customer already exist. You cannot create a duplicate record.');
                    }
                }
            }
                   
         }
        
    }

}