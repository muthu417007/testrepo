public class updateZoneRegionController{
    Public Case c{get;set;}
    public Account a {get;set;}

    public updateZoneRegionController(ApexPages.StandardController stdController) {
        this.c= (case)stdController.getRecord();
        c = [SELECT id,accountId
             FROM case
             WHERE id =: c.id LIMIT 1]; 
        List<Account> accounts = [SELECT ID,Service_Region_Zone__c,billingPostalCode 
            FROM Account
            WHERE id = :c.accountId LIMIT 1];
        if(accounts.size() > 0){
            a = accounts[0];
        } else {
            a = null;
        }
       
    }

    public PageReference updateZoneRegion() {
        if(a==null){return null;}
        zoneDetailsResponse resp = utility.addressVerify(a.BillingPostalCode);
        
        a.Region__c = decimal.valueOf(resp.RegionNo);
        a.Zone__c = resp.ZoneCode;
        
        if(resp.ZoneCode != null && resp.ZoneCode == '09'){
            a.Service_Region_Zone__c =  'Customer Care';  
        } else {
           a.Service_Region_Zone__c =  'Factory Service'; 
        }       

        update a;
        PageReference p= new PageReference('/'+c.id);
        p.setRedirect(true);
        return p;  
    }
    
    
}