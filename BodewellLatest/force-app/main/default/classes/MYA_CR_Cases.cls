/**
*@description : Class has been created to call cases from case Object created for MYA project.
Name: Kanishtika Gupta
Copyright: @ 2022 GE Appliances
**********************************************
Req: 
Task :- IDMSF-1059
**********************************************
Purpose: Class has been created to call cases from case Object created for MYA project.
**********************************************
History
---------------------------------------------
Version    Author    Date    Details
-------    -------    -------    -------
1.0      Kanishtika Gupta 02/08/2022   Created
**********************************************
**********************************************/
public class MYA_CR_Cases {
  @AuraEnabled(cacheable=true)
    public static List<Case> getCaseList() {
          return [SELECT Id, CaseNumber,ClosedDate,CreatedDate,Reason,Subject,OwnerId, Status, Origin, Priority FROM Case where Origin IN ('Web - Chat','WebToCase','Web') ORDER By CreatedDate desc];
        }
}