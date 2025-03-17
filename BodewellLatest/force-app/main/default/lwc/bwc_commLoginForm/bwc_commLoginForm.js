import {api, LightningElement,track, wire} from "lwc";
import {CurrentPageReference, NavigationMixin} from "lightning/navigation";
import loginUser from "@salesforce/apex/PS_GEAIdPCommLoginCtrl.handleLogin";
import getRegisterURL from "@salesforce/apex/PS_GEAIdPCommLoginCtrl.getRegisterURL";
import basePath from "@salesforce/community/basePath";

import getSiteConfiguration from '@salesforce/apex/PS_GEAIdPCustomerConfigHelper.getSiteConfiguration';
import getEnvironmentConfiguration from '@salesforce/apex/PS_GEAIdPEnvironmentConfigHelper.getEnvironmentConfiguration';

export default class bwc_commLoginForm extends NavigationMixin(LightningElement) {
    isLoading = false;
    @api pageTitleLabel = "Sign in to your Account";

    @api userNameLabel = "Email";
    usernameHasError = false;
    @api usernameValidationError = "Username is missing";

    @api passWordLabel = "Password";
    passwordHasError = false;
    @api passwordValidationError = "Password is missing";

    @api forgotPasswordLabel = "Forgot Password";
    forgotPasswordLink;

    @api passwordlessLabel = "Login without password";
    passwordlessLoginLink;

    @api passwordlessLabelBodewell = "Login without password";
    passwordlessLoginLinkBodewell;

    @api loginButtonLabel = "Login";

    @api createAccountLabel = "Create Account";

    @api signUpLabel = "Sign Up";
    @api signUpText = "Don't have an account?";
    signUpLink;

    data = {};
    @api generalErrorMessage = "Error occured";
    @api errorMessage = "Your login attempt has failed. As of September 24, 2023 we have updated our system requiring all users to reset thier passwords. Please use the Forgot Passwords link above.";
    generalError = false;

    urlLanguage;
    urlRedirectURL;
    urlState;
    startURL;
    siteName;
    @track airWatersite;
    connectedCallback() {
        this.airWatersite=false;
        console.log('connectedCallback called');
        getSiteConfiguration()
        .then((siteConfigData)=> {
            console.log('response is '+siteConfigData.QualifiedApiName);
            this.siteName=siteConfigData.QualifiedApiName;
            console.log('this.siteName',this.siteName);
            if(siteConfigData.QualifiedApiName=='AirAndWater'){
                console.log('air water site');
                this.airWatersite=true;
            }
            
        })
        .catch((error)=>{
            console.log('Error while getting data from apex'+error.statuscode());
        });
        
    }

