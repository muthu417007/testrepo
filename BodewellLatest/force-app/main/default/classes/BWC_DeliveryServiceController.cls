/**
* @author Abhishek Bisht
* @date 29/02/2024
* @description The purpose of this class is to generate a payload.
* */
public class BWC_DeliveryServiceController {
/*
* @description This method is called in ProcessOrder apex class in callOracleApi method
* @param orderIdInstance - This parameter is coming from ProcessOrder apex class
* @return JSONGenerator
*/
    public static String getDeliveryService(List<String> skuList, String warehouse){
        try{
            String fakeResponse = '{    "P_ITEM_LIST_TAB": {        "P_ITEM_LIST_TAB_ITEM": {            "REQUEST_ID": null,            "PRICING_EFFECTIVE_DATE": "2024-02-29T00:00:00.000-05:00",            "ORGANIZATION_ID": "1312",            "INVENTORY_ITEM_ID": "2318685",            "SALES_AGREEMENT_NUMBER": null,            "ACCOUNT_NUMBER": null,            "WHSE": "9HL",            "ZONE": null,            "SHIP_TO_STATE": null,            "ITEM_NUMBER": "M019",            "ITEM_TYPE": "DELIVERY SERVICE",            "DESCRIPTION": "DISC ELEC RANGE      ",            "PRICE_LIST_PRICED_FROM_NAME": "DELIVERY - SDS - STD COST BASED PRICE LIST - SERVICES",            "UNIT_PRICE": "18",            "PROD_SEG": "Installation",            "PROD_DEPT": "SDS",            "SCENARIO": "3_Whse",            "ITEM_COST": null,            "CARTD_DELIVERY_ADDER": "4",            "CARTD_DELIVERY_BUMP": "1.5",            "CARTD_SVC_BUMP": "1.2",            "CARTD_DAC_AMT": null,            "MIN_DELIVERY_CHARGE_AGENT": null,            "PRICING_MIN_BUMP_ZONE": null,            "PRICING_MIN_BUMP_ORG": null,            "CARTD_MIN_DELIVERY_ADDER": null,            "CARTD_MIN_DELIVERY_BUMP": null,            "CARTD_MIN_DELIVERY_DAC_AMT": null,            "ACC_IND": null,            "CREATED_BY": "74516",            "CREATION_DATE": "2024-02-29T00:00:00.000-05:00",            "LAST_UPDATED_BY": "74516",            "LAST_UPDATE_DATE": "2024-02-29T00:00:00.000-05:00",            "ATTRIBUTE1": null,            "ATTRIBUTE2": null,            "ATTRIBUTE3": null,            "ATTRIBUTE4": null,            "ATTRIBUTE5": null,            "ATTRIBUTE6": null,            "ATTRIBUTE7": null,            "ATTRIBUTE8": null,            "ATTRIBUTE9": null,            "ATTRIBUTE10": null,            "SUBSCRIBER": null,            "EIP_STATUS": null,            "EIP_STATUS_MESSAGE": null,            "COMPOSITE_KEY": "39HLM019"        }    },    "P_STATUS": "S",    "P_ERRMSG": "Successfull"}';
            
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('scenario', '3_Whse');
            gen.writeFieldName('items');
            gen.writeStartArray();
            for(String skuInstance : skuList){
                gen.writeStartObject();
                gen.writeStringField('itemNumber', skuInstance);
                gen.writeStringField('whse', warehouse);
                gen.writeEndObject();
            }
            gen.writeEndArray();
            gen.writeEndObject();
            gen.writeEndArray();

            String deliveryServicePayLoad = gen.getAsString();
            System.debug('deliveryServicePayLoad-->'+deliveryServicePayLoad);
            Integer counter = 0;
            String response = test.isRunningTest() ? fakeResponse : Utility.isSandbox ? RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth', 'Sandbox_EBS_QA_Token', 'Sandbox_CommerceCloud_DeliveryServiceQA', null, 'POST', deliveryServicePayLoad) : RequestMuleAPIData.getMuleAPIData('Production_MuleAuth', 'PROD_EBS_Token', 'BWC_PROD_DeliveryService', null, 'POST', deliveryServicePayLoad);
            while(response.contains('P_ITEM_LIST_TAB_ITEM')){
                response = response.replaceFirst('P_ITEM_LIST_TAB_ITEM','ITEM_LIST'+counter);
                counter++;
            }
            System.debug('response-->'+response);
            return response;
        }
        catch(Exception ex){
            System.debug('Line Number of getDeliveryServiceMethod-->'+ex.getLineNumber()+'  Error Message-->'+ex.getMessage());
            return null;
        }
    }
}