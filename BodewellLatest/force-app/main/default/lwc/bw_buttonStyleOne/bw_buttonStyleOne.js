import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import basepath from '@salesforce/community/basePath';
import contNumber from '@salesforce/label/c.bw_NavBarContactNumber';

import StyleOne from "./bw_buttonStyleOne.html";
import StyleTwo from "./bw_buttonStyleTwo.html";
import StyleThree from "./bw_buttonStyleThree.html";

export default class Bw_buttonStyleOne extends NavigationMixin(LightningElement) {
    @api ButtonLabel;
    @api RedirectionLink;
    @api ButtonStyle = "StyleOne";
    @api ButtonAlign = "Center";
    @api ButtonOperation = 'Navigation';
    @api redirectURL;
    @api ButtonWidth = 15;
    @api ButtonMarginleft=2;
    @api ButtonMarginRight=2;
    BasePath;
    @track dniContactNumber;

    connectedCallback() {
        this.BasePath = basepath;
    }

    render() {
        if (this.ButtonStyle == "StyleOne") {
            return StyleOne;
        } else if (this.ButtonStyle == "StyleTwo") {
            return StyleTwo;
        } else if (this.ButtonStyle == "StyleThree") {
            return StyleThree;
        }
    }
    get buttonPosition() {
        return 'text-align:' + this.ButtonAlign +';margin-left:' + this.ButtonMarginleft+'rem;margin-right:'+ this.ButtonMarginRight+'rem';
    }
    get rightbutton() {
        return this.ButtonAlign === this.rightalign;
    }
    get centerbutton() {
        return this.ButtonAlign === this.centeralign;
    }
    get buttonwidth() {
        return 'min-width:' + this.ButtonWidth + 'rem';
    }

    handleClick(e) {
        // if (this.ButtonOperation == 'Calling') {
        //     window.location = "tel:+1" + contNumber.replaceAll('-','');
        // } else if (this.ButtonOperation == 'Navigation') {
        //     this.redirectURL = this.BasePath + this.RedirectionLink;
        // }
        debugger;
        this.dniContactNumber = this.template.querySelector('.dni-number').innerHTML;
        if (this.ButtonOperation == 'Calling') {
            window.location = "tel:+1" + this.dniContactNumber.replaceAll('-','');
        } else if (this.ButtonOperation == 'Navigation') {
            this.redirectURL = this.BasePath + this.RedirectionLink;
        }
    }
}