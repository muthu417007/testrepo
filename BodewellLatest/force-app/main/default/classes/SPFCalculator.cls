/* Below class used by the SPFFieldUpdate trigger internally.
    
    1) loadSpfInitials()--
    2) loadHeatGainNOutdoorTemp(List<Seasonal_Performance_Factor__c> spfList)
    3) loadHeatGainNOutdoorTemp(List<Seasonal_Performance_Factor__c> spfNew, List<Seasonal_Performance_Factor__c> spfOld)
    4) deleteOldSPFCalc(Set<Id> ids)    
    5) deleteOldSPF_HPCalc(Set<Id> ids)
    6) calculateSPF(List<Seasonal_Performance_Factor__c> spfList)
    7) calculateSPF(List<Seasonal_Performance_Factor__c> spfList, Double indoorTemp)
    8) calcIndoorSummary(List<Seasonal_Performance_Factor__c> spfList, Double indoorTemp)
    9) calcEstCoolKWH(List<Seasonal_Performance_Factor__c> spfList)
    10) calculate_65_75_etc(List<Seasonal_Performance_Factor__c> spfList)
    11) generatePayBack(List<Seasonal_Performance_Factor__c> spfList)
    12) getSPFList(List<Seasonal_Performance_Factor__c> spfList, Integer field)
    13) getMaps(Set<String> inputList, boolean isCSMap)
    14) calTempHeat(double cop, double tempheatpmpkwh, double PTAC)
    15) getSPFScale(Decimal val)
    16) loadBintemp()
    17) getStartBinNum(Integer id_temp)

*/
public class SPFCalculator {   

    public static Map<String,Decimal> StateCityMap = new Map<String,Decimal>();
    public static Map<String,Decimal> modelMap = new Map<String,Decimal>();
    public static Map<String,Decimal> modelMapOther = new Map<String,Decimal>();
    public static Map<Integer,Integer> spfIndexes = new Map<Integer,Integer>();
    public static List<Integer> spfValues = new List<Integer>();
    
    public static final Integer MODEL=0;
    public static final Integer STATE_CITY=1;

    public static boolean Rflag=true;


    //SPFCalculator preloads the spf indexs, model MANUFACTURER__c,NOM_COOL_CAPACITY_BTU__c,ACT_COOL_CAPACITY_BTU__c and state_city information.
    public static void loadSpfInitials(){
        if(StateCityMap==null || StateCityMap.size()==0){
        for(City_and_State_Information__c csi :[select CITY_STATE__c,HEAT_DESIGN_TEMP__c from City_and_State_Information__c LIMIT 400])
            StateCityMap.put(csi.CITY_STATE__c,csi.HEAT_DESIGN_TEMP__c);
        }
        
        if(modelMap==null || modelMap.size()==0){
        for(Model_Number__c mb :[select MODEL_NUM__c,MANUFACTURER__c,NOM_COOL_CAPACITY_BTU__c,ACT_COOL_CAPACITY_BTU__c from Model_Number__c LIMIT 400])
        {
            modelMap.put(mb.MANUFACTURER__c+'-'+mb.MODEL_NUM__c,mb.NOM_COOL_CAPACITY_BTU__c);
            modelMapOther.put(mb.MANUFACTURER__c+'-'+mb.MODEL_NUM__c,mb.ACT_COOL_CAPACITY_BTU__c);
        }  
        }
        spfValues = loadBintemp();
        Integer index=1;
        for(Integer val: spfValues)
            spfIndexes.put(val, index++);
    }

    //isBeforeInsert - invoked before inserting a SPF record.
    public static void loadHeatGainNOutdoorTemp(List<Seasonal_Performance_Factor__c> spfList){
        for (Seasonal_Performance_Factor__c spf: spfList){ 
            if(spf.Out_Door_design_Temperature__c==null)
                spf.Out_Door_design_Temperature__c =StateCityMap.get(spf.City_and_state__c);
            if(spf.Heat_gain_btuh__c==null)
                spf.Heat_gain_btuh__c=modelMapOther.get(spf.Model_Number__c);
            spf.NOM_COOL_CAPACITY_BTU__c=modelMap.get(spf.Model_Number__c);

            if(spf.Heat_Loss__c==null)
                calHeatLoss(spf);
        }
    }

