import { LightningElement, api, wire, track } from 'lwc';
import RG_Schedule_Call from '@salesforce/label/c.RG_Schedule_Call';

import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubsub';

export default class RG_ScheduleService extends LightningElement {

    @api call = 'CALL TOLL-FREE TO SCHEDULE';
    @api tollfreenumber = '844-988-4066';    
    @api tollfreenumberlink = '';
    label = {
        RG_Schedule_Call
    }
    @api weekDay = "Monday-Friday: 8 a.m. - 9 p.m. ET"
    @api weekEnd = "Saturday-Sunday: 8 a.m. - 6 p.m. ET"

    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        // registerListener('localCityTollFreeNo', this.handleEvent, this);
        if(sessionStorage.getItem('serviceAreaPageHeader') == 'true')
        {
            fireEvent(this.pageRef, 'scheduleServiceCallback', 'true');
        }
        if(this.tollfreenumber){
            this.tollfreenumberlink = 'tel:' + this.tollfreenumber;
        }
        registerListener('tollFreeNoEvent', this.handleEvent, this);
        if(sessionStorage.getItem('dni_value') != 'true') {
            fireEvent(this.pageRef, 'tollefreeEventCallBack', 'true');
        }
    }

    handleEvent(inpVal) {
        this.tollfreenumber = inpVal;
        this.tollfreenumberlink = 'tel:' + this.tollfreenumber;
    }

    handleCall() {
        let contactUsCallEvent = new CustomEvent(
            "gtm__contactUsCall", {
            detail: {
                contact: this.tollfreenumber,
                contactClickLocation: 'footer'
            }
        });
        document.dispatchEvent(contactUsCallEvent, {
            bubbles: true,
            composed: true
        });
    }
}