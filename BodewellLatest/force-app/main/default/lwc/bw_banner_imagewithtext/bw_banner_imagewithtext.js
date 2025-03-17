import { LightningElement, wire, api } from 'lwc';
import concierge from '@salesforce/resourceUrl/svgconcierge';
import contactno from '@salesforce/label/c.bw_NavBarContactNumber';
import Id from '@salesforce/community/Id';
import getContent from '@salesforce/apex/BDW_CMSController.getContent';
import basePath from '@salesforce/community/basePath';
export default class BDW_Banner_ImageWithText extends LightningElement{

    conciergesvg = concierge;

    uid = Id;
    isLoading = true;
    deskimgUrl;
    mobimgUrl;
    @api phone = contactno;
    @api showPhone = 'true';
    @api calltext1;
    @api calltext2;
    @api countrycode;
    title;
    error;
    desktopbanner;
    mobilebanner;
    @api textoverimage;
    @api rightalign = 'Right'
    @api leftalign = 'Left'
    @api centeralign = 'Center'
    @api imageheight = '550'
    @api textAlign;
    @api desktopimageId;
    @api textColor;
    @api mobileimageId;
    @api showIcon;
    isMobile = false;
    availheight = window.screen.availHeight;
    availwidth = window.screen.availWidth;
    get lefttext() {
        return this.textAlign === this.leftalign;
    }
    get righttext() {
        return this.textAlign === this.rightalign;
    }
    get centertext() {
        return this.textAlign === this.centeralign;
    }

    get bg() {
        return `background:linear-gradient( to right, rgba(0, 0, 0, 0), rgba(0, 0, 0, 0.6)), url(${this.banner})`
    }
    @wire(getContent, { contentId: '$desktopimageId', page: 0, pageSize: 1, language: 'en_US', filterby: '' })
    imageContentDesktop({ error, data }) {
        if (data) {
            this.title = data.title ? data.title.value : '';
            this.desktopbanner = data.source ? basePath + '/sfsites/c' + data.source.unauthenticatedUrl : this.deskimgUrl;
            console.log('Desktop Resource' + this.desktopbanner + 'Title' + this.title);
            const divs = this.template.querySelectorAll('div');
            divs.forEach(element => {
                if (element.classList.contains('background-set')) {
                    if (this.textAlign === this.leftalign || this.textAlign === this.centeralign) {
                        element.style.background = `linear-gradient(to left,rgba(255,255,255,0),rgba(0,0,0,.1),rgba(0,0,0,.75)), url(${this.desktopbanner})`;
                    }
                    if (this.textAlign === this.rightalign) {
                        element.style.background = `linear-gradient(to right,rgba(255,255,255,0),rgba(0,0,0,.1),rgba(0,0,0,.75)), url(${this.desktopbanner})`;
                    }
                    element.style.position = `relative`;
                    // element.style.height = `calc(100vh - ` + this.imageheight + `px)`;
                    element.style.height = this.imageheight + 'px';
                    element.style.width = `100%`;
                }
            });
            const textelements = this.template.querySelectorAll('h1');
            textelements.forEach(element => {
                if (element.classList.contains('container-text')) {
                    element.style.color = this.textColor;
                }
            });
            const textverticalalign = this.template.querySelector('.align-text');
            textverticalalign.style.height = `calc(` + this.imageheight + `px - 129px)`;
            const phonelink = this.template.querySelector('.phone-link');
            if(this.showPhone == true){
            phonelink.setAttribute('href', 'tel:+1' + this.phone);
            }
            this.isLoading = false;
        } else if (error) {
            console.log('error1: ', error);
        }
    }
    @wire(getContent, { contentId: '$mobileimageId', page: 0, pageSize: 1, language: 'en_US', filterby: '' })
    imageContentMobile({ error, data }) {
        if (data) {
            this.title = data.title ? data.title.value : '';
            this.mobilebanner = data.source ? basePath + '/sfsites/c' + data.source.unauthenticatedUrl : this.mobimgUrl;
            console.log('Mobile resource' + this.mobilebanner + 'Title' + this.title);
            this.availheight = window.screen.availHeight;
            this.availwidth = window.screen.availWidth;
            const divs = this.template.querySelectorAll('div');
            divs.forEach(element => {
                if (element.classList.contains('background-set')) {
                    if (this.availwidth <= 750) {
                        // this.isMobile = true;
                        if (this.textAlign === this.leftalign || this.textAlign === this.centeralign) {
                            element.style.background = `linear-gradient(to left,rgba(255,255,255,0),rgba(0,0,0,.1),rgba(0,0,0,.75)), url(${this.mobilebanner})`;
                        }
                        if (this.textAlign === this.rightalign) {
                            element.style.background = `linear-gradient(to right,rgba(255,255,255,0),rgba(0,0,0,.1),rgba(0,0,0,.75)), url(${this.mobilebanner})`;
                        }
                        element.style.height = '400px';
                        const textverticalalign = this.template.querySelector('.align-text');
                        textverticalalign.style.height = `calc(400px - 90px)`;
                    }
               }
            });
        } else if (error) {
            console.log('error: ', error);
        }
    }

    connectedCallback() {
        // window.addEventListener('resize', this.imageContentMobile);
    }
}