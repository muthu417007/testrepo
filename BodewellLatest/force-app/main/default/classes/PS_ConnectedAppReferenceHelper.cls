public without sharing class PS_ConnectedAppReferenceHelper {

    @TestVisible
    private static Connected_Application_Reference__mdt connectedAppConfig;
    @TestVisible
    private static Customer_IdP_Environment_Config__mdt customerEnvConfig;

    public static Connected_Application_Reference__mdt getConnectedAppReferenceConfigByDomain(
            String domain
    ) {
        if (Test.isRunningTest() && connectedAppConfig != null) {
            return connectedAppConfig;
        }

        String envName = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox ?
                Url.getOrgDomainUrl().getHost().split('').get(1).split('\\.').get(0) :
                null;

        List<Connected_Application_Reference__mdt> connectedApplicationReference = [
                SELECT Id,Auth_Flow__c,Client_Id__c,Scope__c,Connected_App_Name__c,
                        Redirect_URI__c,Is_Internally_Managed__c,Connected_App_Id__c
                FROM Connected_Application_Reference__mdt
                WHERE Domain__c = :domain
                AND Environment_Name__c = :envName
                LIMIT 1
        ];

        if (connectedApplicationReference.isEmpty()) {
            return null;
        }
        return connectedApplicationReference.get(0);
    }

    public static Connected_Application_Reference__mdt getConnectedAppReferenceConfigByName(
            String appName
    ) {
        if (Test.isRunningTest() && connectedAppConfig != null) {
            return connectedAppConfig;
        }

        List<Connected_Application_Reference__mdt> connectedApplicationReference = [
                SELECT Connected_App_Id__c
                FROM Connected_Application_Reference__mdt
                WHERE Connected_App_Name__c = :appName
                LIMIT 1
        ];

        if (connectedApplicationReference.isEmpty()) {
            return null;
        }
        return connectedApplicationReference.get(0);
    }

    public static Connected_Application_Reference__mdt getConnectedAppReferenceConfigByEnvConfig(
            String sitePrefix
    ) {
        if (Test.isRunningTest() && connectedAppConfig != null) {
            return connectedAppConfig;
        }

        String envName = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox ?
                Url.getOrgDomainUrl().getHost().split('').get(1).split('\\.').get(0) :
                null;

        String devName = envName == null ? sitePrefix : envName + '_' + sitePrefix;

        List<Customer_IdP_Environment_Config__mdt> customerIdPEnvironmentConfigs = [
                SELECT Default_Redirect_App__c
                FROM Customer_IdP_Environment_Config__mdt
                WHERE DeveloperName = :devName
        ];
        if(Test.isRunningTest() && customerEnvConfig != null){
            customerIdPEnvironmentConfigs.add(customerEnvConfig);
        }

        if (customerIdPEnvironmentConfigs.isEmpty() ||
                customerIdPEnvironmentConfigs.get(0).Default_Redirect_App__c == null) {
            return null;
        }

        List<Connected_Application_Reference__mdt> connectedApplicationReference = [
                SELECT Id,Auth_Flow__c,Client_Id__c,Scope__c,Connected_App_Name__c,
                        Redirect_URI__c,Is_Internally_Managed__c,Connected_App_Id__c,Domain__c
                FROM Connected_Application_Reference__mdt
                WHERE Id = :customerIdPEnvironmentConfigs.get(0).Default_Redirect_App__c
                LIMIT 1
        ];
        if (connectedApplicationReference.isEmpty()) {
            return null;
        }

        return connectedApplicationReference.get(0);
    }
}