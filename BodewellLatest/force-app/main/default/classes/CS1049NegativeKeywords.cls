public class CS1049NegativeKeywords {
	@InvocableMethod(label='CS1049NegativeKeywords' description='CS1049NegativeKeywords')
    public static List<String> FuncCS1049NegativeKeywords(List<String> inputString){
       	List<String> returnList = new List<String>();
        String strInputString;
        strInputString = inputString[0];
        strInputString = strInputString.replaceAll(',','');
        List<Negative_CS1049_keywords__mdt> entList = [SELECT Label, OrderNumber__c FROM Negative_CS1049_keywords__mdt order by OrderNumber__c asc];
        for(Negative_CS1049_keywords__mdt ss:entList){ 
           strInputString = strInputString.toLowerCase().replaceAll(ss.Label.toLowerCase(),'');
        }
        //returnList.add(strInputString);
        inputString.set(0, strInputString);
        return inputString;
    }
    
    
}