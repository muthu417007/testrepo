/**
*@description : Class has been created to update primary phone flag true for already existing contact created for MYA project.
Name: Kanishtika Gupta
Copyright: @ 2022 GE Appliances
**********************************************
Req: 

**********************************************
Purpose: Class has been created to update primary phone flag true for already existing contact created for MYA project
**********************************************
History
---------------------------------------------
Version    Author    Date    Details
-------    -------    -------    -------
1.0      Kanishtika Gupta 22/09/2022   Created
**********************************************
**********************************************/
global class MYA_BatchPrimaryPhoneFlag Implements Database.batchable<sobject>,Database.stateful
{
    public integer recordCount = 0;
    String query;
    public MYA_BatchPrimaryPhoneFlag() 
    {
        if(Test.isRunningTest())
        {
            query = 'select id,Phone from contact where Phone != \'\' AND Phone_is_Primary__c = false Limit 1';
        }
        else
        {
            query = 'select id,Phone from contact where Phone != \'\' AND Phone_is_Primary__c = false';
        }
    }
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator(query);
    }
    public  void execute(Database.BatchableContext BC,List<Contact> con)
    {
        List<Contact> conlist = new List<Contact>();
        try
        {
            //Logic is wrong...you have to check if this phone no of this contact is promary phone number in ContatPoint object or not and accordigly you have to update flag on contact
            for(Contact c :con)
            {
               c.Phone_is_Primary__c = true;
               conlist.add(c);
            }
            Update conlist;
            recordCount = recordCount + con.size();
        }
        catch(Exception e)
        {
            system.debug(e.getMessage());
            //write error in Application log object
        }
    }
    global void finish(Database.BatchableContext bc)
    {
        System.debug(LoggingLevel.WARN,'Total Record Processed ' +recordCount);
    }  
}