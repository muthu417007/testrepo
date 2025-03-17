import { LightningElement, wire, track, api } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import BasePath from '@salesforce/community/basePath';


export default class RG_LocalServiceAreaList extends NavigationMixin(LightningElement)
{

  @api serviceAreaName;
  @api serviceAreaList;
  serviceAreaListLength = 0;
  @track serviceAreaItemList = [];

  connectedCallback() {
    if(this.serviceAreaList) {
      this.serviceAreaListLength = this.serviceAreaList.length;
      this.serviceAreaItemList = this.serviceAreaList.map((item, index) => {
        return {
          id: index,
          itemName: item.Name,
          itemTarget: BasePath + '/service-area/' + item.Id + '/' + item.Name.replace(/\s+/g, '-').toLowerCase()
        }
      }); 
    }
  }

  handleClick(event) {
    event.preventDefault();
    this.isLocalArea = false;
    this.localServiceAreaUrl = event.currentTarget.dataset.value;

    let reloadEvent = new CustomEvent(
      "rg_redirection", {
      detail: {
        url: this.localServiceAreaUrl
      }
    });
    document.dispatchEvent(reloadEvent, {
      bubbles: true,
      composed: true
    });
  }
}