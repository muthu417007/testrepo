import {api, LightningElement,track, wire} from "lwc";
import {CurrentPageReference, NavigationMixin} from "lightning/navigation";
import loginUser from "@salesforce/apex/PS_GEAIdPCommLoginCtrl.handleLogin";
import getRegisterURL from "@salesforce/apex/PS_GEAIdPCommLoginCtrl.getRegisterURL";
import getBwcMyaMetaData from '@salesforce/apex/BWC_MYA_Configurations_Controller.getBwcMyaMetaData';
import getSiteConfiguration from '@salesforce/apex/PS_GEAIdPCustomerConfigHelper.getSiteConfiguration';
import getEnvironmentConfiguration from '@salesforce/apex/PS_GEAIdPEnvironmentConfigHelper.getEnvironmentConfiguration';


import GEA from './ps_GEAIdPCommLoginForm.html';
import Bodewell from './ps_GEAIdPCommLoginFormBodewell.html';

import googleImage from '@salesforce/resourceUrl/googleImage';  //google social login
import facebookImage from '@salesforce/resourceUrl/facebookImage'; // facebook social login


export default class Ps_GEAIdPCommLoginForm extends NavigationMixin(LightningElement) {
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
    PasswordlessLoginLinkBodewell;

    @api loginButtonLabel = "Login";

    @api createAccountLabel = "Create Account";

    @api signUpLabel = "Sign Up";
    @api signUpText = "Don't have an account?";
    signUpLink;

    data = {};
    @api generalErrorMessage = "Error occured";
    @api errorMessagePAOutage = "The system is down at this time for site maintenance. Once the system is back up, you will need to reset your password.  Please try again later."
    @api errorMessage = "Your login attempt has failed. Make sure the email and password are correct or use the Forgot Password link to reset your password."
    @api errorMessagePA = "We have updated our system requiring users to reset their passwords. Please use the Forgot Password link above to reset your password."
    generalError = false;
    bwcmetadta = null;
    @track googleAuthUrl = null;
    @track fbAuthUrl = null;
    urlLanguage;
    urlRedirectURL;
    urlState;
    startURL;
    siteName;
    @track airWatersite;
    experience;
    bodewellRegisterUrl;
    isbodewell=true;
    @api brand = 'GEA';

    // to render template base on the brand value
    render() {
        if (this.brand == "GEA") {
          return GEA; // to render gea for all other sites
        } else if (this.brand == "Bodewell") {
            return Bodewell; // to render bodewell for bodewell page
          }
        }

        facebookImage =facebookImage; // image for facebook
        googleImage = googleImage; // image for google

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
        this.getBwcMyaMetadata();
    }

    getBwcMyaMetadata() {
        getBwcMyaMetaData()
            .then(response => {
                this.bwcmetadta = response;
                this.googleAuthUrl = this.bwcmetadta.Google_auth_url__c;
                this.fbAuthUrl = this.bwcmetadta.Facebook_auth_url__c;
            }).catch(error => {
                console.error('error : ', error);
            });
    }

    @wire(getRegisterURL)
    registerURL

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            console.log('currentPageReference'+JSON.stringify(currentPageReference));
            this.urlLanguage = currentPageReference.state.language || null;
           this.urlRedirectURL = currentPageReference.state.redirectURL || null;
            this.urlState = currentPageReference.state.state || null;
            this.startURL = currentPageReference.state.startURL || null;
          // this.startURL = 'https://geapp--bwcommoob.sandbox.my.site.com/bodewellCommerce/mya-my-products';
            console.log('this.startURL ',this.startURL );
            console.log('this.urlRedirectURL',this.urlRedirectURL);
            // this.setSignUpLink();
            this.setForgotPasswordLink();
            this.setPasswordlessLoginLinkBodewell();
            this.setPasswordlessLoginLink();
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

    // for bodewell passwordless login bodewell
    setPasswordlessLoginLinkBodewell(){
        let baseURL = window.location.href.substring(0, window.location.href.indexOf("/s/"));
        console.log('baseURL',baseURL);
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: baseURL + '/passwordless-login'
            },
        }).then((url) => {
            this.PasswordlessLoginLinkBodewell = url;
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
        if(this.brand == "Bodewell" && this.startURL == null){
            this.startURL = '/bodewellCommerce/mya-my-products';
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
                        console.log('generatedUrl',generatedUrl);
                        window.location.replace(generatedUrl);
                    });
                    return;
                }

                this.handleLoading(false);

                //this.submitButtonLabelInternal = data.message;
            })
            .catch((error) => {
               if (error.body.message == 'PA_Outage'){
			       this.setGeneralError(true, this.errorMessagePAOutage);
			       loginFailReason = this.errorMessagePA;
			   } else if (error.body.message == 'PA_Error') {
			            this.setGeneralError(true, this.errorMessagePA);
			            loginFailReason = this.errorMessagePA;
			      } else {
			                  this.setGeneralError(true, this.errorMessage);
			                   loginFailReason = this.errorMessage;
			        }
			   loginStatus = 'fail';
			   console.log('Error: ',error);
               console.log('Error Message: ',loginFailReason);
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

   

    handleCreateAccountBodewell() {
        document.dispatchEvent(
            new CustomEvent("gtm__registrationStart"),
            {
                bubbles: true,
                composed: true
            }
        );
        //let registrationURL = "/SelfRegister";
        let registrationURL = this.startURL ? '/SelfRegister?inst=4P&language=en_US&redirectURL='+ this.startURL :'/SelfRegister';
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
       // window.open(this.registerURL?.data, '_self');
       window.open(this.registerURL?.data + '?inst=4P&language=en_US&redirectURL='+ this.startURL,'_self');

    }

    handleLoading(loading) {
        this.isLoading = loading;
    }

    setGeneralError(isError, errorMessage) {
        this.generalError = isError;
        this.generalErrorMessage = errorMessage;
    }
}