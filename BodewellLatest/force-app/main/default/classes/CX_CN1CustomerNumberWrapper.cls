public with sharing class CX_CN1CustomerNumberWrapper {
    private CX_CN1CustomerNumberWrapper() {}
    
    public static Request preparePayload(Account currentContact, Account location, User currentUser) { 
        system.debug('in preparePayload');
        Payload payload = new Payload();
        payload.ConsumerNo = '';
        payload.LastName = currentContact.LastName;
        payload.FirstName = currentContact.FirstName;
        payload.ConsumerTitle = '';
        payload.TelephoneNo = String.isNotBlank(currentContact.Phone) ? CX_Utils.removeNumberFormatting(currentContact.Phone) : '';
        payload.EmailAddr = currentContact.PersonEmail;
        payload.CreateUserId = currentUser.SSO_ID__c;
        payload.UpdateUserId = currentUser.SSO_ID__c;
        payload.Addr1 = location != null ? location.BillingStreet : '';
        payload.Addr2 = '';
        payload.Addr3 = '';
        payload.Addr4 = '';
        payload.CityName = location != null ? location.BillingCity : '';
        payload.CityNameOverride = '';
        payload.StateCode = location != null ? location.BillingState : '';
        payload.PostalAreaCode = location != null ? location.BillingPostalCode : '';
        payload.BusinessIndicator = 'N';
        payload.BusinessName = '';
        payload.DbaName = '';
        
        Request request = new Request();
        request.request = 'ConsumerInsertUpdateRequest';
        request.searchvalue = '';
        request.payload = payload;
        
        return request;
    }
    
    public class Request {
        public String request { get; set; }
        public String searchvalue { get; set; }
        public Payload payload { get; set; }
    }
    
    public class Payload {
        public String ConsumerNo { get; set; }
        public String LastName { get; set; }
        public String FirstName { get; set; }
        public String ConsumerTitle { get; set; }
        public String TelephoneNo { get; set; }
        public String EmailAddr { get; set; }
        public String CreateUserId { get; set; }
        public String UpdateUserId { get; set; }
        public String Addr1 { get; set; }
        public String Addr2 { get; set; }
        public String Addr3 { get; set; }
        public String Addr4 { get; set; }
        public String CityName { get; set; }
        public String CityNameOverride { get; set; }
        public String StateCode { get; set; }
        public String PostalAreaCode { get; set; }
        public String BusinessIndicator { get; set; }
        public String BusinessName { get; set; }
        public String DbaName { get; set; }
    }    

}