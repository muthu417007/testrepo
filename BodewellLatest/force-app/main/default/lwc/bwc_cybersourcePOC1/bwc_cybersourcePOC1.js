import { LightningElement, wire} from 'lwc';
import { SessionContextAdapter } from 'commerce/contextApi';

import getParameters from '@salesforce/apex/BWC_CybersourcePOCController.getParameters';

export default class bwc_cybersourcePOC extends LightningElement {

    @wire(SessionContextAdapter) // <-- design-time only
    wireSessionContext({ data }) {
        this._sessionContext = data;
    }

    _parametersValues;
    _submittedForm;

    @wire(getParameters)
    wiredGetParameters({data, error}) {
        if (error) {
            console.log('wiredGetParameters()::error' + JSON.stringify(error, null, 2));
        } else {
            this._parametersValues = [];
            for(let key in data) {
                this._parametersValues.push({
                    key: key,
                    value: data[key]
                });
            }
        }
    }

    renderedCallback() {
        if (!this._sessionContext && this._parametersValues?.length > 0) {
            setTimeout(this.submitForm.bind(this), 3000);
        }
    }

    submitForm() {
        console.log(`inside submitForm()`);
        if (!this._submittedForm ) {
            this._submittedForm = true;
            console.log(`submitting form`);
            this.template.querySelector('form').submit();
        }
    }
}