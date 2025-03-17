/**
* @author Abhishek Bisht
* @date 14/03/2024
* @description This is wrapper class of ADC Mule API
* */
public  class BWC_ADC_WrapperResponse {
        @AuraEnabled
        public Integer customerAccountNumber;
        @AuraEnabled
        public String adcOrg;
        @AuraEnabled
        public String returnOrg;
        @AuraEnabled
        public String sdsOrg;
        @AuraEnabled
        public String sdsZone;
        @AuraEnabled
        public String hdOrg;
        @AuraEnabled
        public String hdZone;
        @AuraEnabled
        public String mtOrg;
        @AuraEnabled
        public String mtZone;
        @AuraEnabled
        public String willCallAdcOrgCode;
        @AuraEnabled
        public String willCallSdsOrgCode;
        @AuraEnabled
        public String guaranteedTruck;
        @AuraEnabled
        public String guaranteedTruckZone;
}