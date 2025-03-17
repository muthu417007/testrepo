/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        15.06.2021
 * @description    Wrapper class for the Asset creation process in Siebel
 */
public with sharing class CX_NewAssetWrapper {
    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        15.06.2021
     * @description    Transforms SF records in the new asset integration payload
     * @param      		Asset - The Asset record in SF
     * @param          User - The user who will create the record in the external system
     * @param          String - The asset installation date in String format (yyyyMMdd)
     * @param          Long - The consumer number to be related to the asset
     * @return         NewAssetRequest - The new asset request body
     */
    public static NewAssetRequest preparePayload(Asset newAsset, User currentUser, String installDate, Long consumerNumber) {
        NewAssetPayload payload = new NewAssetPayload();
        payload.ConsumerNo = String.valueOf(consumerNumber);
        payload.BrandCode = newAsset.BrandName__c;
        payload.ProductTypeDesc = newAsset.Product_Type_Desc__c;
        payload.ProductLineDesc = newAsset.Product_Line_Desc__c;
        payload.ModelNumber = newAsset.Model_Number__c;
        payload.SerialNumber = newAsset.SerialNumber;
        payload.ItemCount = '1';
        payload.AddressNumber = '1';
        payload.InstallationDate = installDate;
        payload.Comments = '';
        payload.OwnershipEndDate = '';
        payload.UpdateUserId = currentUser.SSO_ID__c;
        payload.UpdatedDate = Datetime.now().format('yyyyMMddhhmm00');

        NewAssetRequest request = new NewAssetRequest();
        request.request = 'InsertUpdateOwnershipRequest';
        request.searchvalue = '';
        request.payload = payload;

        return request;
    }

    public class NewAssetRequest {
        public String request { get; set; }
        public String searchvalue { get; set; }
        public NewAssetPayload payload { get; set; }
    }

    public class NewAssetPayload {
        public String ConsumerNo { get; set; }
        public String BrandCode { get; set; }
        public String ProductTypeDesc { get; set; }
        public String ProductLineDesc { get; set; }
        public String ModelNumber { get; set; }
        public String SerialNumber { get; set; }
        public String ItemCount { get; set; }
        public String AddressNumber { get; set; }
        public String InstallationDate { get; set; }
        public String Comments { get; set; }
        public String OwnershipEndDate { get; set; }
        public String UpdateUserId { get; set; }
        public String UpdatedDate { get; set; }
    }    
}