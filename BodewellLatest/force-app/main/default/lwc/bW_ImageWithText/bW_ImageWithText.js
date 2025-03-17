import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import BasePath from '@salesforce/community/basePath';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubsub';

export default class BW_ImageWithText extends LightningElement {
    @api imageiconid;
    @api content;
    @api showicon;
    @api imagewidth;
    @api redirectionlink;
    @api contentArea;
    @api callLink;
    @api contentSection;
    @api calltextcontent;
    imageicon;
    @track contentBody;
    isVisibleIcon;
    redirectionUrl;
    contentarea;
    formattedlink;
    rendered = false;
    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        registerListener('bwtollFreeNoEvent', this.handleTollFreeEvent, this);
        if (this.imageiconid) {
            this.imageicon = BasePath + '/sfsites/c/cms/delivery/media/' + this.imageiconid;
        }
        if (this.showicon) {
            this.isVisibleIcon = this.showicon;
        }
        if (this.content && this.content.indexOf('/') == -1) {
            this.contentBody = this.content;
        }
        if (this.content && this.content.indexOf('/') > -1) {
            let contentArray = this.content.split('/');
            this.beforeContent = contentArray[0];
            this.linkContent = contentArray[1];
            this.afterContent = contentArray[2];
            this.contentBody = this.beforeContent + this.linkContent + this.afterContent;
        }
        if (this.redirectionlink) {
            this.redirectionUrl = this.redirectionlink;
            this.setRedirectionlink();
        }
        if (this.contentArea) {
            this.contentarea = this.contentArea;
        }
        if (this.calltextcontent) {
            this.setRedirectionlink();
        }

        if (this.callLink) {
            document.addEventListener('callBack_st_img_with_text', (e) => {
                console.log('DNI No: ', e.detail.value);
                this.linkContent = e.detail.value;
                this.redirectionUrl = 'tel:' + this.linkContent;
                this.setRedirectionlink();
            });
        }
    }

    handleTollFreeEvent(inpVal) {
        this.fireStEvent();
    }

    fireStEvent() {
        this.formattedlink = this.linkContent.replace(/\D+/g, "");
        let dialogEvent = new CustomEvent(
            "st_event_img_with_text", {
            detail: {
                phone: this.formattedlink // need to pass 10 digit(8778882222) string format
            }
        }
        );
        document.dispatchEvent(dialogEvent, {
            bubbles: true,
            composed: true
        });
    }

    setRedirectionlink() {
        this.contentBody = this.beforeContent + '<a class="image-with-text-link" onclick={handleCallClick} href="' + this.redirectionUrl + '">' + this.linkContent + '</a>' + this.afterContent;
        if(this.rendered) {
            this.setContent();
        }
    }

    renderedCallback() {
        this.rendered = true;
        this.setContent();
    }

    setContent() {
        if (this.contentBody) {
            const container = this.template.querySelector('.content-body');
            container.innerHTML = '<span class="content-body-span">' + this.contentBody + '</span>';
        }
        if (this.contentSection) {
            this.template.querySelector('.image-with-text').classList.add(this.contentSection);
        }
        if (this.showicon && this.imagewidth) {
            this.template.querySelector('.img-cnt').style.width = this.imagewidth + 'rem';
        }
        if (this.calltextcontent) {
            const textcontentblock = this.template.querySelector('.calltextcontentblock');
            textcontentblock.innerHTML = '<span>' + this.calltextcontent + '</span>';
        }
    }

    handleCallClick() {
        if (this.callLink) {
            let contactUsCallEvent = new CustomEvent(
                "gtm__contactUsCall", {
                detail: {
                    contact: this.linkContent,
                    contactClickLocation: this.contentArea
                }
            });
            document.dispatchEvent(contactUsCallEvent, {
                bubbles: true,
                composed: true
            });
        }
    }
}