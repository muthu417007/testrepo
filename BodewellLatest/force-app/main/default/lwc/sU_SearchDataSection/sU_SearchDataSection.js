import { LightningElement, api, track, wire } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import { registerListener, fireEvent } from 'c/supubsub';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import assignArticleToCase from '@salesforce/apex/su_vf_console.SUVFConsoleController.assignArticleToCase';
import doesKnowledgeExist from '@salesforce/apex/su_vf_console.SUVFConsoleController.doesKnowledgeExist';
import createLinkOfAttachment from '@salesforce/apex/su_vf_console.SUVFConsoleController.createLinkOfAttachment';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
import getAttachmentRelatedInfo from '@salesforce/apex/su_vf_console.SUVFConsoleController.getAttachmentRelatedInfo';
export default class SU_SearchDataSection extends NavigationMixin(LightningElement) {
    @track showArticlePreview = false;
    @track articleRecordExists=false;
    @track attached_Attachments;
    @api maincontainerwidth;
    @track fileAttachment=[];
    @api containerrightcoordinate;
    @track titleImage;
    @track attachLink;
    currentHeight;
    @track test = false;
    clearFilterText = 'Clear Filter :';
    @api senddata;
    icontextt2 = 'utility:linked';
    icontextt1 = 'utility:attach';
    showFilterPopup;
    @api aggregationsdata;
    @api totalpages;
    @api searchresultime;
    @track showIcon = false;
    firstStickyLabel;
    filterValueOne = [];
    firstStickyLabel1 = false;
    @api totalresults;
    @api resultlabel;
    showfirstFacet = false;
    newResponseList = [];
    @api pagenum;
    @track clearAllClass="su__clear-filters-btn su__cursor  font-12 su__font-bold su__mb-2 su__p-0  su__loading-view "
    stickyPopUp = 'stickyPopUp1';
    searchResultTime = '0.23';
    @api showArticle = false;
    allContentTabSelected = false;
    eventSortType = '';
    previousIndexVal = '';
    borderClass = ""
    advFilterData;
    context = this;
    // showAllStickyFacets = false;
    @track dataSectionClasses = 'su__d-block';

    @track result;
    @track ptitle;
    @track objName;
    @track idd;
    @track sourcename;
    advFilterDatavalues = [];
    @api recordId;
    requiredStickyFacet = [];
    @api showFilter1 = false;
    @api previewModalVal = false;
    @api previewSrcVal = '';
    @api typeofContentForPreview = '';
    @api previewSourceLabel= '';
    showAllFilters;
    advFilterDatavalues1 = [];
    showClearFiltersButton;
    showAllButton = false;
    disableButton = true;
    listofStickyFacet = [];
    sourceArr = [{
        "key": "all_Content",
        "values": "All Content"
    }];
    showArrowIcon = false;
    listofStickyFacet1 = [];
    seeAll = false;
    listofStickyFacetType = [];
    @track active;
    @track storeIndex = [];
    @track tabSelected;
    ffirstStickyLabel = [];
    @track currentKnowledgeArticleId = '';
    hoverResult = {};
    offsetWidth;
    anchorTagXposition;
    anchorTagOffsetHeight;
    topNew;
    @api caseIdExists;
    prevIndex = '';
    @api filterId;
    @api correctspell;
    @api index;
    @track responselistdata = [];
    @api
    set responseListData(value) {
        if (value) {
            this.responselistdata = JSON.parse(JSON.stringify(value));
        }
    };
    get responseListData() {
        return this.responselistdata;
    }
    @api loading = '';
    //selectedStickyFilterToShow = [];
    viewAllStickyButton = false;
    showMergedCSTabs = false;
    @api selectedStickyFilter;
    @api eventCode;
    @api summaryCollapsible;
    @api mergedresults;
    @api urlopensinnewtab;
    rangerId='';
    left;
    timerid ;
    top;
    oldRangerId;
    @api height;
    @track stickyFacets;
    @api resulthits;
    @api sortByCheck;
    @track DataLoaded = false;
    customHeight;
    currentDivHeight = 600;
    previousCurrentDivHeight;
    currentDivWidth;
    @api utilityWidth;
    @api utilityTop;
    @api translationObject;
    diamond;
    @track contentTab = [];
    @api containerxcoordinate;
    emailHref='';
    @api currentUserEmail;
    showSendAsEmailBlock = false;
    @api tabsfilter;
    get showAll_Button() {
        return this.listofStickyFacet.length > 1 ? true : false;
    }
    get showFilter_1() {
        return this.listofStickyFacet.length > 0 ? true : false;
    }
    get checkAttachedorNot() {
        return true;
    }

