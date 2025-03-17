import { LightningElement, wire, track } from 'lwc';

import getParameters from '@salesforce/apex/BWC_CybersourcePOCController.getParameters';

export default class bwc_cybersourcePOC extends LightningElement {
    _parametersValues;

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

    @track
    _cybersourceData = 'no data yet';

    _listenerAdded;
    connectedCallback() {
        if (!this._listenerAdded) {
            if (window.addEventListener) {
                console.log('bwc_cybersourcePOC::window.addEventListener');
                window.addEventListener('message', (message) => {
                    this._cybersourceData = JSON.stringify(message.data);
                    console.log(`bwc_CybersourcePOC::message.data = ${JSON.stringify(message.data, null, 2)}`);
                }, false);
            }
        }
    }

    submitForm() {
      let win = window.open('', '_cybersourcePayment');
      this.template.querySelector('form').submit();
    }
}