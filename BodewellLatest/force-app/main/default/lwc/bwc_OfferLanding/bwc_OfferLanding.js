import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import qrcode from './bwc_QRCodeHelper.js';
import getCouponCode from '@salesforce/apex/BWC_LeadExchangeEmailHelper.getCouponCode';

export default class Bwc_OfferLanding extends LightningElement {

   refId = null;
   couponcode = null;
   domLoaded = false;
   isLoading = false;
   couponCodeRequested = false;
   storeInfo = null;
   storeIcon = null;
   storeAddress = null;
   storeTimimgStatus = null;
   storeDirection = null;
   storePhone = null;
   storePhoneLink = null;
   storePromotionTerms = null;
   storePromotionText = 'Present this personal offer code to an associate at your local';
   couponVisible = false;
   isInvalid = false;

   get viewCodeLabel() {
      if(this.couponVisible) {
         return 'Hide';
      } else {
         return 'View';
      }
   }

   renderedCallback() {
      this.domLoaded = true;
      this.setQR();
   }

   @wire(CurrentPageReference)
   getStateParameters(currentPageReference) {
      if (currentPageReference) {
         this.refId = currentPageReference.state?.ref;
         if (this.couponCodeRequested == false) {
            this.getReferralCode(this.refId);
         }
      }
   }

   getReferralCode(refId) {
      this.couponCodeRequested = true;
      this.isLoading = true;
      getCouponCode({ key: refId }).then(response => {
         if (response.success) {
            console.log('response.data : ', response.data);
            this.couponcode = response.data.coupon;
            this.storeInfo = response.data.account;
            this.storeAddress = this.storeInfo.ShippingStreet + ', ' + this.storeInfo.ShippingCity + ', ' + this.storeInfo.ShippingState + ' ' + this.storeInfo.ShippingPostalCode;
            this.storeIcon = this.storeInfo.Seller_Logo__c;
            this.storePhone = this.storeInfo.Phone;
            this.storePhoneLink = 'tel:' + this.storeInfo.Phone;
            this.storePromotionTerms = response.data.promotions.promotionTerms;
            this.storePromotionText = this.storePromotionText + ' ' + this.storeInfo.Party_Name__c + ' store and ' + response.data.promotions.promotiontext;
            this.storeTimimgStatus = this.getStoreTimingStatus(response.data.storeHours);
            this.getStoreDirection(this.storeInfo);
            this.setQR();
            this.isLoading = false;
            this.isInvalid = false;
         } else {
            console.error('error : ', response.error);
            this.isLoading = false;
            this.isInvalid = true;
         }
      }).catch(error => {
         console.error('error : ', error);
         this.isLoading = false;         
         this.isInvalid = true;
      });
   }

