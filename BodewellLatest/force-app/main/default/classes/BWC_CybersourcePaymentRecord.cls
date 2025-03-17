public class BWC_CybersourcePaymentRecord {

	public String cartId;
	public String webstoreId;
	public String accountId;
	public String currencyIsoCode;
	public String signed_date_time;
	public String request_token;
	public String transaction_id;
	public String auth_code;
	public String auth_time;
	public String payment_token;
	public String req_card_expiry_date;
	public String req_bill_to_forename;
	public String req_bill_to_surname;
	public String req_bill_to_street;
	public String req_bill_to_city;
	public String req_bill_to_state;
	public String req_bill_to_postal_code;
	public String req_bill_to_country;
	public String req_card_type;
	public String req_card_number;
	public Decimal auth_amount;
	public String cardNumber;
	public String card_type_name;
    public Integer expiryYear;
    public Integer expiryMonth;

	public static BWC_CybersourcePaymentRecord parse(String json) {
		return (BWC_CybersourcePaymentRecord) System.JSON.deserialize(json, BWC_CybersourcePaymentRecord.class);
	}
}