    @wire(getRegisterURL)
    registerURL

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlLanguage = currentPageReference.state.language || null;
            this.urlRedirectURL = currentPageReference.state.redirectURL || null;
            this.urlState = currentPageReference.state.state || null;
            this.startURL = currentPageReference.state.startURL || null;
            console.log('this.startURL ',this.startURL );
            // this.setSignUpLink();
            this.setForgotPasswordLink();
            this.setPasswordlessLoginLink();
            this.setPasswordlessLoginLinkBodewell();
        }
    }

    keyPressed(component) {
        //if 'enter' key login
        if (component.which === 13) {
            this.handleLogin();
        }
    }

    setForgotPasswordLink() {
        this[NavigationMixin.GenerateUrl]({
            type: "comm__namedPage",
            attributes: {
                name: "Forgot_Password"
            }
        }).then((url) => {
            this.forgotPasswordLink = url;
        });
    }

    setPasswordlessLoginLinkBodewell(){
        let baseURL = window.location.href.substring(0, window.location.href.indexOf("/s/"));
        console.log('baseURL',baseURL);
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: baseURL + '/passwordless-login'
            },
        }).then((url) => {
            this.passwordlessLoginLink = url;
        });
    }

    setPasswordlessLoginLink() {
        let baseURL = window.location.href.substring(0, window.location.href.indexOf("/s/"));

        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: baseURL + '/s/passwordless-login?startURL=' + this.startURL
            },
        }).then((url) => {
            this.passwordlessLoginLink = url;
        });
    }

    onInputChanged(event) {
        this.data[event.target.name] = event.target.value;
    }

    validateInputs() {
        this.validateUsernameInput();
        this.validatePasswordInput();
        return this.usernameHasError && this.passwordHasError;
    }

    validateUsernameInput() {
        const input = this.template.querySelector(`[data-id="userName_id"]`);
        if (!input.checkValidity()) {
            this.usernameHasError = true;
            input.classList.add("slds-has-error");
        } else {
            this.usernameHasError = false;
            input.classList.remove("slds-has-error");
        }
    }

    validatePasswordInput() {
        const input = this.template.querySelector(`[data-id="password_id"]`);
        if (!input.checkValidity()) {
            this.passwordHasError = true;
            input.classList.add("slds-has-error");
        } else {
            this.passwordHasError = false;
            input.classList.remove("slds-has-error");
        }
    }

    handleLogin() {
        if (this.validateInputs()) {
            return;
        }

        this.handleLoading(true);

        const inputParameters = {
            email: this.data.email,
            password: this.data.password,
            language: this.urlLanguage,
            redirectURL: this.urlRedirectURL,
            state: this.urlState,
            startURL: this.startURL,
            siteName: this.siteName
        };
console.log('inputParameters',inputParameters);
        let loginStatus = 'fail';
        let loginFailReason = null;

        loginUser({
            loginParameters: inputParameters
        })
            .then((result) => {
                console.log('login parameters',result);
                this.setGeneralError(false, null);

                if (result) {
                    console.log('globalId',result.globalCustomerId);
                    console.log('loginPageReferenceUrl',result.loginPageReferenceUrl);
                    let loginSuccessfulEvent = new CustomEvent(
                        "geaidm__loginSuccessful",
                        {
                            detail: {
                                globalId: result.globalCustomerId
                                
                            }
                        }
                    );
                    document.dispatchEvent(
                        loginSuccessfulEvent,
                        {
                            bubbles: true,
                            composed: true
                        }
                    );

                    loginStatus = 'success';

                    this[NavigationMixin.GenerateUrl]({
                        type: "standard__webPage",
                        attributes: {
                            url: result.loginPageReferenceUrl
                        }
                    }).then((generatedUrl) => {
                        window.location.replace(generatedUrl);
                    });
                    return;
                }

                this.handleLoading(false);

                //this.submitButtonLabelInternal = data.message;
            })
            .catch((error) => {
                this.setGeneralError(true, this.errorMessage);
                loginStatus = 'fail';
                loginFailReason = this.errorMessage;

                console.log(error);
                console.log(this.errorMessage);
                this.handleLoading(false);
            })
            .finally(() => {
                let registrationCompletedEvent = new CustomEvent(
                    "gtm__signInAttempt",
                    {
                        detail: {
                            loginStatus: loginStatus,
                            loginFailReason: loginFailReason
                        }
                    }
                );
                document.dispatchEvent(
                    registrationCompletedEvent,
                    {
                        bubbles: true,
                        composed: true
                    }
                );
            });
    }

    handleCreateAccount() {
        document.dispatchEvent(
            new CustomEvent("gtm__registrationStart"),
            {
                bubbles: true,
                composed: true
            }
        );
        console.log("this.registerURL::" + JSON.stringify(this.registerURL.data, null, 2));
        console.log("base url",basePath);
       // let registrationURL = (JSON.stringify(this.registerURL.data, null, 2)).replace("bodewellCommercevforcesite/s/SelfRegister", "bodewellCommerce/SelfRegister");
      let registrationURL = "/SelfRegister";
       
        console.log('registrationURL',registrationURL);
        this[NavigationMixin.Navigate](
            {
              type: "standard__webPage",
              attributes: {
                url: registrationURL,
              },
            },
            true, // Replaces the current page in your browser history with the URL
          );
        
        //window.open(registrationURL?.data, '_self');
    }

    handleLoading(loading) {
        this.isLoading = loading;
    }

    setGeneralError(isError, errorMessage) {
        this.generalError = isError;
        this.generalErrorMessage = errorMessage;
    }
}