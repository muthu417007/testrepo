/*
@Author :Sai Teja Bhavani
@Purpose : To delete share records when userremoved from account team
*/
Public class DeleteSharerecords implements Database.Batchable<string>  {
Public Iterable<string> start(Database.BatchableContext ctx) {
    return new list<String> { 'Meet_Comp__Share','Customer_Agreement__Share','Program_Request__Share','StoreProductShare','Account_Sales_Performance__Share'}; //list of strings with my object names 
}
    //execute method to compare the account team and share record
Public void execute(Database.BatchableContext ctx, list<string> lstsObjectName) {
    String rocause='Account_Team__c';
    String rocau='Manual';
    //Lists intialization to final delete records. 
    List<Meet_Comp__Share> delmetcmpshare = new List<Meet_Comp__Share>();
    List<Customer_Agreement__Share> delCagreeshare = new List<Customer_Agreement__Share>();
    List<Program_Request__Share> delPrshare = new List<Program_Request__Share>();
    List<StoreProductShare> delSpshare = new List<StoreProductShare>();
    List<Account_Sales_Performance__Share> delAspshare = new List<Account_Sales_Performance__Share>();
    
    Map<Id,List<Id>> accountIdWithUserIdMap = new Map<Id,List<Id>>(); //To store accountid and team userids
    
    List<AccountTeamMember> accTeamlist =  [select Id, AccountId, UserId from AccountTeamMember ];  
        For(AccountTeamMember atmlist: accTeamlist)
        {  
            if(accountIdWithUserIdMap.containsKey(atmlist.AccountId)){   // Check if accountteammembers has records 
                accountIdWithUserIdMap.get(atmlist.AccountId).add(atmlist.UserId);
            }
            else {
                //one accountid may have multiple team members so using userslist
                List<Id> userIds = new List<Id>();
                userIds.add(atmlist.UserId);
                accountIdWithUserIdMap.put(atmlist.AccountId,userIds);
            }
        }
     List<Meet_Comp__Share> mcs =[Select Id,UserOrGroupId,Parent.Account__c from Meet_Comp__Share where RowCause =: Rocause];
        For(Meet_Comp__Share  mcp : mcs)
        {  
            if(accountIdWithUserIdMap.get(mcp.Parent.Account__c) == null ){  //check if accountteam is empty for account is empty then delete if any share records
                delmetcmpshare.add(mcp);
            }
            else if(!accountIdWithUserIdMap.get(mcp.Parent.Account__c).contains(mcp.UserOrGroupId)) //check if user is not part of account team
            {
                delmetcmpshare.add(mcp);
            }    
            
        }
       delete delmetcmpshare;
 
 List<Customer_Agreement__Share> cas =[Select Id,UserOrGroupId,Parent.Account_Name__c  from Customer_Agreement__Share where RowCause =: Rocause];
      For(Customer_Agreement__Share  cashr : cas)
        {  
            if(accountIdWithUserIdMap.get(cashr.Parent.Account_Name__c) == null ){
                delCagreeshare.add(cashr);
            }
            else if(!accountIdWithUserIdMap.get(cashr.Parent.Account_Name__c).contains(cashr.UserOrGroupId))
            {
                delCagreeshare.add(cashr);
            }    
            
        }
       delete delCagreeshare;
    
 List<Program_Request__Share> prs =[Select Id,UserOrGroupId,Parent.Account__c  from Program_Request__Share where RowCause =: Rocause];
        For(Program_Request__Share prp  : prs)
        {  
            if(accountIdWithUserIdMap.get(Prp.Parent.Account__c) == null ){
                delPrshare.add(Prp);
            }
            else if(!accountIdWithUserIdMap.get(prp.Parent.Account__c).contains(prp.UserOrGroupId))
            {
                delPrshare.add(prp);
            }    
            
        }
       delete delPrshare;
   
 List<StoreProductShare> sps =[Select Id,UserOrGroupId,Parent.Account__c from StoreProductShare where RowCause =: Rocau];
        For(StoreProductShare  spshr : sps)
        {  
            if(accountIdWithUserIdMap.get(spshr.Parent.Account__c) == null ){
                delSpshare.add(spshr);
            }
            else if(!accountIdWithUserIdMap.get(spshr.Parent.Account__c).contains(spshr.UserOrGroupId))
            {
                delSpshare.add(spshr);
            }    
            
        }
       delete delSpshare;
    
    List<Account_Sales_Performance__Share> asp =[Select Id,UserOrGroupId,Parent.Account__c from Account_Sales_Performance__Share where RowCause =: Rocause];
        For(Account_Sales_Performance__Share  asps : asp)
        {  
            if(accountIdWithUserIdMap.get(asps.Parent.Account__c) == null ){
                delAspshare.add(asps);
            }
            else if(!accountIdWithUserIdMap.get(asps.Parent.Account__c).contains(asps.UserOrGroupId))
            {
                delAspshare.add(asps);
            }    
  
        }
       delete delAspshare; 
}  
    // Method if any actions need to be perfomed
Public void finish(Database.BatchableContext ctx) {
    }   
    }