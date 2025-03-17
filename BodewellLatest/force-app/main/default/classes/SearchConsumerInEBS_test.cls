//THIS IS TEST CLASS FOR SEARCHING THE CONSUMER IN EBS
@isTest()
public class SearchConsumerInEBS_test {
	public static testMethod void SearchConsumer_test1() {
        SearchConsumerInEBS.Requests sp = new SearchConsumerInEBS.Requests();
        sp.varPayload = '{"P_INIT_MSG_LIST": "T","P_CUST_GET_SEARCH_REC":{"EMAIL_ADDRESS": "gowsic.stestuser111@geappliances.com","PHONE_NUMBER": "1111111111","RELATED_ORGANIZATION": "64052704"}}';
        sp.varConsumerFirstName = 'Test First name';
        sp.varConsumerLastName = 'Test Last name';
        List<SearchConsumerInEBS.Requests> splist = new List<SearchConsumerInEBS.Requests>();
        splist.add(sp);
        SearchConsumerInEBS.SearchConsumerInEBS(splist);

    }
}