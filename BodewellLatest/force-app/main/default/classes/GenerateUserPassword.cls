public class GenerateUserPassword {
    @InvocableMethod
    public static void userResetPassword(List<id> userId){
        System.resetPassword(userId[0], true);  // reset password 
    }
}