import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getProductForExplodedDiagram from '@salesforce/apex/BWC_PartsSearchController.getProductForExplodedDiagram';
import Image_Not_Available from '@salesforce/resourceUrl/Image_Not_Available';
import MyModal from 'c/bwc_partsAddedToListModal';


export default class Bwc_partsDiagram extends NavigationMixin(LightningElement) {

    @api productIdReceived;
    @api mfgSkuReceived;
    @api currentUser;
    @api isLaunchedViaManageParts;
    @track imageList = [];
    @track product = {};
    @track productForImageAndManuals = {};
    @track imageSelected = {};
    @track _imagesForCarousel = [];
    @api dropDownOpen;
    productIdMfgSKU = [];
    imageInSingleView;
    lastIndex = 0;
    firstIndex = 0;
    totalParts = 0;
    renderChild = false;
    isMobilePreview = false;
    style = 'border: 3px solid #FFC01F;';
    showCarousel = false;
    @track serviceCarouselCss = '';

    @track showProductDetails = false;
    imageNotAvailable = Image_Not_Available;

    get imagesToDisplay(){
      return this._imagesForCarousel;
    }

    set imagesToDisplay(value){
      this._imagesForCarousel = value;
    }

    @api
    get effectiveAccountId() {
      return this._effectiveAccountId;
    }

    /**
    * Sets the effective account - if any - of the user viewing the product
    * and fetches updated cart information
    */
    _effectiveAccountId;
    set effectiveAccountId(newId) {
      this._effectiveAccountId = newId;
    }

    async connectedCallback() {
      this.serviceCarouselCss = (this.currentUser === 'Service') ? screen.width>=1440 ? 'background-color: white !important; min-height: 8.8rem !important; min-width:11rem !important; object-fit: contain; aspect-ratio: 1 / 1.6;' : 'background-color: white !important; min-height: 8.8rem !important; min-width: 9rem !important; object-fit: contain; aspect-ratio: 1 / 1.6;' : '';
      const queryParams = new URLSearchParams(window.location.search);
      if(this.productIdReceived && this.mfgSkuReceived){
        this.productIdMfgSKU = [this.productIdReceived, this.mfgSkuReceived];
      } else{
        this.productIdMfgSKU = queryParams.has('pdt') && queryParams.has('sku') ? [queryParams.get('pdt'), queryParams.get('sku')] : (window.location.hostname.includes('sitepreview') || window.location.hostname.includes('live-preview')) ? ['01t4P00000BWQ3PQAX', 'GWE19JGL1BB'] : [];
      }
      this.showProductDetails =  !(this.currentUser === 'Service');
      this.isLaunchedViaManageParts = this.isLaunchedViaManageParts == null || this.isLaunchedViaManageParts === undefined ? true : this.isLaunchedViaManageParts;
      switch(FORM_FACTOR.toLowerCase()){
        case 'large':
          this.imageInSingleView = 5;
          break;
        case 'medium':
          this.imageInSingleView = 3;
          break;
        case 'small':
          this.imageInSingleView = 1;
          this.isMobilePreview = true;
          break;
        default:
          this.imageInSingleView = 5;
      }
      if(this.productIdMfgSKU.length > 0){
        const products = await getProductForExplodedDiagram({productId : this.productIdMfgSKU[0]});
        this.product = products?.length > 0 ? products[0] : {Name: 'Dummy Product', StockKeepingUnit: 'GWE16JSLNFSS'};        
        this.product.image = this.product.BWC_Main_Image__c ? true : false;
        this.productForImageAndManuals.fields = this.product;
        const explodedImageObj = JSON.parse(products[0].BWC_Exploded_Diagram_Images__c)['Exploded Diagram Images'];
        Object.keys(explodedImageObj).forEach(key => {
            const innerObj = explodedImageObj[key];
            Object.keys(innerObj).forEach(innerKey => {
              if(innerObj[innerKey]?.includes(this.productIdMfgSKU[1])){
                this.imageList.push({
                  url:innerObj['Image URL'], 
                  imageName: key, 
                  headerName: innerObj['Header'],
                  css: 'slds-col slds-large-size_2-of-12 slds-medium-size_4-of-12 hoverPointer singleImage',
                  style: this.serviceCarouselCss,
                  imageText: 'slds-m-top_small imageText'
                });
              }
            })
        });

        this.imageInSingleView = this.imageList.length < this.imageInSingleView ? this.imageList.length : this.imageInSingleView;
        const tempImages = [];
        this.totalParts = this.imageList?.length;
        this.showCarousel = this.totalParts > 0;
        for(this.lastIndex = 0; this.lastIndex < this.imageInSingleView; this.lastIndex++){
          tempImages.push(this.imageList[this.lastIndex]);
        }
        tempImages[0].style = this.serviceCarouselCss+this.style;
        this.imageSelected = tempImages[0];
        this._imagesForCarousel = tempImages;
        this.renderChild = this.imageSelected !== '{}' && this.product !== '{}';
      }  
    }


