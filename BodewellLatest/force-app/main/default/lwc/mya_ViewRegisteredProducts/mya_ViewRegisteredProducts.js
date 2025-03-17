import { LightningElement, wire, api } from 'lwc';

import getContactName from '@salesforce/apex/Mya_ProductDetails.MYA_GetContactName'

import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';

import mya_CafeTeamplate from './mya_CafeTeamplate.html';
import mya_GeaTemplate from './mya_GeaTemplate.html';
import mya_BodewellTemplate from './mya_BodewellTemplate.html';
import mya_HaierTemplate from './mya_HaierTemplate.html';

import PROUDUCT_IMAGE from '@salesforce/resourceUrl/productimage';
import Wifi_Image1 from '@salesforce/resourceUrl/wifiimage1';
import Wifi_Image2 from '@salesforce/resourceUrl/wifiimage2';

import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

import MYAGEACSS from '@salesforce/resourceUrl/MYAGEACSS';
import MYACAFECSS from '@salesforce/resourceUrl/MYACAFECSS';
import MYAHAIERCSS from '@salesforce/resourceUrl/MYAHAIERCSS';

import deleteAsset from '@salesforce/apex/Mya_ProductDetails.Mya_DeleteAsset';

import MYA_ProductDetails from '@salesforce/apex/MYA_MyProducts.MYA_ProductDetails';
import USER_ID from '@salesforce/user/Id';


export default class Mya_ViewRegisteredProducts extends NavigationMixin(LightningElement) {

    @api brandValue='GEA';
    // brand=BrandValue.toLowerCase();
    recordId;

    productimage = PROUDUCT_IMAGE;
    wifiConnected = Wifi_Image1;
    wifiGreyedOut = Wifi_Image2;


   

    render() {
        if (this.brandValue == "GEA") {
            console.log('haier')
            return mya_GeaTemplate;
        } else if (this.brandValue == "Haier") {
            return mya_HaierTemplate;
        } else if (this.brandValue == "Cafe") {
            return mya_CafeTeamplate;
        } else if(this.brandValue == "Bodewell") {
            console.log('mya products Bodewell');
            return mya_BodewellTemplate;
        }
    }

    // CSS loader function
    //   renderedCallback() {
    //     if (this.BrandValue == "GEA") {
    //         Promise.all([
    //             loadStyle(this, MYAGEACSS + '/MYAGEACSS/mya_GeaTemplate.css')
    //         ]);
    //     }
    //     else if (this.BrandValue == "Haier") {
    //         Promise.all([
    //             loadStyle(this, MYAHAIERCSS + '/MYAHAIERCSS/mya_HaierTemplate.css')
    //         ]);
    //     }
    //     else if (this.BrandValue == "Cafe") {
    //         Promise.all([
    //             loadStyle(this, MYACAFECSS + '/MYACAFECSS/mya_CafeTeamplate.css')
    //         ]);
    //     }
    // }
    
    name;
    AccDetails; //endeca response

    
   @wire(getContactName, { UserId: USER_ID })
    wiredName(result,error) {
        if (result) {
            this.name = result;
            MYA_ProductDetails()
                .then((result) => {
                    this.AccDetails = result;
                    console.log('Account Details',this.AccDetails);
                   
                }).catch((error) => {
                    console.log(error);
                });
        }
    }

  

    showModal;

    handledelete(event) {
        this.recordId = event.target.value;
        deleteAsset({ Id: this.recordId })
            .then((result) => {
                this.showModal = false;
                window.location.reload();
            }).catch((error) => {
                console.error(error);
            });
    }

    openModal(event) {
        this.recordId = event.currentTarget.dataset.value;
        this.showModal = true;
    }

    closeModal() {
        // Setting boolean variable to false, this will hide the Modal
        this.showModal = false;
    }

    prodDescHandler(event) {
       this.prodDesc = event.currentTarget.dataset.value;
      
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'MYA_My_Appliance_Page__c'
              // componentName: 'c__registeredProductDetails'
            },
            state: {
                c__assetrecordId: this.prodDesc
            }
        });
    }
}