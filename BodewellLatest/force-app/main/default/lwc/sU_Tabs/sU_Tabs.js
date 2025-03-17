import { LightningElement, api, track, wire } from 'lwc';
import { registerListener, fireEvent } from 'c/supubsub';

export default class SU_Tabs extends LightningElement {
    allContentTabSelected = false;
    @api showFilter1 = false;
    @api aggregationsdata;
    listofStickyFacet = [];
    @api eventCode;
    previousIndexVal = '';
    @track contentTab = [];
    @track showArrowIcon = false;
    showMergedCSTabs = false;
    @track borderClass = ""
    @track tabSelected;
    @track active;
    sourceArr = [{
        "key": "all_Content",
        "values": "All Content"
    }];
    @api
    set tabsfilter(value) {
        if (value)
            this.contentTab = JSON.parse(JSON.stringify(value));
    };
    get tabsfilter() {
        return this.contentTab;
    }

    tabClicked2(event) {
        this.tabClicked(event);
        this.showMergedCs();
    }
    connectedCallback(){
        registerListener('tabClicked'+this.eventCode, this.tabClicked, this);
    }
    tabClicked(event) {
        if (event && event.target.dataset.name != 'all_Content') {
            this.allContentTabSelected = true;
            this.showFilter1 = true;
        } else {
            this.allContentTabSelected = false;
            this.showFilter1 = false;
        }
        if (this.previousIndexVal == '') {
            this.previousIndexVal = event.target.dataset.name;
        }
        if (this.previousIndexVal != '' && this.previousIndexVal != event.target.dataset.name) {
            if (this.template.querySelector(`[data-name= '${this.previousIndexVal}']`)) {
                this.template.querySelector(`[data-name='${this.previousIndexVal}']`).classList.remove('active-type');
            }
            this.previousIndexVal = event.target.dataset.name;
        }
        var currentIndex = event.target.dataset.name;
        if (this.template.querySelector(`[data-name='${currentIndex}']`)) {
            this.template.querySelector(`[data-name='${currentIndex}']`).classList.add("active-type");
        }
        if (event && event.target.dataset.mergedchild == 'true' && this.template.querySelector(`[data-name='${event.target.name}']`)) {
            this.template.querySelector(`[data-name='${event.target.name}']`).classList.add("active-type");
            this.previousIndexVal = event.target.name;
        }

        // this.coloredIndex = event.target.dataset.ind;
        if (this.sourceArr.length == 0) {
            this.sourceArr.push({
                "key": event.target.dataset.mergedchild == 'true' ? event.target.name : event.target.dataset.name || 'all_Content',
                "values": event.target.label || 'All Content'
            });
        } else {
            this.sourceArr.splice(0, 1, {
                "key": event.target.dataset.mergedchild == 'true' ? event.target.name : event.target.dataset.name || 'all_Content',
                "values": event.target.label || 'All Content'
            });
        }

        var data = event && event.target.dataset;
        var filterValue;
        if (this.sourceArr && !this.sourceArr[0].key && !this.sourceArr[0].values) {
            filterValue = [];
        } else if (this.sourceArr && this.sourceArr[0].key === 'all_Content' && this.sourceArr[0].values === 'All Content') {
            filterValue = [];
        } else {
            filterValue = [{ type: this.aggregationsdata[0].key, filter: [] }];
        }
        if (!data.merged && data.name != 'all_Content' && filterValue.length !== 0) {
            filterValue[0].filter = [data.name];
        } else if (data.merged && !data.showchild && filterValue.length !== 0) {
            let index = data.ind;
            this.contentTab[index].childArray.forEach(function (ele) {
                filterValue[0].filter.push(ele.Contentname);
            });
        }
        fireEvent(null, 'tabclicked' + this.eventCode, filterValue);
    }
    showMergedCs(event) {
        let ind = event.currentTarget.dataset.ind;
        ind = ind >= 0 ? ind : this.mergedTabIndex;
        if (ind >= 0) {
            this.contentTab[ind].showMergedCSTabs = !this.contentTab[ind].showMergedCSTabs;
            this.mergedTabIndex = ind;
        }
        if (ind >= 0 && this.contentTab[ind].showMergedCSTabs) {
            for (let j = 0; j < this.template.querySelectorAll('[data-id="su__overflow-visible"]').length; j++) {
                this.template.querySelectorAll('[data-id="su__overflow-visible"]')[j].classList.add('su__overflow-visible');
            }
        } else {
            for (let j = 0; j < this.template.querySelectorAll('[data-id="su__overflow-visible"]').length; j++) {
                this.template.querySelectorAll('[data-id="su__overflow-visible"]')[j].classList.remove('su__overflow-visible');
            }
        }
    }

    renderedCallback() {
        var selectedTab = '';
        if (this.sourceArr) {
            selectedTab = this.sourceArr[0].key;
        } else {
            selectedTab = 'all_Content';
        }
        if (this.aggregationsdata && this.aggregationsdata.length) {
            if (this.aggregationsdata && this.aggregationsdata.length && this.aggregationsdata[0].values && this.aggregationsdata[0].values.find(f => f.selected)) {
                var selectedTabObj = this.aggregationsdata[0].values.find(f => f.selected);
                selectedTab = selectedTabObj.Contentname;
            } else selectedTab = 'all_Content';
            if (this.previousIndexVal && this.template.querySelector(`[data-name='${this.previousIndexVal}']`))
                this.template.querySelector(`[data-name='${this.previousIndexVal}']`).classList.remove("active-type");
            this.previousIndexVal = selectedTab;
            if (this.template.querySelector(`[data-name='${selectedTab}']`)) {
                this.template.querySelector(`[data-name='${selectedTab}']`).classList.add("active-type")
            }
        }
        var CsNavBar = this.template.querySelector('[data-id="su__csNavbar"]');
        var internalCsDiv = this.template.querySelector('[data-name="internal__div"]');
        if (CsNavBar && internalCsDiv) {
            var navBarWidth = CsNavBar.offsetWidth;
            var internalCsWidth = internalCsDiv.offsetWidth;
            if (internalCsWidth > navBarWidth) {
                this.showArrowIcon = true;
            } else {
                this.showArrowIcon = false;
            }
        }
        if (this.bigscreen) {
            this.borderClass = "su__flex-vcenter"

        } else {
            this.borderClass = "su__flex-vcenter su__border-b"

        }

    }
    clearFilterForSlider1(event) {
        fireEvent(null, 'clearAllFilters' + this.eventCode, null);
        this.tabClicked(event);
    }
    nextContentSource() {
        var scrollRight1 = this.template.querySelector('[data-id="su__csNavbar"]');
       // scrollRight.scrollBy({ left: 160, behavior: 'smooth' });
      scrollRight1.scrollLeft += 100;


    }
    previousContentSource() {
        var scrollRight11 = this.template.querySelector('[data-id="su__csNavbar"]');
        //scrollRight.scrollBy({ left: -160, behavior: 'smooth' });
        scrollRight11.scrollLeft += -100;
    }

    get test() {
        if (this.active == this.tabSelected)
            return true;
        return false;
    }


}