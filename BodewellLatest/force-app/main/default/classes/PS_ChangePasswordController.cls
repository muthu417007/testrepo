/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-17-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class PS_ChangePasswordController {
    @TestVisible
    private static Boolean testPasswordStrengthHasError = null;

    public String newPassword { get; set; }
    public String passwordConfirmation { get; set; }
    public Boolean newPasswordIsEmpty { get; set;}
    public Boolean passwordConfirmationIsEmpty { get; set;}
    public Boolean passwordStrengthHasError { get; set; }
    public Boolean passwordHasAnyError { get; set; }
    public String passwordErrorMessage { get; set; }
    public String passwordStrengthValidationError { get; set; }
    public String passwordMatchValidationError { get; set; }
    public String passwordValidationError { get; set; }
    public Boolean tncCheckBox { get; set; }
    public Boolean tncMessageCheck { get; set; }
    public String tncMessage { get; set; }
    public Boolean HasTermAndConditionContent { get; set; }
    private static final String SPECIAL_CHARACTERS_REGEX = '/[!@#$%^&*(),.?":{}|<>]/';

    public String globalCssVars {
        get {
            return global_Css_Vars;
        }
    }
    @testVisible
    private String global_Css_Vars;

    public String headerAndFooterURL {
        get {
            return header_And_Footer_URL;
        }
    }
    @testVisible
    private String header_And_Footer_URL;

    public String resourceContent {
        get {
            return resource_content;
        }
    }
    @testVisible
    private String resource_content;

    @testVisible
    private Boolean throwException = false;


    public PS_ChangePasswordController() {
        global_Css_Vars = PS_StaticResourceHelper.getResourceURL();

        Customer_IdP_Configuration__mdt siteConfig = PS_GEAIdPCustomerConfigHelper.getSiteConfiguration();
        resource_content = siteConfig.Resource_Content_Path__c;
        header_And_Footer_URL = siteConfig.Header_and_Footer_URL__c;

    }
    public Boolean checkTnc(){
        if(!tncCheckBox){
        System.debug('inside if'+tncCheckBox);
        System.debug('HasTermAndConditionContent---------'+HasTermAndConditionContent);
        tncMessage = 'Please check Terms and conditions';
            tncMessageCheck = true;
        }
        else{
            tncMessageCheck = false;
        }
        return tncCheckBox;
    }

    public PageReference savePassword(){
         if(tncCheckBox || (!tncCheckBox)){
               HasTermAndConditionContent = true;
         }
        if(HasTermAndConditionContent){
         if (checkTnc() && passwordHasErrors()){
            System.debug('HasTermAndConditionContent---------'+HasTermAndConditionContent);
            //System.debug(LoggingLevel.INFO, 'password is not valid ' + newPasswordIsEmpty);
            //System.debug(LoggingLevel.INFO,  tncCheckBox);
            return null;
        }
        else if(!tncCheckBox){
            return null;
        }
        }
        else{
           if (passwordHasErrors()){
            System.debug('HasTermAndConditionContent---------'+HasTermAndConditionContent);
            //System.debug(LoggingLevel.INFO, 'password is not valid ' + newPasswordIsEmpty);
            //System.debug(LoggingLevel.INFO,  tncCheckBox);
            return null;
        } 
        }
        try {
            if (Test.isRunningTest() && throwException) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'My Error'));
                throw new ChangePasswordException();
            }

            Site.changePassword(newPassword, passwordConfirmation);

            if (Apexpages.hasMessages()) {
                passwordHasAnyError = true;
                Apexpages.Message message = Apexpages.getMessages().get(0);
                passwordErrorMessage = message.getSummary();
                return null;
            }
            
            //T & C AuthorizationFormConsent Entries
            Customer_IdP_Configuration__mdt siteConfig = PS_GEAIdPCustomerConfigHelper.getSiteConfiguration();
            User currentUser = [SELECT Id,LanguageLocaleKey FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            PS_GEAIdPSecurityService.generateAuthorizationFormConsent(currentUser, siteConfig);
            //End T & C AuthorizationFormConsent Entries
            
            String destinationOverride = PS_GEAIdPEnvironmentConfigHelper.getEnvironmentConfiguration()
                    ?.Change_Password_Destination_Override__c;

            return String.isBlank(destinationOverride)
                    ? Page.CustomerSSO.setRedirect(true)
                    : new PageReference(destinationOverride).setRedirect(true);

        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, 'PS_ChangePasswordController.savePassword error saving new password ' + ex.getMessage());

            passwordHasAnyError = true;
            if(!Apexpages.getMessages().isEmpty()) {
                Apexpages.Message message = Apexpages.getMessages().get(0);
                passwordErrorMessage = message.getSummary();
            }

            return null;
        }
    }
       
    
  

    private Boolean passwordHasErrors() {
        newPasswordIsEmpty = String.isBlank(newPassword);
        passwordConfirmationIsEmpty = String.isBlank(passwordConfirmation);
        passwordStrengthHasError = validatePasswordStrength();

        return newPasswordIsEmpty || passwordConfirmationIsEmpty || passwordStrengthHasError;
    }
    private Boolean validatePasswordStrength() {
        passwordStrengthHasError = false;
        passwordStrengthValidationError = '';

        if (newPasswordIsEmpty || passwordConfirmationIsEmpty) {
            return passwordStrengthHasError;
        }
        
          /*Validate at least 8 characters
        if (newPassword.length() < 8) {
            passwordStrengthHasError = true;
            passwordStrengthValidationError += 'Password must be at least 8 characters long. ';
        }
 
        // Validate at least one uppercase letter
        if (!Pattern.compile('[A-Z]').matcher(newPassword).find()) {
            passwordStrengthHasError = true;
            passwordStrengthValidationError += 'Password must contain at least one uppercase letter. ';
        }
 
        // Validate at least one special character
        if (!Pattern.compile(SPECIAL_CHARACTERS_REGEX).matcher(newPassword).find()) {
            passwordStrengthHasError = true;
            passwordStrengthValidationError += 'Password must contain at least one special character. ';
        }
 
        // Validate at least one number
        if (!Pattern.compile('[0-9]').matcher(newPassword).find()) {
            passwordStrengthHasError = true;
            passwordStrengthValidationError += 'Password must contain at least one number. ';
        }
*/

 // Start on Related to User Story #1446        
      /*  if (newPassword.length() < 8) {
            passwordStrengthHasError = true;
            passwordStrengthValidationError = 'Password must be at least 8 characters long.';
            return passwordStrengthHasError;
            
        }
 
        // Validate at least one uppercase letter
        if (!Pattern.compile('.*[A-Z].*').matcher(newPassword).matches()) {
            passwordStrengthHasError = true;
            passwordStrengthValidationError = 'Password must contain at least one uppercase letter. ';
             return passwordStrengthHasError;
           
           
        }
 
        // Validate at least one special character
         if (!Pattern.compile('.*[!@#$%^&*(),.?":{}|<>].*').matcher(newPassword).matches()) {
            passwordStrengthHasError = true;
            passwordStrengthValidationError = 'Password must contain at least one special character. ';
              return passwordStrengthHasError;
            
        }
 
        // Validate at least one number
        if (!Pattern.compile('.*[0-9].*').matcher(newPassword).matches()) {
            passwordStrengthHasError = true;
            passwordStrengthValidationError = 'Password must contain at least one number. ';
            System.debug('digit');
            return passwordStrengthHasError;
            
        }
        
        if(!newPassword.equals(passwordConfirmation)){
             passwordStrengthHasError = true;
             passwordMatchValidationError = 'Password do not match. ';
             return passwordStrengthHasError;
        } */
        
         // End on Related to User Story #1446
        
          

        User currentUser = [SELECT Id, Username, FirstName, LastName, ProfileId, Email FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

        System.debug(LoggingLevel.INFO, 'currentUser: ' + currentUser);

        if (!Test.isRunningTest()) {
            System.Site.validatePassword(currentUser, newPassword, passwordConfirmation);
            List<Apexpages.Message> passwordValidationErrors = ApexPages.getMessages();

            if (!passwordValidationErrors.isEmpty()) {
                passwordStrengthHasError = true;

                for (Apexpages.Message msg : passwordValidationErrors) {
                    passwordStrengthValidationError += msg.getSummary() + ' ';
                }
            }
        }

        if (Test.isRunningTest() && testPasswordStrengthHasError != null) {
            return testPasswordStrengthHasError;
        }

        return passwordStrengthHasError;
    }

    public class ChangePasswordException extends Exception { }
}