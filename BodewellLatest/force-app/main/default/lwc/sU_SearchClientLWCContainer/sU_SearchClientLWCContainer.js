import { LightningElement, api, wire, track } from 'lwc';
import getConsoleCustomSettings from '@salesforce/apex/su_vf_console.SUVFConsoleController.getConsoleCustomSettings';
import getCurrentCaseSubject from '@salesforce/apex/su_vf_console.SUVFConsoleController.getCurrentCaseSubject';
import sendEmail from '@salesforce/apex/su_vf_console.SUVFConsoleController.sendEmail';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import caseNumber from '@salesforce/schema/Case.CaseNumber';
import caseSubject from '@salesforce/schema/Case.Subject';
import { CurrentPageReference } from 'lightning/navigation';
import checkArticle from '@salesforce/apex/su_vf_console.SUVFConsoleController.checkArticle';
import UserId from '@salesforce/user/Id';
import { registerListener, fireEvent } from 'c/supubsub';
//import { gza } from 'https://ge151910p.searchunify.com/resources/Allow/an.js?uid=153838d4-2b3e-11ed-85ac-0242ac120002';
const DELAY = 300;
const NUM_OF_TABS = 3;
export default class SU_SearchClientLWCContainer extends NavigationMixin(LightningElement) {
    isUtility=false;
    keyElement;
    advSearchFilter = [];
    //pic = pinIcon;
    @api height = 600;
    @api recordIddFromUtility;
    previous='';
    previousRecordId=''
    @api caseSubject_inUtilityBar;
    previousCaseSUbject='';
    @track showModal = false;
    @track JWTToken;
    @track sourceFacet = true;
    @track currentLanguageSelected = 'English - en'
    @track defaultLang = 'en';
    @track currentCaseSubject;
    @track currentUserId = UserId;
    // globeImg = globeIcon
    @track activePageNumber;
    @api endPointPagination;
    @api isCaseSubject = '';
    @api mapOfFilters = new Map();
    @track tabsFilter;
    @track childTab;
    @track changeIcon = true;
    @track iconName = "utility:chevrondown";
    //verticalImg = moreVerticalIcon
    @track currentCaseNumber;
    @track dropdownIcon = "utility:close"
    @api recordId;
    @track resultTime;
    @track box;
    @api pageSize = 10;
    @api searchString;
    @api searchPageOnFailure;
    @api noResultsMsg;
    @api collapseSearchFilters;
    @api showContentSourceTab;
    @api displayListView;
    @api collapsSummary;
    @api caseSubjectVal;
    @track pageNum = 1;
    @track contentSourceTab = true;
    @track multiVersion = false;
    @track query;
    // @track endPoint = 'https://feature8.searchunify.com/';
    @track endPoint = 'https://ge151910p.searchunify.com';
    @track bearer = '';
    // @track uid = '9e189fc3-0cee-11ed-b702-0242ac120002'// '6fddeb3f-075d-11ed-b702-0242ac120002'; // '9e189fc3-0cee-11ed-b702-0242ac120002';
    @track uid = '153838d4-2b3e-11ed-85ac-0242ac120002';
    @track linkSharingOptions = [{"search_client_id":25,"result_action_id":1,"status":1,"merge":0,"selected_object":"knowledge__kav","content_source_label":"Community"},{"search_client_id":25,"result_action_id":2,"status":1,"merge":0,"selected_object":"knowledge__kav","content_source_label":"Community"},{"search_client_id":25,"result_action_id":3,"status":0,"merge":0,"selected_object":"knowledge__kav","content_source_label":"Community"}];
    suResultsLoader = false;
    suResultsLoaderImg = this.endPoint + '/resources/Assets/su-results-loader.gif';
    @track SID; //@@@@@@@@
    @track currentCommunityURL;
    @track customSettingErrorMessage;
    @track commBaseURL;
    @track customSettingsFilled;
    @track selectedTypeFilter;
    @track toggleDisplayKeys = [];
    @track filterToRight;
    @track active;
    @track defaultTab;
    @track filterValue;
    @track hiddenKeys;
    @track caller;
    @track setFlag;
    @track sortByCheck = '_score';//@@@@@
    @track exactPhrase = ''; //@@@@@
    @track withOneOrMore = '';//@@@@@@
    @track withoutTheWords = '';//@@@@@
    @track refresh;
    @track defaultPageSize = 10;
    @api counter = 1;
    @track tabSelected;
    @track pageSizeAdvFiltr = 10;
    @track advanceSearchEnabled;
    @track filterSortingLoading;
    @track loadingResult;
    @track filterOrder;
    @track originalAggregationsData;
    @api aggregationsData;
    @track currentClickedOrder;
    @track bookmark_list = false;
    @track viewSavePopup;
    @track viewConfirmPopup;
    @track preview;
    @track contentTag;
    @track correctspell;
    @track showSummary;
    @track mergedArray;
    @track componentLoaded = false;
    @track finalLang;
    @track close;
    @track add_bookmark;
    @api bookmarkSearches;
    @track disableButton;
    @track save_bookmark;
    @track bookmarkName;
    @track responseListData = [];
    responseListDataBackup = [];
    @track listview;
    @track hideIcon;
    @track showLanguageDropdown = false;
    @track showViewedResults = false;
    @track translationObj = {};
    @track languageSelectedByUser;
    @track directionText;
    @track selectedLanguages;
    @track previewSource;
    @track previewTitle;
    @track previewLabel;
    @track isModalOpen = false;
    @track noBookmarkSaved = false;
    @track name;
    @track getRecommendations;
    @track showClearFiltersButton = false;
    @track selectedStickyFilter = [];
    @track totalPages;
    @track allContentHideFacet = false;
    summaryCollapsible = false;
    maxLength = 100;
    @track languageEnabled = 0;
    @track caseSelection;
    @track showCaseNumber;
    @track urlOpensInNewTab;
    @api setArray;
    searchResultTime;
    lastPage;
    @api paginationList;
    fromPage;
    toPage;
    showPageSize = false;
    @track showPageClass;
    result = {};
    @track filterContentName;
    @track activeTabIndex;
    @track active = 'all_content';
    activeTab = 'all_Content';
    @track accessKeyValue;
    @track tabIndex = false;
    @track viewAll = false;
    @track showFilter = false;
    @api firstStickyLabel = [];
    value = 'SortByRelevance';
    @api index;
    valueChildTab = '';
    active = 'all_Content'
    content;
    @api activeFilter;
    @api aggData;
    pagingAggregation;
    @track key;
    @track searchFilterString;
    @track facetSearchClose;
    @track suggestionLength = false
    @track bookmark_clicked = false;
    @track bookmark_queryPassed;
    @track isBookmarkExist = false;
    @track showBookMark = false;
    @api searchBarWithBookmark = "max-width:67%";
    @api searchBarWithoutBookmark = "max-width:74%";
    @api globeSize = "max-width=8%";
    @api gridDisplay = false;
    @api langToast;
    @track showButtonsDiv = false;
    @track yellowBack;
    @api noResultMsg;
    // Code added by fresher
    @track childTabsNumber;
    showPreviewIcon = false;
    copySplicedData=[];
    videoId;
    isModalOpen1 = false;
    completeUrl;
    keywordForSources = /_type/;
    keywordForPublicationStatus = /server_tdsf1___knowledge__kav___PublishStatus/;
    keywordForArticleNumber = /server_tdsf1___knowledge__kav___ArticleNumber/;
    keywordForId = /id/;
    keywordForTag = /tag/;
    sArr;
    eitherOfTheHeadersIsSelected;
    eitherOfThreeIsTrue;
    @track globSearch;
    @track searchTrack;
    @track removeSelected = '';
    @track countTab;
    @track testVar = 1;
    @track rcountTab = this.countTab;
    @api showArticle;
    currentUserEmail;
    loading;
    checkHere = false;
    advancedSearchSelected = false;
    buttonValue = true;
    onFilterButtonClick = true;
    eventCode;
    isFreshSearch = -1;
    resultCountReturned;
    hideDataSection = false;
    @api caseUtilitySub;
    previouscaseUtilitySub='';
    @api 
    executeFromAura() {
        this.searchString=data;
        console.log('execute from aura'+this.searchString);
        fireEvent(null,'changeBannerString',this.searchString);
        this.caseSubjectVal=data;
        getData(null,'search');
    }
    get componentStyle() {
        return `height:${this.height}px;`;
    } 
    get activeCaseNumber() {
        return this.currentCaseNumber && this.showCaseNumber ? true : false;
    }
    renderedCallback(){
        if(this.previouscaseUtilitySub!=this.caseUtilitySub) {
            this.searchString=this.caseUtilitySub;
            this.previouscaseUtilitySub=this.searchString;
        }
         if(this.caseSelection && this.previous !=this.caseSubject_inUtilityBar && this.recordIddFromUtility) { //isUtility   && this.recordId==undefined{
            this.previous=this.caseSubject_inUtilityBar;
            this.searchString=this.caseSubject_inUtilityBar;
            this.recordId=this.recordIddFromUtility;
            this.handleSearchPageEvent({searchString:this.searchString,isFreshSearch: -1});//{ searchString: this.searchString2, isFreshSearch: -1}
           
       }
        
       if(this.previousRecordId!=this.recordId) {    
            getCurrentCaseSubject({idd:this.recordId})
            .then(result => {
                this.searchString = result;
                console.log('current searchString---'+this.searchString);
            })
            .catch(error => {
                this.error = error;
            });
           this.previousRecordId=this.recordId;
       }
    }
    tabClicked(e) {

    }
    
    openModal1(event) {
        this.isModalOpen1 = true;
        var videoUrl = event.target.value;
        this.videoId = videoUrl.split("=")[1];
        this.completeUrl = 'https://img.youtube.com/vi/' + this.videoId + '/0.jpg';
    }

    closeModal1() {
        this.isModalOpen1 = false;
    }
    // Code added by fresher (ending here)
    get firrstFilterLength() {
        if (this.firstStickyLabel.length > 0) {
            return true;
        }
        else {
            return false
        }
    }
    get gridElement() {
        if (this.gridDisplay == true) {
            return "width:49%"
        }
        else {
            return "width:100%"
        }
    }
    get langToastClass() {
        if (this.showBookMark == true) {
            return "hideLang"
        }
        else {
            return "hideLang2"
        }
    }
    get searchRowSize() {
        if (this.showBookMark == true) {
            return this.searchBarWithBookmark;
        }
        else {
            return this.searchBarWithoutBookmark;
        }
    }

    handleActive(event) {
        this.active = event.target.value;
        if (this.active == 'all_Content') {
            this.selectedTypeFilter = "";
            if (this.customSettingsFilled && this.bearer)
                this.getData(null, 'pageChange');
            this.goToTopFunc();
        }
        else {
            var filterValue = '[{"type":"_index","filter":["' + this.active + '"]}]';
            this.selectedTypeFilter = filterValue;
            this.pageNum = 1;
            this.counter = 1;
            this.setPagination(this.pageSize, this.pageNum)
            if (this.customSettingsFilled && this.bearer)
                this.getData(null, 'pageChange');
            this.goToTopFunc();
        }
    }

    // handlechange() {
    //     this.active = 'all_Content';
    // }

    get shouldDisplay() {
        return this.index = 0;
    }

