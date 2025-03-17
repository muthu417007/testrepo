/*
@Author :Sai Teja Bhavani
@Purpose : To delete share records when userremoved from account team for the customeragreement share object.
@description: To delete share records when userremoved from account team for the customeragreement share object.

*/
public class DeleteCustomerAgreementshare implements Database.Batchable<sObject> {
 Public Database.QueryLocator start(Database.BatchableContext bc) {
        String roca='Account_Team__c';       
        String query = 'select id,RowCause,UserOrGroupId,ParentId,Parent.Account_Name__c from Customer_Agreement__Share  where RowCause=:roca order by Parent.Account_Name__c' ;
        return Database.getQueryLocator(query);
    }
      //start of the execute method
    Public  void execute(Database.BatchableContext bc, List<Customer_Agreement__Share > caslist) {
        List<Customer_Agreement__Share > delcagreeshare = new List<Customer_Agreement__Share >();
        List<String> userIdAccId = new list<String>();
        Set<Id> accountId = new Set<Id>();
        //getting the accountid so that only team members of those accounts will be fetched
        For(Customer_Agreement__Share  cas : Caslist){
           
            accountId.add(cas.Parent.Account_Name__c);

        }
          //store the account team members list along with the account and userid
        List<AccountTeamMember> accTeamlist =  [select Id, AccountId, UserId from AccountTeamMember where AccountId=:accountId]; 
        
        For(AccountTeamMember atmlist: accTeamlist)
        {
            
            userIdAccId.add(atmlist.UserId+'-'+atmlist.AccountId);
                        
        }
        //compare and check if the user exists in the account team if not add to delete list
        For(Customer_Agreement__Share  cas : caslist){
            if(!userIdAccId.contains(cas.UserOrGroupId+'-'+cas.Parent.Account_Name__c)){
                delcagreeshare.add(cas);
            }
            
        }
        
        if(delCagreeshare.size()>0){
            delete delcagreeshare;
        }  
        
    } 
      // Method if any actions need to be perfomed    
    Public void finish(Database.BatchableContext bc) {
       //to perform the final actions
    }
}