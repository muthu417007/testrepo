public class CalculateTaxResponse {

    public String TaxAmount;

    public static CalculateTaxResponse parse(String json) {
        return (CalculateTaxResponse) System.JSON.deserialize(json, CalculateTaxResponse.class);
    }
}