    get options() {
        return [
            { label: 'Sort By Relevance', value: '_score' },
            { label: 'Sort By Created Date', value: 'post_time' },

        ];
    }
    @wire(getRecord, { recordId: '$recordId', fields: [caseNumber, caseSubject] })
    wiredRecord({ data, error }) {
        if (data) {
            const { fields } = data;
            Object.keys(fields).forEach(item => {
                let value = fields[item] && fields[item].displayValue ? fields[item].displayValue : fields[item].value;
                this.result = { ...this.result, [item]: value }
            })
            this.searchString = this.result.Subject;
            this.currentCaseNumber = this.result.CaseNumber;
            this.currentCaseSubject = this.result.Subject;
            this.caseSubjectVal = this.result.Subject;
        }
        if (error) {
        }
    }

    @wire(CurrentPageReference) pageRef;
    constructor() {
        super();
        Promise.all([
            loadScript(this, this.endPoint+"/resources/Allow/an.js?uid="+this.uid),
            loadStyle(this, this.endPoint + '/resources/search_clients_custom/' + this.uid + '/main.css')
        ]).then(() => {
            sendEmail({userId:this.currentUserId}).then(result => {
                this.currentUserEmail = result;
                console.log('User Email: '+this.currentUserEmail);
                window.GzAnalytics.setUser(this.currentUserEmail);
                this.getCommunityCustomSettings();
            }).catch(error => {
                this.error = error;
                console.log(error);
            });
            console.log('Files loaded.');
        }).catch(error => {
            if (error) {
                console.log('body error');
                console.log(error);
            }
        });
    }
    connectedCallback() {
        this.eventCode = Math.floor(Math.random() * (10000 - 1 + 1)) +1;
        if(this.caseSubject_inUtilityBar) {
            this.searchString=this.caseSubject_inUtilityBar;
        }
        //TestLanguage
        var translation = {
            config: {
                "defaultLanguage": {
                    "code": "en",
                    "name": "English",
                    "label":"English"
                },
                "selectedLanguages": [
                    {
                        "code": "en",
                        "name": "English",
                        "label":"English"
                    }
                ]
            },
        };

        this.translationObj = translation;
        this.defaultLang = this.translationObj.config.defaultLanguage.code;
        this.currentLanguageSelected = this.translationObj.config.selectedLanguages;
        this.bookmarkSearches = JSON.parse(localStorage.getItem('bookmark_searches_' + this.uid) || "[]");
        if (this.bookmarkSearches.length > 0) {
            this.isBookmarkExist = true;
            this.showBookMark = true;
        }
        else {
            this.isBookmarkExist = false
            this.showBookMark = false;
        }
        this.translationFunc();
        registerListener('checkType'+this.eventCode, this.checkTypeFromSUSortBy, this);
        registerListener('searchPage'+this.eventCode, this.handleSearchPageEvent, this);
        registerListener('getSearchResults'+this.eventCode, this.getData, this);
        registerListener('SID'+this.eventCode, this.sidValue, this);
        registerListener('PageClicked'+this.eventCode, this.handleFooterchat, this);
        registerListener('advancePagination'+this.eventCode, this.handleAdvanceSearch, this);
        registerListener('nextpageclicked'+this.eventCode, this.nextPageClicked, this);
        registerListener('selectchange'+this.eventCode, this.selectChangeMethod, this);
        registerListener('previousbuttoncalled'+this.eventCode, this.previousMethodCalled, this);
        registerListener('processme'+this.eventCode, this.processMeCalled, this);
        registerListener('previousPagesDots'+this.eventCode, this.previousPagesDotsMethod, this);
        registerListener('nextPageDots'+this.eventCode, this.nextDotClicked, this);
        registerListener('languageselected'+this.eventCode, this.langSelecetedMethod, this);
        registerListener('sendLinkEvent'+this.eventCode, this.handleSendLinkEvent, this);
        registerListener('copyLinkEvent'+this.eventCode, this.handleCopyLinkEvent, this);
        registerListener('attachToCaseEvent'+this.eventCode, this.handleAttachToCaseEvent, this);
        registerListener('filterSectionEvent'+this.eventCode, this.handleFilterSectionEvent, this);
        registerListener('tabclicked'+this.eventCode, this.tabClickedMethod, this);
        registerListener('caseCommentEmailEvent'+this.eventCode, this.handleCaseCommentEmailEvent, this);
        registerListener('savetolocal'+this.eventCode, this.saveToLocalMethod, this);
        registerListener('bookmarklistrequired'+this.eventCode, this.sendBookmarkList, this);
        // registering checkboxSelection event from suFilterSection 
        registerListener('checkboxSelectedEvent'+this.eventCode, this.checkboxSelectedEvent, this);
        registerListener('removefromlocalstorage'+this.eventCode, this.removefromlocal, this);
        registerListener('getlanglist'+this.eventCode, this.sendList, this);
        registerListener('advfilterclicked'+this.eventCode, this.showClearFilterMethod, this);
        registerListener('filterChangesEvent'+this.eventCode, this.handleFilterChangesEvent, this);
        // registerListener('dataFromContainer'+this.eventCode, this.handleDataFromSuParent, this);
        registerListener('savedbookmarkclicked'+this.eventCode, this.savedBmarkClicked, this);
        registerListener('clearFilterEvent'+this.eventCode, this.handleClearFilterEvent, this);
        registerListener('clearFilterSecEvent'+this.eventCode, this.handleClearFilterSecEvent, this);
        //registering data from headerSu section
        registerListener('headerSUData'+this.eventCode, this.handleDataFromSU, this);
        registerListener('removeStickyFacetEvent'+this.eventCode, this.handleRemoveStickyFacetEvent, this);
        registerListener('trackAnalytics'+this.eventCode, this.handleTrackAnalytics, this);
        registerListener('clearAllFilters'+this.eventCode, this.clearAllFilters, this);
        registerListener('clearSearch'+this.eventCode, this.handleClearSearch, this);
        registerListener('collapseSummary'+this.eventCode, this.handleCollapseSummary, this);
        registerListener('stringChangedFromBanner'+this.eventCode, this.stringChangedFromBanner, this);
        registerListener('filterClosed'+this.eventCode,this.filterClosed,this);
    }

    filterClosed(event) {
        this.hideDataSection = false;
    }

    handleTrackAnalytics(event){
        console.log("============arguments==========",event);
        if (event.type == 'search') {
            if (!event.objToSend) {event.objToSend = {'searchString': this.searchString}}
            event.objToSend = {
                ...event.objToSend,
                responseTime: this.searchResultTime,
                isFreshSearch: this.isFreshSearch == -1 ? true : false,
                result_count: this.resultCountReturned,
                filter: this.query.aggregations,
                default_search: this.default_search,
                exactPhrase: this.exactPhrase,
                withOneOrMore: this.withOneOrMore,
                withoutTheWords: this.withoutTheWords,
                page_no: this.pageNum
            }
            this.isFreshSearch = false;
        }
        if (event.type == 'conversion') {
            event.objToSend.pageSize = this.pageSize;
            event.objToSend.page_no = this.pageNum;
        }
        window.gza(event.type, event.objToSend);
    }

    clearAllFilters(event){
        this.exactPhrase = '';
        this.withOneOrMore = '';
        this.withoutTheWords = '';
        if (!this.totalResults) {
            this.searchString = '';
            fireEvent(null, 'setsearchstring'+this.eventCode, this.searchString);
        }
        this.searchString = !this.totalResults ? this.caseSubjectVal : this.searchString;
    }

    handleRemoveStickyFacetEvent(event){
        let removed = false;
        this.from = 0;
        this.pageNum = 1;
        if (event.label == "With the exact phrase" || event.label == "With one or more words" || event.label == "Without the words") {
            this.exactPhrase = event.label == "With the exact phrase" ? '' : this.exactPhrase;
            this.withOneOrMore = event.label == "With one or more words" ? '' : this.withOneOrMore;
            this.withoutTheWords = event.label == "Without the words" ? '' : this.withoutTheWords;
            if (this.exactPhrase == "" && this.withOneOrMore == "" && this.withoutTheWords == "") {
                this.advanceSearchEnabled = false
            }
            this.isFreshSearch = -1;
            this.getData(null, 'advanceFilterCheck');
        } else {
            if( event.type == '_index') {
                this.selectedTypeFilter = "";
                this.active = 'all';
                removed = true;
            } else if (event.type == '_type' && this.setArray[0].key !== '_index' && this.setArray[0].key !== '') {
                this.selectedTypeFilter = "";
                this.active = 'all';
                removed = true;
            }
            if (removed && (!event.immediateParent || !event.immediateParent.indexOf('merged') > -1)) {
                //fireEvent(this.pageRef, "removeStickyFacetEvent", {});
                this.getData(null,'filterCheck');
            } else {
                var sr = {};
                sr["Contentname"] = event.contentname;
                sr["immediateParent"] = event.immediateParent;
                sr["parent"] = event.type;
                sr["level"] = event.level;
                sr["checkedProp"] = false;
                sr["checked"] = false;
                sr["path"] = event.path;
                // this.typeSelectFunc(component, event, helper, 1, sr);
                fireEvent(this.pageRef, 'nestedFilter'+this.eventCode, {filter : sr});
            }
        }
    }
    //handle removing sticky facet data
    handleRemoveStickyFacetEvent1(event){
        if(event.aggregations != null){
            this.aggregationsData = JSON.stringify(event.aggregations);
            this.checkHere = true;
        }
        if(event.obj != null){
            if(event.obj.label == 'exactPhrase'){
                this.exactPhrase = event.obj.values;
            }
            if(e.target.dataset.name=='withOneOrMore'){
                this.withOneOrMore = event.obj.values;
            }
            if(e.target.dataset.name=='withoutTheWords'){
                this.withoutTheWords = event.obj.values;
            }
        }
        this.getData(null, "clearStickyFilter");
    }

    //handling clear filter section
    handleClearFilterEvent(event) {
        this.selectedTypeFilter = '';
        this.from = 0;
        this.pageNum = "1";
        this.counter = 1;
        this.viewAll = false;
        this.suggestionLength = false
        this.exactPhrase = '';
        this.withOneOrMore = '';
        this.withoutTheWords = '';
        this.advanceSearchEnabled = false;
        this.showClearFiltersButton = false;
        if (this.customSettingsFilled && this.bearer) {
            this.getData(null, 'clearFilter');
        }
        this.active = "all_Content";
    }

    //handling clear filter section
    handleClearFilterSecEvent() {
        this.selectedTypeFilter = '';
        this.from = 0;
        this.pageNum = "1";
        this.counter = 1;
        this.viewAll = false;
        this.suggestionLength = false;
        this.exactPhrase = '';
        this.withOneOrMore = '';
        this.withoutTheWords = '';
        this.advanceSearchEnabled = false;

        this.getData(null, 'clearFilter');
        this.active = "all_Content";
    }

    handleUtilitySlider() {
        this.showFilter = true;
        if(this.template.querySelector('[data-id="filterBlock"]')) {
            this.template.querySelector('[data-id="filterBlock"]').classList.remove('filterDiv');
        }

    }

