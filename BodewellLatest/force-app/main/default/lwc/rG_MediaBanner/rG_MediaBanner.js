import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import BasePath from '@salesforce/community/basePath';
import getMediaServiceCity from '@salesforce/apex/RG_MediaController.getMediaServiceCity';
import RG_MEDIA from '@salesforce/contentAssetUrl/unknown_content_asset';
import RG_Partslink from '@salesforce/label/c.RG_Parts_Link';
import RG_ScheduleServiceLink from '@salesforce/label/c.RG_ScheduleServiceLink';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubsub';
import netStyles from '@salesforce/resourceUrl/RG_StyleSheet';
import { loadStyle } from 'lightning/platformResourceLoader';
import RG_DefaultTollFree from '@salesforce/label/c.RG_Schedule_Call';

export default class RG_MediaBanner extends LightningElement {

   imageheight = 370;
   bannerheading;
   certifiedbannerheading;
   cityflag = false;
   bannersubheading;
   bannercityheading;
   tollfreenumber;
   tollfreenumberlink;
   formattedtollfreenumber;
   partslink = RG_Partslink;
   scheduleservicelink = RG_ScheduleServiceLink;
   bannertext;
   desktopbanner;
   mobilebanner;
   service;
   city;
   imgUrl;
   mediaServiceCalled = false;
   validPage = false;
   notfound = true;
   eventFired = false;

   @wire(CurrentPageReference) pageRef;

   renderedCallback() {
      Promise.all([
         loadStyle(this, netStyles)
      ])
   }
   @wire(CurrentPageReference)
   getStateParameters(currentPageReference) {
      this.currentPageRef = currentPageReference;
      window.scrollTo(0, 0);
      if (this.currentPageRef.state.city) {
         this.city = this.currentPageRef.state.city;
      }
      if (this.currentPageRef.state.service) {
         this.validPage = true;
         this.service = this.currentPageRef.state.service;
         this.getMediaData();
      }
      if (!this.currentPageRef.state.city && !this.currentPageRef.state.service) {
         this.validPage = false;
         this.notfound = true;
         fireEvent(this.currentPageRef, 'isValidPage', this.validPage);
         fireEvent(this.currentPageRef, 'tollfreeEvent', RG_DefaultTollFree);
      }
   }

   connectedCallback() {
      registerListener('mediaContentEnabledCallBack', this.handleMediaFooterCallBack, this);
      if (sessionStorage.getItem('dni_value') != 'true') {
         fireEvent(this.currentPageRef, 'tollefreeEventCallBack', 'true');
      }
   }

   handleMediaFooterCallBack(e) {
      fireEvent(this.currentPageRef, 'mediaContentEnabled', this.validPage ? true : false);
   }

   initDNI() {
      this.formattedtollfreenumber = this.tollfreenumber.replace(/\D+/g, "");
      if (this.formattedtollfreenumber) {
         window.addEventListener('_st_mln_ready', (e) => {
            let dialogEvent = new CustomEvent(
               "st_event", {
               detail: {
                  phone: this.formattedtollfreenumber // need to pass 10 digit(8778882222) string format
               }
            });
            document.dispatchEvent(dialogEvent, {
               bubbles: true,
               composed: true
            });
         });
         // To trigger the event Listener
         document.addEventListener('trackingNumberEvent', (e) => {
            this.tollfreenumber = e.detail.value;
            this.tollfreenumberlink = 'tel:' + this.tollfreenumber;
            fireEvent(this.currentPageRef, 'tollfreeEvent', this.tollfreenumber);
         });
      }
   }

   getMediaData() {
      if (!this.mediaServiceCalled) {
         this.mediaServiceCalled = true;
         getMediaServiceCity({ service: this.service, city: this.city })
            .then(result => {
               if (result.success && result.mediaService && result.mediaService.length == 0) {
                  this.validPage = false;
                  this.notfound = false;
                  fireEvent(this.currentPageRef, 'mediaContentEnabled', false);
                  fireEvent(this.currentPageRef, 'isValidPage', this.validPage);
                  fireEvent(this.currentPageRef, 'tollfreeEvent', RG_DefaultTollFree);
               } else {
                  this.setMediaData(result);
               }
            })
            .catch(error => {
               this.error = error;
               console.error('getMediaServiceCity -> error response :', (JSON.stringify(error)));
               this.validPage = false;
               this.notfound = false;
               fireEvent(this.currentPageRef, 'isValidPage', this.validPage);
               fireEvent(this.currentPageRef, 'mediaContentEnabled', false);
               fireEvent(this.currentPageRef, 'tollfreeEvent', RG_DefaultTollFree);
            });
      }
   }

