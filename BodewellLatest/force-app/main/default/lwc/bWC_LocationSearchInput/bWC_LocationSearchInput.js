import { LightningElement, track, api, wire } from 'lwc';
import getAddress from '@salesforce/apex/RG_SearchApiAddressController.getAddress';
import zipCodeChannel from '@salesforce/messageChannel/zipCodeChange__c';
import { publish, subscribe, MessageContext, createMessageContext } from "lightning/messageService";

export default class BWC_LocationSearchInput extends LightningElement {

    @api zipLocation;
    addressRecommendations = [];
    addressOtherRecommendation = [];
    searchText;
    selectedAddress = '';
    @track searchValue = '';    
    subscription2; 
    context;

    @wire(MessageContext)
    messageContext;

    get hasRecommendations() {
        return (this.addressRecommendations !== null && this.addressRecommendations.length);
    }

    connectedCallback() {
        if(this.zipLocation != undefined && this.zipLocation != null) {
            this.getLocationInfo();
        }        
        this.handleSubscribe();
    }

    getLocationInfo() {
        getAddress({ searchString: this.zipLocation })
            .then(response => {
                this.searchValue = response[0].addComplete;
                this.dispatchEvent(new CustomEvent('itemselect', {
                    detail: {
                        item: {
                            main_text: response[0].addComplete,
                            secondary_text: response[0].addComplete,
                            place_id: response[0].placeId
                        }
                    }
                }));
            }).catch(error => {
                console.error('error : ' + error);
            });
    }

    handleSubscribe() {
        if (this.subscription2) {
            return;
        }
        this.context = createMessageContext();

        this.subscription2 = subscribe(this.context, zipCodeChannel, (message) => {
            const fullAddress = message.message;
            const zipCode = fullAddress.Zipcode;
            console.log('zipCode =',zipCode);
            this.zipLocation = zipCode;
            this.getLocationInfo();
        });
    }

    handleChange(event) {
        this.searchValue = event.target.value;
        this.searchText = event.target.value;
        if (this.searchText.length > 2) {
            this.getAddressRecommendations(this.searchText);
        }
        else {
            this.addressRecommendations = [];
        }
    }

    getAddressRecommendations(searchText) {
        getAddress({ searchString: searchText })
            .then(response => {
                let addressRecommendations = [];
                response.forEach(prediction => {
                    addressRecommendations.push({
                        main_text: prediction.addComplete,
                        secondary_text: prediction.addComplete,
                        place_id: prediction.placeId,
                    });
                });
                this.addressRecommendations = addressRecommendations;
                this.addressOtherRecommendation = addressRecommendations;
                console.log(this.addressRecommendations);
            }).catch(error => {
                console.log('error : ' + JSON.stringify(error));
            });
    }

    handleAddressRecommendationSelect(event) {
        this.addressRecommendations.forEach((item, index) => {
            if (item.place_id == event.currentTarget.dataset.value) {
                this.searchValue = item.main_text;
                this.dispatchEvent(new CustomEvent('itemselect', {
                    detail: {
                        item: item
                    }
                }));
                //sessionStorage.setItem('selectedPlaceId', item.place_id);
            }
        });
        this.addressRecommendations = [];
        this.selectedAddress = '';
        this.resetAddress();
    }

    resetAddress() {
        this.city = '';
        this.country = '';
        this.pincode = '';
        this.state = '';
    }
}