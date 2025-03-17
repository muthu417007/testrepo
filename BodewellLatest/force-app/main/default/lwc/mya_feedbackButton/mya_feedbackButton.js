import { LightningElement, api } from 'lwc';

// Templates
import Cafe from "./mya_feedbackButton_Cafe.html";
import GEA from "./mya_feedbackButton_GEA.html";
import Haier from "./mya_feedbackButton_Haier.html";


import MYAGEACSS from '@salesforce/resourceUrl/MYAGEACSS';
import MYACAFECSS from '@salesforce/resourceUrl/MYACAFECSS';
import MYAHAIERCSS from '@salesforce/resourceUrl/MYAHAIERCSS';


import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

import MedalliaDigitalTool from '@salesforce/resourceUrl/MedalliaDigitalTool';

export default class Mya_feedbackButton extends LightningElement {

    @api brand = 'GEA';

    render() {
        if (this.brand == "GEA") {
            return GEA;
        } else if (this.brand == "Haier") {
            return Haier;
        } else if (this.brand == "Cafe") {
            return Cafe;
        }
    }

    callKamply() {
        try {
            document.dispatchEvent(new CustomEvent('feedbackCall', { detail: this.brand }), { bubbles: true, composed: true });
        } catch (ex) {
            console.error("Test Case error: ", ex);
        }
    }



}