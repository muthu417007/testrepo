import { LightningElement } from "lwc";
import getSiteKey from '@salesforce/apex/RecaptchaV2Controller.getSiteKey';

export default class RecaptchaV2 extends LightningElement {
    _setRecaptchaResponse;

    connectedCallback() {
        this.addRecaptchaEventListener();

        getSiteKey().then(function(sitekey) {
            document.dispatchEvent(
                new CustomEvent('geaidm__recapcha', { 
                    detail: { 
                        sitekey: sitekey
                    } }
                )
            );
        });
    }

    disconnectedCallback() {
        document.removeEventListener("grecaptchaVerified", this._setRecaptchaResponse);
    }

    renderedCallback() {
        var divElement = this.template.querySelector("div.recaptchaCheckbox");
        var payload = { element: divElement };
        document.dispatchEvent(new CustomEvent("grecaptchaRender", { detail: payload }));
    }

    addRecaptchaEventListener() {
        this._setRecaptchaResponse = this.setRecaptchaResponse.bind(this);
        document.addEventListener("grecaptchaVerified", this._setRecaptchaResponse);
    }

    setRecaptchaResponse(e) {
        const passEvent = new CustomEvent("verified", {
            detail: { response: e.detail.response }
        });
        this.dispatchEvent(passEvent);
    }
}