    // This method is called before update to preload the out door design temp, heat_gain_btu and calculate the heat gain metric.       
    public static void loadHeatGainNOutdoorTemp(List<Seasonal_Performance_Factor__c> spfNew, List<Seasonal_Performance_Factor__c> spfOld){
        for (Seasonal_Performance_Factor__c spf: spfNew){ 
            for(Seasonal_Performance_Factor__c spff: spfOld)
            {
                if(spf.City_and_state__c!=spff.City_and_state__c)
                    spf.Out_Door_design_Temperature__c =StateCityMap.get(spf.City_and_state__c);
                if(spf.Model_Number__c!=spff.Model_Number__c)
                    spf.Heat_gain_btuh__c=modelMap.get(spf.Model_Number__c);
                    
                    if(spf.Heat_Loss__c==null || spf.Heat_Loss__c==0)
                    calHeatLoss(spf);
            }
        }   
    }
    //delete the old SPF calculations on update operation.
    public static void deleteOldSPFCalc(Set<Id> ids){
        List <SPFCalculation__c> delList = [select id from SPFCalculation__c where SPF__c in :ids];
            delete delList;
    }
    
    
    //Find and delete all PDFs associated to the SPFs
    public static void deleteOldSPFPDFs(List<Seasonal_Performance_Factor__c> spfs){
         for (Seasonal_Performance_Factor__c spf: spfs){ 
             if (!spf.Emailed_PDF__c) {      
                    List<Attachment> spfPDFs= [SELECT Id FROM Attachment WHERE ContentType='application/pdf' and ParentId=:spf.Id];
                    delete spfPDFs;
             }
          }
    }

    //delete the old Heatpump calculations on update operation.
    public static void deleteOldSPF_HPCalc(Set<Id> ids){
        List <Heat_Pump_Payback_Analysis__c> delList = [select id from Heat_Pump_Payback_Analysis__c where SPF_Calculations__c in :ids];
            delete delList;
    }

