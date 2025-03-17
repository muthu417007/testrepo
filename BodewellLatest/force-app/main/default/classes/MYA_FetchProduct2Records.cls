//******************************************************************************************
//Name : MYA_FetchProduct2Records
//Requirement : To fetch Product2 Records
//******************************************************************************************
//History
//	Version				Author					Date				Detail
//  1.0					Yogesh Sharma			26/09/2023			Initial
//******************************************************************************************
//@description : Class to fetch Product2 Records.
public class MYA_FetchProduct2Records 
{
	//@description: Class to fetch Product2 Records by Manufacturing Model No.
	public static List<Product2> getProduct2ByManufacturingModelNo(String manufacturingModelNo)
    {       
	    return [SELECT Id, Is_Manufacturing_Model__c, Is_Finished_Good__c, StockKeepingUnit, Marketing_Model__r.StockKeepingUnit 
				FROM Product2 
                WHERE Is_Manufacturing_Model__c = 'YES' AND StockKeepingUnit =: manufacturingModelNo];
    }
    //@description: Class to fetch Product2 Records by Marketing Model No.
    public static List<Product2> getProduct2ByMarketingModelNo(String marketingModelNo)
    {       
	    return [SELECT Id, Is_Manufacturing_Model__c, Is_Finished_Good__c, StockKeepingUnit, Marketing_Model__r.StockKeepingUnit 
				FROM Product2 
                WHERE Is_Manufacturing_Model__c = 'YES' AND Marketing_Model__r.StockKeepingUnit =: marketingModelNo];
    }
}