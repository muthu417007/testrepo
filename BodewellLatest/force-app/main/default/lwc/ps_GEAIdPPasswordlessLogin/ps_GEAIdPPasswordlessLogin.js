import {api, LightningElement, wire} from 'lwc';
import {CurrentPageReference, NavigationMixin} from 'lightning/navigation';
import sendPasswordlessLogin from "@salesforce/apex/PS_GEAIdPPasswordlessLoginCtrl.sendPasswordlessLogin";
import verifyPasswordlessLogin from "@salesforce/apex/PS_GEAIdPPasswordlessLoginCtrl.verifyPasswordlessLogin";
import GEA from './ps_GEAIdPPasswordlessLogin.html';
import Bodewell from './ps_GEAIdPPasswordlessLoginBodewell.html';
export default class PsGeaIdPPasswordlessLogin extends NavigationMixin(LightningElement) {

    @api pageTitleLabel = "Want to sign in without your password?";
    @api pageTitleDescriptionLabel = "As long as you are registered and verified with us you can receive a one-time passcode by submitting your email below.";
    @api pageTitleDescriptionLabel1 = "As long as you are registered and verified with us you can receive a one-time ";
    @api pageTitleDescriptionLabel2 ="passcode by submitting your email below."
    @api pageSubTitleLabel = "Check your email for your passcode.";
    @api pageSubTitleDescriptionLabel = "If you are registered and verified with us, then you will receive a passcode.";
    @api continueButtonLabel = "Continue";
    @api sendMeACodeButtonLabel = "Send me a code";
    @api resetMyPasswordButtonLabel = "Reset my password";
    @api didntReceiveTheCodeLabel = "Didn't receive the code?";
    @api didntReceiveTheCodeDescriptionLabel = "If you didn't receive the passcode within a few minutes, we can send it to you again.";
    @api passcodeLabel = "Passcode";
    @api emailMeLabel = "Email Me";
    @api unableToRequestCode = "Unable to request the code. Please try later.";
    @api unableToSubmitCode = "Unable to submit the code. Please try later.";

    isLoading = false;
    showEnterPasscode = false;
    showSubmitError = false;
    showRequestError = false;
    emailInput = '';
    passcode = '';
    userId = null;
    passwordlessId;
    startURL;
    @api brand = 'GEA';

    render() {
        if (this.brand == "GEA") {
          return GEA;
        } else if (this.brand == "Bodewell") {
            return Bodewell;
          }
        }

    onKeyUpEmailInput(component) {
        //if 'enter' key login
        if (component.which === 13) {
            this.handleSendCode();
        }
    }

    onKeyUpCodeInput(component) {
        //if 'enter' key login
        if (component.which === 13) {
            this.handleContinue();
        }
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.startURL = currentPageReference.state.startURL || null;
        }
    }

    handleContinue() {
        this.isLoading = true;
        this.showRequestError = false;
        this.showSubmitError = false;

        verifyPasswordlessLogin({
            userId: this.userId,
            passwordlessId: this.passwordlessId,
            code: this.passcode,
            startUrl: this.startURL
        })
            .then((result) => {
                if (result.isSuccess) {
                    window.location.replace(result.redirectUrl);
                } else {
                    this.showSubmitError = true;
                }
            })
            .catch(() => {
                this.showSubmitError = true;
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleEmailChange(event) {
        this.emailInput = event.target.value;
    }

    handlePasscodeChange(event) {
        this.passcode = event.target.value;
    }

    handleSendCode() {
        let emailInput = this.template.querySelector(`[data-id="emailInput"]`);

        if (this.emailInput.length <= 0 || !emailInput.validity.valid) {
            return;
        }

        this.showRequestError = false;
        this.showSubmitError = false;
        this.showEnterPasscode = true;
        this.isLoading = true;

        sendPasswordlessLogin({
            email: this.emailInput
        })
            .then((result) => {
                this.userId = result.userId;
                this.passwordlessId = result.passwordlessId;
            })
            .catch(() => {
                this.showRequestError = true;
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleResetMyPassword() {
        this[NavigationMixin.GenerateUrl]({
           type: 'standard__webPage',
            attributes: {
                url: 'login/ForgotPassword'
            }, 
            
        }).then((generatedUrl) => {
            window.location.replace(generatedUrl);
        });
    }

    handleResetMyPasswordBodewell() {
        this[NavigationMixin.GenerateUrl]({
          
            type: "comm__namedPage",
            attributes: {
               name: "Forgot_Password"
                
            } 
        }).then((generatedUrl) => {
            window.location.replace(generatedUrl);
        });
    }
}