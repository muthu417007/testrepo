import { LightningElement, track, api } from 'lwc';
import getProductBySearchKey from '@salesforce/apex/BWC_PartsSearchController.getProductBySearchKey';
import { NavigationMixin } from "lightning/navigation";
import PARTS_LOGO from '@salesforce/resourceUrl/PartLogos';
import Image_Not_Available from '@salesforce/resourceUrl/Image_Not_Available';
import searchResultHelper from '@salesforce/label/c.BWC_Parts_Search_ResultHelper';

export default class Bwc_partsSearchResults extends NavigationMixin(LightningElement) {

    tileLenght = 0;
    tileCss;
    @track productsToDisplay = [];
    @track productsResult;

    @track maxLength = 0;

    @api productToDisplayFromParent;
    @api demoSku;
    @api searchRes;
    @api currentUser;
    hideSearchResultHelper = false;
    @track backgroundCss;

    totalRecordsPerPage = 8;
    lastIndex = 0;
    fromRange = 1;
    totalRecords;
    searchKey;
    isDisabled = false;

    image = {
      GE_LOGO : PARTS_LOGO + '/PartsLogo/GE.svg',
    }

    label = {
      searchResultHelper : searchResultHelper.toUpperCase()
    }

    imageNotAvailable = Image_Not_Available;

    picklistOptions = [{label: 'Amazon', value: 'Amazon'}, {label: 'Salesforce', value: 'Salesforce'}]

   async connectedCallback() {
      const queryParams = new URLSearchParams(window.location.search);
      this.searchKey = queryParams.has('matchedResults') ? queryParams.get('matchedResults') : (window.location.hostname.includes('sitepreview') || window.location.hostname.includes('live-preview')) ? 'GWE' : '';
      this.searchKey = this.demoSku ? 'Gwe' : this.searchKey;   
      this.hideSearchResultHelper = this.currentUser === 'Service';
      if(this.hideSearchResultHelper){
        this.backgroundCss = 'background-color:white;';
      }
      else{
        this.backgroundCss = '';

      }
      if(this.searchKey || this.productToDisplayFromParent){
        const allData = this.productToDisplayFromParent ? this.productToDisplayFromParent : await getProductBySearchKey({key : this.searchKey});
        this.searchKey = this.searchKey.toUpperCase();
        const result = JSON.parse(JSON.stringify(allData));
        
        if(result && result.products?.length > 0){
          this.productsResult = result.products;
          this.totalRecords = this.productsResult?.length;
          this.productsResult = Object.assign([], this.productsResult);
          this.maxLength = 0;
          this.productsResult.forEach(product => {
            if(product.BWC_MFG_SKU__c){
              const mfgSkus = product.BWC_MFG_SKU__c.split('~');
              product.mfgSkus = mfgSkus;
              const singleHeight = mfgSkus?.length;
              product.show = singleHeight > 0;
              product.isMfgSkuClickable = product.BWC_Exploded_Diagram_Available__c;
              let innerListLength = product.mfgSkus.length;
            if (innerListLength > this.maxLength) {
              this.maxLength = innerListLength;
            }
              product.image = product.BWC_Main_Image__c ? true : false;
            }
          });
          while(this.lastIndex < this.productsResult?.length && this.lastIndex < this.totalRecordsPerPage){
            this.productsToDisplay.push(this.productsResult[this.lastIndex++]);
          }
           this.productsToDisplay.forEach(item => {
            let remainingLength = this.maxLength - item.mfgSkus.length;
            item.remainingLength = Array.from({ length: remainingLength }, (_, index) => index + 1);
        });
          this.isDisabled = this.productsToDisplay?.length === this.totalRecords;
        }
      } else{
        this[NavigationMixin.Navigate]({
          type: 'comm__namedPage',
            attributes: {
              name: 'parts_search__c'
            }
        })
      }
    }

    handleLoadMore(event){
      event.preventDefault();
        let counter = 0;
        while(this.lastIndex <= this.productsResult?.length - 1 && counter < this.totalRecordsPerPage){
          this.productsToDisplay.push(this.productsResult[this.lastIndex++]);
          counter++;
        }
        this.isDisabled = this.productsToDisplay?.length === this.totalRecords;
    }

    handleOnTop(event){
      window.scrollTo({left : 0, top : 0, behavior: 'smooth'});
    }

    handleMfgSkuClick(event){
      const mfgskuClicked = event.target.dataset.item;
      const productIdClicked = event.target.dataset.id;
      const objToPass = {mfgskuClicked, productIdClicked};
      const isClickAllowed = this.productsResult.find(pdt => {
          return pdt.Id === productIdClicked && pdt.BWC_Exploded_Diagram_Available__c;
      });
      if(isClickAllowed){
        if(this.productToDisplayFromParent){
          const selectedpartevent = new CustomEvent('partselected', {
            detail: objToPass
          });
          this.dispatchEvent(selectedpartevent);
        } else if(mfgskuClicked){
          this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
              attributes: {
                name: 'Parts_Exploded_Diagram__c'
              },
              state: {
                sku : mfgskuClicked,
                pdt : productIdClicked
              }
          })
        }
      }
    }
}