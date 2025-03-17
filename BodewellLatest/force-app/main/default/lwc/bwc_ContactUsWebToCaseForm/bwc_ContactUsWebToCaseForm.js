import { LightningElement, track,api,wire } from 'lwc';

import { loadScript } from 'lightning/platformResourceLoader';
import SITE_KEY from '@salesforce/label/c.BWC_Recaptcha_Site_key';
import RECAPTCHA_SCRIPT from '@salesforce/resourceUrl/BWC_recaptchv2';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import Case_OBJECT from '@salesforce/schema/Case';
import State_FIELD from '@salesforce/schema/Case.State__c';

export default class Bwc_ContactUsWebToCaseForm extends LightningElement {

    @track _ReasonForMessage;
 /**
 * Post url in form
 * @type {String}
 */
@api action
 /**
 * org id 
 * @type {String}
 */
 @api orgid;

  /**
 * Redirect url after submit
 * @type {String}
 */
 @api retURL;


 @api
 get reasonForMessageOptions() {
     return this._ReasonForMessage;
 }
 set reasonForMessageOptions(val) {
    console.log("val====" + val);
     this._ReasonForMessage = val.split(",");
     console.log("_cReasonForMessage====" + this._ReasonForMessage);
 }


 @track isSuccess = true;
    @track siteKey =SITE_KEY;
@track stateValues;
 
    @wire(getObjectInfo, { objectApiName: Case_OBJECT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: State_FIELD})
    StatePicklistValues({error,data})
    {
        if(data)
        {
           // console.log('StatePicklistValues=='+JSON.stringify(data.values));
            this.stateValues=data.values;
    
        }
        else if(error)
        {
            console.log(JSON.stringify(error));
        }
    }
   

 connectedCallback()
 {
    console.log('StatePicklistValues=='+JSON.stringify(this.StatePicklistValues.data));

 }
 

    renderedCallback() {
        if (!this.reCaptchaScriptLoaded) {

            loadScript(this, RECAPTCHA_SCRIPT)

                .then(() => {

                    this.reCaptchaScriptLoaded = true;

                    // Initialize reCAPTCHA after script is loaded
console.log('captcha loaded');
                    grecaptcha.render(this.template.querySelector('.g-recaptcha'), {

                        'sitekey': this.siteKey,
                        'callback': this.handleRecaptchaSuccess.bind(this),
                        'expired-callback':this.handleRecaptchaExpired.bind(this),

                    });

                })

                .catch(error => {

                    console.error('Error loading reCAPTCHA script:', error);

                });

        }

    }

 

    handleRecaptchaSuccess(token) {
        console.log('reCAPTCHA Token:', token);
        // Handle the reCAPTCHA success, you can validate the token here

        // You may want to store it in a variable and include it in your server-side request
this.isSuccess=false;
       

    }
handleRecaptchaExpired()
    {
console.log('expired');
this.isSuccess=true;
grecaptcha.reset();
    }
  

   

    // constructor() {
    //     super();
    //     this.navigateTo = pageUrl;
    //     window.addEventListener("message", this.listenForMessage.bind(this));//add event listener for message that we post in our recaptchaV2 static resource html file.
    // }

  

    // captchaLoaded(event) {
    //     if (event.target.getAttribute('src') == pageUrl) {
    //         console.log('Google reCAPTCHA is loaded.');
    //     }
    // }

    // listenForMessage(message) {
    //     this.isSuccess = false;
      
    //     console.log('message data : ' + message.data);
    //     if(message.data==='captcha Expired')
    //     {
    //         this.isSuccess = true;
    //     }
    // }
   
}