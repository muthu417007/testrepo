public class CaseHandler {
    public static string phNum(list<case> clist){ 
        string phone;     
   for(Case c:clist){
        if(!String.isBlank(c.Phone_Number__c)) {
             phone =c.Phone_Number__c;
            c.Phone_Number__c = phone.replaceAll('\\D','');           
        }
   }
         return phone;
         }
    public static string AltphNum(list<case> clist1){ 
        string phonee;     
   for(Case c:clist1){
        if(!String.isBlank(c.Alternative_Phone_Number__c)) {
             phonee =c.Alternative_Phone_Number__c;
            c.Alternative_Phone_Number__c = phonee.replaceAll('\\D','');           
        }
   }
         return phonee;
         }
}