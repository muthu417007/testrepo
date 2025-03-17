//******************************************************************************************
// Author:       Yogesh Sharma
// Company:      TCS
// Created Date: 27/03/2023
//******************************************************************************************
//@description : Apex Class to handle Service Area requests
public with sharing class RG_ServiceAreasController 
{
    
    //@description : Apex method to handle all Service Area State requests
    @AuraEnabled(cacheable=true)
    public static List<servicearea__c> getServiceAreas()
    {
        List<servicearea__c> serviceArea = New List<servicearea__c>();
        if(Schema.sObjectType.servicearea__c.fields.Id.isAccessible() &&
            Schema.sObjectType.servicearea__c.fields.State__c.isAccessible() &&
            Schema.sObjectType.servicearea__c.fields.Name.isAccessible())
        {
            serviceArea = [SELECT Id, Name, State__c
                            FROM servicearea__c
                            WHERE State__c = null
                            ORDER BY Name];
        }
        return serviceArea;   
    }
    
    //@description : Apex method to handle all Service Area City requests
    @AuraEnabled(cacheable=true)
    public static List<servicearea__c> getLocalServiceAreas(String serviceTerritoryName)
    {
        List<servicearea__c> serviceArea = New List<servicearea__c>();
        if(Schema.sObjectType.servicearea__c.fields.Id.isAccessible() &&
            Schema.sObjectType.servicearea__c.fields.Name.isAccessible() &&
            Schema.sObjectType.servicearea__c.fields.State__c.isAccessible() &&
            Schema.sObjectType.servicearea__c.fields.State_Abbreviation__c.isAccessible())
        {
            serviceArea = [SELECT Id, Name, State__c, State_Abbreviation__c
                            FROM servicearea__c 
                            WHERE State__c =:serviceTerritoryName
                            ORDER BY Name];
        }
        return serviceArea;   
    }

    //@description : Apex method to handle Service Area City Details requests
    @AuraEnabled(cacheable=true)
    public static servicearea__c getLocalAreaDetails(String localAreaName)
    {
        servicearea__c localArea = New servicearea__c();
        if(Schema.sObjectType.servicearea__c.fields.Id.isAccessible() &&
            Schema.sObjectType.servicearea__c.fields.Name.isAccessible() &&
            Schema.sObjectType.servicearea__c.fields.Local_Phone__c.isAccessible() &&
            Schema.sObjectType.servicearea__c.fields.TollFree_Phone__c.isAccessible() &&
            Schema.sObjectType.servicearea__c.fields.Side_Text__c.isAccessible() &&
            Schema.sObjectType.servicearea__c.fields.State_Abbreviation__c.isAccessible())
        {
            localArea = [SELECT Id, Name, State_Abbreviation__c, Local_Phone__c, Side_Text__c, TollFree_Phone__c
                            FROM servicearea__c 
                            WHERE Name =: localAreaName
                            LIMIT 1];
        }
        return localArea;   
    }

    //@description : Apex method to handle Service Area City Details requests for Search Results Page
    @AuraEnabled(cacheable=true)
    public static servicearea__c getLocalAreaDetailsSearchResults(String localAreaDetails, String placeId)
    {
        List<servicearea__c> localArea = New List<servicearea__c>();
        servicearea__c localDetails = New servicearea__c();
        List<String> latLng = localAreaDetails.split(',');
        
        if(Schema.sObjectType.servicearea__c.fields.Id.isAccessible() &&
            Schema.sObjectType.servicearea__c.fields.Name.isAccessible() &&
            Schema.sObjectType.servicearea__c.fields.Local_Phone__c.isAccessible() &&
            Schema.sObjectType.servicearea__c.fields.State__c.isAccessible() &&
            Schema.sObjectType.servicearea__c.fields.Latitude__c.isAccessible() &&
            Schema.sObjectType.servicearea__c.fields.Longitude__c.isAccessible() &&
            Schema.sObjectType.servicearea__c.fields.State_Abbreviation__c.isAccessible())
        {
            localArea = [SELECT Id, Name, State__c, State_Abbreviation__c, Local_Phone__c, Latitude__c, Longitude__c
                            FROM servicearea__c WHERE State__c != null];
        }
        if(localArea.size()>0 && !latLng[0].isNumeric() && !latLng[1].isNumeric())
        {
            for(servicearea__c eachLocal:localArea)
            {
                if(localAreaDetails.contains(eachLocal.Name) && (localAreaDetails.contains(eachLocal.State__c) || localAreaDetails.contains(eachLocal.State_Abbreviation__c)))
                {
                    localDetails = eachLocal;
                    break;
                }
            }
        }
        if(localDetails.Name == null && placeId !=null  && !latLng[0].isNumeric() && !latLng[1].isNumeric())
        {
            List<String> latLngs = RG_SearchApiAddressController.getPlaceDetails(placeId).split(',');
            Location inputLoc = Location.newInstance(Double.valueOf(latLngs[0]),Double.valueOf(latLngs[1]));
            Double minDistance = Double.valueOf(Label.RG_SearchMinimumDistanceRadius);
            for(servicearea__c eachLocal:localArea)
            {
                if(eachLocal.Latitude__c != null && eachLocal.Longitude__c != null)
                {
                    Location cityLoc = Location.newInstance(Double.valueOf(eachLocal.Latitude__c),Double.valueOf(eachLocal.Longitude__c));
                    Double dist = Location.getDistance(inputLoc, cityLoc, 'mi');
                    if(dist < minDistance)
                    {
                        localDetails = eachLocal;
                        minDistance = dist;
                    }
                }
            }            
        }
        return localDetails;   
    }

    //@description : Apex method to handle Service Area City Details requests with Latitude and Longitude for Search Results Page
    @AuraEnabled(cacheable=true)
    public static servicearea__c getLocalAreaDetailsSearchResultsLatLong(String localAreaDetails)
    {
        List<servicearea__c> localArea = New List<servicearea__c>();
        servicearea__c localDetails = New servicearea__c();
        List<String> latLng = localAreaDetails.split(',');
        
        if(Schema.sObjectType.servicearea__c.fields.Id.isAccessible() &&
            Schema.sObjectType.servicearea__c.fields.Name.isAccessible() &&
            Schema.sObjectType.servicearea__c.fields.Local_Phone__c.isAccessible() &&
            Schema.sObjectType.servicearea__c.fields.State__c.isAccessible() &&
            Schema.sObjectType.servicearea__c.fields.Latitude__c.isAccessible() &&
            Schema.sObjectType.servicearea__c.fields.Longitude__c.isAccessible() &&
            Schema.sObjectType.servicearea__c.fields.State_Abbreviation__c.isAccessible())
        {
            localArea = [SELECT Id, Name, State__c, State_Abbreviation__c, Local_Phone__c, Latitude__c, Longitude__c
                            FROM servicearea__c WHERE State__c != null];
        }
        Location inputLoc = Location.newInstance(Double.valueOf(latLng[0]),Double.valueOf(latLng[1]));
        Double minDistance = Double.valueOf(Label.RG_SearchMinimumDistanceRadius);
        for(servicearea__c eachLocal:localArea)
        {
            if(eachLocal.Latitude__c != null && eachLocal.Longitude__c != null)
            {
                Location cityLoc = Location.newInstance(Double.valueOf(eachLocal.Latitude__c),Double.valueOf(eachLocal.Longitude__c));
                Double dist = Location.getDistance(inputLoc, cityLoc, 'mi');
                if(dist < minDistance)
                {
                    localDetails = eachLocal;
                    minDistance = dist;
                }
            }
        }            
        return localDetails;   
    }

    //@description : Apex method to handle all Service Area State and City requests for Sitemap
    @AuraEnabled(cacheable=true)
    public static List<RG_SitemapServiceList> getSiteMapServiceAreas()
    {
        List<servicearea__c> serviceAreaList = New List<servicearea__c>();
        List<servicearea__c> localAreaList = New List<servicearea__c>();
        List<RG_SitemapServiceList> serviceAreaSitemapList = New List<RG_SitemapServiceList>();

        serviceAreaList = getServiceAreas();
        if(Schema.sObjectType.servicearea__c.fields.Id.isAccessible() &&
            Schema.sObjectType.servicearea__c.fields.Name.isAccessible() &&
            Schema.sObjectType.servicearea__c.fields.State__c.isAccessible() &&
            Schema.sObjectType.servicearea__c.fields.State_Abbreviation__c.isAccessible())
            {
                localAreaList = [SELECT Id, Name, State__c, State_Abbreviation__c
                                    FROM servicearea__c
                                    WHERE State__c != null
                                    ORDER BY Name];
            }
                
        for(servicearea__c eachService : serviceAreaList)
        {
            RG_SitemapServiceList serviceTerritory = new RG_SitemapServiceList();
            serviceTerritory.serviceAreaName = eachService.Name;
            serviceTerritory.serviceAreaId = eachService.Id;
            List<servicearea__c> localAreaToAddList = New List<servicearea__c>();
            for(servicearea__c eachLocal : localAreaList)
            {
                if(eachService.Id == eachLocal.State__c)
                {
                    localAreaToAddList.add(eachLocal);
                }
            }
            serviceTerritory.localAreaList = localAreaToAddList;
            serviceAreaSitemapList.add(serviceTerritory);
        }
        return serviceAreaSitemapList;   
    }
    
    //@description : Apex Wrapper Class for Sitemap URL List
    public with sharing class RG_SitemapServiceList
    {
        @AuraEnabled public String serviceAreaId;
        @AuraEnabled public String serviceAreaName;
        @AuraEnabled public List<servicearea__c> localAreaList;
    }
    
    //@description : Apex Wrapper Class for ServiceAreaDetails
    public with sharing class RG_ServiceAreaDetails
    {
        @AuraEnabled public servicearea__c serviceArea;
        @AuraEnabled public List<servicearea__c> localAreaList;
    }
    
    @AuraEnabled(cacheable=true)
    public static RG_ServiceAreaDetails getServiceAreaById(Id objId){
        RG_ServiceAreaDetails area = new RG_ServiceAreaDetails();
        area.serviceArea = [SELECT Id, Name, Side_Text__c, State__c, State_Abbreviation__c, Local_Phone__c, Tollfree_Phone__c FROM servicearea__c WHERE Id =: objId LIMIT 1];
        if(area.serviceArea.State__c == NULL) {
            area.localAreaList = [SELECT Id, Name, State__c FROM servicearea__c WHERE State__c =: objId];
        }
        return area;
    }
}