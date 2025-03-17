import { LightningElement, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import getLocalArea from '@salesforce/apex/RG_ServiceAreasController.getLocalAreaDetailsSearchResults';
import getLocalAreaLatLong from '@salesforce/apex/RG_ServiceAreasController.getLocalAreaDetailsSearchResultsLatLong';
import RG_DefaultTollFree from '@salesforce/label/c.RG_Schedule_Call';
import RG_ServiceAreaSearchPageTitle from '@salesforce/label/c.RG_Service_Area_Search_Page_Title';
import BasePath from '@salesforce/community/basePath'

import netStyles from '@salesforce/resourceUrl/RG_StyleSheet';
import { loadStyle } from 'lightning/platformResourceLoader';

import locationPin from '@salesforce/resourceUrl/RG_LocationPin';
import verfifiedIcon from '@salesforce/resourceUrl/RG_IconVerified';

export default class RG_ServiceAreaSearchResult extends NavigationMixin(LightningElement)
{
  tollfreenumber = RG_DefaultTollFree;
  tollfreelink = 'tel:' + RG_DefaultTollFree;
  localPhoneLink;
  serviceCity;
  serviceCityUrl;
  serviceAddress;
  serviceArea;
  serviceState;
  isServiceAvailable;
  isLatLong = false;
  serviceSplitAddress = [];
  isLoaded = false;
  isExactLocation = false;
  pageViewEventInvoked = false;
  locationPin = locationPin;
  verfifiedIcon = verfifiedIcon;

  stateAbbr =  [{ SA: 'AL' , SN: 'Alabama' },
                { SA: 'AR' , SN: 'Arkansas' },
                { SA: 'AZ' , SN: 'Arizona' },
                { SA: 'CA' , SN: 'California' },
                { SA: 'CO' , SN: 'Colorado' },
                { SA: 'CT' , SN: 'Connecticut' },
                { SA: 'DC' , SN: 'District of Columbia' },
                { SA: 'DE' , SN: 'Delaware' },
                { SA: 'FL' , SN: 'Florida' },
                { SA: 'GA' , SN: 'Georgia' },
                { SA: 'IL' , SN: 'Illinois' },
                { SA: 'IN' , SN: 'Indiana' },
                { SA: 'KS' , SN: 'Kansas' },
                { SA: 'KY' , SN: 'Kentucky' },
                { SA: 'LA' , SN: 'Louisiana' },
                { SA: 'MA' , SN: 'Massachusetts' },
                { SA: 'MD' , SN: 'Maryland' },
                { SA: 'MI' , SN: 'Michigan' },
                { SA: 'MN' , SN: 'Minnesota' },
                { SA: 'MO' , SN: 'Missouri' },
                { SA: 'MS' , SN: 'Mississippi' },
                { SA: 'NC' , SN: 'North Carolina' },
                { SA: 'NE' , SN: 'Nebraska' },
                { SA: 'NH' , SN: 'New Hampshire' },
                { SA: 'NJ' , SN: 'New Jersey' },
                { SA: 'NV' , SN: 'Nevada' },
                { SA: 'NY' , SN: 'New York' },
                { SA: 'OH' , SN: 'Ohio' },
                { SA: 'OK' , SN: 'Oklahoma' },
                { SA: 'OR' , SN: 'Oregon' },
                { SA: 'PA' , SN: 'Pennsylvania' },
                { SA: 'RI' , SN: 'Rhode Island' },
                { SA: 'SC' , SN: 'South Carolina' },
                { SA: 'TN' , SN: 'Tennessee' },
                { SA: 'TX' , SN: 'Texas' },
                { SA: 'UT' , SN: 'Utah' },
                { SA: 'VA' , SN: 'Virginia' },
                { SA: 'WA' , SN: 'Washington' },
                { SA: 'WI' , SN: 'Wisconsin' }];

  renderedCallback() {
    Promise.all([
      loadStyle(this, netStyles)
    ])
  }

  selectedPlaceId;
  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      debugger;
      var regExp = /[a-zA-Z]/g;
      this.selectedPlaceId = sessionStorage.getItem('selectedPlaceId');
      this.serviceAddress = currentPageReference.state.result;
      if(regExp.test(this.serviceAddress))
      {
        this.serviceSplitAddress = this.serviceAddress.split(', ');
        this.serviceArea = this.serviceSplitAddress[0];
        this.stateAbbr.forEach((items, index) => {
          // if (items.SA == this.serviceSplitAddress[1].toUpperCase()) {
          //   this.serviceState = items.SN;
          // }
          if (this.serviceSplitAddress[1].toUpperCase().includes(items.SA)) {
            this.serviceState = this.serviceSplitAddress[1].toUpperCase();
            this.serviceState = this.serviceState.replaceAll(items.SA, items.SN);
          }
        });        
        this.getLocalAreaDetails();
      }
      else
      {
        this.serviceSplitAddress = this.serviceAddress.split(',');
        this.serviceArea = this.serviceSplitAddress[0];
        this.serviceState = this.serviceSplitAddress[1];
        // this.stateAbbr.forEach((items, index) => {
        //   if (items.SA == this.serviceSplitAddress[1].toUpperCase()) {
        //     this.serviceState = items.SN;
        //   }
        // });    
        //this.serviceState = this.serviceSplitAddress[1];
        this.isLatLong = true;
        this.getLocalAreaLatLong();
      }      
    }
  }

  getLocalAreaDetails() {
    getLocalArea({ localAreaDetails: this.serviceAddress , placeId : this.selectedPlaceId})
      .then(result => {
        debugger;
        this.serviceCity = result;
        if (this.serviceCity && this.serviceCity.Id && this.serviceCity.Name) {
          this.serviceCityUrl = BasePath + '/service-area/' + this.serviceCity.Id + '/' + this.serviceCity.Name.replace(/\s+/g, '-').toLowerCase();
          console.log('serviceCity: ', this.serviceCity);
          this.handlePageView();
          if (this.serviceCity.Name) {
            this.localPhoneLink = 'tel:' + this.serviceCity.Local_Phone__c;
            this.isServiceAvailable = true;
            this.isLoaded = true;
          }
          else {
            this.isServiceAvailable = false;
            this.isLoaded = true;
          }
          let serviceAddressUC = this.serviceAddress.toUpperCase();
          if (serviceAddressUC.includes(this.serviceCity.Name.toUpperCase())) {
            this.isExactLocation = true;
          }
        } else {
          this.handlePageView();
          this.isServiceAvailable = false;
          this.isLoaded = true;
        }
      })
      .catch(error => {
        console.error(JSON.stringify(error));
      });
  }

  getLocalAreaLatLong() {
    getLocalAreaLatLong({ localAreaDetails: this.serviceAddress })
      .then(result => {
        this.serviceCity = result;
        if (this.serviceCity.Name) {
          this.localPhoneLink = 'tel:' + this.serviceCity.Local_Phone__c;
          this.isServiceAvailable = true;
          this.isLoaded = true;
        }
        else {
          this.isServiceAvailable = false;
          this.isLoaded = true;
        }
      })
      .catch(error => {
        console.error(error);
      });
  }

  handleCall() {
    let contactUsCallEvent = new CustomEvent(
      "gtm__contactUsCall", {
      detail: {
        contact: this.tollfreenumber,
        contactClickLocation: 'body'
      }
    });
    document.dispatchEvent(contactUsCallEvent, {
      bubbles: true,
      composed: true
    });
  }

  handleLocalCall() {
    let contactUsCallEvent = new CustomEvent(
      "gtm__contactUsCall", {
      detail: {
        contact: this.serviceCity.Local_Phone__c,
        contactClickLocation: 'body'
      }
    });
    document.dispatchEvent(contactUsCallEvent, {
      bubbles: true,
      composed: true
    });
  }

  handleLocalClick(event) {
    event.preventDefault();
    var navUrl = event.currentTarget.dataset.value;
    let reloadEvent = new CustomEvent(
      "rg_redirection", {
      detail: {
        url: navUrl
      }
    });
    document.dispatchEvent(reloadEvent, {
      bubbles: true,
      composed: true
    });
  }

  handlePageView() {
    if (!this.pageViewEventInvoked) {
      let location = this.serviceArea ? this.serviceArea + ', ' + this.serviceState : this.serviceState;
      let titleLabel = RG_ServiceAreaSearchPageTitle.split('{}');
      document.title = titleLabel[0] + ' ' + location + ', United States' + titleLabel[1];
      let pageViewEvent = new CustomEvent("gtm__pageView");
      document.dispatchEvent(pageViewEvent, {
        bubbles: true,
        composed: true
      });
      this.pageViewEventInvoked = true;
    }
  }
}