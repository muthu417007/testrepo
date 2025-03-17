import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import netStyles from '@salesforce/resourceUrl/RG_StyleSheet';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class RG_Overview_List extends NavigationMixin(LightningElement)
{
  @api listitem = 'Service Overview;Service Areas;Certified Technicians;Warranty Overview';
  @track overviewValues = [];
  @track overviewheadings = [];
  @track overviewheadingslist = [];

  @api heading = 'About Overview';
  isArticleDetail = false;
  sectionId;

  connectedCallback() {
    if (this.listitem != '') {
      this.overviewValues = this.listitem.split(';');
      this.overviewValues.forEach(element => {
        let value = element.replace(/ +/g, "");
        this.overviewheadings.push({ value: element, key: value });
      })
    }
    this.overviewheadingslist = this.overviewheadings.map((item, index) => {
      return {
        id: index,
        value: item.value,
        key: item.key,
        url: '#' + item.key
      }
    });
  }
  
  renderedCallback() {
    Promise.all([
      loadStyle(this, netStyles)
    ])
  }

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference.attributes.name == 'FAQ__c') {
      this.isArticleDetail = true;
    }
  }

  handleScroll(e) {
    debugger;
    //var ind = this.overviewValues.indexOf(e.currentTarget.dataset.value) + 1;
    if (this.isArticleDetail) {
      this.sectionId = '#' + e.currentTarget.dataset.value.replace(/\s/g, '');
    }
    else {
      this.sectionId = '#' + e.currentTarget.dataset.value;
    }
  }
}