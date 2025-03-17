/**
* description Community Login Component (ps_GEAIdPCommLoginForm) controller
*/
public with sharing class PS_GEAIdPCommLoginCtrl {
    @TestVisible
    private static Boolean throwExceptionOnLogin = false;
    
    private static final String ANW_DEALER = 'Air_and_Water_Dealer';
    private static final String ANW_DISTRIBUTOR = 'Air_and_Water_Distributor';
    private static final String ANW_SITE = 'AirAndWater';
    
    /**
* description Empty Constructor
*/
    private PS_GEAIdPCommLoginCtrl() {
    }
    
    /**
    * @return Link to Registration Page
    */
    @AuraEnabled(Cacheable=true)
    public static String getRegisterURL() {
        Customer_IdP_Environment_Config__mdt envConfig = PS_GEAIdPEnvironmentConfigHelper.getEnvironmentConfiguration();
        system.debug('envConfig'+envConfig);
        system.debug('Get Network Id' +System.Network.getNetworkId());
        system.debug('Get Self Registration URL' +System.Network.getSelfRegUrl(System.Network.getNetworkId()));
        return String.isBlank(envConfig?.Registration_URL_Override__c)
            ? System.Network.getSelfRegUrl(System.Network.getNetworkId())
            : envConfig.Registration_URL_Override__c;
    }

    /**
     * @return the Status of Outage
     */
    @AuraEnabled(Cacheable=true)
    public static Boolean getOutageStatus() {
        PA_SalesforceOutage__mdt mdtOutageStatus = [Select Outage__c from PA_SalesforceOutage__mdt limit 1];
        System.debug('Outage Status: ' +mdtOutageStatus);
        return mdtOutageStatus.Outage__c;
    }
    
    /**
    * description Site login flow for GEA IDP
    * Check if user exists
    * Check if first login
    * Check if username-password is correct
    * Redirect user
    * In case of any error return error message for lwc component
    * @return login page reference url
    */
    @AuraEnabled
    public static Map<String, String> handleLogin(Map<String, String> loginParameters) {
        UserExistence userController = new UserExistence();
        PS_GEAIdPCommLoginCtrl controller = new PS_GEAIdPCommLoginCtrl();
        
        String email = loginParameters.get('email');
        String password = loginParameters.get('password');
        String startURL = loginParameters.get('startURL');
        startURL = String.isBlank(startURL) ? (Page.CustomerSSO.getUrl()) : startURL;       
        
        String siteName = loginParameters.get('siteName');
        
        system.debug('Test## startURL'+startURL);
        User currentUser = userController.isUserExist(email,siteName);
        String usersid=currentUser.id;
        String loginUrl;        
        try 
        {
            loginUrl = tryToLoginInUser(currentUser.Username, password, startURL);
            system.debug('test login url '+loginUrl); 

            PS_GEAIdPCommNonBodewellLogin.nonBodewellLogin(usersid, loginUrl, currentuser);
           
        } 
            
        catch (SecurityException securityException) {
            //login failed
            if (currentUser.PA_Transformed__c && controller.isFirstLogin(currentUser.LastLoginDate)){
                throwPAException();
            }else if (controller.isFirstLogin(currentUser.LastLoginDate)) { 
                //if isFirstLogin try external service to verify password
                try {
                    PS_ExternalPasswordVerificationService passwordVerificationService =
                        new PS_ExternalPasswordVerificationService(currentUser.Id, currentUser.Email, password);
                    if (!passwordVerificationService.verifyPassword()) {
                        throwAuraHandledException();
                    }
                    
                    //if password verified, set password in salesforce
                    passwordVerificationService.setPassword();
                    
                    loginUrl = tryToLoginInUser(currentUser.Username, password, startURL);
                    
                } catch (Exception e) {
                    System.debug(e.getMessage());
                    System.debug(e.getStackTraceString());
                    
                    throwAuraHandledException();
                }
            } else {
                ////if login failed and it's not a first login -> just wrong password
                throwAuraHandledException();
            }
        }
        
        return new Map<String, String>{
            'loginPageReferenceUrl' => loginUrl,
                'globalCustomerId' => currentUser?.Contact?.Global_Customer_Id__c
                };
                    
                    
                    }
    
    private Boolean isFirstLogin(Datetime lastLoginDate) {
        return lastLoginDate == null;
    }
    
    private static String tryToLoginInUser(String username, String password, String startUrl) {
        if (throwExceptionOnLogin) {
            throwExceptionOnLogin = false;
            throw new SecurityException();
        }
        PageReference siteLogin = Site.login(
            username,
            password,
            startUrl
        );
        return siteLogin?.getUrl();
    }
    
    public without sharing class UserExistence {
        
        Boolean PAOutage = PS_GEAIdPCommLoginCtrl.getOutageStatus();
       
        public User isUserExist(String email, String siteName) {
            system.debug('@@@@ isUserExist email' +email);
            system.debug('@@@@ isUserExist siteName' +siteName);
            List<User> listUser = [
                SELECT Id, LastLoginDate,AccountId, Contact.Global_Customer_Id__c, PA_Transformed__c, Contact.RecordType.DeveloperName, Username, Email
                FROM User
                WHERE Email = :email
                AND IsActive = TRUE
                AND IsPortalEnabled = TRUE
            ];
            system.debug('@@@@ isUserExist listUser' +listUser);
            system.debug('@@@@ isUserExist PA Transformed' +listUser[0].PA_Transformed__c);
            system.debug('@@@@ isUserExist Outage' +PAOutage);
            if (PAOutage){
                if (listUser.isEmpty()){
                    List<User> listPAUserDisabled = [
                        SELECT Id, LastLoginDate, PA_Transformed__c, Username, Email
                        FROM User
                        WHERE Email = :'_'+email
                        AND PA_Transformed__c = TRUE
                        AND IsPortalEnabled = FALSE
                    ];
                    if (!listPAUserDisabled.isEmpty()) {
                        throwPAOutageException();
                    } else {
                        throwAuraHandledException();
                    }
                } else if (!listUser.isEmpty() && listUser[0].PA_Transformed__c){
                    throwPAOutageException();
                }
            } else if (listUser.isEmpty()) {
                throwAuraHandledException();
            }
            
            if(siteName==ANW_SITE){
                for(User u : listUser){
                    if(u.Contact.RecordType.DeveloperName==ANW_DEALER || u.Contact.RecordType.DeveloperName==ANW_DISTRIBUTOR)
                        return u;
                }
            }
            return listUser[0];
        }
    }
    
    private static void throwAuraHandledException() {
        AuraHandledException ahe = new AuraHandledException('General Error');
        ahe.setMessage('General Error');
        throw ahe;
    }
    
    private static void throwPAException() {
        AuraHandledException ahe = new AuraHandledException('PA_Error');
        ahe.setMessage('PA_Error');
        throw ahe;
    }
    
    private static void throwPAOutageException() {
        AuraHandledException ahe = new AuraHandledException('PA_Outage');
        ahe.setMessage('PA_Outage');
        throw ahe;
    }
    
    
    
}