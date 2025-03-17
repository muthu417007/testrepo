import { LightningElement, api, track } from 'lwc';
import getProductForExplodedDiagramViaIds from '@salesforce/apex/BWC_PartsSearchController.getProductForExplodedDiagramViaIds';
import getPriceForProducts from '@salesforce/apex/BWC_PartsSearchController.getPriceForProducts';
import getCartItems from '@salesforce/apex/BWC_PartsSearchController.getCartItems';
import getNetworkId from '@salesforce/apex/BWC_PartsSearchController.getNetworkId';
import getSupersededPartBySku from '@salesforce/apex/BWC_PartsSearchController.getSupersededPartBySku'
import getRelatedItemsByProduct from '@salesforce/apex/BWC_PartsSearchController.getRelatedItemsByProduct';
import getEstimatedDateForSmallAppliance from '@salesforce/apex/BWC_CalendarApi.getEstimatedDateForSmallAppliance';
import addToCart from "@salesforce/apex/BWC_GetInfo.addToCart";
import FORM_FACTOR from '@salesforce/client/formFactor';
import isGuest from "@salesforce/user/isGuest";
import Image_Not_Available from '@salesforce/resourceUrl/Image_Not_Available';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import MyModal from 'c/bwc_partsAddedToListModal';
import { NavigationMixin } from "lightning/navigation";

export default class Bwc_partsExplorer extends NavigationMixin(LightningElement) {

    @api singleProductId;
    @api currentUser;
    @api isLaunchedViaManageParts;
    @api isMobilePreview;
    @track subParts = [];
    @track partsToDisplay;
    @track allParts;
    @api options = [];
    @track buttonLabel = 'ADD TO CART'
    @track showModal = false;
    @track partsAddedToListCount = 0;
    @track mobileView = false;
    showDottedLines = true;
    isServiceView = false;
    partsAddedInListByTechnician = new Set();
    modalInfoMap = new Map();
    showMemberPrice = false;
    @track isShowModal =  false;
    communityId;
    @api dropDownOpen
    @track passPicklistOptions = false;

    imageNotAvailable = Image_Not_Available;

    _product;
    @api
    get product(){
        return this._product;
    }

    _partSelectedTemp;
    set product(value){
        this._product = value;
        if(this._partSelectedTemp && this.product){
            this.getRelatedProducts();
        }
    }

    @api
    get partSelected(){
        return this._partSelectedTemp;
    }

    set partSelected(value){
        this._partSelectedTemp = JSON.parse(JSON.stringify(value));
        if(this._partSelectedTemp && this.product){
            this.getRelatedProducts();
        }
    }


    @api effectiveAccountId;

