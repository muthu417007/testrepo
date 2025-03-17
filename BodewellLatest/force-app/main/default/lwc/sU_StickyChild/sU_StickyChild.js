import { LightningElement, api, track } from 'lwc';
import { fireEvent } from 'c/supubsub';

export default class SU_StickyChild extends LightningElement {
    @api filterType;
    @track seeMore ;
    @api eventCode;
    @track seeLess ;
    @track firstLoad = true;
    @track filterTypeToShowCopy ;
    
    
    get filter(){
         // this function executes every time new filter is selected from facets all filter changes
        this.filterTypeToShowCopy = JSON.parse(JSON.stringify(this.filterType));
        const hasMoreThanThreeValues = this.filterTypeToShowCopy.values.length > 3;
        this.seeMore = (this.firstLoad && hasMoreThanThreeValues) ? true : this.seeMore;
        this.seeLess = this.firstLoad ? false : this.seeLess;
        if (!hasMoreThanThreeValues) {
            this.seeMore = false;
            this.seeLess = false;
            this.firstLoad = true;
        }
        else{
            this.firstLoad = false;
        }
        if (hasMoreThanThreeValues && this.seeMore) {
            this.filterTypeToShowCopy.values = this.filterTypeToShowCopy.values.slice(0, 3);
        } 

          return this.filterTypeToShowCopy;
    }

    seeMoreHandler(e) {
        //runs when see more see less is clicked
        let v = e.target.dataset.val;
            if (v === 'less') {
              this.seeMore =false;
              this.seeLess = true;
              
            } else if (v === 'more') {
              this.seeMore =true;
              this.seeLess = false;
            }
          return item;
      }
    

    removeStickyFilter(event) { 
        let objToSend = {
            contentname: event.target.getAttribute("data-Contentname"),
            label: event.target.getAttribute("data-label"),
            level: event.target.getAttribute("data-level"),
            type: event.target.getAttribute("data-type"),
            immediateParent: event.target.getAttribute("data-immediateParent"),
            path: event.target.getAttribute("data-path") ? JSON.parse(event.target.getAttribute("data-path")) : [],
        }

        fireEvent(this.pageRef, 'removeStickyFacetEvent' + this.eventCode, objToSend);
    
    }
    
}