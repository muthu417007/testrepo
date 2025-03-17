public class DeactivateInactiveUser {
    public static void deactivate()
    {	
        List<User> usersToUpdate = new List<User>();
        List<String> usersIds = new List<String>();
        List<String> profiles=new List<String>();
        for(Automated_Deactivate_Users_Profile__mdt adu:[select Label from Automated_Deactivate_Users_Profile__mdt])
        {
            profiles.add(adu.Label);
        }
        if(Test.isRunningTest()){
            User u=[Select Id, IsActive from User where UserName='TestTest1234@testDeactivateUser.com' and Profile.Name in :profiles];
            u.IsActive=false;
            usersToUpdate.add(u);
            usersIds.add(u.Id);
        }
        for(User u: [SELECT Id, Email, UserName, FirstName, LastName, LastLoginDate, IsActive FROM User where IsActive= true and LastLoginDate <= :DATE.TODAY()-32 and Profile.Name in :profiles])
        {	u.IsActive=false;
            usersToUpdate.add(u);
         	usersIds.add(u.Id);
        }  	
        if (usersToUpdate.size()>0)
        {	Database.update(usersToUpdate, false);
        }  
        getdetails(usersIds);
    }
    @future
    public static void getdetails(List<String> usersIds){
        List<User> userList = new List<User>();
        List<User> activeusers= new List<User>();
        for(User u: [SELECT Id, Email, UserName, FirstName, LastName, LastLoginDate, IsActive FROM User where Id in :usersIds])
        { 	if(u.IsActive){
         		activeusers.add(u);
        	}
         	else {
             	userList.add(u);
         	}
        }
        String updatedusers='<html><style>table{border-collapse: collapse;width: 100%; } th,td{ border: 2px solid green;padding: 15px;}</style><body><br>';
        if(userList.size()>0){
            updatedusers+= '<h3>List of users deacticated Today.</h3><br><br>';
            updatedusers=HTMLTable(updatedusers,userList);
        }
        else {
            updatedusers+= '<h3>No users are deactivated Today.</h3>';
        }
        if(activeusers.size()>0){
            updatedusers+= '<br><h3>Below users are not Deactivated due to high permissions.</h3><br>';
            updatedusers=HTMLTable(updatedusers,activeusers);
        }
        updatedusers+='</body></html>';
        List<String> Emails=new List<String>();
        for(Deactivate_Users_From_To_Mail__mdt email:[select FromMail__c,ToMail__c from Deactivate_Users_From_To_Mail__mdt])
        {	
            Emails.add(email.FromMail__c);
            Emails.add(email.ToMail__c);
        }
        
        SFDCUtil.sendHTMLEmail(new String[]{Emails[1]}, 'Deactivated Users Information', null, Emails[0], null, updatedusers);
             
    }
    public static String HTMLTable(String updatedusers,List<User> userList){
        updatedusers+='<table> <tr><th>FirstName</th><th>LastName</th><th>IsActive</th><th>UserName</th><th>LastLoginDate</th></tr>';
        for(User u:userList){
            updatedusers+= '<tr><td>'+u.FirstName+'</td><td>'+u.LastName+'</td><td>'+u.IsActive+'</td><td>'+u.UserName+'</td><td>'+u.LastLoginDate+'</td></tr>';
        }
        updatedusers+='</table>';
        return updatedusers;
    }

    
}