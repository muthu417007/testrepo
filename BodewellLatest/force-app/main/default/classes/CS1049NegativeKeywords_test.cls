@isTest 
private class CS1049NegativeKeywords_test {
    static testMethod void test1() {
        List<String> pcList = new List<String>();
        //pcList[0] = 'test';
        pcList.add('test');
        List<String> test = CS1049NegativeKeywords.FuncCS1049NegativeKeywords(pcList);
        system.debug(test);
        
        // Test tax is returned
        //System.assertEquals('30', test[0]);
    }
}