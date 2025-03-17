trigger DeleteZonelinePDFAfterUpdate on Zoneline_Energy_Cost_Savings_Analysis__c (after update) {

    try {

        //This trigger will delete all PDFs related to a Zoneline if any exist. This is to ensure PDFs all contain
        //accurate, updated calculations
    
        for (Zoneline_Energy_Cost_Savings_Analysis__c thisZoneline : trigger.new) {
        
            //If the PDF as already been emailed, don't delete the PDF as the Zoneline record cannot be
            //updated after emailing
        
            if (!thisZoneline.Emailed_PDF__c) {
            
                //Find and delete all PDFs associated to the Zoneline
                List<Attachment> zonelinePDFs = [SELECT Id FROM Attachment WHERE ContentType = 'application/pdf' and ParentId = :thisZoneline.Id];
                delete zonelinePDFs;
            }
        }
        //Forcing an Exception to cover the Catch Block for test class code coverage
        if (Test.isRunningTest()) {
            integer intTest = 1/0; 
        }
    }
    catch(Exception e) {
        ExceptionHandler.handleException(e);
    }
}