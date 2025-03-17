public class BWC_MYA_Configurations_Controller {
    @AuraEnabled(cacheable=true) 
    public static BWC_MYA_Configurations__mdt getBwcMyaMetaData() {
        String envName = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox ?
                Url.getOrgDomainUrl().getHost().split('--').get(1).split('\\.').get(0) :
                'prod'; 
        BWC_MYA_Configurations__mdt mc = BWC_MYA_Configurations__mdt.getInstance(envName);
        return mc;
    }

}