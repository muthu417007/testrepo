import { LightningElement, api, wire, track } from 'lwc';
import BWC_MessageChannel from '@salesforce/messageChannel/Bwc_MessageChannel__c';
import { subscribe, MessageContext } from 'lightning/messageService';
export default class Bwc_productTabSpecAndDimensions extends LightningElement {

  
  _specDetails;
  
  /**
     * @type {?JsonData}
     * @private
     */
  _productDetails;
  

  _specAndDimensions = [];
  _claims_and_certifications = [];
  INSERT_PRODUCT_ID;

  /**
   * The product to select variants for.
   * @type {?JsonData}
   */

  @api
  get product() {
    return this._productDetails;
  }
  set product(val) {
    this._productDetails = val;
   
   


    if (val) {
      this._specDetails = JSON.parse(val?.fields?.BWC_ProductSpecAndDetails__c);
    }
    //console.log(JSON.stringify(this._specDetails.Documents));
    if (this._specDetails) {

      this.specDetailsDivider(this._specDetails?.Spec);
    }


  }
  specDetailsDivider(specDetails) {
    this._specAndDimensions = [];


    for (let key in specDetails) {
      if (key != 'sku') {

        const tempDetails = specDetails[key];
        let tempSpec = [];
        for (let temp in tempDetails) {


          tempSpec.push({ key: temp, value: tempDetails[temp] });


        }
        this._specAndDimensions.push({ key: key, value: tempSpec });
      }

    }



  }
//   getCertificationsDetails(certs) {
//     for (let key in certs) {


//       if (certs[key] === 'ADA Compliant') {
//         this._claims_and_certifications.push({ key: certs[key], value: 'https://cdn11.bigcommerce.com/s-pacto3wrn2/product_images/uploaded_images/logo-ada.gif' });
//       }
//       if (certs[key] === 'ENERGY STARÂ® Qualified') {
//         this._claims_and_certifications.push({ key: certs[key], value: 'https://cdn11.bigcommerce.com/s-pacto3wrn2/product_images/uploaded_images/logo-energy-star.gif' });
//       }
//       if (certs[key] === 'MADE IN AMERICA:  70 to 90% U.S. Content') {
//         this._claims_and_certifications.push({ key: certs[key], value: 'https://cdn11.bigcommerce.com/s-pacto3wrn2/product_images/uploaded_images/logo-america-at-work.png' });
//       }
//       if (certs[key] === 'California Prop 65') {
//         this._claims_and_certifications.push({ key: certs[key], value: 'https://cdn11.bigcommerce.com/s-pacto3wrn2/product_images/uploaded_images/california-prop-65.jpg' });
//       }
//       else if ((certs[key] != 'California Prop 65') && (certs[key] != 'MADE IN AMERICA:  70 to 90% U.S. Content') && (certs[key] != 'ENERGY STARÂ® Qualified') && (certs[key] != 'ADA Compliant')) {
//         this._claims_and_certifications.push({ key: certs[key] });

//       }

//     }
//     //console.log('this._claims_and_certifications' + JSON.stringify(this._claims_and_certifications));
//   }
//   docObjectdoc(cad) {
//     // for (let key in documents) {
//     //   this._documentsAndCad.push({ key: key, value: documents[key] });
//     // }
//     for (let key in cad) {
//       if(key!='sku')
//       {
//        // console.log(key);
//        // console.log(cad[key]);
//        var keyWithoutPrefix = key.replace(/^Documents_\d+_/i, ""); // Remove the prefix
//         this._documentsAndCad.push({ key: keyWithoutPrefix, value: cad[key] });
//       }
     
//     }

//   }
 
//   docObjectcad(cad) {
//     // for (let key in documents) {
//     //   this._documentsAndCad.push({ key: key, value: documents[key] });
//     // }
//     for (let key in cad) {
//       if(key!='sku')
//       {
//        // console.log(key);
//        // console.log(cad[key]);
//        var keyWithoutPrefix = key.replace(/^CAD_\d+_/, "CAD FILES "); // Remove the prefix
//        this._documentsAndCad.push({ key: keyWithoutPrefix.replace('_', " "), value: cad[key] });
//       }
     
//     }

//   }
  // Method to divide the main JSON into three different JSON objectsfunction 
//   divideJSON(mainJSON) {
   
//     this.featureCopyItemsFeature = { "BenefitCopy": mainJSON.BenefitCopy.filter(item => (item.Feature && item.Copy && !item.Video && !item.Image)||(item.Feature && !item.Copy && !item.Video && !item.Image)) };
//     let alltemp={ "BenefitCopy": mainJSON.BenefitCopy.filter(item => !((item.Feature && item.Copy && !item.Video && !item.Image)||(item.Feature && !item.Copy && !item.Video && !item.Image))) };
//     //console.log("alltemp 1:", alltemp);
//     if(alltemp.BenefitCopy)
//    {
//     this.firstFourItemsFeature = { "BenefitCopy": alltemp.BenefitCopy.slice(0, 4) };
//     this.remainingItemsFeature = { "BenefitCopy": alltemp.BenefitCopy.slice(4).filter(item => !((item.Feature && item.Copy && !item.Video && !item.Image)||(item.Feature && !item.Copy && !item.Video && !item.Image))) };
    
//    }
 
//     // console.log("First Four Items JSON:", this.firstFourItemsFeature);
//     // console.log("Feature and Copy Items JSON:", this.featureCopyItemsFeature); 
//     //console.log("Remaining Items JSON:", this.remainingItemsFeature);
//   }


//   handelOnclick(event) {

//     const selectedTab = event.target.dataset.tab;
//     const tabList = this.template.querySelectorAll('.tab-item');
//     tabList.forEach((tablist) => {

//       tablist.classList.remove('tabBorder');


//     });
//     event.target.classList.add('tabBorder');
//     const tabContents = this.template.querySelectorAll('.tab-content');
//     tabContents.forEach((tabContent) => {
//       if (tabContent.dataset.tab === selectedTab) {
//         tabContent.classList.add('active');

//       }
//       else {
//         tabContent.classList.remove('active');

//       }
//     });
//   }
//   videoClickHandler(event) {

//    // console.log('data id-----' + event.currentTarget.dataset.id);
//     this.videoLink = event.currentTarget.dataset.id;
//     this.isPlayVideo = true;
//   }
//   closeModel(event) {

//     this.isPlayVideo = false;
//   }