    //This event handle Filter chnge event
    handleFilterChangesEvent(event) {
        this.selectedTypeFilter = event.selectedTypeFilter;
        this.filterOrder = event.filterOrder;
        this.currentClickedOrder = event.currentClickedOrder;
        this.counter = event.counter;
        if (this.selectedTypeFilter.length > 0) {
            this.aggregationsData = [];
            this.from = 0;
            this.pageNum = "1";
            this.counter = 1;
            this.setPagination(this.pageSize, this.pageNum)
        }
        if (this.customSettingsFilled && this.bearer)
            this.getData(null, 'pageChange');
        this.goToTopFunc();
    }

    savedBmarkClicked(event) {
        var p = event.target.getAttribute("data-query");
        p = JSON.parse(p);
        // this.bookmarkClicked(e);
        p.searchString = p.searchString == this.currentCaseSubject ? '' : p.searchString;
        fireEvent(null, 'setsearchstring'+this.eventCode, p.searchString);
        var footerDataObj = {
            "pageNo": p.pageNo,
            "resultsPerPage": p.resultsPerPage
        };
        fireEvent(null, 'sendpaginationdata'+this.eventCode, footerDataObj);
        var sendToDataSection = {
            "pageNo": p.pageNo,
            "aggregations": p.aggregations
        }
        fireEvent(null, 'sendtodatasection'+this.eventCode, sendToDataSection);
        var sendToSortData = {
            "sortby": p.sortby
        }
        fireEvent(null, 'sendsortdata'+this.eventCode, sendToSortData);
        var advSearchObj = {
            "exactPhrase": p.exactPhrase,
            "withOneOrMore": p.withOneOrMore,
            "withoutTheWords": p.withoutTheWords
        }
        fireEvent(null, 'advsearchdata'+this.eventCode, advSearchObj);
        fireEvent(null, 'languagedata'+this.eventCode, p.language);

        // this.searchString='case';
        let query = event.target.getAttribute("data-query");
        let counter = event.target.getAttribute("data-counter");
        let endpointer = event.target.getAttribute("data-endpoint");
        let total = event.target.getAttribute("data-totalresults");
        let pagelist = event.target.getAttribute("data-pagelist");
        var detailedData = JSON.parse(query);
        this.bookmark_clicked = true;
        this.bookmark_queryPassed = JSON.parse(query);
        this.bookmark_list = false;
        fireEvent(null, 'closesavedbmark'+this.eventCode, false);;
        document.body.style.position = 'relative';
        document.body.classList.remove('su__overflow-hidden');
        var oldString = this.searchString;
        this.searchString = detailedData.searchString;
        this.sortByCheck = detailedData.sortby;
        this.exactPhrase = detailedData.exactPhrase;
        this.withOneOrMore = detailedData.withOneOrMore;
        this.withoutTheWords = detailedData.withoutTheWords;
        this.pageSize = detailedData.resultsPerPage;
        this.pageSizeAdvFiltr = detailedData.resultsPerPage;
        this.selectedTypeFilter = JSON.stringify(detailedData.aggregations);
        this.counter = counter;
        this.totalResults = total;
        this.endPointPagination = endpointer;
        this.pageNum = detailedData.pageNum;
        var aggData = detailedData.aggregations;
        this.setPagination(this.pageSize, this.counter);
        this.isFreshSearch = -1;
        if (this.customSettingsFilled && this.bearer) {
            this.getData(null, 'bookmarkSearch');
            this.noBookmarkSaved = false
        }
    }
    showClearFilterMethod(d) {
        this.showClearFiltersButton = d;
        fireEvent(null, 'showclearfilterbtn'+this.eventCode, this.showClearFiltersButton);
    }
    handleDataFromSU(event) {
        let dataToBeSentToHeaderSUComponent = { 
            showClearFiltersButton: this.showClearFiltersButton, 
            recorId: this.recordId, aggregationsData: this.aggregationsData, 
            selectedStickyFilter: this.selectedStickyFilter, 
            showFilter: this.showFilter, 
            tabsFilter: this.tabsFilter,
            bookmarkList: this.bookmarkSearches
        }
        fireEvent(null, 'dataFromContainer'+this.eventCode, dataToBeSentToHeaderSUComponent);
        if(event == 'header')
            this.hideDataSection = true;
    }

    sendList(data) {
        this.currentLanguageSelected = this.currentLanguageSelected.map((value, index) => {
            if (value.name == 'English') {
                return { ...value, "selected": true };
            }
            else {
                return { ...value, "selected": false };
            }

        });
        fireEvent(null, 'langListSend'+this.eventCode, this.currentLanguageSelected);
    }
    removefromlocal(data) {
        this.removeBookmarksList(data);
        fireEvent(null, 'bmarkslist'+this.eventCode, this.bookmarkSearches);
    }
    sendBookmarkList(e) {
        fireEvent(null, 'transssferlist'+this.eventCode, this.bookmarkSearches);
    }
    saveToLocalMethod(data) {
        this.bookmarkName = data;
        this.saveToLocal(data);
    }

    tabClickedMethod(data) {
        this.active = data;
        this.from = 0;
        this.pageNum = 1;
        this.counter = 1;
        
        this.selectedTypeFilter = JSON.stringify(data);
        this.setPagination(this.pageSize, this.pageNum)
        this.getData(null, 'search');
        this.goToTopFunc();
        // if (this.active == 'all_Content') {
        //     this.selectedTypeFilter = "";
        //     this.getData(null, 'search');
        //     this.goToTopFunc();
        // }
        // else {
        //     var filterValue;
        //     filterValue = '[{"type":"' + this.keyElement + '","filter":["' + this.active + '"]}]';
        //     this.selectedTypeFilter = filterValue
        //     this.setPagination(this.pageSize, this.pageNum)
        //     this.getData(null, 'search');
        //     this.goToTopFunc();
        // }
    }
    //Adding checkboxSelection event from suFilterSection
    checkboxSelectedEvent(event) {
        this.getData(null, 'pageChange');
    }

    handleCaseCommentEmailEvent(event) {
        window.gza('linkSharingViaEmail', {
            caseId: this.recordId,
            id: event.id,
            caseNumber: this.currentCaseNumber, //check
            subject: this.currentCaseSubject,
            searchString: this.searchString,
            object: event.objName,
            url: this.url,
            title: event.ptitle,//Check
            author: this.currentUserEmail //check 
        });
    }

    handleFilterSectionEvent(event) {
        this.pagingAggregation = event.pagingAggregation;
        this.key = event.key;
        this.searchFilterString = event.searchFilterString;
        this.getData(null, event.searchFilterString);

    }

    handleAttachToCaseEvent(event) {
        this.responseListData[event.index].showDetachButton = event.attached ? true : false;
        this.responseListData[event.index].showAttachButton = event.attached ? false : !(this.responseListData[event.index].record.merge);
        window.gza('attachToCaseComment', {
            searchString: this.searchString,
            id: event._id,
            articleId: event.Id || event._id,
            url: event.url,
            t: event.title,
            subject: this.currentCaseSubject,
            caseNumber: this.currentCaseNumber,
            index: event.sourceName,
            type: event.objName,
            author: this.currentUserEmail
        });
    }

    handleCopyLinkEvent(evt) {
        window.gza('copyToClipboard', {
            caseId: this.recordId,
            id: evt.id,
            caseNumber: this.currentCaseNumber,
            subject: this.currentCaseSubject,
            searchString: this.searchString,
            object: evt.objName,
            index: evt.sourceName,
            url: evt.plink,
            title: evt.ptitle,
            author: this.currentUserEmail
        });
    }

    handleSendLinkEvent(event) {
        window.gza('linkSharingViaCaseComment', {
            caseId: this.recordId,
            id: event.id,
            caseNumber: this.currentCaseNumber, //check
            subject: this.currentCaseSubject,
            searchString: this.searchString || this.currentCaseSubject,
            object: event.objName,
            index: event.sourceName,
            url: event.url,
            title: event.title,//Check
            author: this.currentUserEmail //check 
        });
    }
    langSelecetedMethod(data) {
        this.currentLangLabel(data);
    }
    nextDotClicked(event) {
        this.pageNum = event.pageNum;
        this.counter = event.counter;
        this.from = ((this.pageNum - 1) * this.pageSize);
        this.getData(null, 'pageChange');
        this.goToTopFunc();
    }
    previousPagesDotsMethod(event) {
        this.pageNum = event.pagenum;
        this.counter = event.counter;
        this.endPointPagination = event.endpointpagination;
        this.from = ((this.pageNum - 1) * this.pageSize);
        this.getData(null, 'pageChange');
        this.goToTopFunc();
    }
    processMeCalled(data) {
        this.pageNum = data;
        this.from = ((this.pageNum - 1) * this.pageSize);
        this.getData(null, 'pageChange');
        this.goToTopFunc();
    }
    previousMethodCalled(event) {
        this.counter = event.counter;
        this.endPointPagination = event.endpointpagination;
        this.pageNum = event.pageNum;
        this.from = ((this.pageNum - 1) * this.pageSize);
        this.getData(null, 'pageChange');
        this.goToTopFunc();
    }
    selectChangeMethod(event) {
        this.pageSizeAdvFiltr = event.pagesizeadvfiltr;
        this.pageSize = event.pagesize;
        this.pageNum = event.pageNum;
        this.from = ((this.pageNum - 1) * this.pageSize);
        this.getData(null, 'pageChange');
        this.goToTopFunc();
    }
    nextPageClicked(event) {
        this.pageNum = event.pageNum;
        this.counter = event.counter;
        this.from = ((this.pageNum - 1) * this.pageSize);
        this.getData(null, 'pageChange');
        this.goToTopFunc();

    }

    // When Slider Button left to search  is clicked
    handleUtilitySlider() {
        if (this.onFilterButtonClick) {
            this.onFilterButtonClick = false;
            this.template.querySelector('[data-id="filterBlock"]').classList.remove('filterDiv');
        }
        else {
            this.onFilterButtonClick = true;
            this.template.querySelector('[data-id="filterBlock"]').classList.add('filterDiv');
            this.template.querySelector('[data-id="filterBlock"]').classList.remove('su__h-100'); 
        }
    }


    checkTypeFromSUSortBy(event) {
        this.sortByCheck = event;
        this.from = 0;
        this.pageNum = "1";
        this.counter = 1;
        this.setPagination(this.pageSize, this.pageNum)
        if (this.customSettingsFilled && this.bearer)
            this.getData(null, 'sortBy');
    }

    handleAdvanceSearch(event) {
        this.firstStickyLabel = [];
        this.from = 0;
        this.pageNum = "1";
        this.counter = 1;
        this.exactPhrase = event.exactPhrase;
        this.withOneOrMore = event.withOneOrMore;
        this.withoutTheWords = event.withoutTheWords;
        this.isFreshSearch = -1;
        // add into sticky facets
        if (this.exactPhrase) { this.firstStickyLabel.push({ "key": "exact Phrase", "value": this.exactPhrase }); }
        if (this.withOneOrMore) {
            this.firstStickyLabel.push({ "key": "with One Or More", "value": this.withOneOrMore });
        }
        if (this.withoutTheWords) { this.firstStickyLabel.push({ "key": "without The Words", "value": this.withoutTheWords }); }

        // Sticky label from adb search 
        this.advSearchFilter = this.firstStickyLabel;
        fireEvent(null, 'advsearchstickyfltr'+this.eventCode, this.advSearchFilter);
        this.setPagination(this.pageSize, this.pageNum);
        if (this.customSettingsFilled && this.bearer) {
            this.getData(null, 'pageChange');
        }
    }