    async getRelatedProducts(){
        this.subParts = [];
        const data = this.product.BWC_Exploded_Diagram_Parts__c;
        const removeEmptyImages = (data) => {
            let cleanedJson = data.replace(/,\s*"Image \d+"\s*:\s*\{""}?/g, '');
            return cleanedJson;
          };
        const cleanedJsonData = removeEmptyImages(data);
        const copy = JSON.parse(cleanedJsonData);
        const explodedDiagramParts = copy['Exploded Diagram Parts'];
        for(const imageName in explodedDiagramParts){
            if(imageName === this._partSelectedTemp.imageName){
                for(const partSku in explodedDiagramParts[imageName]){
                    const subPart = {partSku: partSku, partDiagramNumber: explodedDiagramParts[imageName][partSku]};
                    this.subParts.push(subPart);
                }
            }
        }
        let productSku = [];
        const productIds = [];
        this.options = [];
        this.subParts.forEach(part => {
            productSku.push(part.partSku);
        });
        const productPricing = await getProductForExplodedDiagramViaIds({productIds : productSku});
        this.partsToDisplay = productPricing; 
        this.partsToDisplay = this.partsToDisplay.filter(parts => parts.BWC_Product_Marketing_Description__c != null);
        this.partsToDisplay.forEach(parts => {
            const res = this.subParts.find((ele) => ele.partSku === parts.StockKeepingUnit);
            let diargramNumber = res.partDiagramNumber;
            parts.DiagramNumber = diargramNumber;
            productIds.push(parts.Id);
            parts.image = parts.BWC_Main_Image__c ? true : false;
            diargramNumber = diargramNumber.split('—')[0] + ' - ' + parts.BWC_Product_Marketing_Description__c;
            diargramNumber = JSON.parse(JSON.stringify(diargramNumber));
            const option = {label: diargramNumber, value: parts.BWC_Product_Marketing_Description__c};
            this.options.push(option);
        });
        this.options = [...this.options];
        this.options.unshift({label: 'Show me diagram number', value: 'Show me diagram number'});
        this.passPicklistOptions = true;
        this.singleProductId = productIds[0];
        this.allParts = [...this.partsToDisplay];
        if(!this.isServiceView){
        if(!isGuest){
            const itemsInCart = await getCartItems({communityId : this.communityId , effectiveAccountId : this.effectiveAccountId, pageParam : null});
            this.showMemberPrice = itemsInCart ? (itemsInCart || {}).cartItems.some(cartItem => {
                return cartItem.cartItem.productDetails.sku === 'BDMEM';
            }) : this.showMemberPrice;
        }
        const {isGuestPricing, membershipInfo, memberPrice, nonMemberPrice, guestPrice} = await getPriceForProducts({productIds:productIds, isGuestUser:isGuest, showMemberPriceForNonMember : this.showMemberPrice});
        const productWithPricing = isGuestPricing ? guestPrice : membershipInfo === 'Member' ? memberPrice : nonMemberPrice;
        this.partsToDisplay.forEach(parts => {
            parts.strikeThroughPrice = "";
            const priceReceived = productWithPricing.find((product) => product.Product2Id === parts.Id);
            parts.unitPrice = priceReceived.UnitPrice?.toFixed(2);
            parts.isMember = membershipInfo === 'Member';
            if(parts.isMember && !isGuestPricing){
                parts.strikeThroughPrice = ((nonMemberPrice || {}).find((product) => product.Product2Id === parts.Id) || {}).UnitPrice?.toFixed(2);
            }
        });
        this.checkPartAvailability();
    }
    else{
        this.template.querySelector('c-bwc_searchable-picklist')?.changePicklistValues();
    }
    }

    async connectedCallback() {
        this.showDottedLines = FORM_FACTOR.toLowerCase() === 'small' ? false : true;
        this.mobileView = FORM_FACTOR.toLowerCase() === 'small';
        this.buttonLabel = this.currentUser && this.currentUser === 'Service' ? 'ADD TO LIST' : this.buttonLabel;
        this.isServiceView = this.currentUser === 'Service';
        this.communityId = await getNetworkId();
        this.isMobilePreview = this.mobileView && this.isServiceView;
    }

    handleChange(event){
        const valueClicked = event.detail?.value;
        if(valueClicked !== 'Show me diagram number'){
            const result = this.allParts.find((part) => part.BWC_Product_Marketing_Description__c?.includes(valueClicked));
            this.partsToDisplay = [result];
        } else{
            this.partsToDisplay = [...this.allParts];
        }
    }

    async openLargerImage(){
        if(this.isMobilePreview){
            await MyModal.open({
                label: 'Hello',
                size: 'large',
                image: this.partSelected.url
            });
        } else{
            window.open(this.partSelected.url);
        }
    }

    async handleClick(event){
        if(this.isServiceView){
            const partAddedSku = event.target.dataset.id;
            const selectedItem = event.target.dataset.item;
            const productId = event.target.dataset.recordid;
            let isItemAvailableInList = false;
            this.partsAddedInListByTechnician.forEach(ele => {
                isItemAvailableInList = isItemAvailableInList ? isItemAvailableInList : ele.partAddedSku === partAddedSku;
            });            
            if(!isItemAvailableInList){
                this.partsAddedInListByTechnician.add({partAddedSku:partAddedSku, productId:productId});
                this.modalInfoMap.set(partAddedSku, selectedItem);
                this.partsAddedToListCount = this.partsAddedInListByTechnician.size;
                 const evt = new ShowToastEvent({
                    title: '',
                    message: `${partAddedSku} has been added to your pick list`,
                    variant: 'success',
                 });
                this.dispatchEvent(evt);
            }
        } else{
            const productId = event.target.dataset.recordid;
            const result =  await addToCart({communityId: this.communityId, productId: productId, quantity: '1', effectiveAccountId: this.effectiveAccountId, deliverySku: [], installationSku: [], zipCode: '' });
            this.isShowModal = result.isAddedToCart ? true : this.isShowModal;
        }
    }

