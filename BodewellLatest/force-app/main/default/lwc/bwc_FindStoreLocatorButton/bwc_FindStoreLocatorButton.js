import { LightningElement, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import getAddress from '@salesforce/apex/RG_SearchApiAddressController.getAddress';
import getPlaceDetails from '@salesforce/apex/BWC_LocationController.getPlaceDetails';
import zipCodeChannel from '@salesforce/messageChannel/zipCodeChange__c';
import { publish, subscribe, MessageContext, createMessageContext } from "lightning/messageService";

export default class Bwc_FindStoreLocatorButton extends NavigationMixin(LightningElement) {
    
    hasStore = false;
    storeSearchLink;
    productId;   
    subscription; 
    context;

    @wire(MessageContext)
    messageContext;
    

    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
        if (currentPageReference) {
            this.productId = currentPageReference.attributes.recordId;
        }
    }

    connectedCallback() {
        this.getStoreSearchLink();
        this.getLocationInfo();
        this.handleSubscribe();
    }

    handleSubscribe() {
        if (this.subscription) {
            return;
        }
        this.context = createMessageContext();

        this.subscription = subscribe(this.context, zipCodeChannel, (message) => {
            const fullAddress = message.message;
            const zipCode = fullAddress.Zipcode;
            console.log('zipCode =',zipCode);
            this.zipLocation = zipCode;
            this.getLocationInfo();
        });
    }

    getLocationInfo() {
        let zipCodeInfo = JSON.parse(localStorage.getItem('zipcode'));
        getAddress({ searchString: zipCodeInfo.Zipcode })
            .then(response => {
                let item = {
                    main_text: response[0].addComplete,
                    secondary_text: response[0].addComplete,
                    place_id: response[0].placeId
                }
                this.getNearByStores(item);
            }).catch(error => {
                console.error('error : ' + error);
            });
    }

    getStoreSearchLink() {
        localStorage.setItem('productId',this.productId);
        this[NavigationMixin.GenerateUrl]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Preferred_Partner__c'
            },
        }).then((url) => {
            this.storeSearchLink = url;
        });
    }

    getNearByStores(item) {
        this.getGeoLocation(item.place_id);
    }

    getGeoLocation(placeId) {
        getPlaceDetails({ placeId: placeId })
            .then(response => {
                if (response.success && response.data.length > 0) {
                    this.hasStore = true;
                    console.log('null response: ', response);
                } else {
                    console.log('null response: ', response);
                }
            }).catch(error => {
                console.error('error : ', error);
            });
    }
}