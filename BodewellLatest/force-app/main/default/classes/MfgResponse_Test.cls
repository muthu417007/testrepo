@IsTest
public class MfgResponse_Test {
    
    static testMethod void testParse() {
        String json = '{'+
        '    \"MfgModelNumber\": \"AJCQ08ACFQ1\",'+
        '    \"MktModelNumber\": \"AJCQ08ACF\",'+
        '    \"UPCCode\": \"08469125852\"'+
        '}';
        MfgResponse obj = MfgResponse.parse(json);
        System.assert(obj != null);
    }
}