    handleBackToOrdersClick(event){
        const closePartsFinder = new CustomEvent('closepartsfinder', {
            detail: {
                message: [...this.partsAddedInListByTechnician]
            },
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(closePartsFinder);
    }

    async openPicklistModal(event){
        this.showModal = true;
        let result = await MyModal.open({
            label: 'Hello',
            demo: this.modalInfoMap,
            size: 'small',
        });
        result = JSON.parse(result);
        this.partsAddedToListCount = result?.length;
        const modalInfoUpdated = new Map();
        result.forEach(obj => {
            modalInfoUpdated.set(obj.key, obj.value);
        });
        this.modalInfoMap = modalInfoUpdated;
        const productToPreserve = Array.from(modalInfoUpdated.keys());
        this.partsAddedInListByTechnician.forEach(ele => {
            if(!productToPreserve.includes(ele.partAddedSku)){
                this.partsAddedInListByTechnician.delete(ele);
            }
        });
    }

      async checkPartAvailability(){
        if(!this.isServiceView){
            const zipCode = JSON.parse(localStorage.getItem('zipcode') || '{}');
            const supersededParts = await getRelatedItemsByProduct({prd : this.partsToDisplay, salesRelationshipType : 'Superseded'});
            const skuList = [];
            for(let i = 0; i < this.partsToDisplay.length; i++){
                this.partsToDisplay[i].supersededSKU;
                this.partsToDisplay[i].supersededMesaage;
                skuList.push(this.partsToDisplay[i].StockKeepingUnit);
                const supersededPart  = supersededParts.find(part => part.Product__c === this.partsToDisplay[i].Id);
                if(supersededPart){
                    this.partsToDisplay[i].supersededSKU = supersededPart.Related_Product__r.StockKeepingUnit;
                    this.partsToDisplay[i].supersededMesaage =  this.partsToDisplay[i].StockKeepingUnit + ' has been superseded with ' + this.partsToDisplay[i].supersededSKU;
                    this.partsToDisplay[i].Id = supersededPart.Related_Product__c;
                }
            }
            const zipCodeInstance = (zipCode || {}).Zipcode;
            const availabilityResponse = await getEstimatedDateForSmallAppliance({ skuList: skuList, zipCode: zipCodeInstance, itemType: 'PARTS_ITEM'});
            const availabilityResponseParsed = JSON.parse(availabilityResponse);
            const partsToDisplayWithAvailability = [];
            if(availabilityResponseParsed.availabilityDetails){
            availabilityResponseParsed.availabilityDetails.forEach((response, index) => {
                const matchedPdt = this.partsToDisplay.find(part => part.StockKeepingUnit === response.inventoryItemName);
                matchedPdt.isAvailable = !response.availableQuantity >= 1;
                partsToDisplayWithAvailability.push(matchedPdt);
            });
            }
            this.partsToDisplay = [];
            this.partsToDisplay = [...partsToDisplayWithAvailability];
        this.template.querySelector('c-bwc_searchable-picklist')?.changePicklistValues();

        }
    }

    async handleSupersededClick(event){
        const stockKeepingUnit = event.target.dataset.id;
        const supersededPart = await getSupersededPartBySku({stockKeepingUnit : stockKeepingUnit});
        if(supersededPart){
            this.navigateToPdp(supersededPart[0].Id);
        }
    }

    handlePartToPdpClick(event){
        const productId = event.target.dataset.id;
        this.navigateToPdp(productId);
    }

    navigateToPdp(productId){
        if(!this.isServiceView && productId){
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: productId,
                    objectApiName: 'Product2',
                    actionName: 'view'
                }
            });
        }
    }

    hideModalBox() {
        this.isShowModal = false;
    }

    handleGotoCart() {
        if(!this.isServiceView){
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'Current_Cart'
                }
            });
            setTimeout(() => {
                window.location.reload();
            }, 1000);
        }
    }
    handleChildClick(event) {
        if(event.target.nodeName == 'C-BWC_SEARCHABLE-PICKLIST'){
            this.dropDownOpen = !this.dropDownOpen;
        }
        else{
            this.dropDownOpen = false;
        }
        this.dispatchEvent(new CustomEvent('outsidedropdown', { detail: this.dropdownOpen }));
        event.stopPropagation(); 
    }

    handleShowChange(event){
        this.dropDownOpen = event.detail;
        this.dispatchEvent(new CustomEvent('outsidedropdown', { detail: this.dropdownOpen }));
    }
}