    handleFooterchat(event) {
        this.getData(null, 'pageChange');
    }
    handleClearSearch(event){
        this.searchString = this.caseSubjectVal;
    }

    handleSearchPageEvent(obj) {
        if ((obj.isFreshSearch == -1 && obj.searchString && obj.searchString.length) 
            || (obj.isFreshSearch != -1)) {
            this.searchString = obj.searchString;
            this.isFreshSearch = obj.isFreshSearch == -1 ? obj.isFreshSearch : this.isFreshSearch;
            this.from = 0;
            this.pageNum = "1";
            this.counter = 1;
            this.setPagination(this.pageSize, this.pageNum);
            if (this.customSettingsFilled && this.bearer)
                this.getData(null, 'pageChange');
            this.goToTopFunc();
        }
    }

    sidValue(xyz) {
        this.SID = xyz;
    }
    translationFunc() {
        var translation = this.translationObj;
        var lang = window.localStorage.getItem("language") || 'en';
        var arrayLang = {};
        if (translation[lang]) {
            for (var key in translation[lang].mapping) {
                let newKey = key;
                newKey = key.replace(new RegExp(/[/\W|_/]/gi), '_')
                arrayLang[newKey] = translation[lang].mapping[key];

            }
        }
        this.finalLang = arrayLang;
        var ifExist = false;
        for (var i = 0; i < translation["config"].selectedLanguages.length; i++) {
            if (translation["config"].selectedLanguages[i].code == localStorage.getItem('language')) {
                ifExist = true;
                break;
            }
        }
        if (!ifExist) {
            window.localStorage.setItem("language", translation['config'].defaultLanguage["code"]);
            this.languageSelectedByUser = lang;
        }
        if (lang) {
            this.languageSelectedByUser = lang;
        } else {
            window.localStorage.setItem("language", translation['config'].defaultLanguage["code"]);
            this.languageSelectedByUser = translation['config'].defaultLanguage["code"];
        }

        if (!translation[lang]) {
            window.localStorage.setItem("language", "en");
            this.languageSelectedByUser = "en";
        }
        this.selectedLanguages = translation['config'].selectedLanguages;
        if (translation[lang]) {
            this.directionText = translation[lang].type;
        }
    }
    saveToLocal(event) {
        var a = JSON.parse(localStorage.getItem('bookmark_searches_' + this.uid) || "[]");
        // var recId = JSON.stringify(this.result.CaseNumber)
        a.push({
            title: this.bookmarkName,
            href: JSON.stringify(this.query),
            counter: this.counter,
            endpoint: this.endPointPagination,
            totalresults: this.totalResults,
            pagelist: JSON.stringify(this.paginationList)
        });
        localStorage.setItem("bookmark_searches_" + this.uid, JSON.stringify(a));
        this.bookmarkSearches = a;
        if (this.bookmarkSearches.length > 0) {
            this.showBookMark = true
            this.isBookmarkExist = true;
        }
        else {
            this.showBookMark = false
            this.isBookmarkExist = false;
        }
        this.bookmarkName = "";
        this.viewSavePopup = false;
        this.disableButton = true;
        this.isModalOpen = false;
        this.handleDataFromSU();
    }

    removeBookmarksList(deleteList) {
        for (var j = 0; j < deleteList.length; j++) {
            let item = deleteList[j];
            let a = JSON.parse(localStorage.getItem('bookmark_searches_' + this.uid) || '[]');
            let index = -1;
            for (var i = 0; i < a.length; i++) {
                if (a[i].title == item.title && a[i].href == item.href) {
                    index = i;
                    break;
                }
            }
            if (index > -1) a.splice(index, 1);
            localStorage.setItem("bookmark_searches_" + this.uid, JSON.stringify(a));
        }
        let c = JSON.parse(localStorage.getItem('bookmark_searches_' + this.uid) || "[]");
        let checkboxes = this.template.querySelectorAll('[data-id="checkbox"]')
        for (i = 0; i < checkboxes.length; i++) {
            if (checkboxes[i].checked) {
                checkboxes[i].checked = false;
            }
        }
        this.bookmarkSearches = c;
        if (this.bookmarkSearches.length > 0) {
            this.showBookMark = true;
            this.isBookmarkExist = true;
        }
        else {
            this.showBookMark = false;
            this.isBookmarkExist = false;

        }
        this.handleDataFromSU();
    }
    setResults(result) {
        this.responseListDataBackup = this.responseListData;
        for (var i = 0; i < result.result.hits.length; i++) {
            if (result.result.hits[i].href.toLowerCase().includes('youtube.com')) {
                this.showPreviewIcon = true;
            } else {
                this.showPreviewIcon = false;
                this.isModalOpen1 = false;
            }
        }
        // Code added by fresher (ending here)

        var recordsWrap = [];
        var styleColor;
        if (result.searchClientSettings.preview) {
            for (var i = 0; i < result.result.hits.length; i++) {
                if (result.result.hits[i].href.toLowerCase().includes('youtube.com') || (result.result.hits[i].href.toLowerCase().includes('vimeo.com') && /^\d+$/.test(result.result.hits[i].href.split('.com/')[1])) || result.result.hits[i].href.includes(window.location.origin)) {
                    result.result.hits[i].showPreview = true;
                }
                else {
                    result.result.hits[i].showPreview = false;
                }
            }
        }
        var arr = ("The dog ran through the field.  The dog ate."); //paragraph from which to search    
        for (var i = 0; i < result.result.hits.length; i++) {
            if (result.result.hits[i].highlight.TitleToDisplayString == this.caseSubjectVal) {
                styleColor = 'background-color:#D4E8FF';
            }
            else {
                styleColor = 'background-color:none';
            }

            if(result.result.hits[i].metadata && result.result.hits[i].metadata.length) {
                for (let j = 0; j < result.result.hits[i].metadata.length; j++) {
                    if(result.result.hits[i].metadata[j].value[0] == '') {
                        result.result.hits[i].metadata.splice(j, 1);
                    }
                }
            }

            
            let dataContext = result.result.hits[i]._id;
            //added for testing
            if (dataContext.startsWith("k")) {
                recordsWrap.push({ "showArticles": true, "styleColor": styleColor, "record": result.result.hits[i] });
            } else {
                recordsWrap.push({ "showArticles": false, "styleColor": styleColor, "record": result.result.hits[i] });
            }
        }
        this.responseListData = recordsWrap;
        if (!this.responseListData.length) this.responseListData = this.responseListDataBackup;
        let KnowledgeArticle=[];
        var arrWithrecord ;
        checkArticle({ caseIdd: this.recordId })
        .then((result) => {
            for(let i=0;i<result.length;i++) {
                KnowledgeArticle.push(result[i].KnowledgeArticleId);
            }
            //    Add additional key value pair
    
            arrWithrecord = this.responseListData.map(object => {
                return {...object, attached: false, showAttachButton: object.record.LinkViaAttachArticle && !(object.record && object.record.merge)};
            });
            //   Compare
            arrWithrecord = arrWithrecord.map((value, index) => {
                var kid=value.record._id;
                kid =kid.substring(0, 18);
                if(KnowledgeArticle.indexOf(kid) > -1) {
                    console.log("matched");
                    return { ...value, "attached": true, showAttachButton: false, showDetachButton: value.record.LinkViaAttachArticle };
                } else {
                    return { ...value, "attached": false, showAttachButton: value.record.LinkViaAttachArticle && !(value.record && value.record.merge > 0), showDetachButton: false};
                }

            });
            this.responseListData=arrWithrecord;

        })
        .catch((error) => {
            this.error = error;
        
        });


    }

    sortMergeFacetFunc(filters, sort){
        let sortBy = sort.split('_')[0];
        let orderBy = sort.split('_')[1];
        if (sortBy === 'term') filters = filters.sort(function(a, b) { 
            return ( (a.displayNameFrontend || a.ContentnameFrontend) > (b.displayNameFrontend || b.ContentnameFrontend)
                ? 1
                : (a.displayNameFrontend || a.ContentnameFrontend) < (b.displayNameFrontend || b.ContentnameFrontend)
                    ? -1
                    : 0
                )
        })
        if (sortBy === 'count') filters = filters.sort(function(a, b) {return a.value - b.value});
        if (orderBy === 'desc') filters = filters.reverse();
        let arr = [];
        return(filters.filter(function(f) {
            if (f.selected || f.childSelected) return f; 
            arr.push(f);
        }).concat(arr));
    }

    mergeFilters(h, aggrData) {
        let k = -1;
        let existingIndex = -1;
        aggrData.some(function(f, i) { if (f.key == h.facetName) { k = i; return true; } });
        if (k == -1) return;
        let exists = aggrData.length > 0 ? aggrData[k].values.filter(function(f,i) { if( f.Contentname == 'merged_'+h.filterNewName) { existingIndex = i; return true;} }) : [];
        let children = exists.length ? aggrData[k].values[existingIndex].childArray.map(function(f){return f.Contentname}) : [];
        h.filterList = h.filterList.map(function(filter) { return decodeURIComponent(filter)});
        let l = k > -1 ? aggrData[k].values.filter(function(f) { return h.filterList.indexOf(f.Contentname) > -1 && children.indexOf(f.Contentname) == -1 }) : [];
        let v = 0;
        l.forEach(function(f) {
            v += f.value;
        });

        if (l.length) {
            let place = aggrData[k].values.length;
            aggrData[k].merged = true;
            let childArray = [];
            let s = JSON.parse(JSON.stringify(l[0]));
            l.forEach(function(f) {
                let index = -1;
                aggrData[k].values.some(function(d, i) { if (d.Contentname == f.Contentname) { index = i; return true; } });
                childArray.push(aggrData[k].values[index]);
                if (index < place) place = index;
                if (index > -1) aggrData[k].values.splice(index, 1);
            });

            childArray.forEach(function(f) { f.immediateParent = 'merged_' + h.filterNewName;
                f.level = 2;
                f.parent = h.facetName;
                f.childName = f.Contentname;
                f.displayName = f.displayName || f.Contentname;
            });
            let exists = aggrData[k].values.filter(function(f,i) { if( f.Contentname == 'merged_'+h.filterNewName) { existingIndex = i; return true;}  });
            if (existingIndex == -1) {
                s.displayName = h.filterNewName;
                s.Contentname = 'merged_' + h.filterNewName;
                s.Contentname_short = h.filterNewName;
                s.value = v;
                s.merged = true;
                s.showChild = parseInt(h.showChild ? h.showChild : '0');
                s.selected = false;
                s.indeterminate = false;
                s.childArray = JSON.parse(JSON.stringify(childArray));
                s.childSelected = childArray.some(f => f.selected);
                var aggregations=JSON.parse(this.selectedTypeFilter || '[]');
                if (aggregations.length != 0) {
                    let index = -1;
                    aggregations.some(function (facet, i) { if (facet.type == h.facetName) { index = i; return true; } });
                    if (index >= 0) {
                        var filtersInAggr;
                        let existingChildren = l.map(function(c) { return c.Contentname} )
                        if (aggregations[index] && aggregations[index].filter && aggregations[index].filter.length) {
                            filtersInAggr = aggregations[index].filter.filter(function (ele) {
                                return existingChildren.indexOf(ele) > -1
                            })
                            if (filtersInAggr.length == existingChildren.length){
                                s.selected = true;
                            } else if(filtersInAggr.length) {
                                s.indeterminate =  true;
                            }
                        }
                    }
                }
                aggrData[k].values.splice(place, 0, s);
                // aggrData[k].values = this.sortMergeFacetFunc(aggrData[k].values, aggrData[k].sort);
            }
            else {
                aggrData[k].values[existingIndex].value += v;
                aggrData[k].values[existingIndex].childArray = aggrData[k].values[existingIndex].childArray.concat(childArray);
            }
        }
    }