    get checkAttachedorNot1() {
        return false;
    }
    get showClearFiltersButton1() {
        return (this.selectedStickyFilter && this.selectedStickyFilter.length) || !this.totalresults ? true : false;
    }

    get showNoResults() {
        return ((this.loading && !this.loading.length) || !this.loading) && !this.totalresults ? true : false;
    }

    get showBackupResults() {
        return this.responselistdata && this.responselistdata.length ? true : false;
    }
    // Code Added for preview Start
    closeKnowledgeWidget(event){
        this.handleMouseout(event);
    }

    async articleMouseHover(event) {
        this.diamond = true;
        event.preventDefault();
        var eve = event.target;
        let currentId = event.target.dataset.id; // Setting the id in new var as we are not able to access them in Async calls
        this.rangerId = currentId;
        this.offsetWidth = event.currentTarget.offsetWidth;
        this.anchorTagXposition = event.offsetX;
        this.anchorTagOffsetHeight = event.target.offsetHeight;
        if(this.template.querySelector(`[data-id="${eve.dataset.id}"]`)) {
            var clientyy = this.template.querySelector(`[data-id="${eve.dataset.id}"]`).getBoundingClientRect().y;
            this.topNew = clientyy + (this.anchorTagOffsetHeight / 2);
        }
        this.left = event.clientX;
        this.top = clientyy;
        clearTimeout(this.timerid);
        const toolTipDiv = this.template.querySelector('div.ModelTooltip');
        toolTipDiv.style.opacity = 1;
        let checkOutRecordId = eve.dataset.recordid.toLowerCase();
        const firstTwoChars = checkOutRecordId.substring(0,2);
        if(firstTwoChars === 'ka'){
            if (eve.dataset.recordid.toLowerCase().indexOf('ka') != -1) { // Check article is of type knowledge or not   
                await doesKnowledgeExist({ knowledgeId: event.target.dataset.id }).then(result => {
                    // check if article exist
                    if (result) {
                        this.showArticlePreview = true; // Article exists
                        this.articleRecordExists = true;
                        let checkArticle = '';
                        if (eve.dataset && eve.dataset.recordid && eve.dataset.recordid.toLowerCase().indexOf('ka') != -1 && eve.dataset.recordid.toLowerCase().indexOf('@@@')) {
                            checkArticle = 'knowledgeRecord';
                        }
                        this.hoverResult = eve.name;
                        if (eve.name != undefined && checkArticle == 'knowledgeRecord' && this.showArticlePreview) {
                            if (this.rangerId === undefined || (eve.name != null && eve.name.Id !== undefined && eve.name.Id !== this.oldRangerId)) {
                                this.oldRangerId = this.rangerId;
                                this.rangerId = eve.name.Id;
                            }
                        }
                        toolTipDiv.style.display = "block";
                    }
                    else {
                        this.showArticlePreview = true; // Article not exists
                        this.articleRecordExists = false;
                        toolTipDiv.style.display = "block";
                    }
                })
                    .catch(error => {
                        console.log('Knowledge Id is not valid or knowledge not part of current org ', error);
                    });

                if (this.articleRecordExists) {
                    // Check for the Files from related List
                    createLinkOfAttachment({ recordId: currentId })
                        .then(result => {
                            if (result.length > 0) {
                                this.fileAttachment = result;
                            }
                            else {
                                this.fileAttachment = false;
                            }
                        })
                        .catch(error => {
                            console.log("error>>>>>>" + 'No Files exists' + JSON.stringify(error));
                        });

                    // Check for the Attachments FYI depreciated Now in salesforce
                    getAttachmentRelatedInfo({ recordId: currentId })
                        .then(result => {
                            this.attached_Attachments = JSON.parse(result);
                            this.attached_Attachments = this.attached_Attachments.AttachmentList;
                            this.attached_Attachments = this.attached_Attachments.map((value, index) => {
                                if (value.fieldLabel.endsWith('(Name)')) {
                                    let field_val = value.fieldLabel.substring(0, (value.fieldLabel).length - 6);
                                    return { ...value, 'fieldLabel': field_val };
                                }
                                else {
                                    return { ...value };
                                }
                            });
                        })
                        .catch(error => {
                            console.log("error in getAttachmentRelatedInfo>>>>>>" + error + JSON.stringify(error));
                        });
                }
            }
        }
        else {
            toolTipDiv.style.display = "none"; // Not an article therefore hide the preview
            this.showArticlePreview = false;
        }
    }

