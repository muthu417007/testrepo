import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubsub';
import netStyles from '@salesforce/resourceUrl/RG_StyleSheet';
import { loadStyle } from 'lightning/platformResourceLoader';
import BasePath from '@salesforce/community/basePath';
import RG_DefaultTollFree from '@salesforce/label/c.RG_Schedule_Call';

export default class RG_ImageWithText_Card extends LightningElement {
    @api imageiconid;
    @api heading = 'SCHEDULE SERVICE';
    @api content = 'Schedule service online or call us toll-free at';
    @api isPhoneNumber = false;
    @api phone = RG_DefaultTollFree;
    @api showicon = 'true';
    @api buttonlabel = 'SCHEDULE SERVICE ONLINE';
    @api buttoncolor = '#ffc01f';
    @api buttoncolorhover = '#f7f1e7';
    @api buttontextcolor = '#333333';
    @api buttonalign = 'Center';
    @api redirectionlink;
    @api navigationtype;
    @api buttonArea;
    
    @track redirectURL;
    @track formattedphone;

    imageicon;    
    phoneLink;
    beforeContent;
    afterContent;
    linkArea = 'body';
    BasePath;

    @wire(CurrentPageReference) pageRef;

    renderedCallback() {
        Promise.all([
            loadStyle(this, netStyles)
        ])
        const buttonPosition = this.template.querySelector('.RG-button-cls');
        const buttonColor = this.template.querySelector('.custom-button-cmp');
        buttonColor.style.backgroundColor = this.buttoncolor;
        buttonColor.style.color = this.buttontextcolor;
        if (this.buttonalign == 'Center') {
            buttonPosition.style.textAlign = 'center';
        }
        else if (this.buttonalign == 'Right') {
            buttonPosition.style.textAlign = 'right';
        }
        else if (this.buttonalign == 'Left') {
            buttonPosition.style.textAlign = 'left';
        }
        if (this.imageiconid) {
            this.imageicon = BasePath + '/sfsites/c/cms/delivery/media/' + this.imageiconid;
        }
    }

    connectedCallback() {        
        if (this.navigationtype == 'Site Page') {
            this.redirectURL = BasePath + this.redirectionlink;
        }
        if (this.navigationtype == 'External Link') {
            this.redirectURL = this.redirectionlink;
            console.log(this.redirectURL);
        }
        if (this.isPhoneNumber) {
            this.phoneLink = 'tel:' + this.phone;
            this.formattedphone = this.phone.replace(/\D+/g, "");
            let contentArray = this.content.split('*');
            this.beforeContent = contentArray[0];
            this.afterContent = contentArray[1];
        }
        registerListener('tollFreeNoEvent', this.handleTollfreeNumber, this);
        if (sessionStorage.getItem('dni_value') != 'true') {
            fireEvent(this.pageRef, 'tollefreeEventCallBack', 'true');
        }
    }

    handleClick(e) {
        if (this.buttonlabel.toLowerCase().indexOf('schedule service') > -1) {
            let scheduleServiceEvent = new CustomEvent(
                "gtm__serviceSchedule", {
                detail: {
                    clickLocation: this.buttonArea
                }
            });
            document.dispatchEvent(scheduleServiceEvent, {
                bubbles: true,
                composed: true
            });
        }
    }
    handleOverColor() {
        const buttonColor = this.template.querySelector('.custom-button-cmp');
        buttonColor.style.backgroundColor = this.buttoncolorhover;
    }
    handleOutColor() {
        const buttonColor = this.template.querySelector('.custom-button-cmp');
        buttonColor.style.backgroundColor = this.buttoncolor;
    }

    handleTollfreeNumber(val) {
        debugger;
        this.phone = val;
        this.phoneLink = 'tel:' + this.phone;
        sessionStorage.removeItem('dni_value');
    }

    handleContact(event) {
        let contactUsCallEvent = new CustomEvent(
            "gtm__contactUsCall", {
            detail: {
                contact: this.phone,
                contactClickLocation: this.linkArea
            }
        });
        document.dispatchEvent(contactUsCallEvent, {
            bubbles: true,
            composed: true
        });
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }
}