    getData(argument, searchType) {
	    this.loading = 'su__loading';
        this.selectedTypeFilter =  argument && argument.aggregations ? argument.aggregations : this.selectedTypeFilter;
        this.filterSorting = argument && argument.filterSorting ? argument.filterSorting : false;
        searchType = argument ? 'search' : searchType;
        this.from = argument && argument.filterChecked ? 0 : this.from;
        this.pageNum = argument && argument.filterChecked ? 1 : this.pageNum;
        var runLoader = '';
        if ((!this.searchString || this.searchString == "") && this.caseSubjectVal != undefined) {
            this.isFreshSearch = -1;
            this.searchString = this.caseSubjectVal
            this.default_search = true;
        } else this.default_search = false;
        // add check if No Case subject then hit should not be fired
        if (this.getURLParameter('bookmark')) {
            searchType = this.getURLParameter('bookmark') ? this.getURLParameter('bookmark') : searchType;
        }
        if (!this.refresh || this.refresh && !this.setFlag) {
            var actionBach = window;
            var c = JSON.parse(localStorage.getItem('theme' + this.uid));
            // document.body.style.position = 'relative';
            document.body.style['overflow-y'] = 'unset';
            if (searchType == 'bookmark') {
                tihs.pageNum = this.getURLParameter('pageNum') != "" ? this.getURLParameter('pageNum') : "1";
                this.pageSize = this.getURLParameter('resultsPerPage') != "" ? this.getURLParameter('resultsPerPage') : this.defaultPageSize;
                if (!this.setFlag || this.setFlag && !c) {
                    this.selectedTypeFilter = this.getURLParameter('selectedType') != "" ? this.getURLParameter('selectedType') : "";
                }
                var previousDymString = this.getURLParameter('dym') ? this.getURLParameter('dym') : "undefined";
            }
            this.refresh = true;
            if (this.setFlag) {
                if (c) {
                    if (c.activeTabIndex != 'all' && c.activeTabIndex != undefined) {
                        this.active = c.activeTabIndex;
                        this.defaultTab = c.activeTabIndex;
                        var selectedFacet = (this.getURLParameter('selectedType') != "" ? this.getURLParameter('selectedType') : "");
                        var facetData = [{
                            "type": c.activeTabType,
                            "filter": [c.activeTabIndex.indexOf('merged_') > -1 ? c.activeTabValue : c.activeTabIndex]
                        }]
                        var filterValue = JSON.stringify(facetData);
                        if (selectedFacet != '' && JSON.parse(selectedFacet)[0].type != "_index") {
                            var selectedParams = JSON.parse(selectedFacet).concat(JSON.parse(filterValue));
                        }
                        else {
                            var selectedParams = (JSON.parse(selectedFacet || filterValue));
                        }
                        this.selectedTypeFilter = JSON.stringify(selectedParams);
                    }
                    else {
                        var selectedFacet = (this.getURLParameter('selectedType') != "" ? this.getURLParameter('selectedType') : "");
                        this.selectedTypeFilter = selectedFacet;
                    }
                }
                else {
                    var selectedFacet = (this.getURLParameter('selectedType') != "" ? this.getURLParameter('selectedType') : "");
                    this.selectedTypeFilter = selectedFacet;
                }
            }
            var bodyCom /*= component.find('dvSpinner3');@@@@@@@@@@@*/
            var analyticsCmp /*= component.find("SuAnalytics");@@@@@@@@@@@*/
            var sid = this.SID /*= analyticsCmp.analytics('_gz_taid', '')@@@@@@@@@ */;
            var cookie/* = analyticsCmp.analytics('_gz_sid', '');@@@@@@@*/
            var startTime = new Date();
            if (runLoader == 'true') {
                if (!this.filterSortingLoading) {
                    this.loadingResult = 0;
                }
            }
            // var indexEnabled = this.contentSourceTab;
            // var filterOrderPriority = this.filterOrder;
            // var previousResultAggregation = this.originalAggregationsData;
            var searchText = '';
            var originalQuery = '';
            searchText = this.searchString;
            if (searchText != "" && searchText != null) {
                originalQuery = searchText.trim();
                var EmailregexSlash = '\\\\';
                var regexSlash = new RegExp("\\\\", 'g');
                searchText = searchText.replace(regexSlash, EmailregexSlash);
                var Emailregex = '\\"';
                var re = new RegExp("^[\'\"][^\"]*[\"\']$");
                if (!re.test(searchText)) {
                    if (searchText[0] != '#') {
                        var regex = new RegExp('\"', 'g');
                        searchText = searchText.replace(regex, Emailregex);
                    }
                }
            }
            this.searchString = searchText;
            if (searchText !== "" && searchText != null) {
                searchText = searchText.trim();
            }
            var filterData;
            if(this.checkHere){
                filterData = this.aggregationsData;
                this.checkHere = false;
            }else{
                filterData = this.selectedTypeFilter;
            }
            var arr = [];
            var filterSelect = {
                "Contentname": filterData && JSON.parse(filterData).length != 0 && JSON.parse(filterData)[0].filter ? JSON.parse(filterData)[0].filter[0] : null,
                "checked": true
            }
            if (filterData.length != 0 && filterSelect.Contentname && filterSelect.Contentname.indexOf("merged_") > -1) {
                var data = JSON.parse(filterData);
                data[0].filter = arr;
                if(this.checkHere){
                    filterData = this.aggregationsData;
                    this.checkHere = false;
                }else{
                    filterData = JSON.stringify(data);
                }
            }
            // var pageNum = this.pageNum;
            // var currentPageNumber = Number(pageNum);
            // var pageSize = this.pageSize;
            // this.from = ((this.pageNum - 1) * this.pageSize)
            // var currentClickedOrder = this.currentClickedOrder;
            // var tempClientFilters = '' //JSON.parse(JSON.stringify(previousResultAggregation)); @@@@@@
            this.bookmark_list = false;
            this.viewSavePopup = false;
            this.viewConfirmPopup = false;
            if (filterData) {
                this.multiVersion = false;
            } else {
                this.multiVersion = true;
            }
            var data = JSON.stringify({
                "searchString": searchText,
                "from": this.from || 0,
                "pageNum": parseInt(this.pageNum),
                "pageNo": parseInt(this.pageNum),
                "sortby": this.sortByCheck,
                "orderBy": "desc",
                "resultsPerPage": parseInt(this.pageSize),
                "exactPhrase": this.exactPhrase,
                "withOneOrMore": this.withOneOrMore,
                "withoutTheWords": this.withoutTheWords,
                "aggregations": filterData ? JSON.parse(filterData) : [], //@@@
                "referrer": document.referrer,
                "recommendResult": "",
                "indexEnabled": this.contentSourceTab,
                "sid": window._gr_utility_functions.getCookie("_gz_taid"),
                "cookie": '',//@@@
                "uid": this.uid,
                "language": localStorage.getItem('language') || 'en',
                "versionResults": this.multiVersion,
                "getAutoTunedResult": true
            });
            let query = JSON.parse(data);
            this.query = query;
            var xmlHttp = new XMLHttpRequest();
            var url = this.endPoint + "/search/SUSearchResults";
            xmlHttp.withCredentials = true;
            xmlHttp.open("POST", url, true);
            xmlHttp.setRequestHeader("Accept", "application/json");
            xmlHttp.setRequestHeader('Authorization', 'bearer ' + this.bearer);
            xmlHttp.setRequestHeader('Content-Type', 'application/json');
            xmlHttp.send(data);
            xmlHttp.onreadystatechange = () => {
                if (xmlHttp.readyState === 4) {
                    if (xmlHttp.status === 200) {
                        var actionBachHref = actionBach.document.URL;
                        var result = JSON.parse(xmlHttp.response);
                        if (result.statusCode != 402) {
                            var total = result.result.total;
                            if (result.statusCode == 200 || result.statusCode == 400) {
                                this.loading = '';
                                fireEvent(this.pageRef, 'API_RESULT'+this.eventCode, { result, querySent: data, selectedTypeFilter: this.selectedTypeFilter });
                                if (result.searchClientSettings.ViewedResults == 1) {
                                    this.showViewedResults = 'su__viewed-results';
                                } else {
                                    this.showViewedResults = '';
                                }
                                if(this.exactPhrase !== "" || this.withOneOrMore !== "" || this.withoutTheWords !== "") {
                                    this.advancedSearchSelected = true;
                                } else {
                                    this.advancedSearchSelected = false;
                                }
                    
                                // if (!this.advancedSearchSelected) {
                                //     this.show.showAdvancedClear = false;
                                // } else {
                                //     // this.clearFiltersFlag = false;
                                //     this.show.showAdvancedClear = true;
                                //     advancedSearchInitiated = false;
                                // }
                                this.getRecommendations = result.searchClientSettings.recommendations ? true : false;
                                result.searchClientSettings.preview ? this.preview = true : this.preview = false
                                result.searchClientSettings.contentTag ? this.contentTag = true : this.contentTag = false;
                                result.searchClientSettings.showMore ? this.showSummary = true : this.showSummary = false;
                                if (result.searchClientSettings.hideAllContentSources && this.aggregationsData && this.aggregationsData.length && JSON.parse(filterData)) {
                                    let selectedFilters = JSON.parse(filterData);
                                    this.allContentHideFacet = selectedFilters.filter(f => f.type == this.aggregationsData[0].key).length ? false : true;
                                } else this.allContentHideFacet = result.searchClientSettings.hideAllContentSources || false;
                                this.summaryCollapsible = result.searchClientSettings.showMore ? true : false;
                                this.maxlength = result.searchClientSettings.minSummaryLength;
                                this.languageEnabled = result.searchClientSettings.languageManager;
                                this.caseSelection = JSON.parse(result.searchClientSettings.SCsalesforceConsoleConfigurations).caseSelection == '1';
                                this.showCaseNumber = JSON.parse(result.searchClientSettings.SCsalesforceConsoleConfigurations).caseNumberView == '1';
                                this.urlOpensInNewTab = JSON.parse(result.searchClientSettings.SCsalesforceConsoleConfigurations).searchResultsOpensNewBrowserTab == '1';
                                try {
                                    this.correctspell = result.suggest.simple_phrase[0].options;
                                } catch (exception) {
                                    console.log(exception);
                                }
                                this.totalResults = total;
                                var endTime = new Date();
                                var Seconds_from_T1_to_T2 = (endTime.getTime() - startTime.getTime()) / 1000;
                                var seconds_Between_Dates = Math.abs(Seconds_from_T1_to_T2);
                                this.searchResultTime = seconds_Between_Dates;
                                this.resultTime = this.searchResultTime;
                                this.resultCountReturned = result.result.hits.length;
                                //gza('search', obj);
                                if (!this.filterSorting) this.handleTrackAnalytics({type:'search'});
                                var aggrData = result.aggregationsArray;

                                // merge facet changes 
                                if (result.merged_facets && result.merged_facets.length) {
                                    this.mergedArray = JSON.parse(result.merged_facets || '[]');
                                    let self = this;
                                    this.mergedArray.forEach(function (o) {
                                        self.mergeFilters(o, aggrData);
                                    });
                                }
                        
                                this.keyElement = aggrData[0].key;
                                this.setArray = aggrData;
                                this.searchSummaryLength = result.searchClientSettings.minSummaryLength;
                                var suggestData = '';
                                this.suggestData = "";
                                var c = JSON.parse(localStorage.getItem('theme' + this.uid));
                                if (c) {
                                    if (c["hiddenFacets"]) {
                                        setArray.forEach(function (child) {
                                            if (c.hiddenFacets.includes(child.label)) {
                                                child.hide = true;
                                                child.hideEye = true;
                                            } else {
                                                child.hide = false;
                                                child.hideEye = false;
                                            }
                                        })
                                    } else {
                                        setArray.forEach(function (child) {
                                            child.hide = false;
                                            child.hideEye = false;
                                        })
                                    }
                                }
                                if(result.result.hits && result.result.hits.length) {
                                    for (var i = 0; i < result.result.hits.length; i++) {
                                        if (result.result.hits[i].highlight.TitleToDisplay[0] == null || result.result.hits[i].highlight.TitleToDisplay[0] == '') {
                                            Object.assign(result.result.hits[i], { 'highlightTitleToDisplay': true });//if(!data.highlight.TitleToDisplay[0] || data.highlight.TitleToDisplay[0] == '', true, false)@@@@
                                        } else {
                                            Object.assign(result.result.hits[i], { 'highlightTitleToDisplay': false });
                                        }
                                        if (result.result.hits[i].highlight.TitleToDisplayString[0]) {
                                            Object.assign(result.result.hits[i], { 'highlightTitleToDisplayString': result.result.hits[i].highlight.TitleToDisplayString[0] });//data.highlight.TitleToDisplayString[0]
                                        } else {
                                            Object.assign(result.result.hits[i], { 'highlightTitleToDisplayString': null });
                                        }
                                        if (result.result.hits[i]._id != null) {
                                            Object.assign(result.result.hits[i], { 'dataHitscollapseVersionIconID': 'collapseVersion-2-' + result.result.hits[i]._id + '_icon' });//{!'collapseVersion-2-'+data._id+'_icon'}
                                            Object.assign(result.result.hits[i], { 'dataHitscollapseVersionToggleIconID': 'collapseVersion-2-' + result.result.hits[i]._id + '_toggleIcon' }); //{!'collapseVersion-2-'+data._id+'_toggleIcon'}
                                            Object.assign(result.result.hits[i], { 'collapseVersionDataId': 'collapseVersion-2-' + result.result.hits[i]._id }); //{!'collapseVersion-2-'+data._id}
                                            Object.assign(result.result.hits[i], { 'collapseVersionOverlayId': 'collapseVersion-2-' + result.result.hits[i]._id + '_overlay' }); //{!'collapseVersion-2-'+data._id+_overlay}
                                        }
                                        else {
                                            Object.assign(result.result.hits[i], { 'dataHitscollapseVersionIconID': null });
                                            Object.assign(result.result.hits[i], { 'dataHitscollapseVersionToggleIconID': null });
                                            Object.assign(result.result.hits[i], { 'collapseVersionDataId': 'collapseVersion-2-' + result.result.hits[i]._id }); //{!'collapseVersion-2-'+data._id}
                                            Object.assign(result.result.hits[i], { 'collapseVersionOverlayId': 'collapseVersion-2-' + result[i]._id } + '_overlay'); //{!'collapseVersion-2-'+data._id+_overlay}
                                        }
                                        if ( this.summaryCollapsible && result.result.hits[i].highlight.SummaryToDisplay.join('').length > (this.maxlength + result.result.hits[i].highlight.SummaryToDisplay.length * 5)) {
                                            result.result.hits[i].showMore = true;
                                            result.result.hits[i].highlight.SummaryToDisplayMax = result.result.hits[i].highlight.SummaryToDisplay.join('#').split('#');
                                            result.result.hits[i].highlight.SummaryToDisplay = result.result.hits[i].highlight.SummaryToDisplay.join('#').substring(0, this.maxlength).split('#');
                                        } else result.result.hits[i].showMore = false;
                                        if(this.linkSharingOptions && this.linkSharingOptions.length) {
                                            var foundObj = this.linkSharingOptions.filter((r) => r.selected_object == result.result.hits[i].objName && r.content_source_label == result.result.hits[i].sourceLabel)
                                            foundObj.forEach(obj => {
                                                console.log(JSON.stringify(obj));
                                                if (obj.result_action_id == 1)
                                                    result.result.hits[i].LinkViaEmail = obj.status;
                                                if (obj.result_action_id == 2)
                                                    result.result.hits[i].LinkViacaseComment = obj.status;
                                                if (obj.result_action_id == 3)
                                                    result.result.hits[i].LinkViaAttachArticle = obj.status;
                                                result.result.hits[i].merge = obj.merge;
                                            })
                                        }
                                    }
                                }
                                if (this.totalResults == 0) {
                                    this.noResultMsg = "No results found. Kindly search with some other keywords";
                                }
                                
                                
                                this.setStickyFacets(this.setArray);
                                this.setFilters(this.setArray);
                                this.setClearFilters();
                                this.setResults(result);
                                this.setPagination(this.pageSize, this.pageNum);
                                this.handleDataFromSU();
                                this.componentLoaded = true;//@@@@
                                this.setFlag = false;//@@@@
                                if (!filterData || !filterData.length) fireEvent(this.pageRef, "clearFilterDataEvent"+this.eventCode, null);
                                fireEvent(null, 'setAggregationsData'+this.eventCode, this.aggregationsData);
                                this.suResultsLoader = true;
                            }
                        }
                    }
                }
            };
         // }  
          }
    }
    setFilters(setArray) {
        var splicedData = [];
        const arr = setArray[0].values;
        var tabsData = setArray;
        for (var j = 0; j < setArray.length; j++) {
            if (setArray[j].values.length > 0 && setArray[j].key != "_index") {

                splicedData.push(setArray[j]);
            }
        }
        if (this.sourceFacet) {
            splicedData = splicedData.splice(1);
        }

        var splicedTabFilter = [];
        var filterValue = '{"displayName":"All Content","Contentname":"all_Content","immediateParent": "_all"}';
        if (arr == 0)//if No value return hide all content.
        { }
        else {
            splicedTabFilter.push(JSON.parse(filterValue));
        }
        for (var i = 0; i < tabsData[0].values.length; i++) {
            splicedTabFilter.push(tabsData[0].values[i]);
        }
        this.tabsFilter = splicedTabFilter;
        var self = this;
        //  test
        this.countTab = 0;
        for (let i in this.tabsFilter) {
            if (this.tabsFilter[i].childArray) {
                self.childTab = (this.tabsFilter[i].childArray);
            }
        }
        // var stringText1 = ' ';
        if (this.childTab) {
            var searchTab = '';
            for (let i in this.childTab) {
                searchTab = searchTab + ' ' + this.childTab[i].displayName;
                this.countTab = this.countTab + 1;
            }

            this.stringText = searchTab;
        }
        this.tabSelected = this.stringText;
        // if (this.stringText != ' ') {
        // }
        this.copySplicedData=splicedData;
        this.aggregationsData = setArray;
        this.facetSearchIcon = this.endPoint + '/resources/Assets/search-img.svg';
        this.facetSearchClose = this.endPoint + '/resources/Assets/search-close.svg';
        this.aggregationsData = this.aggregationsData.filter(function (facet) {
            if (!facet.values || !facet.values.length) return false;
            if (self.searchFilterString != "") {
                if (facet.key == self.key) {
                    var filterValues = [];
                    if (facet.values.length > 0) {
                        for (var j = 0; j < facet.values.length; j++) {
                            if (facet.values[j].Contentname.includes(self.searchFilterString)) {
                                filterValues.push(facet.values[j]);
                            }
                        }
                    }
                    Object.assign(facet, { 'filterSuggest': "result" });
                    Object.assign(facet, { 'filterSuggestions': filterValues });
                    if (facet.values.length > 0) {
                        Object.assign(facet, { 'suggestionLength': true });
                        self.suggestionLength = true;
                    }
                }
            }
            else if (self.searchFilterString == "" && self.key != "") {
                Object.assign(facet, { 'filterSuggest': "no-result" });
                Object.assign(facet, { 'filterSuggestions': [] });
                Object.assign(facet, { 'suggestionLength': false });
                self.suggestionLength = false;

            }
            if (facet.key != 'post_time' && facet.key != 'CreatedDate' && facet.label != 'Created Date') {
                Object.assign(facet, { 'post_Time_Enable': true });//{!if(filter.key != 'post_time', true,false)}
            } else {
                Object.assign(facet, { 'post_Time_Enable': false });
            }
            if (facet.label == 'Sources') { //!if(filter.label == 'Sources', true,false)
                Object.assign(facet, { 'enable_Custom_Sort': true });
            } else {
                Object.assign(facet, { 'enable_Custom_Sort': false });
            }
            if (facet.label == 'Created Date') { //!if(filter.label == 'Created Date', true,false)
                Object.assign(facet, { 'enable_Created_Date': true });
            } else {
                Object.assign(facet, { 'enable_Created_Date': false });
            }
            if (facet.sort == 'custom') { //{!filter.sort == 'term_asc' ? 'font-12 su__color-black su__px-4 su__py-2 su__cursor su__bg-gray-hover su__filters-sort-active': 'font-12 su__color-black su__px-4 su__py-2 su__cursor su__bg-gray-hover'}
                Object.assign(facet, { 'customSortingClass': 'font-12 su__color-black su__px-4 su__py-2 su__cursor su__bg-gray-hover su__filters-sort-active' });
            } else {
                Object.assign(facet, { 'customSortingClass': 'font-12 su__color-black su__px-4 su__py-2 su__cursor su__bg-gray-hover' });
            }
            if (facet.sort == 'term_asc') { //{!filter.sort == 'term_asc' ? 'font-12 su__color-black su__px-4 su__py-2 su__cursor su__bg-gray-hover su__filters-sort-active': 'font-12 su__color-black su__px-4 su__py-2 su__cursor su__bg-gray-hover'}
                Object.assign(facet, { 'term_ascSortingClass': 'font-12 su__color-black su__px-4 su__py-2 su__cursor su__bg-gray-hover su__filters-sort-active' });
            } else {
                Object.assign(facet, { 'term_ascSortingClass': 'font-12 su__color-black su__px-4 su__py-2 su__cursor su__bg-gray-hover' });
            }
            if (facet.sort == 'term_desc') { //{!filter.sort == 'term_asc' ? 'font-12 su__color-black su__px-4 su__py-2 su__cursor su__bg-gray-hover su__filters-sort-active': 'font-12 su__color-black su__px-4 su__py-2 su__cursor su__bg-gray-hover'}
                Object.assign(facet, { 'term_descSortingClass': 'font-12 su__color-black su__px-4 su__py-2 su__cursor su__bg-gray-hover su__filters-sort-active' });
            } else {
                Object.assign(facet, { 'term_descSortingClass': 'font-12 su__color-black su__px-4 su__py-2 su__cursor su__bg-gray-hover' });
            }
            if (facet.sort == 'count_desc') { //{!filter.sort == 'term_asc' ? 'font-12 su__color-black su__px-4 su__py-2 su__cursor su__bg-gray-hover su__filters-sort-active': 'font-12 su__color-black su__px-4 su__py-2 su__cursor su__bg-gray-hover'}
                Object.assign(facet, { 'count_descSortingClass': 'font-12 su__color-black su__px-4 su__py-2 su__cursor su__bg-gray-hover su__filters-sort-active' });
            } else {
                Object.assign(facet, { 'count_descSortingClass': 'font-12 su__color-black su__px-4 su__py-2 su__cursor su__bg-gray-hover' });
            }
            if (facet.sort == 'count_asc') { //{!filter.sort == 'term_asc' ? 'font-12 su__color-black su__px-4 su__py-2 su__cursor su__bg-gray-hover su__filters-sort-active': 'font-12 su__color-black su__px-4 su__py-2 su__cursor su__bg-gray-hover'}
                Object.assign(facet, { 'count_ascSortingClass': 'font-12 su__color-black su__px-4 su__py-2 su__cursor su__bg-gray-hover su__filters-sort-active' });
            } else {
                Object.assign(facet, { 'count_ascSortingClass': 'font-12 su__color-black su__px-4 su__py-2 su__cursor su__bg-gray-hover' });
            }
            Object.assign(facet, { 'collapseExampleID': 'collapseExample-' + facet.key + '_icon' });//{!'collapseExample-'+filter.key+'_icon'}
            Object.assign(facet, { 'collapseExampletoggleIconID': 'collapseExample-' + facet.key + '_toggleIconOn' });//{!'collapseExample-'+filter.key+'_toggleIconOn'}
            Object.assign(facet, { 'collapseExampletoggleIconOffID': 'collapseExample-' + facet.key + '_toggleIconOff' });//{!'collapseExample-'+filter.key+'_toggleIconOn'}
            Object.assign(facet, { 'collapseExampleEmptyID': 'collapseExample-' + facet.key });//{!'collapseExample-'+filter.key}
            Object.assign(facet, { 'filterisCollapsed': 'visibilityHidden su__position-absolute ' });
            Object.assign(facet, { 'isCollapsed': 'su__d-none' });//{!filter.isCollapsed? 'su__bg-overlay su__overlay': 'su__d-none'}
            Object.assign(facet, { 'expanded_Id': facet.key + '_filter_' + facet.order });//{!filter.key+'_filter_'+filter.order}
            Object.assign(facet, { 'filterSortingLoad': '' });//aggregationsData[i].filterSortingLoad = true;<!--{!filter.filterSortingLoad ? 'su__loading' : ''}-->
            Object.assign(facet, { 'filterNonExpanded': facet.values.length > 9 ? 'su__nonExpanded su__filter-content-row su__py-2' : 'su__Expanded su__filter-content-row su__py-1'});
            if (facet.values.length > 9) {
                Object.assign(facet, { 'filtersMoreThan9': true });//{!if(filter.values.length > 9 || filter.merged,true,false)}
            } else {
                Object.assign(facet, { 'filtersMoreThan9': false });
            }
            Object.assign(facet, { 'showmorefacetIcon': 'show-more-facetIcon-' + facet.key });//{!'show-more-facetIcon-'+filter.key}
            if (facet.values.length > 9) {
                Object.assign(facet, { 'filtervalues': true });//{!if(filter.values.length > 9 )}
            } else {
                Object.assign(facet, { 'filtervalues': false });
            }
            Object.assign(facet, { 'showMoreOrder': facet.key + '_filter_' + facet.order + '_showMore' });//{!filter.key+'_filter_'+filter.order+'_showMore'}
            if (facet.key != '_type') {
                Object.assign(facet, { 'keytype': true }); // {!if(filter.key != '_type',true,false)}
            } else {
                Object.assign(facet, { 'keytype': false });
            }
            Object.assign(facet, { 'select': false });
            Object.assign(facet, { 'facetIconId': 'searchFacetDiv-facetIcon-' + facet.key });
            Object.assign(facet, { 'facetSearchId': facet.key + '-facetSearch' });
            Object.assign(facet, { 'facetSearchInput': 'su__search-facet-input-' + facet.key })
            Object.assign(facet, { 'facetIconClass': 'facetIcon-' + facet.key + ' su__position-absolute su__facet-close-icon su__cursor' });
            Object.assign(facet, { 'facetCloseId': 'facetCloseIcon-facetIcon-' + facet.key });
            Object.assign(facet, { 'filterSuggestItemClass': 'su__toggle-input su__position-absolute su__cursor checkType_' + facet.order })
            Object.assign(facet, { 'filterSuggestLabelClass': 'su__toggle-label su__d-inline-flex su__cursor su__loading-view-border su__' + facet.key });
            Object.assign(facet, { 'facetFilterId': 'facetSearchIcon-facetIcon-' + facet.key });
            Object.assign(facet, { 'facetFilterClass': 'facetIcon-' + facet.key + ' su__d-block su__facet-search-icon' })
            Object.assign(facet, { 'filterSuggestClass': 'su__search-facet-input su__loading-view' });
						
            facet.values.forEach(function(filter) {
                if (filter.value == 0) {
                    Object.assign(filter, { 'disabledValue': 'disabled' });//{!if(filterType.value == 0,'disabled','yes')}
                } else {
                    Object.assign(filter, { 'disabledValue': 'yes' });//{!if(filterType.value == 0,'disabled','yes')}
                }
                if (filter.displayName != null) {//{filterType.displayName || filterType.Contentname}
                    Object.assign(filter, { 'titleName': filter.displayName });
                } else if (filter.Contentname != null) {
                    Object.assign(filter, { 'titleName': filter.Contentname });
                    Object.assign(filter, { 'displayNameNOTAvailable': true });//{!if ( !filterType.displayName &amp;&amp; filterType.Contentname, true, false)}
                }
                if (filter.childArray) {
                    Object.assign(filter, { 'collapseExampleID': 'collapseExample-' + facet.key +'_'+ filter.Contentname + '_icon' });//{!'collapseExample-'+filter.key+'_icon'}
                    Object.assign(filter, { 'collapseExampletoggleIconID': 'collapseExample-' + facet.key +'_'+ filter.Contentname + '_toggleIconOn' });//{!'collapseExample-'+filter.key+'_toggleIconOn'}
                    Object.assign(filter, { 'collapseExampletoggleIconOffID': 'collapseExample-' + facet.key +'_'+ filter.Contentname + '_toggleIconOff' });//{!'collapseExample-'+filter.key+'_toggleIconOn'}
                    Object.assign(filter, { 'collapseExampleEmptyID': 'collapseExample-' + facet.key +'_'+ filter.Contentname });
			        filter.showChild = filter.childArray.length && !filter.merged ? 1 : filter.showChild;
                }
                Object.assign(filter, { 'uniqueId': facet.key+ '_' + filter.Contentname });

            });
            return facet;
        });

        this.setFlag = false;
    }
    // async
    async getCommunityCustomSettings() {
        getConsoleCustomSettings()
            .then(result => {
                this.JWTToken = result;
                this.getCommunityCustomSettings2(this.JWTToken);
                // this.bearer=this.JWTToken;
            })
            .catch(error => {
                console.log(error);
            });

    }
    getCommunityCustomSettings2(jwtToken) {
        var permission = ''
        var searchQuery = '';
        if (jwtToken) {
            this.bearer = jwtToken;
            this.customSettingsFilled = true;
            this.selectedTypeFilter = localStorage.getItem("selectedFilter") || "";
            this.bookmarkSearches = JSON.parse(localStorage.getItem('bookmark_searches_' + this.uid) || "[]");
            if (this.bookmarkSearches.length > 0) {
                this.showBookMark = true
                this.isBookmarkExist = true
            }
            else {
                this.showBookMark = false
                this.isBookmarkExist = false
            }
            this.pageNum = "1";
            this.searchString = searchQuery;
            if (this.customSettingsFilled && this.bearer) {
                var c = JSON.parse(localStorage.getItem('theme' + this.uid));
                if (c != null) {
                    this.filterToRight = c.filters;
                    if (c.activeTabIndex != 'all' && c.activeTabIndex != undefined) {
                        this.active = c.activeTabIndex;
                        this.defaultTab = c.activeTabIndex;
                        var filterValue = '[{"type":"_index="filter":["' + c.activeTabIndex + '"]}]';
                        this.selectedTypeFilter = filterValue;
                    }
                    if (c.hideTitle == true) {
                        this.hiddenKeys.push("Title");
                    }
                    if (c.hideSummary == true) {
                        this.hiddenKeys.push("Summary");
                    }
                    if (c.hideMetadata == true) {
                        this.hiddenKeys.push("Metadata");
                    }
                    if (c.hideUrl == true) {
                        this.hiddenKeys.push("Url");
                    }
                    if (c.hideIcon == true) {
                        this.hiddenKeys.push("Icon");
                    }
                    if (c.hideTag == true) {
                        this.hiddenKeys.push("Tag");
                    }
                }
                this.caller = false;
                this.setFlag = true;
                this.getData(null, 'search');
            }
        } else {
            this.customSettingErrorMessage = 'Please configure your SearchUnify and try again.';
        }
    }
    getURLParameter(param) {
        var m = window;
        var s = m.location.href; //Change for IE/Edge
        var result;
        let str = s;
        if (window.location.hash != "") {
            str = s.slice(0, s.indexOf(window.location.hash));
        }
        result = decodeURIComponent((new RegExp('[#|s?|&]' + param + '=' + '([^&;]+?)(&|#|;|$)').exec(decodeURIComponent(s)) || [, ""])[1].replace(/\+/g, '%20'))
        return result;
    }

