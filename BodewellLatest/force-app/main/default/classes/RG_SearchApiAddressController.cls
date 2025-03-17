//******************************************************************************************
// Author:       Yogesh Sharma
// Company:      TCS
// Created Date: 25/04/2023
//******************************************************************************************
//@description : Apex Class to handle Service Area requests
public class RG_SearchApiAddressController 
{
    //@description : Apex method to handle all API Callout requests for address suggestions
    @AuraEnabled
    Public Static list<RG_SuggestionWrapper> getAddress(String searchString)
    {
        if(String.isNotBlank(searchString))
        {
            String endpointURL;
            if(searchString.isNumeric() && searchString.length()>4)
            {
                endpointURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input='+searchString+'&key='+Label.RG_GoogleMapsApiKey+'&types=postal_code&language=en&components=country:us';
            }
            else
            {
                endpointURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input='+searchString+'&key='+Label.RG_GoogleMapsApiKey+'&types=(cities)'+'&language=en&components=country:us';
            }
            List<RG_SuggestionWrapper> suggestions=new List<RG_SuggestionWrapper>();
            searchString = EncodingUtil.urlEncode(searchString, 'UTF-8');
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setMethod('GET');
            request.setEndPoint(endpointURL);
            HttpResponse response = http.send(request);
            if(response.getStatusCode()==200){
                RG_SuggestionAddressPayload jsonPayload= parseSuggestion(response.getbody());
                string completeAddress = '';
                List<String> completeaddressList = new List<String>();
                if(jsonPayload.predictions != null){
                    for(RG_SuggestionAddressPayload.Predictions prediction : jsonPayload.predictions){
                        if(string.isNotBlank(prediction.description)){
                            completeAddress = prediction.description;
                            suggestions.add(new RG_SuggestionWrapper(completeAddress,prediction.place_id));
                        }
                    }
                }
                return suggestions;  
            }             
        }
        return null;
    }
    //@description : Apex method to handle all API Callout requests for place details using placeId
    @AuraEnabled
    public static string getPlaceDetails(String placeId) 
    {
        if(String.isNotBlank(placeId)){
            String strURL = 'https://maps.googleapis.com/maps/api/geocode/json?' + 'place_id=' + EncodingUtil.urlEncode(placeId, 'UTF-8') + '&key='+Label.RG_GoogleMapsGeocodeApiKey; 
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            HttpResponse response = new HttpResponse();
            req.setMethod('GET');
            req.setEndpoint(strURL);
            req.setTimeout(120000);
            response = h.send(req);
            RG_AddressByPlaceIdPayload jsonPayload = (RG_AddressByPlaceIdPayload) JSON.deserialize(response.getbody(), RG_AddressByPlaceIdPayload.class);
            String lati = String.valueOf(jsonPayload.results[0].geometry.location.lat);
            String longi = String.valueOf(jsonPayload.results[0].geometry.location.lng);
            return lati + ',' + longi;  
        }else{
            return null;
        }         
    }
    //@description : Wrapper Class
    public class RG_SuggestionWrapper{
        // @AuraEnabled
        // public String addComplete;
        // @AuraEnabled
        // public String placeId;
        @AuraEnabled
        public String addComplete{get;set;}
        @AuraEnabled
        public String placeId{get;set;}
         
        public RG_SuggestionWrapper(string addComplete,String placeId){
            this.addComplete = addComplete;
            this.placeId = placeId;
        }
    }        
    //@description : Apex method to parse Address Suggestions     
    public static RG_SuggestionAddressPayload parseSuggestion(String json) {
        return (RG_SuggestionAddressPayload) System.JSON.deserialize(json, RG_SuggestionAddressPayload.class);
    }
}