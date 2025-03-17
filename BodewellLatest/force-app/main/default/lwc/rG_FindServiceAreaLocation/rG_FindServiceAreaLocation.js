import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import getAddress from '@salesforce/apex/RG_SearchApiAddressController.getAddress';

import netStyles from '@salesforce/resourceUrl/RG_StyleSheet';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class RG_FindServiceAreaLocation extends NavigationMixin(LightningElement) {
  searchCoordinates;
  @api isbannerstrip;

  renderedCallback() {
    Promise.all([
      loadStyle(this, netStyles)
    ])
  }

  handleUseCurrentLocation() {
    debugger;
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(position => {
        this.searchCoordinates = position.coords.latitude + ',' + position.coords.longitude;
        this[NavigationMixin.GenerateUrl]({
          type: 'comm__namedPage',
          attributes: {
            name: 'Search_Results__c',
          },
          state: {
            result: this.searchCoordinates
          }

        }).then(url => {
          let reloadEvent = new CustomEvent(
            "rg_redirection", {
            detail: {
              url: url
            }
          });
          document.dispatchEvent(reloadEvent, {
            bubbles: true,
            composed: true
          });
        });
      });
    }
  }
  isSearchValid = false;
  handleFindLocation() {
    if (this.searchValue && this.addressOtherRecommendation) {
      this.addressOtherRecommendation.forEach((item, index) => {
        if (item.main_text == this.searchValue) {
          this.isSearchValid = true;
        }
      });
      sessionStorage.setItem('isSearchValid', this.isSearchValid);
      this[NavigationMixin.GenerateUrl]({
        type: 'comm__namedPage',
        attributes: {
          name: 'Search_Results__c',
        },
        state: {
          result: this.searchValue
        }

      }).then(url => {
        let reloadEvent = new CustomEvent(
          "rg_redirection", {
          detail: {
            url: url
          }
        });
        document.dispatchEvent(reloadEvent, {
          bubbles: true,
          composed: true
        });
      });
    }
    else if(this.searchValue)
    {
      sessionStorage.setItem('isSearchValid', this.isSearchValid);
      this[NavigationMixin.GenerateUrl]({
        type: 'comm__namedPage',
        attributes: {
          name: 'Search_Results__c',
        },
        state: {
          result: this.searchValue
        }

      }).then(url => {
        let reloadEvent = new CustomEvent(
          "rg_redirection", {
          detail: {
            url: url
          }
        });
        document.dispatchEvent(reloadEvent, {
          bubbles: true,
          composed: true
        });
      });
    }
  }

  addressRecommendations = [];
  selectedAddress = '';
  addressDetail = {};
  @track searchValue = '';
  city;
  country;
  pincode;
  state;

  get hasRecommendations() {
    return (this.addressRecommendations !== null && this.addressRecommendations.length);
  }

  @track searchText;
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

  addressOtherRecommendation;
  getAddressRecommendations() {
    getAddress({ searchString: this.searchText })
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

  resetAddress() {
    this.city = '';
    this.country = '';
    this.pincode = '';
    this.state = '';
  }

  handleAddressRecommendationSelect(event) {
    this.addressRecommendations.forEach((item, index) => {
      if (item.place_id == event.currentTarget.dataset.value) {
        this.searchValue = item.main_text;
        sessionStorage.setItem('selectedPlaceId', item.place_id);
      }
    });
    this.addressRecommendations = [];
    this.selectedAddress = '';
    this.resetAddress();
  }
}