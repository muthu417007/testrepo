global with sharing class PS_UserSendVerificationAction {
    @TestVisible
    private static Boolean failedSendingEmail = false;

    @TestVisible
    private static Boolean throwErrorSendingEmail = false;

    @InvocableMethod(label='Send User Verification Email')
    global static List<SendVerificationOutput> sendVerificationEmail(List<SendVerificationInput> inputVerification) {
        List<SendVerificationOutput> outputVerification = new List<SendVerificationOutput>();
        
        for (SendVerificationInput input : inputVerification) {
            SendVerificationOutput output = new SendVerificationOutput();
            try {
                output.result = System.UserManagement.sendAsyncEmailConfirmation(
                    input.userId,
                    input.emailTemplateId,
                    input.networkId,
                    input.startUrl
                );

                if (Test.isRunningTest() && failedSendingEmail) {
                    output.result = false;
                } else if(Test.isRunningTest() && throwErrorSendingEmail) {
                    throw new PS_UserSendVerificationActionException();
                }

                if (output.result) {
                    output.message = 'Success';
                } else {
                    output.message = 'Error while send async email confirmation.';
                }
                
                outputVerification.add(output);
            } catch (Exception e) {
                output.message = 'ERROR: ' + e.getLineNumber() + ', ' + e.getMessage();
                System.debug(output.message);
            }
        }
        return outputVerification;
    }
    
    global class SendVerificationInput {
        @InvocableVariable
        global String userId;
        
        @InvocableVariable
        global String networkId;
        
        @InvocableVariable
        global String emailTemplateId;
        
        @InvocableVariable
        global String startUrl;
    }
    
    global class SendVerificationOutput {
        @InvocableVariable
        global String message;
        
        @InvocableVariable
        global Boolean result;
    }

    public class PS_UserSendVerificationActionException extends Exception { }
}