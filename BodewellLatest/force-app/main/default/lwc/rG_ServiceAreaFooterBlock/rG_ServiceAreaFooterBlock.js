import { LightningElement, wire, track, api } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import getServiceArea from '@salesforce/apex/RG_ServiceAreasController.getServiceAreas';
import BasePath from '@salesforce/community/basePath';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubsub';

import netStyles from '@salesforce/resourceUrl/RG_StyleSheet';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class RG_ServiceAreaFooterBlock extends NavigationMixin(LightningElement)
{
  isExpand = true;
  serviceAreaList = [];
  serviceAreaItemList = [];
  serviceAreaListLength;
  serviceAreaName;
  error;
  @api textcontent = 'We proudly serve over 300 cities nationwide in 39 states and the District of Columbia. Select a state to find a local technician.';
  
  @wire(CurrentPageReference) pageRef;

  renderedCallback() {
    Promise.all([
      loadStyle(this, netStyles)
    ])
  }

  @wire(getServiceArea)
  wiredServiceArea({ error, data }) {
    if (data) {
      this.serviceAreaList = data;
      // console.log('serviceAreaList: ', this.serviceAreaList);
      this.serviceAreaListLength = this.serviceAreaList.length;
      this.serviceAreaItemList = data.map((item, index) => {
        return {
          id: index,
          itemName: item.Name,
          itemTarget: BasePath + '/service-area/' + item.Id + '/' + item.Name.replace(/\s+/g, '-').toLowerCase()
        }
      });
      // console.log('params -> serviceAreaListEvnt');
      fireEvent(this.pageRef, 'serviceAreaListEvnt', { serviceAreaList: this.serviceAreaList });
    } else if (error) {
      // window.console.log(error);
    }
  }

  handleClick(event) {
    event.preventDefault();
    let navUrl = event.currentTarget.dataset.value;
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
  showAll() {
    if (this.isExpand == false) {
      this.isExpand = true;
    } else if (this.isExpand == true) {
      this.isExpand = false;
    }
  }

}