   getStoreDirection() {
      if (localStorage.getItem("zipcode") === null) {
         if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => {
               this.currentLatitude = position.coords.latitude;
               this.currentLongitude = position.coords.longitude;
               this.currentLoc = this.currentLatitude + ',' + this.currentLongitude;
               let dest = this.storeInfo.Party_Name__c + ', ' + this.storeInfo.ShippingStreet + ', ' + this.storeInfo.ShippingCity + ', ' + this.storeInfo.ShippingState + ', ' + this.storeInfo.ShippingPostalCode;
               this.storeDirection = 'https://www.google.com/maps/dir/?api=1&origin=' + encodeURIComponent(this.currentLoc) + '&destination=' + encodeURIComponent(dest) + '&travelmode=driving';
            });
         }
      } else {
         let zipCodeInfo = JSON.parse(localStorage.getItem('zipcode'));
         this.currentLoc = zipCodeInfo.City + ',' + zipCodeInfo.State + ',' + zipCodeInfo.Country;
         let dest = this.storeInfo.Party_Name__c + ', ' + this.storeInfo.ShippingStreet + ', ' + this.storeInfo.ShippingCity + ', ' + this.storeInfo.ShippingState + ', ' + this.storeInfo.ShippingPostalCode;
         this.storeDirection = 'https://www.google.com/maps/dir/?api=1&origin=' + encodeURIComponent(this.currentLoc) + '&destination=' + encodeURIComponent(dest) + '&travelmode=driving';
      }
      
   }

   setQR() {
      if (this.domLoaded && this.couponcode) {
         try {
            const qrCodeGenerated = new qrcode(0, 'H');
            let strForGenearationOfQRCode = this.couponcode;
            qrCodeGenerated.addData(strForGenearationOfQRCode);
            qrCodeGenerated.make();
            let element = this.template.querySelector(".qrcode2");
            element.innerHTML = qrCodeGenerated.createSvgTag({});
         } catch (err) {
            console.error(err);
            alert('qr logic error');
         }
      }
   }

   getStoreTimingStatus(input) {
      let currentD = new Date();
      console.log(currentD.toLocaleString());
      let currentinfo = input.filter(item => item.dayOfWeek == currentD.toLocaleString('en-us', { weekday: 'long' }))[0];
      let nextdayinfo = this.getNextDate(currentD, input);
      let nextstart = nextdayinfo.strStartTime.split(':');
      let nextstartTime = new Date();
      nextstartTime.setHours(nextstart[0], nextstart[1]);
      let nextDayOfWeek = nextdayinfo.dayOfWeek.substring(0, 3);
      if (currentinfo.type == 'Holiday') {
         return {
            isOpened: false,
            isClosing: false,
            isOpening: false,
            nextDayStarting: this.formatAMPM(nextstartTime)
         }

      } else {
         let start = currentinfo.strStartTime.split(':');
         let end = currentinfo.strEndTime.split(':');
         let startTime = new Date();
         startTime.setHours(start[0], start[1]);
         let nearStartTime = new Date();
         nearStartTime.setHours(Number(start[0]) - 1, start[1]);
         let endTime = new Date();
         endTime.setHours(end[0], end[1]);
         let nearEndTime = new Date();
         nearEndTime.setHours(Number(end[0]) - 1, end[1]);
         if (currentD >= startTime && currentD < endTime && currentD > nearEndTime) {
            return {
               isOpened: true,
               isClosing: true,
               isOpening: false,
               closingTime: this.formatAMPM(endTime),
               nextDayStarting: this.formatAMPM(nextstartTime),
               nextDayOfWeek: nextDayOfWeek
            }
         } else if (currentD >= startTime && currentD < endTime) {
            return {
               isOpened: true,
               isClosing: false,
               isOpening: false,
               closingTime: this.formatAMPM(endTime),
            }
         } else if (currentD < startTime && currentD >= nearStartTime) {
            return {
               isOpened: false,
               isClosing: false,
               isOpening: true,
               openingTime: this.formatAMPM(startTime),
               nextDayStarting: this.formatAMPM(nextstartTime),
               nextDayOfWeek: nextDayOfWeek
            }
         } else {
            return {
               isOpened: false,
               isClosing: false,
               isOpening: false,
               nextDayStarting: this.formatAMPM(nextstartTime),
               nextDayOfWeek: nextDayOfWeek
            }
         }
      }
   }

   getNextDate(today, input) {
      let tomorrow = new Date(today);
      tomorrow.setDate(tomorrow.getDate() + 1);
      let tomorrowinfo = input.filter(item => item.dayOfWeek == tomorrow.toLocaleString('en-us', { weekday: 'long' }))[0];
      if (tomorrowinfo.type == 'Holiday') {
         this.getNextDate(tomorrow);
      } else {
         return tomorrowinfo;
      }
   }

   formatAMPM(date) {
      var hours = date.getHours();
      var minutes = date.getMinutes();
      var ampm = hours >= 12 ? 'pm' : 'am';
      hours = hours % 12;
      hours = hours ? hours : 12; // the hour '0' should be '12'
      minutes = minutes < 10 ? '0' + minutes : minutes;
      var strTime = hours + ':' + minutes + ' ' + ampm;
      return strTime;
   }

   handleViewCode() {
      this.couponVisible = !this.couponVisible;
   }

   async handleCopy() {
      let msg = this.couponcode;

      if (navigator.clipboard && window.isSecureContext) {
         return navigator.clipboard.writeText(msg);
      } else {
         let textArea = document.createElement("textarea");
         textArea.value = msg;
         textArea.style.position = "fixed";
         textArea.style.left = "-999999px";
         textArea.style.top = "-999999px";
         document.body.appendChild(textArea);
         textArea.focus();
         textArea.select();
         return new Promise((res, rej) => {
            document.execCommand("copy") ? res() : rej();
            textArea.remove();
         });
      }
   }
}