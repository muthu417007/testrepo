public class SearchPhoneResponse {
 
    public Data data {get;set;}
    public List<Errors> errors {get;set;}
    public statusMessage status {get;set;}
    
    public class statusMessage{
        public String responseCode {get;set;}
        public String Message {get;set;}
    }
    
    public class Orders {
        public String AddressLine1;
        public String DataSourceCode;
        public String DataSourceName;
        public String FirstName;
        public String LastName;
        public String Locality;
        public String OrderCreatedBy;
        public String OrderDate;
        public List<OrderDetails> OrderDetails;
        public String OrderDiscountAmount;
        public String OrderGrossAmount;
        public String OrderID;
        public String OrderNetAmount;
        public String OrderNumber;
        public String OrderPaymentMethod;
        public String OrderPlacedOn;
        public String OrderPromoCode;
        public String OrderShipmentAmount;
        public String OrderTaxAmount;
        public String OrderUniqueKey;
        public String PersonID;
        public String PostalCode;
        public String Region;
    }

    public class Errors {
        public List<String> path;
        public String locations;
        public String message;
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
        public String LocationID {get;set;}
        public String AddressLine1 {get;set;}
        public String AddressLine2 {get;set;}
        public String Locality {get;set;}
        public String Region {get;set;}
        public String PostalCode {get;set;}
        public String CountryCode {get;set;}
    }

    public class Data {
        public List<HouseHoldByPhone> HouseHoldByPhone {get;set;}
    }
    
    public class EmailAddress{
        public String EmailAddress;
        public String EmailID;
        public String IsPrimaryEmail;
        public String IsPrimaryPerson;
        public String MYAMyAccountId;
    }
    
    public class PersonDetail {
      public String COPSPersonNumber;
      public String GEConsumerNo;
      public String PersonDetailID;
      public String PersonID;
    }
    
    public class Phone {
        public String IsPrimaryPhone;
        public String PhoneNumber;
        public String PhoneTypeName;
        public String PhoneUseTypeName;
    }
      
    public class HouseHoldByPhone {
        public String ClientPersonCode;
        public String FirstName {get;set;}
        public String Gender;
        public Boolean IsDead;
        public String LastName{get;set;}
        public String MiddleName;
        public String PersonID{get;set;}
        public List<Orders> Orders;
        public List<EmailAddress> EmailAddresses;
        public List<PersonDetail> Details;
        public String plevel {get;set;}
        public String Salutation;
        public List<Assets> Assets;
        public List<Locations> Locations;
        public List<Phone> phone;
    }
    
    public static SearchPhoneResponse parse(String json) {
        return (SearchPhoneResponse) System.JSON.deserialize(json, SearchPhoneResponse.class);
    }
}