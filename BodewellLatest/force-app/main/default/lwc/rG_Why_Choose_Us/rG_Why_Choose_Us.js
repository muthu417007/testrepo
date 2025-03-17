import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import BasePath from '@salesforce/community/basePath';

export default class RG_Why_Choose_Us extends NavigationMixin(LightningElement)
{
   @api heading1 = 'WHY CHOOSE US';
   @api content1 = 'At GE Appliances Factory Service, we know GE Appliances inside and out.';
   @api heading2 = 'Certified Technicians';
   @api content2 = 'Our local professionals have the training, tools, and know-how to take complete care of your appliances.';
   @api heading3 = 'All Appliances Repaired';
   @api content3 = 'We fix all GE Appliances brands: GE, Profile, Café, Monogram, Hotpoint, Haier, and Adora.';
   @api heading4 = 'Reliable Service';
   @api content4 = 'Get fast, quality repairs backed by industry-leading warranties.';
   @api heading5 = 'Genuine Parts';
   @api content5 = 'We only use genuine GE Appliances parts.';
   @api icon1;
   @api icon2;
   @api icon3;
   @api icon4;
   @api buttonLabel = 'Learn More';
   @api redirectionLink;

   @track redirectURL;

   icon1Id;
   icon2Id;
   icon3Id;
   icon4Id;
   isOnlyServiceArea = false;

   connectedCallback() {
      if (this.redirectionLink) {
         this.redirectURL = BasePath + this.redirectionLink;
      }
      if (this.icon1) {
         this.icon1Id = BasePath + '/sfsites/c/cms/delivery/media/' + this.icon1;
      }
      if (this.icon2) {
         this.icon2Id = BasePath + '/sfsites/c/cms/delivery/media/' + this.icon2;
      }
      if (this.icon3) {
         this.icon3Id = BasePath + '/sfsites/c/cms/delivery/media/' + this.icon3;
      }
      if (this.icon4) {
         this.icon4Id = BasePath + '/sfsites/c/cms/delivery/media/' + this.icon4;
      }
   }

   handleClick(e) {
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

   @wire(CurrentPageReference)
   getStateParameters(CurrentPageReference) {
      if (CurrentPageReference.attributes.name == 'Service_Areas__c' &&
         !CurrentPageReference.state.servicearea) {
         this.isOnlyServiceArea = true;
      }
   }
}