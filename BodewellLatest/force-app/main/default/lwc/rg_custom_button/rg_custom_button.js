import { LightningElement, api } from 'lwc';
import basepath from '@salesforce/community/basePath';
export default class Rg_custom_button extends LightningElement {

    @api buttonLabel = 'SCHEDULE SERVICE ONLINE';
    @api buttoncolor = '#ffc01f';
    @api buttoncolorhover = '#FFC739';
    @api buttontextcolor = '#333333';
    @api buttonAlign = 'Center';
    @api borderRadious;
    @api buttonWidth;    
    @api redirectURL;
    @api redirectionLink;
    @api navigationtype;
    @api showIcon = 'true';
    @api buttonArea = 'body';

    connectedCallback() {
        this.BasePath = basepath;
        if (this.navigationtype == 'Site Page') {
            this.redirectURL = this.BasePath + this.redirectionLink;
        }
        else if (this.navigationtype == 'External Link') {
            this.redirectURL = this.redirectionLink;
        }
    }

    renderedCallback() {        
        const buttonPosition = this.template.querySelector('.RG-button-cls');
        const buttonColor = this.template.querySelector('.custom-button-cmp');
        buttonColor.style.backgroundColor = this.buttoncolor;
        buttonColor.style.color = this.buttontextcolor;
        if(this.borderRadious) {
            buttonColor.style.borderRadious = this.borderRadious;
        }
        if(this.buttonWidth) {
            buttonColor.style.width = this.buttonWidth;
        }
        if (this.buttonAlign == 'Center') {
            buttonPosition.style.textAlign = 'center';
        }
        else if (this.buttonAlign == 'Right') {
            buttonPosition.style.textAlign = 'right';
        }
        else if (this.buttonAlign == 'Left') {
            buttonPosition.style.textAlign = 'left';
        }
    }

    handleClick(e) {
        if (this.buttonLabel.toLowerCase().indexOf('schedule service') > -1) {
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
        if (this.navigationtype == 'Site Page') {
            e.preventDefault();
            let reloadEvent = new CustomEvent(
                "rg_redirection", {
                detail: {
                    url: this.redirectURL
                }
            });
            document.dispatchEvent(reloadEvent, {
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
}