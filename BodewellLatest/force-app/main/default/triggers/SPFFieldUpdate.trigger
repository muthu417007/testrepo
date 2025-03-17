//Below Trigger contains all the event driven logic to handle the SPF calculations.

trigger SPFFieldUpdate on Seasonal_Performance_Factor__c (Before Insert,Before Update,After Insert,After Update) { 
            SPFCalculator.loadSpfInitials();
        //1. Loads outdoor temp and heat gain
        //2. Calculates and loads SPF record with estimated cool KWH and hourse above BTUs.
        //3. Calculates annaual SPF for 65, 75 and selected indoor temparature loads these into SPF vaiables.  
        if(Trigger.isBefore && Trigger.isInsert){
            SPFCalculator.loadHeatGainNOutdoorTemp(trigger.new);
            SPFCalculator.calcEstCoolKWH(trigger.new);
            SPFCalculator.calculate_65_75_etc(trigger.new);
        }
        //1. Loads outdoor temp and heat gain
        //2. Calculates and loads SPF record with estimated cool KWH and hourse above BTUs.
        //3. Calculates annaual SPF for 65, 75 and selected indoor temparature loads these into SPF vaiables.  
       else if(Trigger.isBefore && Trigger.isUpdate){
            SPFCalculator.loadHeatGainNOutdoorTemp(trigger.new, trigger.old);
            SPFCalculator.calcEstCoolKWH(trigger.new);
            SPFCalculator.calculate_65_75_etc(trigger.new);
        }
    
        //1. After SPF record is created, create the selected indoor temparature related list records and insert those into SPFCalculation__c object.
        //2. Also calculate the Heat pump analysis metric and load those into the Heat pump related list.
       else if(Trigger.isAfter && Trigger.isInsert ){
            System.debug('<------------------COMIN HERE Trigger.isAfter && SPFCalculator.runOnce() && Trigger.isInsert---------->');
            SPFCalculator.calculateSPF(trigger.new);
            SPFCalculator.generatePayBack(trigger.new);
        }
        //1. After SPF record is updated delete the old related lists.
        //2. After SPF record is updated, create the selected indoor temparature related list records and insert those into SPFCalculation__c object.
        //3. Also calculate the Heat pump analysis metric and load those into the Heat pump related list.
       else if(Trigger.isAfter && Trigger.isUpdate ){
            System.debug('<------------------COMIN HERE Trigger.isAfter && SPFCalculator.runOnce()&& Trigger.isUpdate---------->');
            SPFCalculator.deleteOldSPFCalc(trigger.oldMap.keyset());
            SPFCalculator.deleteOldSPF_HPCalc(trigger.oldMap.keyset());
            SPFCalculator.deleteOldSPFPDFs(trigger.new);
            SPFCalculator.calculateSPF(trigger.new);
            SPFCalculator.generatePayBack(trigger.new);
        }
}