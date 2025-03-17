public class BWC_CybersourceCartSummary {

	public String grandTotalAmount;
	public String totalTaxAmount;
	public String cartId;
	public String currencyIsoCode;

	public static BWC_CybersourceCartSummary parse(String json) {
		return (BWC_CybersourceCartSummary) System.JSON.deserialize(json, BWC_CybersourceCartSummary.class);
	}
}