    currentDivHeightWidth(e) {
        this.currentDivHeight = e.detail.divHeight; // Preview box height
        this.currentDivWidth = e.detail.clientWidth; // Preview box width

        //Article Preview box position from top
        if (this.template.querySelector('div.slds-modal')) {
            let temp = (window.innerHeight - this.currentDivHeight) / 2;
            this.template.querySelector('div.slds-modal').style.setProperty('top', temp + 'px');
        }
        var left;
        //Article Preview box (calculation left and right position)
        if (this.template.querySelector('div.slds-modal')) {
            if((Math.round((this.left + this.currentDivWidth) / 5) * 5) < window.innerWidth) {
                if(window.innerWidth - ((this.left - this.anchorTagXposition) + this.offsetWidth) < this.currentDivWidth) {
                    this.template.querySelector('div.slds-modal').style.setProperty('left', 'auto');
                    this.template.querySelector('div.slds-modal').style.setProperty('right', + 10 + 'px');
                } else {
                    if(this.left < 400 && this.maincontainerwidth < 400) { 
                        left = this.maincontainerwidth;
                        this.template.querySelector('div.slds-modal').style.setProperty('right', + 'auto');
                    } else {
                        if(this.left - this.anchorTagXposition + this.offsetWidth + 15 + this.currentDivWidth < window.innerWidth) {
                            left = this.left - this.anchorTagXposition + this.offsetWidth + 15;
                        } else {
                            left = this.left - this.anchorTagXposition + this.offsetWidth + 15  - (this.left - this.anchorTagXposition + this.offsetWidth + 15 + this.currentDivWidth - (window.innerWidth - 15));
                        }
                        this.template.querySelector('div.slds-modal').style.setProperty('right', + 10 + 'px');
                    }
                    this.template.querySelector('div.slds-modal').style.setProperty('left', left + 'px');
                }
            } else {
                this.diamond = false;
                left = this.left - this.anchorTagXposition - 20 - this.currentDivWidth;
                if(0 < left) {
                    this.template.querySelector('div.slds-modal').style.setProperty('left', + left + 'px');
                    this.template.querySelector('div.slds-modal').style.setProperty('right', + 'auto');
                } else {
                    this.template.querySelector('div.slds-modal').style.setProperty('left', + 10 + 'px');
                }
            }
        }
        if(this.utilityWidth && window.location.href.indexOf('popout') == -1) {
            this.template.querySelector('div.slds-modal').style.setProperty('top', 'auto');
            this.template.querySelector('div.slds-modal').style.setProperty('bottom', 0 + 'px');
            this.template.querySelector('div.slds-modal').style.setProperty('left', this.utilityWidth + 'px')
        }
        fireEvent(null, 'sendDataToArticleParentPreview' + this.eventCode, {
            diamond: this.diamond, 
            anchorTagOffsetHeight: this.anchorTagOffsetHeight
        });
    }
    
