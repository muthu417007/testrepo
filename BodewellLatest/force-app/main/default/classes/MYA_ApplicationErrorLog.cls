/**
 * @author         Akhil Raj
 * @company        TCS
 * @created        27.06.2022
 * @description    For saving application errors while product registraion
 */
public without sharing class MYA_ApplicationErrorLog {
    // Application Error log
	@AuraEnabled( cacheable=false )  
    public static Boolean ErrorLog(
        String logCode, 
        String errorMessage, 
        String sourceClass, 
        String sourceFunction,
        String modelNumber,
        String serialNumber, 
        String installDate, 
        String name, 
        String lastName,
        String email,
        String phone,
        String street, 
        String city, 
        String state,
        String dataSourceCode
    ) {
        try
        {
            CX_ApplicationLog__c ApplicationLogObj = new CX_ApplicationLog__c(
                Debug_Level__c  = 'Error',
                Source__c = sourceClass,
                Source_Function__c = sourceFunction,
                Message__c = errorMessage,
                Log_Code__c = LogCode
            );
            insert ApplicationLogObj;  
                        
            WebConsumerInfo__c WebConsumerInfoObj = new WebConsumerInfo__c(
                Model_number__c  = modelNumber,
                Serial_Number__c = serialNumber,
                Install_date__c = date.parse(installDate),
                Name = name,
                Last_Name__c = lastName,
                Email_Address__c  = email,
                Phone_Number__c = phone,
                Billing_Street__c = street,
                Billing_City__c = city,
                Billing_State__c = state,
                Data_Source_Code__c = dataSourceCode,
                Application_Log__c = ApplicationLogObj.Id,
                Is_Error__c = true
            );
            insert WebConsumerInfoObj;
            return true;
        }
        catch (Exception e) {
            return false;
        }  
    }
    // Exception Handler 
    public static void Mya_ExHandler(Exception e,string sourceClass,string sourceFunction)
    { 
            CX_ApplicationLog__c ApplicationLogObj = new CX_ApplicationLog__c( 
                Debug_Level__c  = 'Error', 
                Source__c = sourceClass, 
                Source_Function__c = sourceFunction, 
                Message__c = String.valueOf(e) 
            ); 
            insert ApplicationLogObj; 
    }  
    // Custom Exception Handler 
    public static void Mya_CustomExHandler(String errorMessage,string sourceClass,string sourceFunction) 
    { 
            CX_ApplicationLog__c ApplicationLogObj = new CX_ApplicationLog__c( 
                Debug_Level__c  = 'Error', 
                Source__c = sourceClass, 
                Source_Function__c = sourceFunction, 
                Message__c = errorMessage 
            ); 
            insert ApplicationLogObj; 
    }  
}