    //  calculateSPF -  Does the calculations based on the inputted Indoor temparature      
    public static void calculateSPF(List<Seasonal_Performance_Factor__c> spfList){
        insert calcIndoorSummary(spfList,null);
    }
    //before insert calculate this.
    public static void calculateSPF(List<Seasonal_Performance_Factor__c> spfList, Double indoorTemp){
        double total_PTAC=0;
        double total_HPKW=0;

        List<SPFCalculation__c> spfCalList = calcIndoorSummary(spfList,indoorTemp);
        for(SPFCalculation__c spfCal : spfCalList ){
            total_PTAC +=spfCal.PTAC_Resistance_Heating_KWH__c;
            total_HPKW+=spfCal.Heat_Pump_Kwh__c;
        }

        for(Seasonal_Performance_Factor__c spf: spfList)
        {
            if(indoorTemp==null){
                spf.Energy_For_Heating_HDN__c=Math.round(total_PTAC);
                spf.Energy_For_Heating_KiloWatt_Hrs_HDN__c=Math.round(total_HPKW);
            }
            else if(indoorTemp==65){
                spf.Annual_KWH_Required_For_Resistance_Ht65F__c=Math.round(total_PTAC);
                spf.Annual_KWH_Required_For_Heat_Pump_Sys65F__c=Math.round(total_HPKW);
            }else if(indoorTemp==75){
                spf.Annual_KWH_Required_For_Resistance_Ht75F__c=Math.round(total_PTAC);
                spf.Annual_KWH_Required_For_Heat_Pump_Sys75F__c=Math.round(total_HPKW);
            }else{
                spf.Annual_KWH_Required_For_Resistance_Ht70F__c=Math.round(total_PTAC);
                spf.Annual_KWH_Required_For_Heat_Pump_Sys70F__c=Math.round(total_HPKW);
            }
        }
    }
    //calcIndoorSummary -  calculates the SPF based on the indoor temparature
    public static List <SPFCalculation__c> calcIndoorSummary(List<Seasonal_Performance_Factor__c> spfList, Double indoorTemp){
        List <SPFCalculation__c> Calc = new List <SPFCalculation__c>();
        Map<String, sObject> cSMap = getMaps(getSPFList(spfList,SPFCalculator.STATE_CITY),true);
        Map<String, sObject> mdlMap = getMaps(getSPFList(spfList,SPFCalculator.MODEL),false);
        
        for(Seasonal_Performance_Factor__c spfc: spfList)
        {
            if(spfc.Indoor_Design_Temperature__c != null) {     
                List<Integer> spfScale = getSPFScale(indoorTemp==null?spfc.Indoor_Design_Temperature__c:indoorTemp);
                if(spfScale != null) {
                    //sort the spf scale by ascending order
                    spfScale.sort();
                    for(Integer intg : spfScale) 
                    {
                        Integer iIndex=spfIndexes.get(intg);
                        City_and_State_Information__c cs = (City_and_State_Information__c)cSMap.get(spfc.City_and_state__c);
                        Model_Number__c mdl=(Model_Number__c)mdlMap.get(spfc.Model_Number__c.split('-')[1]);
                        if(cs!=null  && mdl!=null )
                        {
                            double cap = double.valueOf(mdl.get('CAPACITY' + iIndex + '__c'));
                            double cop = double.valueOf(mdl.get('COEFF' + iIndex + '__c'));
                            double binhrs = integer.valueOf(cs.get('BIN_HOURS' + iIndex + '__c'));

                            double tempaddheat=0.0;
                            double tempheatpmpkwh=0.0;
                            double heat_loss=0.0;
                            double PTAC=0.0;
                    
                        try{
                            //if(spfc.Indoor_Design_Temperature__c!=null && spfc.Indoor_Design_Temperature__c!=0 && indoorTemp!=0 && Spfc.Out_Door_design_Temperature__c !=null && Spfc.Out_Door_design_Temperature__c!=0 && intg!=0)
                            heat_loss = (Spfc.Heat_Loss__c  /  ((indoorTemp==null?spfc.Indoor_Design_Temperature__c:indoorTemp) - Spfc.Out_Door_design_Temperature__c )) * ((indoorTemp==null?spfc.Indoor_Design_Temperature__c:indoorTemp)-5- intg );
                                
                            //if(heat_loss!=0 && binhrs!=0)
                                PTAC = (heat_loss  * binhrs) / 1000.00;

                            tempheatpmpkwh = calTempHeat(cop,tempheatpmpkwh,PTAC);

                            if(Spfc.Use_Heat_Pump_Balance_Point__c!=null && Spfc.Use_Heat_Pump_Balance_Point__c==true){
                                double heatpump_cap_watts;
                                double tempcop;
                                double hp_energy_in;

                                if(cap!=0)
                                {
                                    heatpump_cap_watts = cap/3.412;
                                    if(heatpump_cap_watts < heat_loss)
                                    {
                                        tempaddheat =  heat_loss - heatpump_cap_watts;
                                        hp_energy_in = heatpump_cap_watts / cop;
                                        tempcop  = heat_loss/ (hp_energy_in + tempaddheat);
                                        cop = tempcop;
                                    }
                                }///end of if
                                tempheatpmpkwh = calTempHeat(cop,tempheatpmpkwh,PTAC);
                            }   
                            
                        }catch(Exception e){System.debug(e.getMessage());}
                        
                        if(binhrs==0){
                             PTAC=0;
                             tempaddheat=0;
                             cop=0;
                             tempheatpmpkwh=0;
                        }
                           Calc.add( new SPFCalculation__c(SPF__c=Spfc.ID,Outdoor_Temp__c=intg,Heating_Hours__c=binhrs, PTAC_Resistance_Heating_KWH__c=Math.round(PTAC),Additional_Heat_Required_Heat_Hr_Watts__c=tempaddheat, Coefficient_of_Performance__c=cop,Heat_Pump_Kwh__c=Math.round(tempheatpmpkwh)));
                        }
                    }
                }
            }
        }
        return  Calc;
    }
    