   setMediaData(data) {
      if (data.success && data.mediaService && data.mediaService.length > 0 && data.mediaService[0].Main_Header__c) {
         this.bannerheading = data.mediaService[0].Main_Header__c;
      }
      if (data.success && data.mediaService && data.mediaService.length > 0 && data.mediaService[0].Main_Header__c) {
         this.certifiedbannerheading = data.mediaService[0].CertifiedServiceHeader__c;
      }
      if (data.success && data.mediaService && data.mediaService.length > 0 && data.mediaService[0].Sub_Header__c) {
         this.bannersubheading = data.mediaService[0].Sub_Header__c;
      }
      if (data.success && data.mediaCity && data.mediaCity.length > 0 && data.mediaCity[0].City_Flag__c) {
         this.cityflag = data.mediaCity[0].City_Flag__c == '1' ? true : false;
      }
      if (data.success && data.mediaCity && data.mediaCity.length > 0 && data.mediaCity[0].Name__c) {
         let cityName = data.mediaCity[0].Name__c[0].toUpperCase() + data.mediaCity[0].Name__c.substring(1);
         this.bannercityheading = 'IN ' + cityName;
      }
      if (data.success && data.mediaService && data.mediaService.length > 0 && data.mediaService[0].Phone__c) {
         this.tollfreenumber = data.mediaService[0].Phone__c;
         this.tollfreenumberlink = 'tel:' + data.mediaService[0].Phone__c;
      }
      if (this.cityflag && data.mediaCity && data.mediaCity.length > 0 && data.mediaCity[0].City_Phone__c) {
         this.tollfreenumber = data.mediaCity[0].City_Phone__c;
         this.tollfreenumberlink = 'tel:' + data.mediaCity[0].City_Phone__c;
      }
      if (data && data.mediaService && data.mediaService.length > 0 && data.mediaService[0].Image__c) {
         this.desktopbanner = RG_MEDIA + '?pathinarchive=media/' + data.mediaService[0].Image__c + '.png';
         this.mobilebanner = RG_MEDIA + '?pathinarchive=media/m-' + data.mediaService[0].Image__c + '.png';
         const divs = this.template.querySelectorAll('div');
         divs.forEach(element => {
            if (element.classList.contains('rgbanner')) {
               element.style.background = `linear-gradient(to left,rgba(255,255,255,0),rgba(0,0,0,.1),rgba(0,0,0,.75)), url(${this.desktopbanner})`;
               element.style.position = `relative`;
               element.style.top = '0px';
               element.style.height = this.imageheight + 'px';
            }
         });
         const textverticlealign = this.template.querySelector('.desk-only .heroborder');
         textverticlealign.style.height = this.imageheight + 'px';
      }

      if (data && data.mediaService && data.mediaService.length > 0 && data.mediaService[0].Title_Tag__c) {
         let titleLabel = data.mediaService[0].Title_Tag__c.split('|');
         let documentTitle = titleLabel[0] + 'in ' + this.city[0].toUpperCase() + this.city.substring(1) + ' |' + titleLabel[1];
         document.title = documentTitle;
      }

      if (data && data.mediaService && data.mediaService.length > 0 && data.mediaService[0].Description_Tag__c) {
         var meta = document.createElement("meta");
         meta.setAttribute("name", "description");
         meta.setAttribute("content", data.mediaService[0].Description_Tag__c);
         document.getElementsByTagName('head')[0].appendChild(meta);
      }

      fireEvent(this.currentPageRef, 'tollfreeEvent', this.tollfreenumber);
      fireEvent(this.currentPageRef, 'mediaContentEnabled', true);


      this.initDNI();
      this.pageViewEvent();
   }

   handleSchedule() {
      // if (this.buttonlabel.toLowerCase().indexOf('schedule service') > -1) {
      let scheduleServiceEvent = new CustomEvent(
         "gtm__serviceSchedule", {
         detail: {
            clickLocation: 'body'
         }
      });
      document.dispatchEvent(scheduleServiceEvent, {
         bubbles: true,
         composed: true
      });
      // }
   }

   handleCallTollFree() {
      let contactUsCallEvent = new CustomEvent(
         "gtm__contactUsCall", {
         detail: {
            contact: this.tollfreenumber,
            contactClickLocation: 'body'
         }
      });
      document.dispatchEvent(contactUsCallEvent, {
         bubbles: true,
         composed: true
      });
   }

   pageViewEvent() {
      if(!this.eventFired) {
          let pageViewEvent = new CustomEvent("gtm__pageView");
          document.dispatchEvent(pageViewEvent, {
              bubbles: true,
              composed: true
          });      
          this.eventFired = true;
      }  
  }

   disconnectedCallback() {
      unregisterAllListeners(this);
   }
}