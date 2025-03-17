public class PS_ShowroomPdfGenerator_ctrl {

    public StoreProduct[] products {get; set;}
    public RetailStore rs {get; set;}

    public PS_ShowroomPdfGenerator_ctrl(ApexPages.StandardController controller) {
        Id rsId = controller.getRecord().Id;
        rs = [SELECT Count_Competitive_Products__c, Count_GEA_Products__c, Account__r.Name, Name, GE_Appliances_Floor_Penetration__c
              FROM RetailStore WHERE Id = :rsId];
        Apexpages.currentPage().getHeaders().put( 'content-disposition', 'inline; filename=' + rs.Name.replaceAll('[^a-zA-Z0-9\\s+]', '') + '-' + System.today());

        products = [
            SELECT SKU__c, Brand__c, Product_Line__c, Sub_Product_Line__c, Count__c, Description__c, GEA_Status__c,
                ADC_Avail_Date__c, Low_Est_Retail__c, Plan_to_Sell__c, NPI_Transition__c, NPI_ADC_Date__c, SPIFF__c,
                Notes__c, Cust_Floor_Price__c, Display__c
            FROM StoreProduct
            WHERE RetailStoreId = :rsId and IsActive__c = True
            ORDER BY Product_Line__c, Sub_Product_Line__c, Low_Est_Retail__c
        ];
    }

}