  publisherMessage = '';
  subscription = null;

  @wire(MessageContext)
  messageContext;

  connectedCallback() {
   // this.handleSubscribe();
  }

  handleSubscribe() {
    if (this.subscription) {
      return;
    }
    this.subscription = subscribe(this.messageContext, BWC_MessageChannel, (message) => {
      //console.log(message.message);
      this.publisherMessage = message.message;
      this.scrollFunction();
    });
  }

  scrollFunction() {

    const topDiv = this.template.querySelector('[data-id="pdpTabs"]');
    topDiv.scrollIntoView({ behavior: "smooth", block: "start", inline: "nearest" });
  }
  
  @track ShowSpecifications = true;
  @track toggleLabel = 'See All Specifications ';
  get getContentStyle() {
    return this.ShowSpecifications ? 'max-height: 500px;overflow: hidden;transition: max-height 0.5s ease;' : '';
  }
  get getLinkStyle() {
    //position: absolute;
    return this.ShowSpecifications ? 'background: transparent linear-gradient(180deg,#fffFFF00 0,#fff 11%,#DED1B1 30%);bottom: 0;left: 0;right: 0;display: block;padding: 30px 0 10px 0;' : 'position: relative;background: #DED1B1;padding: 10px 0;'
  }
  toggleSection() {
    this.ShowSpecifications = !this.ShowSpecifications;
    this.toggleLabel = this.ShowSpecifications ? 'See All Specifications ' : 'See Less Specifications ';
  }
}