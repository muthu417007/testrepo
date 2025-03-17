//******************************************************************************************
//Name : Mya_Payload
//Requirement : To display Orders data on My Orders 
//EPIC/US/TASK : IDMSF- 31, IDMSF- 37, IDMSF- 1032, IDMSF- 1033
//******************************************************************************************
//History
//  Version		Author				Date		        Detail
//  1.0			Yogesh Sharma		07/11/2022			Initial
//  2.0			Yogesh Sharma		17/01/2024			Updated.
//******************************************************************************************
//@description : Wrapper Class to handle Orders API data while Deserializing
public without sharing class Mya_Payload 
{
	//@description: For Parsing Order Xapi
	public class P_OUT_LINE_TBL 
	{
		public List<P_OUT_LINE_TBL_ITEMS> P_OUT_LINE_TBL_ITEMS;
	}

	//@description: For Parsing Order Xapi
	public class P_OUT_LINE_VAL_TBL_ITEMS 
	{
		public String SHIPPING_METHOD;
        public String ITEM_RELATIONSHIP_TYPE_DSP;
        public String ORIGINAL_ORDERED_ITEM;
	}

	//@description: For Parsing Order Xapi
	public class P_HOLD_HEADER_LEVEL_INFO_TAB_ITEMS 
	{
		public String HOLD_NAME;
	}

	//@description: For Parsing Order Xapi
	public class P_OUT_LINE_VAL_TBL 
	{
		public List<P_OUT_LINE_VAL_TBL_ITEMS> P_OUT_LINE_VAL_TBL_ITEMS;
	}

	public P_OUT_HEADER_REC P_OUT_HEADER_REC;
	public P_OUT_LINE_TBL P_OUT_LINE_TBL;
	public P_OUT_LINE_VAL_TBL P_OUT_LINE_VAL_TBL;
	public P_OUT_HEADER_PAYMENT_TBL P_OUT_HEADER_PAYMENT_TBL;
	public P_HOLD_HEADER_LEVEL_INFO_TAB P_HOLD_HEADER_LEVEL_INFO_TAB;
	public P_OUT_HEADER_VAL_REC P_OUT_HEADER_VAL_REC;

	//@description: For Parsing Order Xapi
	public class P_OUT_HEADER_PAYMENT_TBL_ITEMS 
	{
		public String PAYMENT_AMOUNT;
	}

	//@description: For Parsing Order Xapi
	public class P_OUT_HEADER_REC 
	{
		public String ATTRIBUTE2; //Changes part of CCOE-1134
		public String ATTRIBUTE8;
		public String ORDERED_DATE;
		public String ORDER_NUMBER;
		public String ORIG_SYS_DOCUMENT_REF;
		public String REQUEST_DATE;
		public String PAYMENT_AMOUNT;
		public String FLOW_STATUS_CODE;
	}

	//@description: For Parsing Order Xapi
	public class P_OUT_LINE_TBL_ITEMS 
	{
		public String ORDERED_ITEM;
		public String LINE_CATEGORY_CODE;
		public String LINE_NUMBER;
		public String ORDERED_QUANTITY;
		public String REQUEST_DATE;
		public String SCHEDULE_ARRIVAL_DATE;
		public String SHIPPING_INTERFACED_FLAG;
		public String SOURCE_TYPE_CODE;
		public String TAX_VALUE;
		public String UNIT_LIST_PRICE;
		public String UNIT_LIST_PRICE_PER_PQTY;
		public String UNIT_SELLING_PRICE_PER_PQTY;
		public String FORM_FLOW_STATUS_CODE;
        public String SCHEDULE_SHIP_DATE;
		public FROM_SERIAL_NUMBER FROM_SERIAL_NUMBER;
        public String ATTRIBUTE1; //Changes part of CCOE-1134
	}

	//@description: For Parsing Order Xapi
	public class FROM_SERIAL_NUMBER_ITEMS 
	{
		public String FM_SERIAL_NUMBER;
	}

	//@description: For Parsing Order Xapi
	public class FROM_SERIAL_NUMBER 
	{
		public List<FROM_SERIAL_NUMBER_ITEMS> FROM_SERIAL_NUMBER_ITEMS;
	}

	//@description: For Parsing Order Xapi
	public class P_HOLD_HEADER_LEVEL_INFO_TAB 
	{
		public List<P_HOLD_HEADER_LEVEL_INFO_TAB_ITEMS> P_HOLD_HEADER_LEVEL_INFO_TAB_ITEMS;
	}

	//@description: For Parsing Order Xapi
	public class P_OUT_HEADER_VAL_REC 
	{
		public String INVOICE_TO_ADDRESS1;
		public String INVOICE_TO_ADDRESS2;
		public String INVOICE_TO_ADDRESS3;
		public String INVOICE_TO_ADDRESS4;
		public String INVOICE_TO_STATE;
		public String INVOICE_TO_CITY;
		public String INVOICE_TO_ZIP;
		public String SHIP_TO_ADDRESS1;
		public String SHIP_TO_ADDRESS2;
		public String SHIP_TO_ADDRESS3;
		public String SHIP_TO_ADDRESS4;
		public String SHIP_TO_STATE;
		public String SHIP_TO_COUNTRY;
		public String SHIP_TO_ZIP;
		public String SHIP_TO_CITY;
		public String SOLD_TO_ORG;
		public String SHIPPING_METHOD;
	}
	
	//@description: For Parsing Order Xapi
	public class P_OUT_HEADER_PAYMENT_TBL 
	{
		public List<P_OUT_HEADER_PAYMENT_TBL_ITEMS> P_OUT_HEADER_PAYMENT_TBL_ITEMS;
	}
}