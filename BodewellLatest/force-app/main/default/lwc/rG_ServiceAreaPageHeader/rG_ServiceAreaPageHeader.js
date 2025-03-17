import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import RG_State_Page_Phone_Number from '@salesforce/label/c.RG_StatePagePhoneNumber';
import RG_Schedule_Call from '@salesforce/label/c.RG_Schedule_Call';
import contactlogo from '@salesforce/resourceUrl/RG_IconContact';
import ScheduleServiceLink from '@salesforce/label/c.RG_ScheduleServiceLink';
import getLocalArea from '@salesforce/apex/RG_ServiceAreasController.getLocalAreaDetails';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubsub';

// import { publish, MessageContext } from 'lightning/messageService';
// import SERVICE_AREA_CHANNEL from '@salesforce/messageChannel/ServiceAreaUpdate__c';

import netStyles from '@salesforce/resourceUrl/RG_StyleSheet';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class RG_ServiceAreaPageHeader extends NavigationMixin(LightningElement)
{
  @api stateContentHeading = "FAST, RELIABLE APPLIANCE REPAIR";
  @api cityContentHeading = "EXPERT REPAIRS DONE RIGHT";
  @api stateContentBody = "Whether it’s a leaky fridge, smoking oven, clogged dishwasher, or noisy dryer, unexpected appliance issues can disrupt your entire household routine. Rest assured, our expert technicians are well-equipped to quickly diagnose and resolve your appliance problem—often in a single visit*. Get back on track sooner: book a repair with GE Appliances Factory Service today.";

  serviceAreaName;
  localServiceAreaName;
  localServiceAreaPhone;
  localServiceAreaPhoneLink;
  localServiceAreaTollFreePhone;
  localServiceAreaSideText;
  stateAbbreviation;
  pageRef;
  isLocalArea = false;
  isOnlyServiceArea = false;
  isStateAbbLoaded = false;
  schedulePhone = RG_Schedule_Call;
  schedulePhoneLink;
  hasPageLinkList = false;
  @track pageLinkList = [];
  connected = false;
  // @wire(MessageContext)
  messageContext;
  localState;
  formattedtollfreenumber;
  isState = false;
  scheduleServiceLink = ScheduleServiceLink;
  communityData = {
    contactlogo: contactlogo
  }

  pageLinks = [
    {
      pageLabel: 'Refrigerator',
      pageApiName: 'Refrigerator_Resources__c'
    },
    {
      pageLabel: 'Oven/Range',
      pageApiName: 'Oven_Range_Resources__c'
    },
    {
      pageLabel: 'Dishwasher',
      pageApiName: 'Dishwasher_Resources__c'
    },
    {
      pageLabel: 'Dryer',
      pageApiName: 'Dryer_Resources__c'
    },
    {
      pageLabel: 'Washing Machine',
      pageApiName: 'Washing_Machine_Resources__c'
    },
    {
      pageLabel: 'Freezer',
      pageApiName: 'Freezer_Resources__c'
    }
  ]

  currentUrl;
  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference && !this.connected) {
      this.pageRef = currentPageReference;
      if (currentPageReference.attributes.name == 'Service_Areas__c' &&
        this.isOnlyServiceArea == false &&
        !currentPageReference.state.servicearea) {
        this.isOnlyServiceArea = true;
      }

      if (!currentPageReference.state.localarea && currentPageReference.state.servicearea) {
        this.isState = true;
      }

      this.serviceAreaName = currentPageReference.state.servicearea;
      this.localServiceAreaName = undefined;
      this.isLocalArea = false;
      this.isStateAbbLoaded = false;
      if (currentPageReference.state.localarea) {
        this.isLocalArea = true;
        this.localServiceAreaName = currentPageReference.state.localarea;
        let selectedArea = sessionStorage.getItem('selectedarea');
        if (selectedArea) {
          let data = JSON.parse(selectedArea);
          if (this.localServiceAreaName.toLowerCase() == data.Label.toLowerCase()) {
            this.stateAbbreviation = data.State_Abbreviation__c;
            this.isStateAbbLoaded = true;
            fireEvent(this.pageRef, 'serviceAreaEvent', { state: this.stateAbbreviation, localarea: this.localServiceAreaName });
          }
        }
        this.getLocalAreaDetails();
      } else {
        // const timeout = setTimeout(() => {
        //   fireEvent(this.pageRef, 'serviceAreaEvent', { state: this.serviceAreaName }), 5000
        // });        
        this.getLocalAreaDetails();
      }
    }
  }

  renderedCallback() {
    Promise.all([
      loadStyle(this, netStyles)
    ])
  }

  connectedCallback() {
    this.connected = true;
    this.schedulePhoneLink = 'tel:' + this.schedulePhone;

    if (!this.isOnlyServiceArea) {
      sessionStorage.setItem('serviceAreaPageHeader', 'true');
      registerListener('scheduleServiceCallback', this.handleEvent, this);
    }

    if (this.isState) {
      registerListener('tollFreeNoEvent', this.handleTollfreeNumber, this);
      if (sessionStorage.getItem('dni_value') != 'true') {
        fireEvent(this.pageRef, 'tollefreeEventCallBack', 'true');
      }
    }

    this.pageLinks.forEach((item, index) => {
      this[NavigationMixin.GenerateUrl]({
        type: 'comm__namedPage',
        attributes: {
          name: item.pageApiName
        },
      }).then((url) => {
        this.hasPageLinkList = true;
        this.pageLinkList.push({
          pageLabel: item.pageLabel,
          pageApiName: item.pageApiName,
          pageUrl: url
        });
        console.log('this.pageLinkList: ', JSON.stringify(this.pageLinkList));
      });
    });

  }

  handleEvent(inpVal) {
    //fireEvent(this.pageRef, 'localCityTollFreeNo', RG_State_Page_Phone_Number);
  }

  handleTollfreeNumber(val) {
    this.schedulePhone = val;
    this.schedulePhoneLink = 'tel:' + this.schedulePhone;
    sessionStorage.removeItem('dni_value');
  }

  handleResourceNavigation(event) {
    // var navUrl = event.currentTarget.dataset.value;
    // this[NavigationMixin.Navigate]({
    //   type: 'comm__namedPage',
    //   attributes: {
    //     name: navUrl
    //   }
    // });
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

  handleScheduleOnline() {
    let scheduleServiceEvent = new CustomEvent(
      "gtm__serviceSchedule", {
      detail: {
        clickLocation: 'body'
      }
    });
    document.dispatchEvent(scheduleServiceEvent, {
      bubbles: true,
      composed: true
    });
    //window.open(scheduleServiceLink, "_blank");
  }

  getLocalAreaDetails() {
    getLocalArea({ localAreaName: this.localServiceAreaName })
      .then(result => {
        this.stateAbbreviation = result.State_Abbreviation__c;
        this.localServiceAreaPhone = result.Local_Phone__c;
        this.localServiceAreaPhoneLink = 'tel:' + this.localServiceAreaPhone;
        this.localServiceAreaSideText = result.Side_Text__c;
        this.localServiceAreaTollFreePhone = result.TollFree_Phone__c;
        this.isStateAbbLoaded = true;
        fireEvent(this.pageRef, 'localCityTollFreeNo', this.localServiceAreaTollFreePhone);
        fireEvent(this.pageRef, 'serviceAreaEvent', { state: this.stateAbbreviation, localarea: this.localServiceAreaName });
      })
      .catch(error => {
        fireEvent(this.pageRef, 'serviceAreaEvent', { state: this.serviceAreaName });
        console.log('getLocalAreaDetails error: ', error);
      });
  }

  handleServiceArea() {
    let selectedArea = sessionStorage.getItem('selectedarea');
    if (selectedArea) {
      sessionStorage.setItem('selectedarea', JSON.stringify(selectedArea));
    }
    // const payload = { areaName: this.localState };
    // publish(this.messageContext, SERVICE_AREA_CHANNEL, payload);
  }

  handleCall() {
    let contactUsCallEvent = new CustomEvent(
      "gtm__contactUsCall", {
      detail: {
        contact: this.schedulePhone,
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
        contact: this.localServiceAreaPhone,
        contactClickLocation: 'body'
      }
    });
    document.dispatchEvent(contactUsCallEvent, {
      bubbles: true,
      composed: true
    });
  }

  disconnectedCallback() {

    unregisterAllListeners(this);

  }
}