/*
@Author :Sai Teja Bhavani
@Purpose : To delete share records when userremoved from account team for the Storeproduct share object.
@description: To delete share records when userremoved from account team for the Storeproduct share object.
*/
public class DeleteStoreProductShare implements Database.Batchable<sObject> {
 Public Database.QueryLocator start(Database.BatchableContext bc) {
        String roca='Manual';       
        String query = 'select id,RowCause,UserOrGroupId,ParentId,Parent.Account__c from StoreProductShare  where RowCause=:roca order by Parent.Account__c' ;
        return Database.getQueryLocator(query);
    }
     //start of the execute method
    Public  void execute(Database.BatchableContext bc, List<StoreProductShare > spslist) {
        List<StoreProductShare > delSpshare = new List<StoreProductShare >();
        List<String> userIdAccId = new list<String>();
        Set<Id> accountId = new Set<Id>();
        //getting the accountid so that only team members of those accounts will be fetched
        For(StoreProductShare  spshr : spslist){
           
            accountId.add(spshr.Parent.Account__c);

        }
        //store the account team members list along with the account and userid
        List<AccountTeamMember> accTeamlist =  [select Id, AccountId, UserId from AccountTeamMember where AccountId=:accountId]; 
        
        For(AccountTeamMember atmlist: accTeamlist)
        {
            
            userIdAccId.add(atmlist.UserId+'-'+atmlist.AccountId);
                        
        }
        //compare and check if the user exists in the account team if not add to delete list
        For(StoreProductShare  spshr : spslist){
            if(!userIdAccId.contains(spshr.UserOrGroupId+'-'+spshr.Parent.Account__c)){
                delSpshare.add(spshr);
            }
        }
        
        if(delSpshare.size()>0){
            delete delSpshare;
        }  
        
    } 
      // Method if any actions need to be perfomed    
    Public void finish(Database.BatchableContext bc) {
       // Method if any actions need to be perfomed 
    }
}