/*
@Author :Sai Teja Bhavani
@Purpose : To delete share records when userremoved from account team for the ProgramRequestShare share object.
@description: To delete share records when userremoved from account team for the ProgramRequest share object.

*/
public class DeleteProgramRequestShare implements Database.Batchable<sObject> {
 Public Database.QueryLocator start(Database.BatchableContext bc) {
        String roca='Account_Team__c';       
        String query = 'select id,RowCause,UserOrGroupId,ParentId,Parent.Account__c from Program_Request__Share  where RowCause=:roca order by Parent.Account__c' ;
        return Database.getQueryLocator(query);
    }
     //start of the execute method
    Public  void execute(Database.BatchableContext bc, List<Program_Request__Share > caslist) {
        List<Program_Request__Share > delcagreeshare = new List<Program_Request__Share >();
        List<String> userIdAccId = new list<String>();
        Set<Id> accountId = new Set<Id>();
        //getting the accountid so that only team members of those accounts will be fetched
        For(Program_Request__Share  cas : Caslist){
           
            accountId.add(cas.Parent.Account__c);

        }
        //store the account team members list along with the account and userid
        List<AccountTeamMember> accTeamlist =  [select Id, AccountId, UserId from AccountTeamMember where AccountId=:accountId]; 
        
        For(AccountTeamMember atmlist: accTeamlist)
        {
            
            userIdAccId.add(atmlist.UserId+'-'+atmlist.AccountId);
                        
        }
        //compare and check if the user exists in the account team if not add to delete list
        For(Program_Request__Share  cas : caslist){
            if(!userIdAccId.contains(cas.UserOrGroupId+'-'+cas.Parent.Account__c)){
                delcagreeshare.add(cas);
            }
            
        }
        
        if(delCagreeshare.size()>0){
            delete delcagreeshare;
        }  
        
    } 
    // Method if any actions need to be perfomed      
    Public void finish(Database.BatchableContext bc) {
           // Method if any actions need to be perfomed
    }
}