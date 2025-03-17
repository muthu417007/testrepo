public class SubscriptionCreate{
	public String P_ORG_ID;	//82
	//public String P_OPERATING_UNIT;
	//public String P_API_VERSION_NUMBER;	//1.0
	//public String P_INIT_MSG_LIST;	//T
	//public String P_RETURN_VALUES;	//T
	//public String P_ACTION_COMMIT;	//T
	public cls_P_BILLING_PLAN_HEADER_TBL P_BILLING_PLAN_HEADER_TBL;
	/*class cls_P_OPERATING_UNIT {
	}*/
	public class cls_P_BILLING_PLAN_HEADER_TBL {
		public List<cls_P_BILLING_PLAN_HEADER_TBL_ITEM> P_BILLING_PLAN_HEADER_TBL_ITEM;
	}
	public class cls_P_BILLING_PLAN_HEADER_TBL_ITEM {
		public String OPERATION;	//CREATE
		public String SOURCE_ORDER_HEADER_ID;	//49016732
		public String SOURCE_ORDER_LINE_ID;	//189388320
		public String BILLING_PLAN_STATUS;	//OPEN
		public String BILL_WITH_SOURCE_LINE;	//N
		public String BILLING_FREQUENCY;	//1
		public String BILLING_PERIOD;	//MTH
		public String START_DATE;	//2024-09-09
		public String BILLING_AMOUNT;	//200
		public String NUMBER_OF_BILLING_PLAN_LINES;	//12
		public String TYPE_OF_BILLING;	//F
		//public String RETURN_STATUS;
		public String LINE_INDEX;	//1
		public String GENERATE_BILLING_PLAN_LINES;	//Y
		//public String USAGE_UNIT_DESC;
		//public String TYPE_OF_USAGE;
	}
	/*class cls_RETURN_STATUS {
	}
	class cls_USAGE_UNIT_DESC {
	}
	class cls_TYPE_OF_USAGE {
	}*/
	/*public static fromJSON parse(String json){
		return (fromJSON) System.JSON.deserialize(json, fromJSON.class);
	}*/
}