    /* onmouseenter*/
    handleMouseover(event) {
        event.preventDefault();
        clearTimeout(this.timerid);
        if (this.rangerId === undefined || (event.target.name != null && event.target.name.Id !== undefined && event.target.name.Id !== this.oldRangerId)) {
            this.oldRangerId = this.rangerId;
            this.rangerId = event.target.name.Id;
        }
        const toolTipDiv = this.template.querySelector('div.ModelTooltip');
        if(toolTipDiv) {
            toolTipDiv.style.opacity = 1;
            toolTipDiv.style.display = "block";
            document.body.style.overflow = 'hidden';
        }
    }

    /* onmouseleave*/
    linkMouseOut(event) {
        event.preventDefault();
        this.timerid = setTimeout(() => {
            const toolTipDiv = this.template.querySelector('div.ModelTooltip');
            toolTipDiv.style.opacity = 0;
            toolTipDiv.style.display = "none";
            this.showArticlePreview = false;
        }, 150);  // setTimeout is added on link to sustain popup for a second
    }
    handleMouseout(event) {
        event.preventDefault();
        clearTimeout(this.timerid);
        const toolTipDiv = this.template.querySelector('div.ModelTooltip');
        toolTipDiv.style.opacity = 0;
        toolTipDiv.style.display = "none";
        this.showArticlePreview = false;
        document.body.style.overflow = 'auto';
    }
    // Code Added for preview End
    clearFilterForSlider1(event) {
        fireEvent(null, 'clearAllFilters' + this.eventCode, null);
        fireEvent(null, 'tabClicked' + this.eventCode, event);
    }
    tabClicked(event){
        fireEvent(null, 'tabClicked' + this.eventCode, event);
    }
    
    connectedCallback() {
        registerListener("checkType"+this.eventCode, this.checkDataFromSearchSection, this);
        registerListener("showclearfilterbtn"+this.eventCode, this.searchBtn, this);
        registerListener("advsearchstickyfltr"+this.eventCode, this.stickyFilterData, this);
        registerListener("removeAllPreviousFacets"+this.eventCode, this.removeAllFacets, this);
        registerListener("sendvalueoffacet"+this.eventCode, this.getFacetAdvSearchData, this);
        registerListener("showFilterData"+this.eventCode, this.showFilterDataMethod, this);
        registerListener("sendstickytodatasection"+this.eventCode, this.sendStickyFromAdvSearch, this);
        registerListener("showclearfilter"+this.eventCode, this.showClearFilterValue, this);
        registerListener("sendtodatasection"+this.eventCode, this.dataFromFilterSection, this);
         registerListener("clearFilterDataEvent"+this.eventCode, this.handleClearFilterDataEvent, this);
        registerListener("closeSendEmailBlock"+this.eventCode, this.closeSendEmailBlock, this);
        registerListener('bigscreen'+this.eventCode,this.bigScreenSet,this);
        

        this.customHeight = 'height: calc(100% - 100px)!important;'
    }

    closeSendEmailBlock(){
        this.showSendAsEmailBlock = false;
    }
    bigScreenSet(bigscreenevent){
        this.showIcon = false
        if(bigscreenevent === false){
            this.dataSectionClasses = 'su__d-block'
            if(this.selectedStickyFilter && this.selectedStickyFilter.length ){
                this.stickyFacets = true;
            }else{
                this.stickyFacets = false;
    
             }
            
        }
        else if (bigscreenevent === true){
            this.showIcon = true;
            this.dataSectionClasses = 'su__d-none'
            if(this.selectedStickyFilter && this.selectedStickyFilter.length ){
                this.stickyFacets = true;
            }else{
                this.stickyFacets = false;
             }
        }
        
    }
    //clear filter
    handleClearFilterDataEvent(event) {
        this.listofStickyFacet = [];
        this.listofStickyFacet1 = [];
        var selectedTab = 'all_Content';
        this.sourceArr.splice(0, 1, {
            "key": "all_Content",
            "values": "All Content"
        });

        if (this.previousIndexVal != '' && this.template.querySelector(`[data-name=' ${this.previousIndexVal}']`)) {
            this.template.querySelector(`[data-name=' ${this.previousIndexVal}']`).classList.remove("active-type");
            this.previousIndexVal = selectedTab;
        }
        if (this.template.querySelector(`[data-name='${selectedTab}']`))
            this.template.querySelector(`[data-name='${selectedTab}']`).classList.add("active-type")
        fireEvent(this.pageRef, 'clearStickyFilter' + this.eventCode, null);
    }

