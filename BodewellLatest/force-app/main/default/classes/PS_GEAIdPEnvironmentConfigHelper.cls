public without sharing class PS_GEAIdPEnvironmentConfigHelper {

    @TestVisible
    private static Customer_IdP_Environment_Config__mdt environmentConfigTest = null;
    @TestVisible
    private static Customer_IdP_Environment_Config__mdt environmentConfigCache = null;

    @TestVisible
    private static Boolean envConfigNotFound = false;

    @AuraEnabled
    public static Customer_IdP_Environment_Config__mdt getEnvironmentConfiguration() {
        if (Test.isRunningTest() && environmentConfigTest != null) {
            return environmentConfigTest;
        }

        if (environmentConfigCache != null) {
            return environmentConfigCache;
        }

        String environmentConfigDevName = getEnvironmentConfigDevName();

          if (Test.isRunningTest() && environmentConfigDevName.contains('null')) {
            environmentConfigDevName = environmentConfigDevName.split('_')[0] + '_' + 'gea';
        }

        System.debug(LoggingLevel.INFO, 'PS_GEAIdPEnvironmentConfigHelper.getEnvironmentConfiguration environmentConfigDevName: ' + environmentConfigDevName);

        List<Customer_IdP_Environment_Config__mdt> environmentConfig = [
                SELECT Id, DeveloperName, Default_Redirect_App__c,
                        Innovation_Studio_Beacon_Script_URL__c,Registration_URL_Override__c,
                        Change_Password_Destination_Override__c,
                        Outage__c
                FROM Customer_IdP_Environment_Config__mdt
                WHERE DeveloperName = :environmentConfigDevName
        ];

        if (Test.isRunningTest() && envConfigNotFound) {
            environmentConfig.clear();
        }

        if (environmentConfig.isEmpty()) {
            return null;
        }

        environmentConfigCache = environmentConfig.get(0);
        system.debug('environmentConfigCache'+environmentConfigCache);
        return environmentConfigCache;
    }

    private static String getEnvironmentConfigDevName() {
        List<Organization> organizations = [
                SELECT IsSandbox
                FROM Organization
                LIMIT 1
        ];
        Url domainUrl = Url.getOrgDomainUrl();
        String orgDomainUrlHost = domainUrl.getHost();
        String envPart = organizations.get(0).IsSandbox?orgDomainUrlHost.split('--').get(1):'';
        String envName = organizations.get(0).IsSandbox? envPart.split('\\.').get(0): '';
		
		
                system.debug('envPart:'+envPart);
                system.debug('envName:'+envName);
        List<String> pathPrefixSplit = Site.getPathPrefix().split('/');
        String siteName = pathPrefixSplit.size() >= 2 ? pathPrefixSplit.get(1) : null;
        system.debug('pathPrefixSplit:'+pathPrefixSplit);
        System.debug('siteName:'+siteName);
        String result = null;

        if(String.isBlank(envPart)) {
            result = Test.isRunningTest()?'gea': siteName;
        }else {
            result = envName + '_' + siteName;
        }
        System.debug('result:'+result);
		
		
        return result;
    }
}