    handleLeftClick(event){
      try{
        if(this.lastIndex > this.imageInSingleView){
          const newSetOfImages = this.imagesToDisplay;
          newSetOfImages[0].style = this.serviceCarouselCss;
          newSetOfImages.splice(this.imageInSingleView - 1, 1);
          newSetOfImages.unshift(this.imageList[this.lastIndex - (this.imageInSingleView+1)]);

          this.lastIndex--;
          newSetOfImages[0].style = this.serviceCarouselCss+this.style;

          this.imageSelected = newSetOfImages[0];
          this.imagesToDisplay = newSetOfImages;
        } 
      } catch(error){
        console.error('Left Click Error Captured > ');
      }
    }

    handleRightClick(event){
      if(this.lastIndex < this.imageList.length){
        const imagesInCurrentView = this.imagesToDisplay;
        imagesInCurrentView.splice(0, 1);
        imagesInCurrentView.push(this.imageList[this.lastIndex++]);
        imagesInCurrentView[0].style = this.serviceCarouselCss+this.style;
        this.imageSelected = imagesInCurrentView[0];
        this.imagesToDisplay = imagesInCurrentView;
        this.firstIndex++;
      } else if(this.lastIndex >= this.imageList.length){
        this.imageInSingleView = this.imageList.length < this.imageInSingleView ? this.imageList.length : this.imageInSingleView;
        const tempImages = [];
        this.totalParts = this.imageList?.length;
        for(this.lastIndex = 0; this.lastIndex < this.imageInSingleView; this.lastIndex++){
            this.imageList[this.lastIndex].style = this.serviceCarouselCss;
            tempImages.push(this.imageList[this.lastIndex]);
        }
        tempImages[0].style = this.serviceCarouselCss+this.style;
        this.imageSelected = tempImages[0];
        this.imagesToDisplay = tempImages;
      }
    }

    handleImageSelected(event){
      const imgaeName = event.target.dataset.item;
      const headerName = event.target.dataset.id;
      let demo = JSON.parse(JSON.stringify(this._imagesForCarousel));
      demo.forEach(image => {
          if(image.style.includes(this.style) && image.imageName !== imgaeName){
            image.style = this.serviceCarouselCss;
          } else if(image.imageName === imgaeName){
            image.style = this.serviceCarouselCss+this.style;
            this.imageSelected = image;
          }
      });
      this._imagesForCarousel = [];
      this.imagesToDisplay = demo;
    }

    async openLargerImage(){
      const evt = new ShowToastEvent({
        title: '',
        message: `View Larger Clicked`,
        variant: 'success',
     });
    this.dispatchEvent(evt);
      await MyModal.open({
        label: 'Hello',
        size: 'large',
        image: this.imageSelected.url
      });
    }

    handleClick(event){
      if(event.target.nodeName == 'C-BWC_PARTS-EXPLORER'){
      }
      else{
          this.dropDownOpen = false;
      }
    }
    handleOutsideDropDown(event){
      this.dropDownOpen = event.detail;
    }
}