    dataFromFilterSection(data) {
        this.listofStickyFacet = [];
        this.listofStickyFacet1 = [];
        this.listofStickyFacet = data.arr_StickyData;
        this.listofStickyFacetType = data.arr_StickyData1;
        this.listofStickyFacet1 = data.arr_StickyData;

    }

    showClearFilterValue(data) {
        this.showFilter1 = true;
    }

    sendStickyFromAdvSearch(data) {
        for (let i = 0; i < data.length; i++) {
            for (let j = 0; j < this.listofStickyFacet.length; j++) {
                if (this.listofStickyFacet[j].label == data[i].label) {
                    this.listofStickyFacet[j].values = data[i].values;
                    break;
                }
            }
            var check = false;
            for (let k = 0; k < this.listofStickyFacet.length; k++) {
                if (this.listofStickyFacet[k].label == data[i].label) {
                    check = true;
                    break;
                }
            }
            if (!check) {
                this.listofStickyFacet.push(data[i]);
            }
        }

        this.listofStickyFacet1 = [];
        this.listofStickyFacet1.push(this.listofStickyFacet[0]);


    }
    showFilterDataMethod(data) {
        this.showFilter1 = data.showFilter,
        this.showFilter1 = true;
        this.selectedStickyFilter1 = data.selectedStickyFilter
        this.requiredStickyFacet = (this.selectedStickyFilter1);
        this.filterValueOne.push(data[0]);
    }
    stickyFilterData(data) {
        this.ffirstStickyLabel = [];
        this.firstStickyLabel = data;
        this.ffirstStickyLabel.push(data[0]);
        if (this.firstStickyLabel.length > 0) {
            this.firstStickyLabel1 = true;
        }
        if (data.length > 1) {
            this.viewAll = true;
        }
        this.showAllFilters = data;

    }
    searchBtn(d) {
        this.showClearFiltersButton = d;
    }
    changeLabelCalled(data) {
        this.resultlabel = data;
    }
    checkDataFromSearchSection(event) {
        this.eventSortType = event;
    }

    @api par(str) {
        this.result = JSON.stringify(str);
    };

    get gridElement() {
        if (this.gridDisplay == true) {
            return "width:49%"
        }
        else {
            return "width:100%"
        }
    }
    get test() {
        if (this.active == this.tabSelected)
            return true;
        return false;
    }

    renderedCallback() {
        this.DataLoaded = true;
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
        if(this.selectedStickyFilter && this.selectedStickyFilter.length ){
            this.stickyFacets = true;
            
        }else{
            this.stickyFacets = false;


        }

    }

    openPreviewModal(event){
        this.runScriptMethod(event);
        //   = event.currentTarget.dataset.value; 
        this.typeofContentForPreview = event.currentTarget.dataset.title || event.currentTarget.dataset.value; 
        this.previewSrcVal  = this.modifyUrlForPreview(event.currentTarget.dataset.value); 
         this.previewModalVal = true;
         this.responselistdata.forEach((value) => {
            if(value.record.hits){
                value.record.hits.forEach((data)=>{
                    if (data.record && data.record.showPreview &&  event.currentTarget.dataset.value === data.record.href) {
                    this.previewSourceLabel = data.record.sourceLabel;
                    data.record.showPreviewModal = true;
                    // value.record.showMRClass = 'version-field';
                }else{
                    data.record.showPreviewModal = false;
                }
                })
            }else{
                if (value.record && value.record.showPreview &&  event.currentTarget.dataset.value === value.record.href) {
                    this.previewSourceLabel = value.record.sourceLabel;
                    value.record.showPreviewModal = true;
                    // value.record.showMRClass = 'version-field';
                }else{
                    value.record.showPreviewModal = false;
                }
            }     
        })
    }

