//******************************************************************************************
//Name : BDW_CreateLead 
//Requirement : To Create Lead Records
//******************************************************************************************
//History
//	Version				Author					Date				Detail
//  1.0					Yogesh Sharma			11/23/2022			Initial
//******************************************************************************************
//@description : To Create Lead Records
public without sharing class BDW_CreateLead 
{
	//@description : To Create Lead Records
	@AuraEnabled
    public static Lead createLead(Lead leadRec) 
    {
        system.debug('acc'+leadRec);
        insert leadRec;
        return leadRec;
    }
}