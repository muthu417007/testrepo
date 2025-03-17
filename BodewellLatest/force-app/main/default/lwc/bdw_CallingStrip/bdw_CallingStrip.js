import { LightningElement, wire, api } from 'lwc';
import contNumber from '@salesforce/label/c.bw_NavBarContactNumber';
import concierge from '@salesforce/resourceUrl/svgconcierge';

export default class Bdw_CallingStrip extends LightningElement {
    conciergesvg = concierge;
    contactNumber = contNumber;

    @api calltext1;
    @api calltext2;
    @api FontSize = "18px";
    @api FontColor = '#fff';
    @api FontColorPhone = "#fff";
    @api IconColor = 'Black';

    isIconBlack = false;

    handleClick() {
        this.gtmEvent();
        window.location = "tel:+1" + contNumber.replaceAll('-', '');
    }
    renderedCallback() {

        const textelement = this.template.querySelectorAll('.phone-number');
        textelement.forEach(element => {
            if (element.classList.contains('phone-number')) {
                element.style.color = this.FontColor;

            }
        });

        const textelement2 = this.template.querySelectorAll('.semiBold');
        textelement2.forEach(element => {
            if (element.classList.contains('semiBold')) {
                element.style.color = this.FontColorPhone;
            }
        });

        if (this.IconColor == 'Black') {
            this.isIconBlack = true;
        }


    }
    get fontSize() {
        return 'font-size:' + this.FontSize + 'px' + '' + '!important';
    }

    gtmEvent() {
        let contactUsCallEvent = new CustomEvent(
            'gtm__contactUsCall', {
            detail: {
                contact: this.calltext1 + " " + contNumber + " " + this.calltext2
            }
        });
        document.dispatchEvent(
            contactUsCallEvent, {
            bubbles: true,
            composed: true
        });
    }
}