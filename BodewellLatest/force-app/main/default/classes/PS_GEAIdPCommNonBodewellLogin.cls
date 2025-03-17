public without sharing class PS_GEAIdPCommNonBodewellLogin 
{

    public static void nonBodewellLogin(String usersid, String loginUrl, User currentuser)
    {
        List<LoginHistory> LogFirstTime =[SELECT Id,LoginUrl FROM LoginHistory Where UserId=:usersid ORDER BY LoginTime ASC NULLS LAST LIMIT 1];
        System.debug('loginUrl - ' + loginUrl);
        
            if(!LogFirstTime.isEmpty())
            {
                String logurl=LogFirstTime[0].LoginUrl;
                if(!logurl.contains('bodewell') )
                { 
                    if(loginUrl.contains('bodewell'))
                    {                
                        try
                        {  
                            
                            String accid = currentuser.AccountId;
                            BWC_AssignBodewellCommercePermissions.MakeAsBuyerEnabled(accid,usersid);
                            
                        }
                        catch (Exception e) 
                        {
                            System.debug(e.getMessage());
                        }
                    } 
                }
            
            
            
        }
    }

}