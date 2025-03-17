/*
  @description       : This Helper returns the Customer IdP Configuration from Customer_IdP_Configuration__mdt based on the Site
  @author            : Luis Ramirez (l.ramirez@polsource.com)
  @group             : 
  @last modified on  : 08-18-2021
  @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
  Modifications Log 
  Ver   Date         Author                                   Modification
  1.0   06-16-2021   Luis Ramirez (l.ramirez@polsource.com)   Initial Version
*/
public without sharing class PS_GEAIdPCustomerConfigHelper {

    @TestVisible
    private static Customer_IdP_Configuration__mdt customerIdPConfiguration;
    @TestVisible
    private static String testSiteName = null;

    private static Set<String> configFieldNames = null;
    private static final String GLOBAL_CONFIG_NAME = 'Default';
  
    private static final String CONFIGURATION_OBJECT_NAME = 'Customer_IdP_Configuration__mdt';
    private static Customer_IdP_Configuration__mdt configCache = null;

    public static Set<String> getAllSiteConfigsRegistrationProfiles() {
        Set<String> registrationProfilesNames = new Set<String>();

        for (Customer_IdP_Configuration__mdt config : [SELECT Registration_Profile__c FROM Customer_IdP_Configuration__mdt]) {
            registrationProfilesNames.add(config.Registration_Profile__c);
        }
        return registrationProfilesNames;
    }

    @AuraEnabled
    public static Customer_IdP_Configuration__mdt getSiteConfiguration() {
        if (Test.isRunningTest() && customerIdPConfiguration != null) {
            return customerIdPConfiguration;
        }

        List<String> pathPrefixSplit = Site.getPathPrefix().split('/');
        String siteName = pathPrefixSplit.size() >= 2 ? pathPrefixSplit.get(1) : null;
       system.debug('Test ---siteName'+siteName);
        return getSiteConfiguration(siteName);
    }

    public static Customer_IdP_Configuration__mdt getSiteConfiguration(String siteName) {
        if (configCache != null) {
            return configCache;
        }

        List<Customer_IdP_Configuration__mdt> globalConfigData = Database.query(getQuery(GLOBAL_CONFIG_NAME));
      system.debug('Test -- globalConfigData'+globalConfigData);

        if (globalConfigData.isEmpty()) {
            throw new PS_GEAIdPCustomerConfigHelperException('Global Configuration is not set it up.');
        }

        Customer_IdP_Configuration__mdt globalConfig = globalConfigData.get(0);
        configCache = globalConfig;

        if (Test.isRunningTest() && testSiteName != null) {
            siteName = testSiteName;
        }

        if (String.isBlank(siteName)) {
            return globalConfig;
        }

        List<Customer_IdP_Configuration__mdt> siteConfigData = Database.query(getQuery(siteName));
        system.debug('Test -- siteConfigData'+siteConfigData);

        if (siteConfigData.isEmpty()) {
            return globalConfig;
        }

        Customer_IdP_Configuration__mdt siteConfig = siteConfigData.get(0);

        for (String fieldName : getConfigFieldNames()) {
            if (siteConfig.get(fieldName) == null) {
                siteConfig.put(fieldName, globalConfig.get(fieldName));
            }
        }

        configCache = siteConfig;
        system.debug('Test -- siteConfig'+siteConfig);
        return siteConfig;
    }

    private static String getQuery(String developerName) {
        String fieldsForQuery = getFieldsForQuery();
        String result = 'SELECT ' + fieldsForQuery + ' FROM ' + CONFIGURATION_OBJECT_NAME + ' WHERE DeveloperName = \'' + developerName + '\'';

        System.debug(LoggingLevel.INFO, 'PS_GEAIdPCustomerConfigHelper.getQuery: ' + result);

        return result;
    }

    private static String getFieldsForQuery() {
        Set<String> configFieldNames = getConfigFieldNames();
        String fields = '';
        String fieldSeparator = ', ';
        for (String fieldName : configFieldNames) {
            fields = fields + fieldName + fieldSeparator;
        }

        fields = fields.removeEnd(fieldSeparator);

        return fields;
    }

    private static Set<String> getConfigFieldNames() {
        if (configFieldNames == null || configFieldNames.isEmpty()) {
            configFieldNames = Schema.getGlobalDescribe().get(CONFIGURATION_OBJECT_NAME).getDescribe().fields.getMap().keySet();
        }

        return configFieldNames;
    }

    public class PS_GEAIdPCustomerConfigHelperException extends Exception {

    }
}