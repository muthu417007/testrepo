import { LightningElement, api,wire } from 'lwc';
import BWC_MessageChannel from '@salesforce/messageChannel/Bwc_MessageChannel__c';
import { subscribe, MessageContext } from 'lightning/messageService';
export default class Bwc_productTabFeatures extends LightningElement {

    isPlayVideo = false;
    videoLink;
    firstFourItemsFeature;
    featureCopyItemsFeature;
    remainingItemsFeature;
    _claims_and_certificationsflag=false;
    /**
     * @type {?JsonData}
     * @private
     */
    _productDetails;
    _features;
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
            this.INSERT_PRODUCT_ID=val?.fields?.StockKeepingUnit;
            this._features = JSON.parse(val?.fields?.BWC_Benefit_Copy__c);
            this._specDetails = JSON.parse(val?.fields?.BWC_ProductSpecAndDetails__c);
            // this._Cad = (val?.fields?.BWC_CAD__c)?.replaceAll('=>', ':').replaceAll('}{', ',').replaceAll('=>', ':');
            // this._documents = JSON.parse(val?.fields?.BWC_Documents__c);
            let claims_and_certifications = (val?.fields?.BWC_Claims_and_certifications__c)?.split("~");
            if (claims_and_certifications) {
                this.getCertificationsDetails(claims_and_certifications);
            }
        }
        
        // Call the method to get the three divided JSON objects
        if (this._features) {
            this.divideJSON(this._features);
        }
    }

    getCertificationsDetails(certs) {
        this._claims_and_certifications=[];
        for (let key in certs) {
            if (certs[key] === 'ADA Compliant') {
                this._claims_and_certifications.push({ key: certs[key], value: 'https://cdn11.bigcommerce.com/s-pacto3wrn2/product_images/uploaded_images/logo-ada.gif' });
            }
            if (certs[key] === 'ENERGY STAR® Qualified') {
                this._claims_and_certifications.push({ key: certs[key], value: 'https://cdn11.bigcommerce.com/s-pacto3wrn2/product_images/uploaded_images/logo-energy-star.gif' });
            }
            if (certs[key] === 'MADE IN AMERICA:  70 to 90% U.S. Content') {
                this._claims_and_certifications.push({ key: certs[key], value: 'https://cdn11.bigcommerce.com/s-pacto3wrn2/product_images/uploaded_images/logo-america-at-work.png' });
            }
            if (certs[key] === 'California Prop 65') {
                this._claims_and_certifications.push({ key: certs[key], value: 'https://cdn11.bigcommerce.com/s-pacto3wrn2/product_images/uploaded_images/california-prop-65.jpg' });
            }
            if(certs[key].includes('California AB-1200 Disclosures'))
            {
                console.log('tag true');
                this._claims_and_certifications.push({  tag: certs[key]});
                console.log('tag this._claims_and_certifications=='+JSON.stringify(this._claims_and_certifications));
            }
            else if ((certs[key] != 'California Prop 65') && (certs[key] != 'MADE IN AMERICA:  70 to 90% U.S. Content') && (certs[key] != 'ENERGY STARÂ® Qualified') && (certs[key] != 'ADA Compliant')) {
                this._claims_and_certifications.push({ key: certs[key] });

            }
        }
        if(this._claims_and_certifications)
        {
            if(this._claims_and_certifications.length>0)
            {
                this._claims_and_certificationsflag=true;
            }
        }
       
    }

    // Method to divide the main JSON into three different JSON objectsfunction 
    divideJSON(mainJSON) {
        this.featureCopyItemsFeature = { "BenefitCopy": mainJSON.BenefitCopy.filter(item => (item.Feature && item.Copy && !item.Video && !item.Image)||(item.Feature && !item.Copy && !item.Video && !item.Image)) };
        let alltemp={ "BenefitCopy": mainJSON.BenefitCopy.filter(item => !((item.Feature && item.Copy && !item.Video && !item.Image)||(item.Feature && !item.Copy && !item.Video && !item.Image))) };
        if(alltemp.BenefitCopy) {
            this.firstFourItemsFeature = { "BenefitCopy": alltemp.BenefitCopy.slice(0, 4) };
            this.remainingItemsFeature = { "BenefitCopy": alltemp.BenefitCopy.slice(4).filter(item => !((item.Feature && item.Copy && !item.Video && !item.Image)||(item.Feature && !item.Copy && !item.Video && !item.Image))) };
        }
    }

    videoClickHandler(event) {
        this.videoLink = event.currentTarget.dataset.id;
        this.isPlayVideo = true;
    }
    closeModel(event) {
        this.isPlayVideo = false;
    }

    publisherMessage = '';
    subscription = null;
  
    @wire(MessageContext)
    messageContext;
  
    connectedCallback() {
      this.handleSubscribe();
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

       // const topDiv = this.template.querySelector('[data-id="pdpTabs"]');
        // let targetId ='pdpTabs';
        // let topDiv = this.template.querySelector('[data-id="${targetId}"]');
    const topDiv = this.template.querySelector('[data-id="pdpTabs"]');
    if(topDiv)
    {
        topDiv.scrollIntoView({ behavior: "smooth", block: "start", inline: "nearest" });

    }
      }
}