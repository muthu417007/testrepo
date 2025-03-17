trigger TriggerDuctless on Ductless_product_registration__c (before insert) {
for(Ductless_product_registration__c a : Trigger.new) {
        System.debug('OUTPUT outdoor_unit_model__c =' + a.outdoor_unit_model__c);
        System.debug('OUTPUT outdoor_unit_serial__c =' + a.outdoor_unit_serial__c);
        //
        if(String.isNotBlank(a.outdoor_unit_model__c) && String.isNotEmpty(a.outdoor_unit_model__c))
        {
             Integer intCommaCount = getCharLength(a.outdoor_unit_model__c);
            System.debug('intCommaCount ' + intCommaCount);
            if (intCommaCount > 0)
            {
                System.debug('Not Zero');
                List<String> allModels = a.outdoor_unit_model__c.split(',');
                List<String> allSerials = a.outdoor_unit_serial__c.split(',');
                if (intCommaCount == 1)
                {
                    a.outdoor_unit_model__c = allModels[0];
                    a.outdoor_unit_serial__c = allSerials[0];
                    a.indoor_unit_1_model__c = allModels[1];
                    a.indoor_unit_1_serial__c = allSerials[1];
                }
                if (intCommaCount == 2)
                {
                    a.outdoor_unit_model__c = allModels[0];
                    a.outdoor_unit_serial__c = allSerials[0];
                    a.indoor_unit_1_model__c = allModels[1];
                    a.indoor_unit_1_serial__c = allSerials[1];
                    a.indoor_unit_2_model__c = allModels[2];
                    a.indoor_unit_2_serial__c = allSerials[2];
                }
                if (intCommaCount == 3)
                {
                    a.outdoor_unit_model__c = allModels[0];
                    a.outdoor_unit_serial__c = allSerials[0];
                    a.indoor_unit_1_model__c = allModels[1];
                    a.indoor_unit_1_serial__c = allSerials[1];
                    a.indoor_unit_2_model__c = allModels[2];
                    a.indoor_unit_2_serial__c = allSerials[2];
                    a.indoor_unit_3_model__c = allModels[3];
                    a.indoor_unit_3_serial__c = allSerials[3];
                }
                if (intCommaCount == 4)
                {
                    a.outdoor_unit_model__c = allModels[0];
                    a.outdoor_unit_serial__c = allSerials[0];
                    a.indoor_unit_1_model__c = allModels[1];
                    a.indoor_unit_1_serial__c = allSerials[1];
                    a.indoor_unit_2_model__c = allModels[2];
                    a.indoor_unit_2_serial__c = allSerials[2];
                    a.indoor_unit_3_model__c = allModels[3];
                    a.indoor_unit_3_serial__c = allSerials[3];
                    a.indoor_unit_4_model__c = allModels[4];
                    a.indoor_unit_4_serial__c = allSerials[4];
                }
                if (intCommaCount == 5)
                {
                    a.outdoor_unit_model__c = allModels[0];
                    a.outdoor_unit_serial__c = allSerials[0];
                    a.indoor_unit_1_model__c = allModels[1];
                    a.indoor_unit_1_serial__c = allSerials[1];
                    a.indoor_unit_2_model__c = allModels[2];
                    a.indoor_unit_2_serial__c = allSerials[2];
                    a.indoor_unit_3_model__c = allModels[3];
                    a.indoor_unit_3_serial__c = allSerials[3];
                    a.indoor_unit_4_model__c = allModels[4];
                    a.indoor_unit_4_serial__c = allSerials[4];
                    a.indoor_unit_5_model__c = allModels[5];
                    a.indoor_unit_5_serial__c = allSerials[5];
                }
                if (intCommaCount == 6)
                {
                    a.outdoor_unit_model__c = allModels[0];
                    a.outdoor_unit_serial__c = allSerials[0];
                    a.indoor_unit_1_model__c = allModels[1];
                    a.indoor_unit_1_serial__c = allSerials[1];
                    a.indoor_unit_2_model__c = allModels[2];
                    a.indoor_unit_2_serial__c = allSerials[2];
                    a.indoor_unit_3_model__c = allModels[3];
                    a.indoor_unit_3_serial__c = allSerials[3];
                    a.indoor_unit_4_model__c = allModels[4];
                    a.indoor_unit_4_serial__c = allSerials[4];
                    a.indoor_unit_5_model__c = allModels[5];
                    a.indoor_unit_5_serial__c = allSerials[5];
                    a.indoor_unit_6_model__c = allModels[6];
                    a.indoor_unit_6_serial__c = allSerials[6];

                }
                if (intCommaCount == 7)
                {
                    a.outdoor_unit_model__c = allModels[0];
                    a.outdoor_unit_serial__c = allSerials[0];
                    a.indoor_unit_1_model__c = allModels[1];
                    a.indoor_unit_1_serial__c = allSerials[1];
                    a.indoor_unit_2_model__c = allModels[2];
                    a.indoor_unit_2_serial__c = allSerials[2];
                    a.indoor_unit_3_model__c = allModels[3];
                    a.indoor_unit_3_serial__c = allSerials[3];
                    a.indoor_unit_4_model__c = allModels[4];
                    a.indoor_unit_4_serial__c = allSerials[4];
                    a.indoor_unit_5_model__c = allModels[5];
                    a.indoor_unit_5_serial__c = allSerials[5];
                    a.indoor_unit_6_model__c = allModels[6];
                    a.indoor_unit_6_serial__c = allSerials[6];
                    a.indoor_unit_7_model__c = allModels[7];
                    a.indoor_unit_7_serial__c = allSerials[7];

                }
                if (intCommaCount == 8)
                {
                    a.outdoor_unit_model__c = allModels[0];
                    a.outdoor_unit_serial__c = allSerials[0];
                    a.indoor_unit_1_model__c = allModels[1];
                    a.indoor_unit_1_serial__c = allSerials[1];
                    a.indoor_unit_2_model__c = allModels[2];
                    a.indoor_unit_2_serial__c = allSerials[2];
                    a.indoor_unit_3_model__c = allModels[3];
                    a.indoor_unit_3_serial__c = allSerials[3];
                    a.indoor_unit_4_model__c = allModels[4];
                    a.indoor_unit_4_serial__c = allSerials[4];
                    a.indoor_unit_5_model__c = allModels[5];
                    a.indoor_unit_5_serial__c = allSerials[5];
                    a.indoor_unit_6_model__c = allModels[6];
                    a.indoor_unit_6_serial__c = allSerials[6];
                    a.indoor_unit_7_model__c = allModels[7];
                    a.indoor_unit_7_serial__c = allSerials[7];
                    a.indoor_unit_8_model__c = allModels[8];
                    a.indoor_unit_8_serial__c = allSerials[8];

                }
                if (intCommaCount == 9)
                {
                    a.outdoor_unit_model__c = allModels[0];
                    a.outdoor_unit_serial__c = allSerials[0];
                    a.indoor_unit_1_model__c = allModels[1];
                    a.indoor_unit_1_serial__c = allSerials[1];
                    a.indoor_unit_2_model__c = allModels[2];
                    a.indoor_unit_2_serial__c = allSerials[2];
                    a.indoor_unit_3_model__c = allModels[3];
                    a.indoor_unit_3_serial__c = allSerials[3];
                    a.indoor_unit_4_model__c = allModels[4];
                    a.indoor_unit_4_serial__c = allSerials[4];
                    a.indoor_unit_5_model__c = allModels[5];
                    a.indoor_unit_5_serial__c = allSerials[5];
                    a.indoor_unit_6_model__c = allModels[6];
                    a.indoor_unit_6_serial__c = allSerials[6];
                    a.indoor_unit_7_model__c = allModels[7];
                    a.indoor_unit_7_serial__c = allSerials[7];
                    a.indoor_unit_8_model__c = allModels[8];
                    a.indoor_unit_8_serial__c = allSerials[8];
                    a.indoor_unit_9_model__c = allModels[9];
                    a.indoor_unit_9_serial__c = allSerials[9];
                }
            }
            else
            {
                System.debug('No additional Products found');
            }
        }
    }
    public Integer getCharLength(String input)
    {
        String validCharString = ',';
        Integer count = 0;
        if(input.length() > 0) {
            for (integer i=0;i<input.length();i++){
            if(validCharString.contains((input.mid(i,1)).toLowerCase())) {
                count++;
                }
            }
            return count;
        }
        return 0;
    }
}