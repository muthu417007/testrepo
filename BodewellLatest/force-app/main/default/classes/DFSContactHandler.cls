public class DFSContactHandler implements PS_ITriggerHandler {

    public static Boolean TriggerDisabled = false;

    public Boolean IsDisabled() {
        return TriggerDisabled;
    }
    
  public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
      	if(!Test.isRunningTest())  
      		TriggerDisabled=true;
        List<Contact_From_DFS__c> dfscontacts= (List<Contact_From_DFS__c>)newItems.values();
        for(Contact_From_DFS__c dfsContact: dfscontacts){
            System.debug(dfsContact.status__c);
            if(dfsContact.Account__c==null && dfsContact.status__c=='Approved')
                dfsContact.addError('Please populate account before approving');
            
            else if(dfsContact.status__c=='Approved'){
                    Map<String, Object> inputs = new Map<String, Object>();
                    inputs.put('record', dfsContact);
                    inputs.put('record_prior', oldItems.get(dfsContact.Id));
                	inputs.put('random_number', Integer.valueof(Math.random()*10000));
                    Flow.Interview.DFS_Contact_on_Update myFlow = new Flow.Interview.DFS_Contact_on_Update(inputs);
                if(!Test.isRunningTest())    
                	myFlow.start();
            }
            else{}
        }
    }
    
    public void beforeInsert(List<SObject> newItems){
        
    }
    
    public void beforeDelete(Map<Id, SObject> oldItems){
        
    }
    
    public void afterInsert(List<SObject> newItems){
        
    }
    
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        
    }
    
    public void afterDelete(Map<Id, SObject> oldItems){
        
    }
}