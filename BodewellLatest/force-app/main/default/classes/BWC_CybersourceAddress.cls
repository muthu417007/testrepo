public class BWC_CybersourceAddress {

	public String street;
	public String city;
	public String region;
	public String postalCode;
	public String country;

	public static BWC_CybersourceAddress parse(String json) {
		return (BWC_CybersourceAddress) System.JSON.deserialize(json, BWC_CybersourceAddress.class);
	}
}