    closePreviewModal(){
        this.previewModalVal = false;
        this.previewSrcVal = '';
        this.typeofContentForPreview = '';
        this.closePreviewHandler();
    }

    closePreviewHandler(){
        this.responselistdata.forEach((value) => {
            if(value.record.hits){
                value.record.hits.forEach((data)=>{
                    if (data.record && data.record.showPreview) {
                    data.record.showPreviewModal = false;
                }
                })
            }else{
                if (value.record && value.record.showPreview ){
                    value.record.showPreviewModal = false;
                }
            }
        });
    }

    handlePreviewModalBackdrop(){
        this.previewModalVal = false;
        this.previewSrcVal = '';
        this.typeofContentForPreview = '';
        this.closePreviewHandler();
    }

     modifyUrlForPreview(url){
        if (url.toLowerCase().includes('youtube.com')) {
            return url.replace('watch?v=', 'embed/')
        }
        else if (url.toLowerCase().includes('vimeo.com')) {
            return 'https://player.vimeo.com/video/' + url.split('.com/')[1];
        }
        else { return url }
    }

    // This method is used to toggle show and hide of filter data
    handleInsideFilters(event) {
        this.index = event.currentTarget.dataset.rank;
        if (this.prevIndex != this.index) {
            this.responselistdata.forEach((value) => {
                if (value.record && value.record.showMR) {
                    value.record.showMR = false;
                    value.record.showMRClass = 'version-field';
                }
            })
            this.prevIndex = this.index;
        }
        this.responselistdata[this.index].record.showMR = !this.responselistdata[this.index].record.showMR;
        if(this.responselistdata[this.index].record.showMRClass != 'version-field su__active-Filter-color') {
            this.responselistdata[this.index].record.showMRClass = 'version-field su__active-Filter-color';
        } else {
            this.responselistdata[this.index].record.showMRClass = 'version-field';
        }
    }

    mergeResultOutsideClick() {
        this.responselistdata.forEach((value) => {
            if (value.record && value.record.showMR) {
                value.record.showMR = false;
                value.record.showMRClass = 'version-field';
            }
        })
    }

