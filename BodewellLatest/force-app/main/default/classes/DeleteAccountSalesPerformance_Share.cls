/*
@Author :Sai Teja Bhavani
@Purpose : To delete share records when userremoved from account team for the Accountsalesperformance share object.
@description: To delete share records when userremoved from account team for the Accountsalesperformance share object.
*/
public class DeleteAccountSalesPerformance_Share implements Database.Batchable<sObject> {
 Public Database.QueryLocator start(Database.BatchableContext bc) {
        String roca='Account_Team__c';       
        String query = 'select id,RowCause,UserOrGroupId,ParentId,Parent.Account__c from Account_Sales_Performance__Share  where RowCause=:roca order by Parent.Account__c' ;
        return Database.getQueryLocator(query);
    }
     //start of the execute method
    Public  void execute(Database.BatchableContext bc, List<Account_Sales_Performance__Share > asplist) {
        List<Account_Sales_Performance__Share > delAspshare = new List<Account_Sales_Performance__Share >();
        List<String> userIdAccId = new list<String>();
        Set<Id> accountId = new Set<Id>();
         //getting the accountid so that only team members of those accounts will be fetched
        For(Account_Sales_Performance__Share  asp : asplist){
           
            accountId.add(asp.Parent.Account__c);

        }
        //store the account team members list along with the account and userid
        List<AccountTeamMember> accTeamlist =  [select Id, AccountId, UserId from AccountTeamMember where AccountId=:accountId]; 
        
        For(AccountTeamMember atmlist: accTeamlist)
        {
            
            userIdAccId.add(atmlist.UserId+'-'+atmlist.AccountId);
                        
        }
        //compare and check if the user exists in the account team if not add to delete list
        For(Account_Sales_Performance__Share  asp : asplist){
            if(!userIdAccId.contains(asp.UserOrGroupId+'-'+asp.Parent.Account__c)){
                delAspshare.add(asp);
            }
            
        }
        
        if(delAspshare.size()>0){
            delete delAspshare;
        }  
        
    } 
     // Method if any actions need to be perfomed       
    Public void finish(Database.BatchableContext bc) {
       
    }
}