    onCheck(event) {
    }
    setClearFilters() {
        if (JSON.parse(this.selectedTypeFilter || "[]").length || this.exactPhrase != "" || this.withOneOrMore != "" || this.withoutTheWords != "") {

            //Code Added by fresher
            this.sArr = this.selectedTypeFilter;
            if (this.keywordForSources.exec(this.arr) !== null) {
                this.keywordForSources = this.keywordForSources.exec(this.sArr).index;
            }
            if (this.keywordForPublicationStatus.exec(this.arr) !== null) {
                this.keywordForPublicationStatus = this.keywordForPublicationStatus.exec(this.sArr).index;
            }
            if (this.keywordForArticleNumber.exec(this.arr) !== null) {
                this.keywordForArticleNumber = this.keywordForArticleNumber.exec(this.sArr).index;
            }
            if (this.keywordForId.exec(this.arr) !== null) {
                this.keywordForId = this.keywordForId.exec(this.sArr).index;
            }
            if (this.keywordForTag.exec(this.arr) !== null) {
                this.keywordForTag = this.keywordForTag.exec(this.sArr).index;
            }
            if (this.keywordForArticleNumber != 0 || this.keywordForId != 0 || this.keywordForPublicationStatus != 0 || this.keywordForSources != 0 || this.keywordForTag != 0) {
                this.eitherOfTheHeadersIsSelected = true;
            }

            if (this.exactPhrase != "" || this.withOneOrMore != "" || this.withoutTheWords != "") {
                this.eitherOfThreeIsTrue = true;
            }
            if (this.eitherOfThreeIsTrue && this.eitherOfTheHeadersIsSelected) {
                this.showClearFiltersButton = true;
            }
            //Code added by fresher(ending here)
            else
                if (this.eitherOfThreeIsTrue) {
                    this.showClearFiltersButton = true;
                }
                else {
                    for (let i = 0; i < JSON.parse(this.selectedTypeFilter).length; i++) {
                        if (JSON.parse(this.selectedTypeFilter)[i].filter || JSON.parse(this.selectedTypeFilter)[i].children || this.exactPhrase != "" || this.withOneOrMore != "" || this.withoutTheWords != "") {
                            this.showClearFiltersButton = true;
                        } else {
                            this.showClearFiltersButton = false;
                        }
                    }
                }
        } else {

            this.showClearFiltersButton = false;
        }
    }
    clearFilters() {
        this.selectedTypeFilter = '';
        this.from = 0;
        this.pageNum = "1";
        this.counter = 1;
        this.viewAll = false;
        this.suggestionLength = false
        this.exactPhrase = '';
        this.withOneOrMore = '';
        this.withoutTheWords = '';
        this.advanceSearchEnabled = false;
        this.showClearFiltersButton = false;
        if (this.customSettingsFilled && this.bearer) {
            this.getData(null, 'clearFilter');
        }
        this.active = "all_Content";
    }
    setStickyFacets(setArray){
        let self = this;
        return new Promise(function(resolve, reject){
            var stickyArray= JSON.parse (JSON.stringify(setArray));
            var selectedStickyFilter =stickyArray.filter(function (x) {
                x.tempValues = [];
                if (x.key == '_index') {
                    x.values.map(function (o) {
                        // if (o.Contentname == self.active) {
                        //     o.sticky_name = o.displayName.toUpperCase();
                        //     x.tempValues.push(o)
                        // }
                        if (o.selected){
                            o.sticky_name = o.displayName.toUpperCase();
                            x.sticky_label = "Tab";
                            x.tempValues.push(o)
                        }
                    });
                }
                    
                x.values.map(function (f) {
                    if (f.selected && f.parent != '_index') {
                        f.sticky_name = f.displayName || f.Contentname;
                        x.tempValues.push(f);
                    }
                    if (f.childArray && (x.order !=0 ||  (!f.merged || (f.merged && f.showChild != 0))) ) {
                        self.checkChildArray(x.tempValues, f.childArray, (f.displayName || f.Contentname));
                    }
                })
                
                if (x.tempValues.length) {
                    x.values = JSON.parse(JSON.stringify(x.tempValues || []));
                    delete x.tempValues;
                    return x;
                }
            });
    
            var exactPhrase = self.exactPhrase;
            var withOneOrMore = self.withOneOrMore;
            var withoutTheWords = self.withoutTheWords;
            exactPhrase ? selectedStickyFilter.unshift({ "key": 'exactPhrase', "label": "With the exact phrase", "values": [{ "selected": true, "Contentname": exactPhrase, "sticky_name" : exactPhrase }] }) : '';
            withOneOrMore ? selectedStickyFilter.unshift({ "key": 'withOneOrMore', "label": "With one or more words", "values": [{ "selected": true, "Contentname": withOneOrMore, "sticky_name": withOneOrMore }] }) : '';
            withoutTheWords ? selectedStickyFilter.unshift({ "key": 'withoutTheWords', "label": "Without the words", "values": [{ "selected": true, "Contentname": withoutTheWords, "sticky_name": withoutTheWords }] }) : '';
            var stickyFilter_label = selectedStickyFilter.map(function (c) { return c.label });
            self.exactPhrase = exactPhrase;
            self.withOneOrMore = withOneOrMore;
            self.withoutTheWords = withoutTheWords;

            var stickyFilter_label = selectedStickyFilter.map(function(c) { return c.label });
            self.stickyFilter_label = stickyFilter_label;
            self.activeSticky = stickyFilter_label[0];
            self.selectedStickyFilter = selectedStickyFilter;
            self.stickyClass = selectedStickyFilter.length > 2, 'su__selectedFilter-collapse', '' ;
            resolve();
        })  
    }