        //calcEstCoolKWH - calculates teh estimated cool KWH
    public static void calcEstCoolKWH(List<Seasonal_Performance_Factor__c> spfList){
        double ratio,est_cool_kwh=0;
        Map<String, sObject> cSMap = getMaps(getSPFList(spfList,SPFCalculator.STATE_CITY),true);
        Map<String, sObject> mdlMap = getMaps(getSPFList(spfList,SPFCalculator.MODEL),false);
        
        for(Seasonal_Performance_Factor__c spfc: spfList)
        {
            double hoursabovehours=0;
            City_and_State_Information__c cs = (City_and_State_Information__c)cSMap.get(spfc.City_and_state__c);
            Model_Number__c mdl=(Model_Number__c)mdlMap.get(spfc.Model_Number__c.split('-')[1]);
            if(cs!= null)
            {
                Integer start;
                double hours_above_temp= spfc.Hours_Above_75_70_or_80__c;
                if(hours_above_temp==70)
                    start=getStartBinNum(70); 
                else if(hours_above_temp==75)
                    start=getStartBinNum(75);
                else
                    start=getStartBinNum(80);

                for(Integer intg=1; intg<=start; intg++) 
                    hoursabovehours += Double.valueOf(cs.get('BIN_HOURS' + intg + '__c'));
            }
            spfc.Hours_Above_70F_75F_80F__c=spfc.Hours_Above_75_70_or_80__c;
            if(mdl!=null && mdl.ACT_COOL_CAPACITY_BTU__c!=null && mdl.ACT_COOL_CAPACITY_BTU__c!=0 && spfc.Heat_gain_BTUH__c!=null ){
                ratio = spfc.Heat_gain_BTUH__c/mdl.ACT_COOL_CAPACITY_BTU__c;
                est_cool_kwh = (ratio * mdl.COOL_WATTS__c/1000)* (hoursabovehours);
            }
            spfc.est_cool_kwh__c=est_cool_kwh;
        }
    }

