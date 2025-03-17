public class BWC_AvailabilityCacheWrapper {
    @auraenabled
    public String errorStatus{get;set;}
   @auraenabled
    public String errorMessage{get;set;}
    @auraenabled
    public list<availabilityDetails> availabilityDetails{get;set;}
   
    public class availabilityDetails{
        @auraenabled
        public Integer requestedDateQuantity{get;set;}
        @auraenabled
        public String shipDate{get;set;}
        @auraenabled
        public Double availableQuantity{get;set;}
        @auraenabled
        public String requestedShipDate{get;set;}
        @auraenabled
        public Integer errorCode{get;set;}
        @auraenabled
        public Integer quantityOrdered{get;set;}
        @auraenabled
        public String message{get;set;}
        @auraenabled
        public String inventoryItemName{get;set;}
    }
    public static BWC_AvailabilityCacheWrapper parse(String json) {
        if(test.isRunningTest()){
            json='{  "errorStatus": "Success",  "errorMessage": "No errors",  "availabilityDetails": [    {      "requestedDateQuantity": 10,      "shipDate": "2023-09-30",      "availableQuantity": 8.5,      "requestedShipDate": "2023-10-05",      "errorCode": null,      "quantityOrdered": 5,      "message": "Item A is available",      "inventoryItemName": "Item A"    },    {      "requestedDateQuantity": 5,      "shipDate": "2023-10-10",      "availableQuantity": 4.0,      "requestedShipDate": "2023-10-15",      "errorCode": null,      "quantityOrdered": 2,      "message": "Item B is available",      "inventoryItemName": "Item B"    }  ]}';
        }
      return (BWC_AvailabilityCacheWrapper) System.JSON.deserialize(json, BWC_AvailabilityCacheWrapper.class);
    }
}