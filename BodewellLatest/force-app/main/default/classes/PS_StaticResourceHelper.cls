public without sharing class PS_StaticResourceHelper {
    public static String getResourceURL() {
        Customer_IdP_Configuration__mdt config = PS_GEAIdPCustomerConfigHelper.getSiteConfiguration();
        String resourcePath = config.Stylesheet__c;
        String resourceName = '';
        if (String.isNotBlank(config.Stylesheet__c)) {
            resourceName = config.Stylesheet__c.split('/').get(0);
        }

        List<StaticResource> resourceList = [
                SELECT Name, NamespacePrefix, SystemModstamp
                FROM StaticResource
                WHERE Name = :resourceName
        ];

        String result = '';

        if (resourceList.size() == 1) {
            result = '/resource/' + resourceList[0].SystemModstamp.getTime() + '/' + resourcePath;
        }else {
            result = '/resource/' + resourcePath;
        }
        
        result = Site.getBaseUrl() + result;
        
        System.debug(LoggingLevel.INFO, 'resource URL: ' + result);

        return result;
    }
}