    //calculate_65_75_etc  - Calculates the 65/75/70 or dynamic Indoor Temparature related SPF.
    public static void calculate_65_75_etc(List<Seasonal_Performance_Factor__c> spfList){
        calculateSPF(spfList,  65);
        calculateSPF(spfList,  75);
        double id_temp_3rdcol;

        for(Seasonal_Performance_Factor__c spfc: spfList)
        {
            double l_indoorTemp=spfc.Indoor_Design_Temperature__c;
            if(l_indoorTemp != null && (l_indoorTemp== 65 || l_indoorTemp== 75  )) 
                id_temp_3rdcol = 70;
            else
                id_temp_3rdcol = l_indoorTemp;
        }       
        calculateSPF(spfList,  id_temp_3rdcol);

        for(Seasonal_Performance_Factor__c spf: spfList)
        {
            spf.Energy_For_Cooling_HDN__c=spf.est_cool_kwh__c;
            spf.Energy_For_Cooling_KiloWatt_Hrs_HDN__c=spf.est_cool_kwh__c;

            if(spf.est_cool_kwh__c!=null && spf.Annual_KWH_Required_For_Resistance_Ht70F__c!=null && ((spf.est_cool_kwh__c + spf.Annual_KWH_Required_For_Resistance_Ht70F__c)>0))
                spf.Energy_For_Cooling_PTAC_HDN__c=(spf.est_cool_kwh__c/(spf.est_cool_kwh__c + spf.Annual_KWH_Required_For_Resistance_Ht70F__c));

            if(spf.est_cool_kwh__c!=null && spf.Annual_KWH_Required_For_Heat_Pump_Sys70F__c!=null && ((spf.est_cool_kwh__c + spf.Annual_KWH_Required_For_Heat_Pump_Sys70F__c)>0))
                spf.Energy_For_Cooling_PTHP_HDN__c=(spf.est_cool_kwh__c/(spf.est_cool_kwh__c + spf.Annual_KWH_Required_For_Heat_Pump_Sys70F__c));

            if(spf.est_cool_kwh__c!=null && spf.Annual_KWH_Required_For_Resistance_Ht70F__c!=null && ((spf.est_cool_kwh__c + spf.Annual_KWH_Required_For_Resistance_Ht70F__c)>0))
                spf.Energy_For_Heating_PTAC_HDN__c=(spf.Annual_KWH_Required_For_Resistance_Ht70F__c/(spf.Annual_KWH_Required_For_Resistance_Ht70F__c+spf.est_cool_kwh__c));

            if(spf.est_cool_kwh__c!=null && spf.Annual_KWH_Required_For_Heat_Pump_Sys70F__c!=null && ((spf.est_cool_kwh__c + spf.Annual_KWH_Required_For_Heat_Pump_Sys70F__c)>0))
                spf.Energy_For_Heating_PTHP_HDN__c=(spf.Annual_KWH_Required_For_Heat_Pump_Sys70F__c/(spf.Annual_KWH_Required_For_Heat_Pump_Sys70F__c+ spf.est_cool_kwh__c));

            spf.X3rd_Temparature_HDN__c=id_temp_3rdcol;
        }
        calculateSPF(spfList,  null);
    }

    //1. generated the heat pump payback metric and inserts into the related list.  
    public static void generatePayBack(List<Seasonal_Performance_Factor__c> spfList)
    {
        Integer utility_cost_start=6,utility_cost_end=16;// utility cost is hardcoded i.e payback report is done for 6 cents to 15 cents.
        double utility_cost;
        List <Heat_Pump_Payback_Analysis__c> HPList = new List <Heat_Pump_Payback_Analysis__c>();
        boolean isElecCostGreater=false;

        for(Seasonal_Performance_Factor__c spf: spfList)
        {
            if(spf.Calculate_PayBack__c==false)
                break;
            if(spf.Electricity_cost_per_KWH_in_cents__c > 0)
                isElecCostGreater=true;

            for(Integer i=utility_cost_start;i<=utility_cost_end;i++)
            {
                utility_cost = i/100.0; //converting into $dolors

                if(i==16 && isElecCostGreater)
                    utility_cost = (spf.Electricity_cost_per_KWH_in_cents__c==null?0:spf.Electricity_cost_per_KWH_in_cents__c)/100.0;

                double Total_Annual_Cost_Resistance_Heat=0; 
                double Total_Annual_Cost_Heat_Pump=0;
                double Annual_Savings_With_Heat_Pump=0;
                double Years_for_Payback=0; 
                
                
                try{
                    Total_Annual_Cost_Resistance_Heat=(utility_cost * (spf.est_cool_kwh__c+spf.Annual_KWH_Required_For_Resistance_Ht70F__c));
                    Total_Annual_Cost_Heat_Pump=(utility_cost * (spf.est_cool_kwh__c+spf.Annual_KWH_Required_For_Heat_Pump_Sys70F__c));
                    Annual_Savings_With_Heat_Pump=(utility_cost * (spf.Annual_KWH_Required_For_Resistance_Ht70F__c-spf.Annual_KWH_Required_For_Heat_Pump_Sys70F__c));
                    Years_for_Payback=(((spf.Heat_Pump_initial_cost_over_resist_heat__c==null?0:spf.Heat_Pump_initial_cost_over_resist_heat__c)+(spf.Drain_line_Installation_Cost__c==null?0:spf.Drain_line_Installation_Cost__c))/(utility_cost * (spf.Annual_KWH_Required_For_Resistance_Ht70F__c-spf.Annual_KWH_Required_For_Heat_Pump_Sys70F__c))); 
                }catch(Exception e){
                    System.debug('Calculation ERROR at Heat Pump Payback Analysis '); 
                }

                HPList.add( new Heat_Pump_Payback_Analysis__c(
                        SPF_Calculations__c=spf.ID,
                        Utility_Cost_Per_KWHR__c=utility_cost,
                        Total_Annual_Cost_Resistance_Heat__c=Total_Annual_Cost_Resistance_Heat, 
                        Total_Annual_Cost_Heat_Pump__c=Total_Annual_Cost_Heat_Pump,
                        Annual_Savings_With_Heat_Pump__c=Annual_Savings_With_Heat_Pump,
                        Years_for_Payback__c=Years_for_Payback));
            }
        }

        if(!isElecCostGreater && HPList.size()>0)
            HPList.remove(HPList.size()-1);
        insert HPList;
    }
    
