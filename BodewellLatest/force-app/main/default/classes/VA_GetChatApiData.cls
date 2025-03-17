/**
 * @description VA_GetChatApiData
 * Test class : VA_GetChatApiDataTest
 * Author : Santhosh Kanne.
 */
public without sharing class VA_GetChatApiData {

    /**
     * @description method to call the Chat Analytics API
     * @param category, childId, counter, prdIn, model, serial, phone, param1, param2, param3
     * @return JSON response from the API
     */
    @AuraEnabled
	public static String getAnalyticsResponse(String category,String childId,String counter,String prdIn,String model,String serial,String phone,String param1,String param2,String param3){
        
        String extraurl='/chat?category=';
        if(category!='' && category!=null) {
            extraurl+=category;	}
        //extraurl+='&childId=';
        if(childId!='' && childId!=null) {
            extraurl+='&childId='+childId; }
        extraurl+='&counter=';
        if(counter!='' && counter!=null) {
            extraurl+=counter; }
        extraurl+='&prdIn=';
        if(prdIn!='' && prdIn!=null) {
            extraurl+=prdIn; }
        extraurl+='&modelNum=';
        if(model!='' && model!=null) {
            extraurl+=model; }
        extraurl+='&serialNum=';
        if(serial!='' && serial!=null) {
            extraurl+=serial; }
        extraurl+='&phoneNum=';
        if(phone!='' && phone!=null) {
            extraurl+=phone; }
        extraurl+='&param1=';
        if(param1!='' && param1!=null) {
            extraurl+=param1; }
        extraurl+='&param2=';
        if(param2!='' && param2!=null) {
            extraurl+=param2; }
        extraurl+='&param3=';
        if(param3!='' && param3!=null) {
            extraurl+=param3; }
        System.debug('url is '+extraurl);
        String res;
        if(utility.isSandbox){
         	res = RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','VA_Chat_Dev_Token','VA_MuleDevChatURL',extraurl,'GET',null);
        }
        else {
            res = RequestMuleAPIData.getMuleAPIData('Production_MuleAuth','Prod_Connected_Token','VA_MuleProdChatURL',extraurl,'GET',null);
        
        }
        //system.debug('res is '+res);
        String resp=res.remove('\n');
        //system.debug(resp);
        return resp;
    }
	/**
     * @description method to get user name
     * @param userId
     * @return user name of logged in user
     */
    @AuraEnabled
	public Static String getUserName(String userId){
        User u=[Select FirstName,LastName from User where id=:userId WITH SECURITY_ENFORCED];
        return u.LastName+' '+u.FirstName;
    }
}