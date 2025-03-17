import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import BasePath from '@salesforce/community/basePath';
import CMS_REF_URL from '@salesforce/label/c.CMS_Image_Reference_URL';

export default class RG_TroubleshootArticleCard extends NavigationMixin(LightningElement)
{
    @api cardTitle;
    @api cardDescription;
    @api buttonLabel;
    @api articleURL;
    @api tileImageId;

    redirectUrl;

    orgData = {
        basePath: BasePath,
        cmsReferenceUrl: CMS_REF_URL
    };

    tileImageRef;

    connectedCallback() {
        this.tileImageRef = this.orgData.basePath + this.orgData.cmsReferenceUrl + this.tileImageId;
        this[NavigationMixin.GenerateUrl]({
            type: 'comm__namedPage',
            attributes: {
              name: 'FAQ__c',
            }    
          }).then(url => {
            this.redirectUrl = url + '/article/' + this.articleURL;
        });
    }

    handleButtonClick(event) {        
        event.preventDefault();
        let reloadEvent = new CustomEvent(
            "rg_redirection", {
            detail: {
              url: this.redirectUrl
            }
          });
          document.dispatchEvent(reloadEvent, {
            bubbles: true,
            composed: true
          });
    }
}