    public static Set<String> getSPFList(List<Seasonal_Performance_Factor__c> spfList, Integer field){      
        Set<String> mdlSet = new Set<String>();
        if(field==SPFCalculator.MODEL){
            for(Seasonal_Performance_Factor__c spfc: spfList){
                mdlSet.add(spfc.Model_Number__c.split('-')[1]);
            }
        }else if(field==SPFCalculator.STATE_CITY){
            for(Seasonal_Performance_Factor__c spfc: spfList)
                mdlSet.add(spfc.City_and_state__c);
        }
        return mdlSet;
    }
    
    
    
    public static Map<String, sObject> getMaps(Set<String> inputList, boolean isCSMap){
        Map<String, sObject> csMap = new Map<String, sObject>();
        
        if(isCSMap){
        for(City_and_State_Information__c cs: [SELECT CITY_STATE__c, BIN_HOURS1__c,BIN_HOURS2__c,BIN_HOURS3__c,BIN_HOURS4__c,BIN_HOURS5__c,BIN_HOURS6__c,BIN_HOURS7__c,BIN_HOURS8__c,BIN_HOURS9__c,BIN_HOURS10__c,BIN_HOURS11__c,BIN_HOURS12__c,BIN_HOURS13__c,BIN_HOURS14__c,BIN_HOURS15__c,BIN_HOURS16__c,BIN_HOURS17__c,BIN_HOURS18__c,BIN_HOURS19__c,BIN_HOURS20__c,BIN_HOURS21__c,BIN_HOURS22__c,BIN_HOURS23__c,BIN_HOURS24__c,BIN_HOURS25__c,BIN_HOURS26__c,BIN_HOURS27__c,BIN_HOURS28__c,BIN_HOURS29__c,BIN_HOURS30__c,BIN_HOURS31__c FROM City_and_State_Information__c WHERE CITY_STATE__c IN :inputList])
        csMap.put(cs.CITY_STATE__c, cs);
        }else{
            for(Model_Number__c mdl: [SELECT MODEL_NUM__c, ACT_COOL_CAPACITY_BTU__c,COOL_WATTS__c, COEFF1__c,COEFF2__c,COEFF3__c,COEFF4__c,COEFF5__c,COEFF6__c,COEFF7__c,COEFF8__c,COEFF9__c,COEFF10__c,COEFF11__c,COEFF12__c,COEFF13__c,COEFF14__c,COEFF15__c,COEFF16__c,COEFF17__c,COEFF18__c,COEFF19__c,COEFF20__c,COEFF21__c,COEFF22__c,COEFF23__c,COEFF24__c,COEFF25__c,COEFF26__c,COEFF27__c,COEFF28__c,COEFF29__c,COEFF30__c,COEFF31__c, CAPACITY1__c,CAPACITY2__c,CAPACITY3__c,CAPACITY4__c,CAPACITY5__c,CAPACITY6__c,CAPACITY7__c,CAPACITY8__c,CAPACITY9__c,CAPACITY10__c,CAPACITY11__c,CAPACITY12__c,CAPACITY13__c,CAPACITY14__c,CAPACITY15__c,CAPACITY16__c,CAPACITY17__c,CAPACITY18__c,CAPACITY19__c,CAPACITY20__c,CAPACITY21__c,CAPACITY22__c,CAPACITY23__c,CAPACITY24__c,CAPACITY25__c,CAPACITY26__c,CAPACITY27__c,CAPACITY28__c,CAPACITY29__c,CAPACITY30__c,CAPACITY31__c  FROM Model_Number__c WHERE MODEL_NUM__c IN :inputList])
        csMap.put(mdl.MODEL_NUM__c, mdl);
        }
        return csMap;
    }
    //This method calculates the temp heat.
    public static Double calTempHeat(double cop, double tempheatpmpkwh, double PTAC){
        if(cop>= 1.0)
            return tempheatpmpkwh=PTAC / cop;
        else if (cop< 1.0 && cop > 0.0)
            return tempheatpmpkwh = PTAC;
        else return 0;
    }

