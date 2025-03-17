import { LightningElement, track } from 'lwc';
import contNumber from '@salesforce/label/c.bw_NavBarContactNumber';

export default class Bdw_callingNumber extends LightningElement 
{
    contactNumber = contNumber;
    @track dniContactNumber;

    handleClick()
    {
        this.dniContactNumber = this.template.querySelector('.phone').innerHTML;
        this.gtmEvent();
        window.location = "tel:+1" + this.dniContactNumber.replaceAll('-','');
        //window.location = "tel:+1" + contNumber.replaceAll('-','');
    }

    gtmEvent() {
        let contactUsCallEvent = new CustomEvent(
            'gtm__contactUsCall', {
            detail: {
                contact: "Call toll-free to schedule"
            }
        });
        document.dispatchEvent(
            contactUsCallEvent, {
            bubbles: true,
            composed: true
        });
    }
}