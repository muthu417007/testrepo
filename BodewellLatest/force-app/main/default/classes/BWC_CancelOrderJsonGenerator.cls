public class BWC_CancelOrderJsonGenerator {
    public static String cancelPayloadGenerator(String headerId){
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('P_OPERATION','UPDATE');
        gen.writeFieldName('P_HEADER_REC');
        gen.writeStartObject();
        gen.writeStringField('CANCELLED_FLAG', 'Y');
        gen.writeStringField('HEADER_ID', headerId);
        gen.writeNumberField('ORG_ID', 82);
        gen.writeStringField('OPERATION', 'UPDATE');
        gen.writeStringField('CHANGE_REASON', 'CANCEL - CUSTOMER REQUEST');
        gen.writeStringField('CHANGE_COMMENTS', 'Decided to go with different product');
        gen.writeEndObject();
        gen.writeEndObject();
        String jsonString = gen.getAsString();
        system.debug(jsonString);
        return jsonString;
    }
}