    checkChildArray(tempValues, childArray, name) {
        let self = this;
        childArray.forEach(function (y) {
            if (y.selected) {
                y.pathString = JSON.stringify(y.path);
                y.sticky_name = name + " > " + (y.displayName || y.Contentname);
                tempValues.push(y);
            }
            if (y.childArray) {
                self.checkChildArray(tempValues, y.childArray, name + " > " + (y.displayName || y.Contentname));
            }
        });
    }
    selectedSticky(event) {
        let label = event.target.getAttribute("data-label");
        this.activeSticky = label;
        var a = document.querySelectorAll("[data-id$='_sticky']");
    }

    setPagination(pageSize, pageNum) {
        var pageNumber = parseInt(pageNum);
        var total = this.totalResults;
        this.totalPages = Math.ceil(total / pageSize);
        var pageList = [];
        if (this.totalResults == 0) {
            pageList.push(pageNumber - (pageNumber - this.counter), (pageNumber + 1) - (pageNumber - this.counter), (pageNumber + 2) - (pageNumber - this.counter), (pageNumber + 3) - (pageNumber - this.counter))
            this.paginationList = pageList;
        }
        if (this.totalPages > 0) {
            if (this.totalPages <= 4) {
                var counter = 1;
                for (; counter <= this.totalPages; counter++) {
                    pageList.push(counter);
                }
                this.paginationList = pageList;
            }
            else {
                if (pageNumber == this.counter + 4) {
                    this.counter = pageNumber;
                }
                if (this.counter == pageNumber) {
                    for (var i = pageNumber; i <= this.totalPages; i++) {
                        if (i == pageNumber + 4) {
                            this.endPointPagination = i - 1;
                            break;
                        }
                        if ((i) == this.totalPages) {
                            pageList.push(i);
                            this.endPointPagination = this.totalPages;
                            break;
                        }
                        pageList.push(i);
                    }
                    this.paginationList = pageList;
                }
                else {
                    if (pageNumber - (pageNumber - this.counter) == this.endPointPagination) {
                        pageList.push(pageNumber - (pageNumber - this.counter));
                    }
                    else if ((pageNumber + 1) - (pageNumber - this.counter) == this.endPointPagination) {
                        pageList.push(pageNumber - (pageNumber - this.counter), (pageNumber + 1) - (pageNumber - this.counter))

                    }
                    else if ((pageNumber + 2) - (pageNumber - this.counter) == this.endPointPagination) {
                        pageList.push(pageNumber - (pageNumber - this.counter), (pageNumber + 1) - (pageNumber - this.counter), (pageNumber + 2) - (pageNumber - this.counter))
                    }
                    else if ((pageNumber + 3) - (pageNumber - this.counter) == this.endPointPagination) {
                        pageList.push(pageNumber - (pageNumber - this.counter), (pageNumber + 1) - (pageNumber - this.counter), (pageNumber + 2) - (pageNumber - this.counter), (pageNumber + 3) - (pageNumber - this.counter))
                    }
                    this.paginationList = pageList;
                }
            }
        }
        this.disableEnableActions(pageNumber);
    }
    disableEnableActions(pageNumber) {
        let buttons = this.template.querySelectorAll('[data-id="paginationButton"]');
        buttons.forEach(bun => {
            if (bun.value == pageNumber) {
                bun.style = "background:#0070d2;color:#fff";

            } else {
                bun.style = "background:white;color:#808080";
            }
        });
    }
    toggleResultsPerPage() {
        this.showPageSize = !this.showPageSize;
        this.showPageClass = this.showPageSize ? 'su__d-md-block' : 'visibilityHidden';
    }

