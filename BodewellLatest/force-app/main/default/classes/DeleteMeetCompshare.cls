/*
@Author :Sai Teja Bhavani
@Purpose : To delete share records when userremoved from account team for the meetcomp share object.
@description: To delete share records when userremoved from account team for the meetcomp share object.
*/
Public class DeleteMeetCompshare implements Database.Batchable<sObject> {
    Public Database.QueryLocator start(Database.BatchableContext bc) {
        String roca='Account_Team__c';       
        String query = 'select id,RowCause,UserOrGroupId,ParentId,Parent.Account__c from Meet_Comp__Share where RowCause=:roca order by Parent.Account__c' ;
        return Database.getQueryLocator(query);
    }
     //start of the execute method
    Public  void execute(Database.BatchableContext bc, List<Meet_Comp__Share> mcplist) {
        List<Meet_Comp__Share> delmetcmpshare = new List<Meet_Comp__Share>();
        List<String> userIdAccId = new list<String>();
        Set<Id> accountId = new Set<Id>();
        //getting the accountid so that only team members of those accounts will be fetched
        For(Meet_Comp__Share mcp : mcplist){
           
            accountId.add(mcp.Parent.Account__c);

        }
        //store the account team members list along with the account and userid
        List<AccountTeamMember> accTeamlist =  [select Id, AccountId, UserId from AccountTeamMember where AccountId=:accountId]; 
        
        For(AccountTeamMember atmlist: accTeamlist)
        {
            
            userIdAccId.add(atmlist.UserId+'-'+atmlist.AccountId);
                        
        }
        //compare and check if the user exists in the account team if not add to delete list
        For(Meet_Comp__Share mcp : mcplist){
            if(!userIdAccId.contains(mcp.UserOrGroupId+'-'+mcp.Parent.Account__c)){
                delmetcmpshare.add(mcp);
            }
        }
        
        if(delmetcmpshare.size()>0){
            delete delmetcmpshare;
        }  
        
    } 
            // Method if any actions need to be perfomed
    Public void finish(Database.BatchableContext bc) {
       //if any final actions need to be performed.
    }
}