    attachToCaseCmt(e) {
        var attached = e.currentTarget.dataset.attached;
        var knowledgeId = e.currentTarget.dataset.knowledgeid;
        var sendData = {
            Id: e.currentTarget.dataset.Id,
            _id: knowledgeId,
            objName: e.currentTarget.dataset.objname,
            sourceName: e.currentTarget.dataset.sourcename,
            url: e.currentTarget.dataset.url,
            title: e.currentTarget.dataset.title,
            attached: attached == 0 ? true : false,
            index: e.currentTarget.dataset.index,
            childindex :e.currentTarget.dataset.childindex
        };
        knowledgeId = knowledgeId.slice(0, 18);

        assignArticleToCase({ contextIdentifier: attached == 0 ? 'attach' : 'deattach', caseIdVal: this.recordId, knowlegeId: knowledgeId })
            .then((data, error) => {
                if (data) {
                    this.error = undefined;
                    if (attached == 0) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Attach To Case',
                                message: 'Attached To Case Successfully',
                                variant: 'success',
                                mode: 'dismissable'
                            }),
                        );
                    } else {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Detach To Case',
                                message: 'Detached To Case Successfully',
                                variant: 'success',
                                mode: 'dismissable'
                            }),
                        );
                    }
                } else if (error) {
                    this.error = error;
                    console.log('Error:' + JSON.stringify(error));
                    this.dispatchEvent(
                        new ShowToastEvent({
                            message: 'Something went wrong:' + error,
                            variant: 'error'
                        }));
                }
            });
        fireEvent(null, "attachToCaseEvent" + this.eventCode, sendData);
    }

    handleCaseComments(event) {
        var id = event.currentTarget.dataset.knowledgeid;
        var shouldDettach = event.currentTarget.dataset.showdettached;
        if ((shouldDettach == 'false' || shouldDettach == '0') && parseInt(event.currentTarget.dataset.merge) && parseInt(event.currentTarget.dataset.shouldattach))
            this.attachToCaseCmt(event);
        var sendData = {
            id: id,
            url: event.currentTarget.dataset.url,
            title: event.currentTarget.dataset.title,
            objName: event.currentTarget.dataset.objname,
            sourceName: event.currentTarget.dataset.sourcename,
         };
        fireEvent(null, "sendLinkEvent" + this.eventCode, sendData);
        this[NavigationMixin.Navigate]({
            type: "standard__component",
            attributes: {
                componentName: "c__SUNavigateToCaseComment"
            },
            state: {
                c__caseId: this.recordId,
                c__caseComment: event.currentTarget.dataset.url
            }
        });
    }

    copyLink(event) {
        var result = this.template.querySelector('.getHref');
        var ptitle = event.currentTarget.dataset.sub;
        var plink = event.currentTarget.dataset.url;
        var idd = event.currentTarget.dataset.recordid;
        var copyId = plink;

        let tag = document.createElement('textarea');
        tag.setAttribute('id', 'input_test_id');
        tag.value = copyId;
        tag.href = plink;
        document.getElementsByTagName('body')[0].appendChild(tag);
        document.getElementById('input_test_id').select();
        document.execCommand('copy');
        document.getElementById('input_test_id').remove();

        var linkId = this.template.querySelector('[data-id="toastId"]');
        this.template.querySelector('[data-id="toastId"]').classList.remove('showFormBlock');
        setTimeout(function () { linkId.classList.add('showFormBlock'); }, 1000);
        var sendData = {
            "id": idd,
            "plink": plink,
            "ptitle": ptitle,
            objName: event.currentTarget.dataset.type,
            sourceName: event.currentTarget.dataset.index
        };
        fireEvent(null, "copyLinkEvent" + this.eventCode, sendData);
    }

    handleCaseCommentsEmail(event) {
        var shouldDettach = event.currentTarget.dataset.showdettached;
        if ((shouldDettach == 'false' || shouldDettach == '0') && parseInt(event.currentTarget.dataset.merge) && parseInt(event.currentTarget.dataset.shouldattach)){
            this.attachToCaseCmt(event);
            
        }      
        this.emailHref = event.currentTarget.dataset.url;
        this.ptitle = event.currentTarget.dataset.title;
        this.objName = event.currentTarget.dataset.objname;
        this.idd = event.currentTarget.dataset.id;
        this.showSendAsEmailBlock = true;
        this.sourcename = event.currentTarget.dataset.sourcename;
    }
    handleViewAll() {
        this.showFilterPopup = true;
        this.stickyPopUp = 'stickyPopUp2'
    }
    closeFilterSection() {
        this.stickyPopUp = 'stickyPopUp1';
    }
    removeAllFacets(d) {
        this.firstStickyLabel1 = false;
    }
    getFacetAdvSearchData(data) {

    }
    removeFromSearch(e) {
        var newArr = [];
        for (let i = 0; i < this.advFilterDatavalues.length; i++) {
            if (this.advFilterDatavalues[i].label == e.target.dataset.name) {
                continue;
            }
            newArr.push(this.advFilterDatavalues[i]);
        }
        if (newArr.length != 0) {
        }
        else {
            this.firstStickyLabel1 = false;
            this.showClearFiltersButton = false;
            this.show = false;
            this.showFilter1 = false;
            this.advFilterDatavalues = [];
        }
        if (newArr.length == 0) {
            this.showfirstFacet = false;
        }
        fireEvent(null, 'removeadvsearchfilter' + this.eventCode, newArr)
    }
	correctSpelling() {
        fireEvent(this.pageRef, 'searchPage' + this.eventCode, { searchString: this.correctspell, isFreshSearch: -1 });
    };
    getAllStickyFacets() {
        fireEvent(null, 'viewAllStickyButton' + this.eventCode, { show: this.viewAllStickyButton });
        let message = "header";
        fireEvent(null, 'headerSUData' + this.eventCode, message);
    }
    runScriptMethod(e) {
        fireEvent(null, 'trackAnalytics' + this.eventCode, {
            type: 'conversion', objToSend: {
            index: e.currentTarget.dataset.index,
            type: e.currentTarget.dataset.type,
            id: e.currentTarget.dataset.recordid,
            rank: parseInt(e.currentTarget.dataset.rank) + 1,
            convUrl: e.currentTarget.dataset.url,
            convSub: e.currentTarget.dataset.sub || e.currentTarget.dataset.url,
            autoTuned: e.currentTarget.dataset.autotuned ? e.currentTarget.dataset.autotuned : false,
            }
        });
        var href = e.currentTarget.dataset.url;
        var id = e.currentTarget.dataset.recordid.split('__')[0];
        var object = e.currentTarget.dataset.type;
        var allowLinkOpenNewTab = e.currentTarget.dataset.allowlinkopennewtab;
        if (this.urlopensinnewtab) return;
        else if (object == 'case' || object.toLowerCase().slice(-5) == '__kav') {
            this.invokeWorkspaceAPI('isConsoleNavigation').then(isConsole => {
                if (isConsole) {
                    this.invokeWorkspaceAPI('getFocusedTabInfo').then(focusedTab => {
                        this.invokeWorkspaceAPI('openSubtab', {
                            parentTabId: focusedTab.isSubtab ? focusedTab.parentTabId : focusedTab.tabId,
                            recordId: id,
                            focus: true
                        }).then(tabId => { })
                        .catch(error => {
                            this.invokeWorkspaceAPI('openTab', {
                                recordId: id,
                                focus: true
                            }).then(tabId => { });
                        });
                    });
                }
            });
        } else if(!allowLinkOpenNewTab) {
            window.open(href, "_blank"); // to give href or result as it is here
        } 
    }
    collapseSummary(event){
        let collapse = event.target.dataset.collapse;
        let index = event.target.dataset.index;
       
        this.responselistdata[index].showLess = parseInt(collapse) ? false : true;
        if( this.responselistdata[index].showLess){
            this.responselistdata[index].record.showMore = false;
        }
        this.responselistdata[index].record.showMore = parseInt(collapse) ? true : false;
        if( this.responselistdata[index].record.showMore){
            this.responselistdata[index].showLess = false;
        }
    }

    invokeWorkspaceAPI(methodName, methodArgs) {
        return new Promise((resolve, reject) => {
            const apiEvent = new CustomEvent("internalapievent", {
            bubbles: true,
            composed: true,
            cancelable: false,
            detail: {
                category: "workspaceAPI",
                methodName: methodName,
                methodArgs: methodArgs,
                callback: (err, response) => {
                if (err) {
                    return reject(err);
                } else {
                    return resolve(response);
                }
                }
            }
            });

            window.dispatchEvent(apiEvent);
        });
    }

    handleMouseLeaveMetaData(event) {
        if(this.template.querySelector(`[data-id='${event.target.dataset.id}']`)) {
            this.template.querySelector(`[data-id='${event.target.dataset.id}']`).classList.remove('su__metaData-block');
        }
    }

    handleMouseEnterMetaData(event) {
        if(this.template.querySelector(`[data-id='${event.target.dataset.id}']`)) {
            this.template.querySelector(`[data-id='${event.target.dataset.id}']`).classList.add('su__metaData-block');
        }
    }
}