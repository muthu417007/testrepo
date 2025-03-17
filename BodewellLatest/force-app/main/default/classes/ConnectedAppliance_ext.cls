public class ConnectedAppliance_ext{
	public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}
    private Asset asset;
    public connectedApplianceResponse connectedStatus {get;set;}
    
   public connectedAppliance_ext(ApexPages.StandardController stdController) {
        String val=String.valueOf(stdController);
            this.asset= (Asset )stdController.getRecord();
            asset = [select id, MACAddress__c from Asset where Id = :asset.id LIMIT 1 ];
        
    } 

    
    public pageReference macAddressSearch(String mac){
        try{
            if(mac==null){
            	apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'No Mac Address' ));
            	throw new OtherException('No macAddress');
       		 }
           connectedStatus = ConnectedApplianceHelper.checkOnlineStatus(mac);
            
           }catch(exception e){
               apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'The status code returned was not expected: ' + e.getMessage()));
               return null;
           }
        return null;
    }
    
    public pageReference checkStatus(){
        return macAddressSearch(asset.MACAddress__c);
    }
    
    @AuraEnabled(cacheable=True) 
    public static string fetchCase (Id RecId){
        List<Map<Object,Object>> caseInfo=new List<Map<Object,Object>>();
        for(Case_Asset__c c: [SELECT Name, Mac_Address__c FROM Case_Asset__c where Case__c = :RecId])
        {	if(c.Name==null){
            return '[]';
        	}
         	
            Map<Object, Object> MyStrings = new Map<Object, Object>{'CaseAssetName' =>c.Name ,'MacAddress' => c.Mac_Address__c};
            caseInfo.add(MyStrings);         	
        } 
        String caseData = JSON.serialize(caseInfo);
        return caseData;
    }  
     
}