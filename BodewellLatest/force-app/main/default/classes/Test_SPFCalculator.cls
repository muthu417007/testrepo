@isTest(seealldata=true)
private class Test_SPFCalculator   {
    static testMethod void positiveTest()
 {
   //Insert SPF Record
    Seasonal_Performance_Factor__c  sp = new  Seasonal_Performance_Factor__c(Job_Name__c = 'Testspf-fromWB2',Model_Number__c='GE-AZ61H07***',City_and_state__c='BIRMINGHAM, AL',Use_Heat_Pump_Balance_Point__c=True,Calculate_PayBack__c=True,Indoor_Design_Temperature__c=70,NOM_COOL_CAPACITY_BTU__c=7000,Out_Door_design_Temperature__c=70,Cooling_Cost_per_KWH_in_cents__c=7.50,Hours_Above_75_70_or_80__c=75,Heat_Pump_initial_cost_over_resist_heat__c=100,Electricity_cost_per_KWH_in_cents__c=0);
    insert sp;
    //Update SPF Record     
    sp.Model_Number__c='GE-AZ61H09***';
    sp.City_and_state__c='ENTERPRISE, AL';   
    sp.Hours_Above_75_70_or_80__c=70;
    sp.Indoor_Design_Temperature__c=100;
    sp.NOM_COOL_CAPACITY_BTU__c=9000;  
    update sp; 
 }
   static testMethod void positiveTestMoreValues()
 {
    //Insert SPF Record  
    Seasonal_Performance_Factor__c  sp = new  Seasonal_Performance_Factor__c(Job_Name__c = 'Testspf-fromWB2',Model_Number__c='GE-AZ61H07***',City_and_state__c='BIRMINGHAM,AL',Use_Heat_Pump_Balance_Point__c=False,Calculate_PayBack__c=False,Indoor_Design_Temperature__c=75,NOM_COOL_CAPACITY_BTU__c=12000,Out_Door_design_Temperature__c=70,Cooling_Cost_per_KWH_in_cents__c=7.50,Hours_Above_75_70_or_80__c=75,Heat_Pump_initial_cost_over_resist_heat__c=100,Drain_line_Installation_Cost__c=0);
    insert sp;
    //Update SPF Record  
    sp.Model_Number__c='GE-AZ61H07***';
    sp.City_and_state__c='ENTERPRISE, AL';
    sp.Indoor_Design_Temperature__c=90; 
    sp.Hours_Above_75_70_or_80__c=70;
    sp.Out_Door_design_Temperature__c=40;
    sp.Use_Heat_Pump_Balance_Point__c=True;
    sp.Calculate_PayBack__c=True;
    sp.Electricity_cost_per_KWH_in_cents__c=20;
    sp.NOM_COOL_CAPACITY_BTU__c=14000;
    Update sp;    
    }
    static testMethod void positveTestWithElectricCost()
 {
    // Insert SPF Record
    Seasonal_Performance_Factor__c  sp = new  Seasonal_Performance_Factor__c(Job_Name__c = 'Testspf-fromWB2',Model_Number__c='GE-AZ61H07***',City_and_state__c='BIRMINGHAM,AL',Use_Heat_Pump_Balance_Point__c=True,Calculate_PayBack__c=True,Indoor_Design_Temperature__c=70,NOM_COOL_CAPACITY_BTU__c=18000,Out_Door_design_Temperature__c=70,Cooling_Cost_per_KWH_in_cents__c=7.50,Hours_Above_75_70_or_80__c=75,Heat_Pump_initial_cost_over_resist_heat__c=100,Drain_line_Installation_Cost__c=0,Electricity_cost_per_KWH_in_cents__c=0);
    insert sp;   
    // Update SPF Record
    sp.Model_Number__c='GE-AZ61H07***';
    sp.City_and_state__c='ENTERPRISE, AL';
    sp.Indoor_Design_Temperature__c=100;
    sp.Hours_Above_75_70_or_80__c=80;
    sp.Electricity_cost_per_KWH_in_cents__c=20;
    sp.NOM_COOL_CAPACITY_BTU__c=6000;
    Update sp;  

 }
   static testMethod void NomcoolTest()
 {
   //Insert SPF Record
    Seasonal_Performance_Factor__c  sp = new  Seasonal_Performance_Factor__c(Job_Name__c = 'Testspf-fromWB2',Model_Number__c='GE-AZ61H07***',City_and_state__c='BIRMINGHAM,AL',Use_Heat_Pump_Balance_Point__c=True,Calculate_PayBack__c=True,Indoor_Design_Temperature__c=70,NOM_COOL_CAPACITY_BTU__c=6000,Out_Door_design_Temperature__c=70,Cooling_Cost_per_KWH_in_cents__c=7.50,Hours_Above_75_70_or_80__c=75,Heat_Pump_initial_cost_over_resist_heat__c=100,Drain_line_Installation_Cost__c=0,Electricity_cost_per_KWH_in_cents__c=0);
    insert sp;
    //Update SPF Record     
    sp.Model_Number__c='GE-AZ61H07***';
    sp.City_and_state__c='ENTERPRISE, AL';   
    sp.NOM_COOL_CAPACITY_BTU__c=18000;
    sp.Out_Door_design_Temperature__c=0;
    update sp; 

    // system.debug('Update*****' +sp.id);
          
 }
    static testMethod void NomcoolTest2()
 {
   //Insert SPF Record
    Seasonal_Performance_Factor__c  sp = new  Seasonal_Performance_Factor__c(Job_Name__c = 'Testspf-fromWB2',Model_Number__c='GE-AZ61H07***',City_and_state__c='BIRMINGHAM,AL',Use_Heat_Pump_Balance_Point__c=True,Calculate_PayBack__c=True,Indoor_Design_Temperature__c=70,NOM_COOL_CAPACITY_BTU__c=180,Out_Door_design_Temperature__c=70,Cooling_Cost_per_KWH_in_cents__c=7.50,Hours_Above_75_70_or_80__c=75,Heat_Pump_initial_cost_over_resist_heat__c=100,Drain_line_Installation_Cost__c=0,Electricity_cost_per_KWH_in_cents__c=0);
    insert sp;
    //system.debug('INse*****'+sp.Heat_Loss_Multiplier_HDN__c+sp);
    sp.Out_Door_design_Temperature__c=0;
    sp.NOM_COOL_CAPACITY_BTU__c=15000;
    update sp;
}
    static testMethod void NomcoolTest3()
 {
   //Insert SPF Record
    Seasonal_Performance_Factor__c  sp = new  Seasonal_Performance_Factor__c(Job_Name__c = 'Testspf-fromWB2',Model_Number__c='GE-AZ61H07***',City_and_state__c='BIRMINGHAM,AL',Use_Heat_Pump_Balance_Point__c=True,Calculate_PayBack__c=True,Indoor_Design_Temperature__c=70,NOM_COOL_CAPACITY_BTU__c=6000,Out_Door_design_Temperature__c=70,Cooling_Cost_per_KWH_in_cents__c=7.50,Hours_Above_75_70_or_80__c=75,Heat_Pump_initial_cost_over_resist_heat__c=100,Drain_line_Installation_Cost__c=0,Electricity_cost_per_KWH_in_cents__c=0);
    insert sp;
    //system.debug('INse*****'+sp.Heat_Loss_Multiplier_HDN__c+sp);
    sp.Out_Door_design_Temperature__c=0;
    sp.NOM_COOL_CAPACITY_BTU__c=14000;
    update sp;
    system.debug('INse*****'+sp.Heat_Loss_Multiplier_HDN__c+sp);
}
    static testMethod void NomcoolTest4()
 {
   //Insert SPF Record
    Seasonal_Performance_Factor__c  sp = new  Seasonal_Performance_Factor__c(Job_Name__c = 'Testspf-fromWB2',Model_Number__c='GE-AZ61H07***',City_and_state__c='BIRMINGHAM,AL',Use_Heat_Pump_Balance_Point__c=True,Calculate_PayBack__c=True,Indoor_Design_Temperature__c=70,NOM_COOL_CAPACITY_BTU__c=120,Out_Door_design_Temperature__c=70,Cooling_Cost_per_KWH_in_cents__c=7.50,Hours_Above_75_70_or_80__c=75,Heat_Pump_initial_cost_over_resist_heat__c=100,Drain_line_Installation_Cost__c=0,Electricity_cost_per_KWH_in_cents__c=0);
    insert sp;   
    sp.Out_Door_design_Temperature__c=0;
    sp.NOM_COOL_CAPACITY_BTU__c=12000;
    update sp;
    system.debug('INse*****'+sp.Heat_Loss_Multiplier_HDN__c+sp);
}
    static testMethod void OutdoorTempnull()
 {
   //Insert SPF Record without OutdoorTemp
    Seasonal_Performance_Factor__c  sp = new  Seasonal_Performance_Factor__c(Job_Name__c = 'Testspf-fromWB2',Model_Number__c='GE-AZ61H07***',City_and_state__c='BIRMINGHAM,AL',Use_Heat_Pump_Balance_Point__c=True,Calculate_PayBack__c=True,Indoor_Design_Temperature__c=70,NOM_COOL_CAPACITY_BTU__c=12000,Cooling_Cost_per_KWH_in_cents__c=7.50,Hours_Above_75_70_or_80__c=75,Heat_Pump_initial_cost_over_resist_heat__c=100,Drain_line_Installation_Cost__c=0,Electricity_cost_per_KWH_in_cents__c=0);
    insert sp;

}
static testMethod void NomcoolTest5()
 {
   //Insert SPF Record
    Seasonal_Performance_Factor__c  sp = new  Seasonal_Performance_Factor__c(Job_Name__c = 'Testspf-fromWB2',Model_Number__c='GE-AZ61H07***',City_and_state__c='BIRMINGHAM,AL',Use_Heat_Pump_Balance_Point__c=True,Calculate_PayBack__c=True,Indoor_Design_Temperature__c=70,NOM_COOL_CAPACITY_BTU__c=12000,Out_Door_design_Temperature__c=70,Cooling_Cost_per_KWH_in_cents__c=7.50,Hours_Above_75_70_or_80__c=75,Heat_Pump_initial_cost_over_resist_heat__c=100,Drain_line_Installation_Cost__c=0,Electricity_cost_per_KWH_in_cents__c=0);
    insert sp; 
    sp.NOM_COOL_CAPACITY_BTU__c=120;
    update sp;  
}
}