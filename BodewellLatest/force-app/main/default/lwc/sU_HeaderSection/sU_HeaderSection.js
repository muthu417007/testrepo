import { LightningElement, api, track } from 'lwc';

import { registerListener, fireEvent } from 'c/supubsub';

export default class SU_HeaderSection extends LightningElement {
    @api showClearFiltersButton;
    @api searchString;
    @api langlist;
    @api selectedTypeFilter;
    @api recordId;
    @api aggregationsData;
    @api recordIdfromSUParent;
    @api selectedStickyFilter;
    @track notBigScreen;
    @track dynamicClassHeader = 'su__d-block';
    @api showFilter;
    @api tabsFilter;
    @api uid;
    @api endPoint;
    @api gototopcontainer;
    @api allarehidden;
    @api bearer;
    @api exactphrase;
    @api withoneormore;
    @api withoutthewords;
    @api updateadvancesearch;
    @api advancedSearchSelected = false;
    @api eventCode;
    @api searchQuery;
    @api bookmarkList;
    @api allContentHideFacet = false;
    @api languageEnabled = false;
    @api mergedArray;
    @api urlopensinnewtab;
    @api translationObject;

    filterButtonClass = 'su__text-center su__bg-white su__cursor su__filters-button';

    tabsFilter;
    buttonValue=false;

    get getBookmarkListLength() {
        return this.bookmarkList && this.bookmarkList.length ? true : false;
    }

    connectedCallback() {
        this.template.querySelector('.bck');
        registerListener('dataFromContainer'+this.eventCode,this.handleDataFromContainer,this);
        registerListener('filterClosed'+this.eventCode,this.filterClosed,this);
        registerListener('viewAllStickyButton'+this.eventCode, this.viewAllStickyButton, this);
        registerListener('bigscreen'+this.eventCode,this.setBigscreen,this);
    }

    renderedCallback(){

        this.allContentHideFacet = this.aggregationsData && (this.aggregationsData.length == 0 || this.aggregationsData.length == 1);
        if (this.allContentHideFacet){
            this.filterButtonClass = 'su__facethide-inner su__text-center su__bg-white su__cursor su__filters-button su__disable-btn';
        }
        else if(this.allarehidden ){
             this.filterButtonClass = 'su__text-center su__bg-white su__filters-button su__disable-btn';

        }
        else{
            this.filterButtonClass = 'su__text-center su__bg-white su__cursor su__filters-button';
        }
    }

    filterClosed(event){
        if(this.template.querySelector('[data-id="filterBlock"]')) {
            this.template.querySelector('[data-id="filterBlock"]').classList.remove('filter-absolute');             
        }
        this.showFilter = false;
    }

    viewAllStickyButton(event){
        this.template.querySelector('[data-id="filterBlock"]').classList.add('filter-absolute');

    }

    //this method is called when button is clicked and will fire the event to parent(SuSearchClientLWC Container)
    handleUtilitySlider(event) {
        this.showFilter= true;
        let message="header";
        fireEvent(null,'headerSUData'+this.eventCode,message);
        if(this.template.querySelector('[data-id="filterBlock"]')) {
            this.template.querySelector('[data-id="filterBlock"]').classList.add('filter-absolute');            
        }
    }
    setBigscreen(bigscreenevent){
        if(bigscreenevent === false){
            this.dynamicClassHeader = 'su__d-block'
            this.notBigScreen = true;
        }
        else if (bigscreenevent === true){
            this.dynamicClassHeader = 'su__d-none';
            
        }
        
    }


    handleDataFromContainer(event){
        this.recordIdfromSUParent=event.recorId;
        this.aggregationsData=event.aggregationsData;
        this.selectedStickyFilter=event.selectedStickyFilter;
        this.tabsFilter=event.tabsFilter;
        this.showClearFiltersButton = event.showClearFiltersButton;
        this.bookmarkList = event.bookmarkList;
    }

}