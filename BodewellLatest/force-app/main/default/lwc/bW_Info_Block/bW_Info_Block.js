// purpose:- Bodewell Information Block with image text and button
// Author:- Kanishtika Gupta
// Created By:- Kanishtika Gupta
import { LightningElement,api ,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import concierge from '@salesforce/resourceUrl/svgconcierge';
import Path from '@salesforce/community/basePath';
export default class BW_Info_Block extends NavigationMixin(LightningElement){
    @api contentId;
    @api richtext;
    @api buttontext;
    @api buttonwidth = '16';
    @api showImg = 'false';
    @api showHeading = 'true';
    @api redirectionlink;
    @api heading;
    @api imgUrl;
    redirectURL;
    banner;
    conciergesvg = concierge;
    BasePath;
    connectedCallback() {
        this.BasePath = Path;
        this.redirectURL = this.BasePath + this.redirectionlink;

        if (this.contentId) {
           this.imgUrl = this.BasePath + '/sfsites/c/cms/delivery/media/' + this.contentId;
        }
     }
     renderedCallback() {
        if(this.showImg == true){
            //imageSource.setAttribute('src',this.banner);
            const heading = this.template.querySelector('.cta-link-block');
            heading.style.height = '430px';
            const content = this.template.querySelector('.inner-content');
            content.style.padding = '0 20%';
            }
            const buttonsize = this.template.querySelector('.basic-info-button ');
            buttonsize.style.width = this.buttonwidth + 'rem';
     }
     handleClick(){
        this.BasePath = Path;
        console.log( this.redirectURL);
    }
}