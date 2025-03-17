global with sharing virtual class PS_WebServiceUserInfoWrapper {

    public String firstname;
    public String lastname;
    public String email;
    public String mobile;
    public String language;
    public String region;
    public Address address;
    public Geolocation geolocation;
    public Boolean isFrozen;
    public String thirdPartyUserId;
    Public String UserAccess;
    
    public List<AcceptedTerms> acceptedTerms = new List<AcceptedTerms>();

    public class AcceptedTerms {
        public String name;
        public String revision;
        public String language;
        public Datetime consentDateTime;
    }

    public class Address {
        public String street;
        public String city;
        public String state;
        public String zipCode;
        public String country;
    }

    public class Geolocation {
        public Decimal latitude;
        public Decimal longitude;
    }
}