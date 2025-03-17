public class SearchIdResponse {
    @AuraEnabled
    public Data data;
    @AuraEnabled
    public List<Errors> errors;
    @AuraEnabled
    public statusMessage status {get;set;}
    
    public class statusMessage{
        @AuraEnabled
        public String responseCode {get;set;}
        @AuraEnabled
        public String Message {get;set;}
    }
    
    public class Orders {
        @AuraEnabled
        public String AddressLine1;
        public String DataSourceCode;
        public String DataSourceName;
        @AuraEnabled
        public String FirstName;
        @AuraEnabled
        public String LastName;
        @AuraEnabled
        public String Locality;
        public String OrderCreatedBy;
        @AuraEnabled
        public String OrderDate;
        public List<OrderDetails> OrderDetails;
        public String OrderDiscountAmount;
        @AuraEnabled
        public String OrderGrossAmount;
        public String OrderID;
        public String OrderNetAmount;
        @AuraEnabled
        public String OrderNumber;
        public String OrderPaymentMethod;
        @AuraEnabled
        public String OrderPlacedOn;
        @AuraEnabled
        public String OrderPromoCode;
        @AuraEnabled
        public String OrderShipmentAmount;
        public String OrderTaxAmount;
        @AuraEnabled
        public String OrderUniqueKey;
        public String PersonID;
        @AuraEnabled
        public String PostalCode;
        public String Region;
    }

    public class Errors {
        public List<String> path;
        public String locations;
        public String message;
    }
    
    public class EmailAddress{
        public String EmailAddress;
        public String EmailID;
        public String IsPrimaryEmail;
        public String IsPrimaryPerson;
        public String MYAMyAccountId;
    }

    public class OrderDetails {
        public String AssetID;
        public String BrandName;
        public String CleansedModelNumber;
        public String DiscountPercent;
        public String InvoiceLine;
        public String InvoiceNumber;
        public String ManufacturerCost;
        public String NetInvoiceValue;
        public String OrderID;
        public String OriginalModelNumber;
        public String PartNumber;
        public String ProductCategoryName;
        public String ProductDescription;
        public String ProductLineName;
        public String TaxAmount;
    }

    public class Assets {
        public String AssetClassName;
        public String AssetID;
        public String AssetScrappedOn;
        public String AssetShippedOn;
        public String BrandName;
        public String CleansedModelNumber;
        public String IsProductReturned;
        public String LocationID;
        public String MACAddress;
        public String OriginalEngineeringModelNumber;
        public String OwnershipStartedOn;
        public String ProductCategoryName;
        public String ProductDescription;
        public String ProductLineName;
        public String SerialNumber;
    }

    public class Locations {
        public String LocationID;
        public String AddressLine1;
        public String AddressLine2;
        public String Locality;
        public String Region;
        public String PostalCode;
        public String CountryCode;
    }

    public class PersonById {
        @AuraEnabled
        public String ClientPersonCode;
        @AuraEnabled
        public String FirstName;
        @AuraEnabled
        public String Gender;
        public String IsDead;
        public String LastName;
        public String MiddleName;
        @AuraEnabled
        public List<Orders> Orders;
        public List<EmailAddress> EmailAddresses;
        public String PersonID;
        public String plevel;
        public String Salutation;
        public List<Assets> Assets;
        public List<Locations> Locations;
    }
    
    public class Data {
        @AuraEnabled
        public PersonById PersonById;
    }

    
    public static SearchIdResponse parse(String json) {
        return (SearchIdResponse) System.JSON.deserialize(json, SearchIdResponse.class);
    }
}