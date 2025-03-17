public class PS_MeetCompPdfGenerator_ctrl {
    
    public Meet_Comp__c[] meetComps {get; set;}
    public Account ac {get; set;}

    public PS_MeetCompPdfGenerator_ctrl(ApexPages.StandardController controller) {
        Id accountId = controller.getRecord().Id;
        ac = [
            SELECT Oracle_Account_Number__c, BillingStreet, BillingCity, BillingState,
                BillingPostalCode, Doing_Business_As_DBA__c, Fax, Phone, Name
            FROM Account
            WHERE Id = :accountId
        ];
        String template = apexpages.currentpage().getparameters().get('template');
        Apexpages.currentPage().getHeaders().put( 'content-disposition', 'inline; filename=' + ac.Name.replaceAll('[^a-zA-Z0-9\\s+]', '') + '-' + template + '-' + System.today());

        if(template == 'Current_Meet_Comps_Document') {
            meetComps = [SELECT Competitive_Invoice_Price__c, Total_Discounts__c, Competitive_Net_Price__c, SKU__c,
                        Termination_Date_of_Competitive_Data__c, Quantity__c, Competitive_Model__r.Name, MC_Type__c FROM Meet_Comp__c 
                        WHERE Account__c = :accountId
                        AND (Stage_Name__c = 'Approved' OR Stage_Name__c = 'Approved and Transferred')
                        AND Effective_Date__c <= TODAY
                        AND Termination_Date__c > TODAY];
        } else if (template == 'Future_Meet_Comps_Document') {
            meetComps = [SELECT Competitive_Invoice_Price__c, Total_Discounts__c, Competitive_Net_Price__c, SKU__c,
                        Termination_Date_of_Competitive_Data__c, Quantity__c, Competitive_Model__r.Name, MC_Type__c FROM Meet_Comp__c
                        WHERE Account__c = :accountId 
                        AND (Stage_Name__c = 'Approved' OR Stage_Name__c = 'Approved and Transferred')
                        AND Effective_Date__c > TODAY];
        } else {
            meetComps = [SELECT GEA_Model__r.StockKeepingUnit, GEA_Meet_Comp_Price__c, GEA_Volume_Rebate_Pif__c, GEA_Inventory_Financing__c, GEA_Other_Backside_curnc__c,
                        GEA_Net_Price__c, Quantity__c, Effective_Date__c, Termination_Date__c, MC_Type__c, SKU__c
                        FROM Meet_Comp__c
                        WHERE Account__c = :accountId 
                        AND (Stage_Name__c = 'Approved' OR Stage_Name__c = 'Approved and Transferred')
                        AND Termination_Date__c >= Today];            
        }
    }
}