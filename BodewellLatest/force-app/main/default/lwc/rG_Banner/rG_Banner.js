// purpose:- Repair GE banner
// Author:- Kanishtika Gupta
// Created By:- Kanishtika Gupta

import { LightningElement, api, wire } from 'lwc';
import BasePath from '@salesforce/community/basePath';
import netStyles from '@salesforce/resourceUrl/RG_StyleSheet';
import { loadStyle } from 'lightning/platformResourceLoader';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

export default class RG_Banner extends NavigationMixin(LightningElement)
{
   @api desktopimageId;
   @api mobileimageId;
   @api bannerheading = 'GE Appliances Factory Service';
   @api bannertext;
   @api imageheight = '190';
   @api showStrip = false;
   desktopbanner;
   mobilebanner;
   isStateArea = false;
   connectedCallback() {
      if (this.desktopimageId) {
         this.desktopbanner = BasePath + '/sfsites/c/cms/delivery/media/' + this.desktopimageId;
      }
      if (this.mobileimageId) {
         this.mobilebanner = BasePath + '/sfsites/c/cms/delivery/media/' + this.mobileimageId;
      }
   }
   renderedCallback() {
      Promise.all([
         loadStyle(this, netStyles)
     ])
      const divs = this.template.querySelectorAll('div');
      divs.forEach(element => {
         if (element.classList.contains('rgbanner')) {
            console.log('cms image');
            element.style.background = `linear-gradient(to left,rgba(255,255,255,0),rgba(0,0,0,.1),rgba(0,0,0,.75)), url(${this.desktopbanner})`;
            element.style.position = `relative`;
            element.style.top = '0px';
            element.style.height = this.imageheight + 'px';
         }
      });
      const textverticlealign = this.template.querySelector('.desk-only .heroborder');
      textverticlealign.style.height = this.imageheight + 'px';
   }
   @wire(CurrentPageReference)
   getStateParameters(CurrentPageReference) {
      if (CurrentPageReference.attributes.name == 'Service_Areas__c' &&
         CurrentPageReference.state.servicearea) {
         this.isStateArea = true;
      }
   }
}