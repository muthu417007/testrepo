/******************************************************************************************
// Author:      Shubhada Kurumkar
//@description : Apex Class to get address for bodewell
******************************************************************************************/

public without sharing class BWC_geolocateZipcodeController 
{
   
      //@description : Apex method to handle  API Callout requests for address from latitude and longitude
    @AuraEnabled
    Public Static String getAddress( String zipCode)
    {
     
    Map<String,String> mapAddress=new Map<String,String>();
        String endpointurl1='https://maps.googleapis.com/maps/api/geocode/json?address='+zipCode+'&key='+Label.BWC_Google_Map_Api;
       
      
            
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndPoint(endpointurl1);
        HttpResponse response = http.send(request);
        if(response.getStatusCode()==200){
            system.debug('response()'+response.getBody());
            return response.getBody();
        }
        
         else
         {
             return null;
         }
         
     
      
    }
    
      //@description : Apex method to handle  API Callout requests for address from latitude and longitude
    @AuraEnabled
    Public Static user updateUserZipcode( String userId,String zipCode)
    {
        if(userId!=null && zipCode!=null )
        {
            user u=[select Id, BWC_Current_Location_ZipCode__c from User WHERE Id=:userId];
        u.BWC_Current_Location_ZipCode__c=zipcode;
        update u; 
            return u;
        }
        else
        {
             return null;
        }
       
       
    }
    
    
    
    //@description : Apex method to handle  API Callout requests for address from latitude and longitude
    @AuraEnabled
    Public Static String getZipcodeByLatLong( String latLong)
    {
     
 
        String endpointurl1='https://maps.googleapis.com/maps/api/geocode/json?latlng='+latLong+'&key='+Label.BWC_Google_Map_Api;
        
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndPoint(endpointurl1);
        HttpResponse response = http.send(request);
        if(response.getStatusCode()==200){
            system.debug('response()'+response.getBody());
            return response.getBody();
        }
        
         else
         {
             return null;
         }
         
     
  
      
}
    
}