    pageChange() {
        if (this.counter == parseInt(this.pageNum)) {
            this.counter = this.counter - 4;
            this.endPointPagination = this.counter + 3;
        }
        this.from = (this.pageNum - 1) * this.pageSize;
        this.pageNum = parseInt(this.pageNum) - 1;
        this.setPagination(this.pageSize, this.pageNum);

        if (this.customSettingsFilled && this.bearer)
            this.getData(null, 'pageChange');
        this.goToTopFunc();
    }

    nextPage() {
        this.pageNum = parseInt(this.pageNum) + 1;
        if (this.pageNum == this.endPointPagination + 1) {
            this.counter = this.pageNum;
        }
        this.from = (this.pageNum - 1) * this.pageSize;
        this.setPagination(this.pageSize, this.pageNum)
        if (this.customSettingsFilled && this.bearer)
            this.getData(null, 'pageChange');
        this.goToTopFunc();
    }


    processMe(button) {
        this.pageNum = parseInt(button.target.value);
        if (this.customSettingsFilled && this.bearer)
            this.getData(null, 'pageChange');
        this.goToTopFunc();
    }
    goToTopFunc() {
        var goToTop = this.template.querySelector('[data-id="searchUnifyContainer"]');
        if(goToTop) {
            window.scroll({
                top: goToTop.offsetTop,
                behavior: "smooth"
            });
        } else {
            document.body.scrollTop = 0;
            document.documentElement.scrollTop = 0;
        }
    }
    handleChange(event) {
        this.sortByCheck = event.detail.value;
        this.from = 0;
        this.pageNum = "1";
        this.counter = 1;
        this.setPagination(this.pageSize, this.pageNum)
        if (this.customSettingsFilled && this.bearer)
            this.getData(null, 'pageChange');
    }

    currentLangLabel(lngCode) {
        var translations = (this.translationObj);
        if (translations.hasOwnProperty(lngCode)) { }
        else { lngCode = 'en'; }
        if (translations.hasOwnProperty(lngCode)) {
            var languageObj = translations[lngCode];
            var langMap = languageObj['mapping'];
            fireEvent(null, "labelchange"+this.eventCode, '');
        }
        else {
            console.log('not exist');
        }
    }

    gridView() {
        this.gridDisplay = true;
    }
    listView() {
        this.gridDisplay = false;
    }
    // mergeFilterClicked(arg, arg2, arg3) { }

    ConversionMethod(e) {
        var p = this.template.querySelector('.underline');
        var currentDataId = p.getAttribute('data-id')
        var getIds = this.template.querySelector('.linkadd');
        getIds = getIds.href;
        var arr = getIds.split('/');

        window.gza("conversion",
            {
                index: '',
                type: arr[5],
                id: currentDataId,
                rank: '',
                convUrl: '',
                pageSize: '',
                page_no: '',
                autoTuned: '',
                sc_analytics_fields: ''
            });
    }
    conversionViaLink() {

        window.gza("conversion",
            {
                index: '',
                type: '',
                id: '',
                rank: '',
                convUrl: '',
                pageSize: '',
                page_no: '',
                autoTuned: '',
                sc_analytics_fields: ''
            });
    }
    updateContactHandler(event) {
        this.responseListData = [...event.detail.records]
    }
    handleCollapseSummary(event){
        let collapse = event.target.dataset.collapse;
        let index = event.target.dataset.index;
        this.responseListData[index].showLess = parseInt(collapse) ? false : true;
        this.responseListData[index].record.showMore = parseInt(collapse) ? true : false;
    }
    stringChangedFromBanner(searchString){
        this.searchString = searchString.trim().length ? searchString : this.caseSubjectVal;
    }
}