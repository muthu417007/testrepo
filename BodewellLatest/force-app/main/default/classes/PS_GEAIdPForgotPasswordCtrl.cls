public with sharing class PS_GEAIdPForgotPasswordCtrl {

    @AuraEnabled
    public static void sendForgotEmail(String email) {
        PS_ForgotPasswordService forgotPasswordService = new PS_ForgotPasswordService(email, null, null);
        HttpResponse httpResponse = forgotPasswordService.sendForgotEmail();

        System.debug('Test Response'+httpResponse);
        if (httpResponse.getStatusCode() != 200) {
            AuraHandledException ahe = new AuraHandledException('General Error');
            ahe.setMessage('General Error');
            throw ahe;
        }
    }
}