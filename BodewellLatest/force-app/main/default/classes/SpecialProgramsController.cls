public class SpecialProgramsController{
    Public Case c{get;set;}
    Public List<Special_Programs_and_Recalls__c> specialPrograms{get;set;}
    Public String message{get;set;}
    Public String programTitle{get;set;}
    Public String description{get;set;}
    Public String programType{get;set;}
    Public String testString{get;set;}

    public SpecialProgramsController(ApexPages.StandardController stdController) {
        this.c= (case)stdController.getRecord();
        
        testString = 'Program Type ' + '\\n' + 'Program Title';
        system.debug('c.id Value ' + c.id);
        //get asset model and serial number
        List<Case_Asset__c> assets = [SELECT ID,Asset__r.model_number__c,Asset__r.serialnumber
            FROM Case_Asset__c
            WHERE Case__c = :c.id];
        
        if(assets.size() == 0){
            return;
        }
        system.debug('assets ' + assets);
        if(assets.size() >0 && !string.isBlank(assets[0].Asset__r.serialnumber)){
            Integer modelLen = assets[0].Asset__r.model_number__c.length();
            if(modelLen > 4){ modelLen = 4;}
            String modelSearch = assets[0].Asset__r.model_number__c.subString(0,modelLen) + '%';
            String SerialSearch = assets[0].Asset__r.serialnumber.subString(0,2);
            system.debug('modelSearch ' + modelSearch);
            //get specialprograms based on date and model number
             specialPrograms = [SELECT ID, Description__c, Program_Title__c,Program_Type_Desc__c, Serial_Start_Alpha__c, Serial_End_Alpha__c, Model_Number__c, Serial_Number_Start__c, Serial_Number_End__c FROM Special_Programs_and_Recalls__c WHERE Program_Start_Date__c <= TODAY AND Program_Expiration_Date__c >= TODAY AND model_number__C like :modelSearch AND Serial_Start_Alpha__c like :SerialSearch LIMIT 500];
 				system.debug('sp ' + specialPrograms.size() + ' ' +  specialPrograms);
                List<Special_Programs_and_Recalls__c> modelNumbersMatch = new List<Special_Programs_and_Recalls__c>();
                if(specialPrograms != null && specialPrograms.size()> 0){
                    //find matching model numbers
                    for(Special_Programs_and_Recalls__c sp:specialPrograms){
                        
                        if(sp.Model_Number__c.length() > assets[0].Asset__r.model_number__c.length()){
                            continue;
                        }
                        if(sp.Model_Number__c == assets[0].Asset__r.model_number__c.subString(0,sp.Model_Number__c.length())){
                            modelNumbersMatch.add(sp);
                        }
                    }
                  system.debug('model match ' + modelNumbersMatch.size() + ' '   + modelNumbersMatch) ; 
                    if(modelNumbersMatch.size() == 0){
                        message = '';
                        programTitle = 'No Special Programs Found';
                        return;
                    }
                
                 
                    // process by serial numbers
                    //grab first to characters of serial number
                    String serial2 = assets[0].Asset__r.serialnumber.subString(0,2);
                    Integer serialNumeric;
                    //system.debug('AssetIsNumeric ' + assets[0].GEA_Asset__r.serial_number__c.subString(2,assets[0].GEA_Asset__r.serial_number__c.length()));
                    ////////////
                    Integer SerialLen = assets[0].Asset__r.serialnumber.length();
                    if(SerialLen > 7)
                    {
                        if(assets[0].Asset__r.serialnumber.subString(2,8).isNumeric()){
                     		serialNumeric = integer.valueOf(assets[0].Asset__r.serialnumber.subString(2,8));   
                    	} 
                        else 
                        {
                        	return;
                    	}
                    }
                    else
                    {
                        if(assets[0].Asset__r.serialnumber.subString(2,assets[0].Asset__r.serialnumber.length()).isNumeric()){
                     		serialNumeric = integer.valueOf(assets[0].Asset__r.serialnumber.subString(2,assets[0].Asset__r.serialnumber.length()));   
                    	} 
                        else 
                        {
                        	return;
                    	}
                    }
                    
                    ////////////
                    system.debug(' serial2 ' + serial2 + ' serialNumeric ' + serialNumeric);
                    List<Special_Programs_Full_Cycle__c > fullCycle = [SELECT Id, Sequence__c, MO_YR__c 
                                        FROM Special_Programs_Full_Cycle__c 
                                        order by sequence__c];
                 	//loop modelNumbersMatch
                 	List<Special_Programs_and_Recalls__c> firstSerialMatch = new List<Special_Programs_and_Recalls__c>();
                    Boolean startRec;
                    for(Special_Programs_and_Recalls__c sp:modelNumbersMatch){
                         //loop cyclej
                         startRec = false;
                         for(Special_Programs_Full_Cycle__c  fc:fullCycle){
                             
                             //find start  Serial_Start_Alpha__c,Serial_End_Alpha__c
                             system.debug('checking ' + fc.MO_YR__c + ' ' + sp.Serial_Start_Alpha__c);
                             if(fc.MO_YR__c == sp.Serial_Start_Alpha__c){
                             	startRec = true;
                                system.debug('found start ' + fc.MO_YR__c);
                             }
                             if(startRec){
                                 system.debug('check after start ' + fc.MO_YR__c + ' ' +  serial2);
                                 if(fc.MO_YR__c == serial2){
        							firstSerialMatch.add(sp);
                                 }
                             }
                             if(startRec && fc.MO_YR__c == sp.Serial_End_Alpha__c){
                             	break;    
                             }
                
                         }
                        system.debug('firstSerialMatch ' + firstSerialMatch.size() + ' ' + firstSerialMatch); 
                        if(firstSerialMatch.size() == 0){
                            message = '';
                            programTitle = 'No Special Programs Found';
                            return;
                        }
                        List<Special_Programs_and_Recalls__c> finalSerialMatch = new List<Special_Programs_and_Recalls__c>();
                        //Serial_Number_Start__c,Serial_Number_End__c,
                        for(Special_Programs_and_Recalls__c fsm:firstSerialMatch){
                            if(integer.valueOf(fsm.Serial_Number_Start__c.subString(2,fsm.Serial_Number_Start__c.length())) <=
                                         serialNumeric && 
                              integer.valueOf(fsm.Serial_Number_End__c.subString(2,fsm.Serial_Number_Start__c.length())) >=
                                         serialNumeric){
                             	finalSerialMatch.add(fsm);   
                            } 	   
                        }
                        if(finalSerialMatch.size() == 0){
                            message = '';
                            programTitle = 'No Special Programs Found';
                            return;
                        } else {
                            message = 'Ok';
                            programTitle= finalSerialMatch[0].Program_Title__c;
                            programTitle = programTitle.remove('\'');
                            description= finalSerialMatch[0].Description__c;
                            description = description.remove('\'');
                            programType = finalSerialMatch[0].Program_Type_Desc__c;
                            programType = programType.remove('\'');
                            system.debug(EncodingUtil.urlEncode(description, 'UTF-8'));
                            String test1 = EncodingUtil.urlEncode(description, 'UTF-8');
                            system.debug(test1.replaceAll('%0A','xxyyzz'));
                            description = EncodingUtil.urlDecode(test1.replaceAll('%0A','xxyyzz'), 'UTF-8');
                            description = description.replaceAll('xxyyzz',' ');
                            system.debug('desc ' + description);
                            //description = description.subString(0,150);
                        }
                     
                     } 
                } else {
                    message = '';
                    programTitle = 'No Special Programs Found';
                    description = '';
                    programType = '';
                }
             } else {
                 message = '';
                 programTitle = 'No Special Programs Found';
                 description = '';
                 programType = '';
             }
    }
}