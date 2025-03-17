/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        31.05.2021
 * @description    Wrapper class for the Contact Search
 */
public class CX_ContactSearchWrapper {
    public Data data { get; set; }
    public List<Errors> errors { get; set; }
    public StatusMessage status { get; set; }

    public class StatusMessage{
        public String responseCode { get; set; }
        public String Message { get; set; }
    }

    public class Errors {
        public List<String> path { get; set; }
        public String locations { get; set; }
        public String message { get; set; }
    }

    public class Data {
        public List<HouseHoldByPhone> HouseHoldByPhone { get; set; }
        public List<HouseHoldByEmail> HouseHoldByEmail { get; set; }
    }

    public class HouseHoldByPhone extends HouseHold {}

    public class HouseHoldByEmail extends HouseHold {}

    public virtual class HouseHold {
        public Contact contactSalesforce { get; set; }
        public String ClientPersonCode { get; set; }
        public String FirstName { get; set; }
        public String Gender { get; set; }
        public Boolean IsDead { get; set; }
        public String LastName { get; set; }
        public String MiddleName { get; set; }
        public String PersonID { get; set; }
        public List<Order> Orders { get; set; }
        public List<EmailAddress> EmailAddresses { get; set; }
        public List<PersonDetail> Details { get; set; }
        public String plevel { get; set; }
        public String Salutation { get; set; }
        public List<Asset> Assets { get; set; }
        public List<Location> Locations { get; set; }
        public List<Phone> Phone { get; set; }
    }
    
    public class Order {
        public String AddressLine1 { get; set; }
        public String DataSourceCode { get; set; }
        public String DataSourceName { get; set; }
        public String FirstName { get; set; }
        public String LastName { get; set; }
        public String Locality { get; set; }
        public String OrderCreatedBy { get; set; }
        public String OrderDate { get; set; }
        public List<OrderDetails> OrderDetails { get; set; }
        public String OrderDiscountAmount { get; set; }
        public String OrderGrossAmount { get; set; }
        public String OrderID { get; set; }
        public String OrderNetAmount { get; set; }
        public String OrderNumber { get; set; }
        public String OrderPaymentMethod { get; set; }
        public String OrderPlacedOn { get; set; }
        public String OrderPromoCode { get; set; }
        public String OrderShipmentAmount { get; set; }
        public String OrderTaxAmount { get; set; }
        public String OrderUniqueKey { get; set; }
        public String PersonID { get; set; }
        public String PostalCode { get; set; }
        public String Region { get; set; }
    }

    public class OrderDetails {
        public String AssetID { get; set; }
        public String BrandName { get; set; }
        public String CleansedModelNumber { get; set; }
        public String DiscountPercent { get; set; }
        public String InvoiceLine { get; set; }
        public String InvoiceNumber { get; set; }
        public String ManufacturerCost { get; set; }
        public String NetInvoiceValue { get; set; }
        public String OrderID { get; set; }
        public String OriginalModelNumber { get; set; }
        public String PartNumber { get; set; }
        public String ProductCategoryName { get; set; }
        public String ProductDescription { get; set; }
        public String ProductLineName { get; set; }
        public String TaxAmount { get; set; }
    }

    public class EmailAddress{
        public String EmailAddress { get; set; }
        public String IsPrimaryEmail { get; set; }
        public Boolean IsPrimaryPerson { get; set; }
        public String MYAMyAccountId { get; set; }
    }

    public class PersonDetail {
        public String COPSPersonNumber { get; set; }
        public String GEConsumerNo { get; set; }
        public String PersonDetailID { get; set; }
        public String PersonID { get; set; }
      }

    public class Asset {
        public String AssetClassName { get; set; }
        public String AssetID { get; set; }
        public String AssetScrappedOn { get; set; }
        public String AssetShippedOn { get; set; }
        public String BrandName { get; set; }
        public String CleansedModelNumber { get; set; }
        public String IsProductReturned { get; set; }
        public String LocationID { get; set; }
        public String MACAddress { get; set; }
        public String OriginalEngineeringModelNumber { get; set; }
        public String OwnershipStartedOn { get; set; }
        public String ProductCategoryName { get; set; }
        public String ProductDescription { get; set; }
        public String ProductLineName { get; set; }
        public String SerialNumber { get; set; }
    }

    public class Location {
        public String LocationID { get; set; }
        public String AddressLine1 { get; set; }
        public String AddressLine2 { get; set; }
        public String Locality { get; set; }
        public String Region { get; set; }
        public String PostalCode { get; set; }
        public String CountryCode { get; set; }
    }
    
    public class Phone {
        public String IsPrimaryPhone { get; set; }
        public String PhoneNumber { get; set; }
        public String PhoneTypeName { get; set; }
        public String PhoneUseTypeName { get; set; }
    }
    
    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        31.05.2021
     * @description    Parses a string to a CX_ContactSearchWrapper instance
     * @param          String - A Json string
     * @return         CX_ContactSearchWrapper - A wrapper instance
     */
    public static CX_ContactSearchWrapper parse(String body) {
        return (CX_ContactSearchWrapper) JSON.deserialize(body, CX_ContactSearchWrapper.class);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        08.06.2021
     * @description    Returns all records for a type
     * @param          String - The match type (email or phone)
     * @return         List<HouseHold> - The records for the type
     */
    public List<HouseHold> getRecordsByType(String type) { 
        List<HouseHold> records = new List<HouseHold>();

        if(type == 'email' && this.data.HouseHoldByEmail != null) { 
            records.addAll(this.data.HouseHoldByEmail);
        }else if(type == 'phone' && this.data.HouseHoldByPhone != null) { 
            records.addAll(this.data.HouseHoldByPhone);
        }

        return records;
    }
}