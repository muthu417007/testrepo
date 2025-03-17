import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import BasePath from '@salesforce/community/basePath';
import getNavigationMenu from '@salesforce/apex/RG_NavigationMenuItemsController.getNavigationMenuItems';
import getServiceAreas from '@salesforce/apex/RG_ServiceAreasController.getSiteMapServiceAreas';

export default class RG_SitemapUrlList extends NavigationMixin(LightningElement)
{
  @api menuName;
  @track menuItems = [];
  @track menuListItems = [];
  @track isLoaded = false;
  @track error;

  success = 'Not Available';
  serviceAreaName;
  localAreaName;
  serviceAreaList = [];
  serviceAreaItemList = [];

  // Wire methods
  @wire(getNavigationMenu, {
    menuName: '$menuName',
    publishedStatus: 'Draft'
  })
  wiredMenuItems({ error, data }) {
    if (data && !this.isLoaded) {
      if (data.success) {
        this.menuItems = data.result;
        this.menuListItems = data.result.map((item, index) => {
          return {
            id: index,
            menuItemId: item.menuItemId,
            menuItemName: item.menuItemName,
            menuItemTarget: BasePath + item.menuItemTarget
          }
        });
        this.success = 'Success';
        console.log(`Resource Nav List: ${JSON.stringify(this.menuListItems)}`);
      }
    } else if (error) {
      this.error = error;
      this.menuItems = [];
      console.log(`Resource Nav List error: ${JSON.stringify(this.error)}`);
      this.success = 'Failed';
    }
  }
  // Wire methods end

  connectedCallback() {
    this.getLocalServiceAreas();
  }

  getLocalServiceAreas() {
    getServiceAreas()
      .then(result => {
        this.serviceAreaList = result;
        console.log(this.serviceAreaList);
        console.log(JSON.stringify(this.serviceAreaList));
        debugger;
        this.serviceAreaItemList = result.map((item, index) => {
          return {
            id: index,
            itemName: item.serviceAreaName,
            itemTarget: BasePath + '/service-area/' + item.serviceAreaId + '/' + item.serviceAreaName.replace(/\s+/g, '-').toLowerCase(),
            subItems: item.localAreaList.map((elem, elemindex) => {
              return {
                id: elemindex,
                subItemName: elem.Name,
                subItemTarget: BasePath + '/service-area/' + elem.Id + '/' + elem.Name.replace(/\s+/g, '-').toLowerCase()
              }
            })
          }
        });
        this.success = 'Success';
        console.log('serviceAreaList: ', this.serviceAreaList);
        console.log(`serviceAreaItemList: ${JSON.stringify(this.serviceAreaItemList)}`);
      })
      .catch(error => {
        console.error(error);
      });
  }

  handleNavigation(event) {
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
  
}