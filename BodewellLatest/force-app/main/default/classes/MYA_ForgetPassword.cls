public class MYA_ForgetPassword {

    @InvocableMethod(callout=true label='Get User Password')    
    public static List<String> getforgetPassword(List<flowforget> requests) { //get the flow input
        //pageReference pr;
        system.debug('requests '+requests);
        String newPassword=requests[0].newPass; //get new password
        String verifyNewPassword=requests[0].rePass; //get old password
        String oldPassword=requests[0].oldPass; //re-enter the password
        try{
            Site.changePassword(newPassword,verifyNewPassword, oldPassword);  //change it by usig standard site method
            return new List<String>{'Password Change is Successful'};
        }catch(Exception e){
           system.debug('message'+e.getMessage());
           system.debug('cause'+e.getCause());
            return new List<String>{'Failed to change password: '+e.getMessage()};
        }
       
        
    }
    /*public static PageReference changePassword(String newPassword, String verifyNewPassword, String oldpassword) {
        return Site.changePassword(newPassword, verifyNewPassword, oldpassword);    
    }  */   
    
    public class flowforget{
        //@InvocableVariable public string email;
        @InvocableVariable public string oldPass;
        @InvocableVariable public string newPass;
        @InvocableVariable public string rePass;
    }
}