import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

//apex classes
import getAccountProduct from '@salesforce/apex/Mya_ProductDetails.MYA_GetAccountProduct'; //address fetching
import getContactName from '@salesforce/apex/Mya_ProductDetails.MYA_GetContactName'
import deleteAsset from '@salesforce/apex/Mya_ProductDetails.Mya_DeleteAsset';
import MYA_ProductDetails from '@salesforce/apex/MYA_MyProducts.MYA_ProductDetails';
import MYA_ProductDetails1 from '@salesforce/apex/MYA_MyProducts.MYA_ProductDetails1';


//images
import PROUDUCT_IMAGE from '@salesforce/resourceUrl/productimage';
import PROUDUCT_IMAGE1 from '@salesforce/resourceUrl/GEImageForProducts';

import mya_GEATeamplate from './mya_ScheduleServices.html';
import mya_CafeTeamplate from './mya_ScheduleServiceCafe.html';
import mya_HaierTeamplate from './mya_ScheduleServicehaier.html';
import mya_BodewellTeamplate from './mya_ScheduleServiceBodewell.html';

//metadata
import getmyaConfigs from '@salesforce/apex/Mya_ProductDetails.getmyaConfigs';

import USER_ID from '@salesforce/user/Id';

export default class Mya_ScheduleServices extends NavigationMixin(LightningElement) {
  @api brandValue = 'GEA';
  brand;
  showSchedule = true;
  productimage = PROUDUCT_IMAGE;
  proImage1 = PROUDUCT_IMAGE1;
  url;
  GCId;
  schdUrl;
  isLoading = true;
  @api assetIds;

  scheduleUrl;

  render() {
    if (this.brandValue == "GEA") {
      this.brand = false;
      return mya_GEATeamplate
    }
    else if (this.brandValue == "Haier") {
      this.brand = true;
      return mya_HaierTeamplate
    }
    else if (this.brandValue == "Cafe") {
      this.brand = false;
      return mya_CafeTeamplate
    }
    else if (this.brandValue == "Bodewell") {
      this.brand = false;
      return mya_BodewellTeamplate
    }
  }
  handleClick() {
    this.showSchedule = false;
  }
  name
  AccDetails  //endeca response

  // @wire(getmyaConfigs)
  // WiredUrl(result) {
  //   if (result.data) {
  //     this.schdUrl = result.data;
  //     console.log('url', this.schdUrl);
  //   }
  // }

  @api US_ID = USER_ID;

  @wire(getContactName, { UserId: '$US_ID' })
  wiredName(result) {

    if (result.data) {
      this.name = result.data;
      if (this.name[0].Contact) {
        
      this.getmyaConfigs();

        console.log(this.name)
      }

    }

    
  }
  showModal
  getProductDetails()
  {
    MYA_ProductDetails()
    .then((result) => {
      this.AccDetails = result;
      this.isLoading = false;
      console.log(this.AccDetails)
    }).catch((error) => {
      this.isLoading = false;
      console.log(error);
    })
  }

  getmyaConfigs()
  {
    getmyaConfigs()
    .then((result) => {
      this.schdUrl = result;
      this.GCId = this.name[0].Contact.Global_Customer_Id__c;
        this.scheduleUrl = this.schdUrl.EService_Source_URL__c + encodeURI(this.schdUrl.EService_Target_Url__c + 'idpRequestToken') +
          '&language=en_US&allowGuest=1&state=' + encodeURI(this.schdUrl.EService_Target_Url__c + 'productSelection?personId=') + this.GCId;
      this.getProductDetails(); 
    }).catch((error) => {
      console.log(error);
    })
  }
  

  handledelete(event) {
    this.recordId = event.target.value;
    deleteAsset({ Id: this.recordId })
      .then((result) => {
        this.showModal = false;
        window.location.reload()
      }).catch((error) => {
        console.error(error)
      })
  }

  openModal(event) {
    this.recordId = event.currentTarget.dataset.value;
    this.showModal = true;
  }

  closeModal() {
    // Setting boolean variable to false, this will hide the Modal
    this.showModal = false;
  }

  //get the address of logged in user
  address
  wiredAddress
  @wire(getAccountProduct)
  wiredProduct(result) {
    this.wiredAddress = result
    if (result) {
      this.address = result;
    }
  }

  produrl(event) {
    this.assetIds = event.currentTarget.dataset.value;
    console.log('assetId' + event.currentTarget.dataset.value);
    console.log('assetIds' + this.assetIds);

    MYA_ProductDetails1({ assetId: this.assetIds })
      .then(result => {
        if (result) {
          console.log('results' + JSON.stringify(result));
          if (result.ModelValidityFlag__c) {
            this.url = this.schdUrl.EService_Source_URL__c + encodeURI(this.schdUrl.EService_Target_Url__c + 'idpRequestToken') +
              '&language=en_US&allowGuest=1&state=' + encodeURI(this.schdUrl.EService_Target_Url__c + 'confirmzipcode?personId=' + this.GCId) +
              '%26K%3D' + result.Model_Number__c + '%26M%3D' + result.OriginalModelNumber__c + '%26S%3D' + result.SerialNumber;
          }
          else {
            this.url = this.schdUrl.EService_Source_URL__c + encodeURI(this.schdUrl.EService_Target_Url__c + 'idpRequestToken') +
              '&language=en_US&allowGuest=1&state=' + encodeURI(this.schdUrl.EService_Target_Url__c + 'confirmzipcode?personId=' + this.GCId) +
              '%26K%3D' + result.OriginalModelNumber__c + '%26M%3D' + result.OriginalModelNumber__c + '%26S%3D' + result.SerialNumber;
          }
          console.log('url' + this.url);
        }

      }).catch(error => {
        console.log('error' + JSON.stringify(error));
      })
  }
  //navigate to registered product deatil page 
  prodDesc

  prodDescHandler(event) {
    this.prodDesc = event.currentTarget.dataset.value;
    this[NavigationMixin.Navigate]({
      type: 'comm__namedPage',
      //  type:'standard__component',
      attributes: {
        name: 'MYA_My_Appliance_Page__c',
        componentName: 'c__registeredProductDetails'
      },
      state: {
        c__assetrecordId: this.prodDesc
      }
    })
  }
}