import { LightningElement } from 'lwc';

import { loadScript } from 'lightning/platformResourceLoader';

import RECAPTCHA_SCRIPT from '@salesforce/resourceUrl/BWC_recaptchv2';
export default class Recaptcha2code extends LightningElement {
    siteKey = '6Leuhs4nAAAAADiIZv2i8bvcfpRKPPOJmYaPFHPX';

    reCaptchaScriptLoaded=false;

    connectedCallback() {

        if (!this.reCaptchaScriptLoaded) {

            loadScript(this, RECAPTCHA_SCRIPT)

                .then(() => {

                    this.reCaptchaScriptLoaded = true;

                    // Initialize reCAPTCHA after script is loaded
console.log('captcha loaded');
                    grecaptcha.render(this.template.querySelector('.g-recaptcha'), {

                        'sitekey': this.siteKey,

                        'callback': this.handleRecaptchaSuccess,
                        'expired-callback':this.handleRecaptchaExpired,

                    });

                })

                .catch(error => {

                    console.error('Error loading reCAPTCHA script:', error);

                });

        }

    }

 

    handleRecaptchaSuccess(token) {

        // Handle the reCAPTCHA success, you can validate the token here

        // You may want to store it in a variable and include it in your server-side request

        console.log('reCAPTCHA Token:', token);

    }
handleRecaptchaExpired()
    {
console.log('expired');
grecaptcha.reset();
    }

 

    handleSubmit() {

        // Handle your form submission here, you can check the reCAPTCHA token before proceeding

    }

}