    //This method calculates the heat gain.
    public static void calHeatLoss(Seasonal_Performance_Factor__c spf)
    {
        if(spf!=null)
        {
            IF(spf.NOM_COOL_CAPACITY_BTU__c==6000)
            spf.Heat_Loss_Multiplier_HDN__c=19.482;
            else IF(spf.NOM_COOL_CAPACITY_BTU__c==7000)
            spf.Heat_Loss_Multiplier_HDN__c=21.76;
            else IF(spf.NOM_COOL_CAPACITY_BTU__c==9000)
            spf.Heat_Loss_Multiplier_HDN__c=36.72;
            else IF(spf.NOM_COOL_CAPACITY_BTU__c==12000)
            spf.Heat_Loss_Multiplier_HDN__c=47.26;
            else IF(spf.NOM_COOL_CAPACITY_BTU__c==14000)
            spf.Heat_Loss_Multiplier_HDN__c=56.015;
            else IF(spf.NOM_COOL_CAPACITY_BTU__c==15000)
            spf.Heat_Loss_Multiplier_HDN__c=61.3275;
            else IF(spf.NOM_COOL_CAPACITY_BTU__c==18000)
            spf.Heat_Loss_Multiplier_HDN__c=73;
            else
            spf.Heat_Loss_Multiplier_HDN__c=0;

            If(spf.Indoor_Design_Temperature__c!=null && spf.Out_Door_design_Temperature__c!=null)
            spf.Heat_Loss__c =spf.Heat_Loss_Multiplier_HDN__c * (spf.Indoor_Design_Temperature__c - spf.Out_Door_design_Temperature__c ); 
        }
    }

    // This method gives the SPF scale from an index. 
    public static List<Integer> getSPFScale(Decimal val) {
        List<Integer> setOutput = new List<Integer>();
        for(Integer spfVal :spfValues) {
            if(val > spfVal ) 
                setOutput.add(spfVal);
        }
        setOutput.remove(0);
        return setOutput;
    }

    // This method gives the SPF scale. 
    public  static List<Integer> loadBintemp()
    {
        Integer j = 117;
        List<Integer> bin_temp = new List<Integer>();
        j=117;
        for(Integer i=0 ;i<31;i++)
        {
            bin_temp.add(j);
            j=j-5;
        }
        return bin_temp;
    }   

    //getStartBinNum gets the index of the selected indoor temparature.
    public static Integer getStartBinNum(Integer id_temp)
    {
        Integer start_bin_num=1;
        while(spfValues[start_bin_num]> id_temp)
            start_bin_num ++; 
        return start_bin_num;
    }
}