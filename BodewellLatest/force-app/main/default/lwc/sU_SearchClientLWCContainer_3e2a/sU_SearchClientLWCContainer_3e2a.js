import { LightningElement, api, wire, track } from 'lwc';
import getConsoleCustomSettings from '@salesforce/apex/su_vf_console.SUVFConsoleController.getConsoleCustomSettings';
import getCustomSettings from '@salesforce/apex/su_vf_console.SUVFConsoleController.getCustomSettings';
import sendEmail from '@salesforce/apex/su_vf_console.SUVFConsoleController.sendEmail';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import caseNumber from '@salesforce/schema/Case.CaseNumber';
import caseSubject from '@salesforce/schema/Case.Subject';
import { CurrentPageReference } from 'lightning/navigation';
import checkArticle from '@salesforce/apex/su_vf_console.SUVFConsoleController.checkArticle';
import UserId from '@salesforce/user/Id';
import { registerListener, fireEvent, mergeFilters, updateTranslation, translationObject } from 'c/supubsub';
const DELAY = 300;
const NUM_OF_TABS = 3;
/*
managed package 1.35
https://login.salesforce.com/packaging/installPackage.apexp?p0=04t7F000005R2p9
*/
export default class SU_SearchClientLWCContainer extends NavigationMixin(LightningElement) {
    currentCaseId;
    previousCaseId;
    isUtility = false;
    // keyElement;
    advSearchFilter = [];
    //pic = pinIcon;
    @api height;
    @api utilityWidth = 0;
    @api utilityTop = 0;
    @api recordIddFromUtility;
    previous = '';
    previousRecordId = ''
    @api caseSubject_inUtilityBar;
    mergeResults;
    @track titleToShow;
    @track mergeSourcesTypeIndex;
    @api casePreSelectedValues; // to get field values from SUConsoleLWC for utility bar
    previousCaseSUbject = '';
    @track showModal = false;
    @track JWTToken;
    @track sourceFacet = true;
    @track currentLanguageSelected = 'English'
    @track defaultLang = 'en';
    @track currentCaseSubject;
    @track currentUserId = UserId;
    @track showPagination;
    // globeImg = globeIcon
    @track containerRightCoordinate;
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
    @track goToTopContainer;
    @api recordId;
    @track resultTime;
    @track box;
    @api pageSize = 10;
    @api searchString;
    @api searchPageOnFailure;
    @api noResultsMsg;
    @api allAreHidden;
    @api collapseSearchFilters;
    @api showContentSourceTab;
    @api displayListView;
    @api collapsSummary;
    @track bigscreen = false;
    @api caseSubjectVal;
    @track pageNum = 1;
    @track contentSourceTab = true;
    @api multiVersion = false;
    @track searchQuery;
    @track s3EndPoint = 'https://d3uolsfk4tmkxs.cloudfront.net/b2d26c413c3b97cc1680df03fd6153f6/search-clients/3e2aff98-2630-11ea-af05-02a11824e6ec';
    @track endPoint = '';
    @track bearer = '';
    @track uid = '3e2aff98-2630-11ea-af05-02a11824e6ec';
    @track linkSharingOptions = [];
    suResultsLoader = false;
    suResultsLoaderImg = this.s3EndPoint + '/Assets/su-results-loader.gif';
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
    @track resultSectionContainer ;
    @track showLanguageDropdown = false;
    @track showViewedResults = 'su__h-100';
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
    hiddenFacet = false;
    maxLength = 100;
    hideFacetsValues = '';
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
    @track dataSectionClass = "";
    @track fullWidth = true;
    @track resizeclass = 'su__d-none';
    @track resizeclassFilter = 'su__d-none';
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
    copySplicedData = [];
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
    showAgentHelperTab = false;
    isAgentHelperEnabled = false;
    agentHelperConfiguration;
    showTabsPopup = false;
    onFilterButtonClick = true;
    eventCode;
    containerXCoordinate;
    isFreshSearch = -1;
    resultCountReturned;
    hideDataSection = false;
    customHeight;
    @api caseUtilitySub;
    @api mergeResultHits;
    @track caseIdExists;
    previouscaseUtilitySub = '';
    maincontainerwidth;
    firstLoad = true;
    translationObject;
    myCustomFields = [caseNumber, caseSubject]; // array to store all case fields that need to be queried
    myCustomSettings; // object that stores all custom settings of console
    preSelectedFilters; // object that stores all preSelected field values
    @wire(getCustomSettings)
    handlemyCustomSettings({ data, error }) {
        if (data) {
            this.myCustomSettings = data;
            if (data.su_vf_console__FilterFieldName__c)
                this.myCustomFields = this.myCustomFields.concat(data.su_vf_console__FilterFieldName__c.split(',').map(f => 'Case.' + f));
        }
    };
    firstTimeLoad = true;

    errorCallback(error, stack) {
        console.log("-----------error-----------stack-----------", error, stack);
    }
    openAgentHelper() {
        this.showAgentHelperTab = true;
    }
    showSearchConsole() {
        this.showAgentHelperTab = false;
    }
    get componentStyle() {
        return this.height ? `height:${this.height}px;` : 'height:100%';
        
    }
    get Style(){
        return `height:100%`;
    }
    get activeCaseNumber() {
        return this.currentCaseNumber && this.showCaseNumber ? true : false;
    }
    get eventClass() {
        return 'su__searchUnifyContainer su__h-100 su__' + this.eventCode;
    }
    renderedCallback() {
        this.caseIdExists = this.currentCaseNumber ? true : false;
        if (this.totalResults > 10) {
            this.showPagination = true
        } else {
            this.showPagination = false
        }
        // Initially set value in  caseId in local Storage
        // if(window.localStorage.getItem("previousCaseId")==null && this.recordId) {
        //     console.log('---inside 1st case window.localStorage.getItem("previousCaseId")',window.localStorage.getItem("previousCaseId"));
        //    window.localStorage.setItem("previousCaseId",this.recordId);
        //    this.previousCaseId = this.recordId;
        // }
        // //on switching tab
        // if(window.localStorage.getItem("previousCaseId") != this.recordId) {
        //     this.previousCaseId=window.localStorage.getItem("previousCaseId");
        //     window.localStorage.setItem("previousCaseId", this.recordId);
        //     console.log('---inside 2nd case window.localStorage.getItem("previousCaseId"): ',window.localStorage.getItem("previousCaseId"));
        // }
        if (this.template.querySelector('.suContainer')) {
            this.containerXCoordinate = this.template.querySelector('.suContainer').getBoundingClientRect().x;
            this.containerRightCoordinate = this.template.querySelector('.suContainer').getBoundingClientRect().right;
        }
        if (this.previouscaseUtilitySub != this.caseUtilitySub) {
            this.searchString = this.caseUtilitySub;
            this.previouscaseUtilitySub = this.searchString;
        }
        if (this.caseSelection && this.previous != this.caseSubject_inUtilityBar && this.recordIddFromUtility && this.caseSubject_inUtilityBar && this.recordId != this.recordIddFromUtility) { //isUtility   && this.recordId==undefined{

            // if(this.previousCaseId && this.previousCaseId != 'undefined'){
            this.previous = this.caseSubject_inUtilityBar;
            this.searchString = this.caseSubject_inUtilityBar;
            this.recordId = this.recordIddFromUtility; // id received from SUConsoleLWC component
            this.previousCaseId = this.recordId;
            console.log('----inside sending search hit this.previousCaseId: ', this.previousCaseId);
            //this.handleSearchPageEvent({searchString:this.searchString,isFreshSearch: -1});//{ searchString: this.searchString2, isFreshSearch: -1}
            this.preSelectedFilters = this.casePreSelectedValues || {};
            this.setPreSelectedFilters().then(() => {
                this.handleSearchPageEvent({ searchString: this.searchString, isFreshSearch: -1 });
                fireEvent(null, 'setsearchstring' + this.eventCode, '');
            });
            // }

        }
        if (this.firstLoad && this.template.querySelector('div.su__' + this.eventCode) && this.template.querySelector('div.su__' + this.eventCode).clientWidth > 0) {
            window.addEventListener('resize', this.resizeCheck.bind(this));
            this.applyClasses();
            this.resizeCheck();
            this.firstLoad = false;
        }
        this.goToTopContainer = this.template.querySelector('[data-id="searchUnifyContainer"]');
        if(this.template.querySelector('[data-id="searchUnifyContainerResultSection"]')){
            this.resultSectionContainer = this.template.querySelector('[data-id="searchUnifyContainerResultSection"]');
        }
    }
   
    applyClasses() {
        let e = this.template.querySelector('div.su__searchUnifyContainer');
        this.dataSectionClass = "";
        if (this.template.querySelector('div.su__' + this.eventCode)) {
            this.maincontainerwidth = this.template.querySelector('div.su__' + this.eventCode).clientWidth;
        }
        if (this.maincontainerwidth < 450) {
            e.className = 'su__searchUnifyContainer su__' + this.eventCode + ' su__width-320';
            fireEvent(null, 'bigscreen' + this.eventCode, false);
        }
        else if (this.maincontainerwidth < 600) {
            e.className = 'su__searchUnifyContainer su__' + this.eventCode + ' su__width-320 su__width-450';
            fireEvent(null, 'bigscreen' + this.eventCode, false);
        }
        else if (this.maincontainerwidth < 1200) {
            e.className = 'su__searchUnifyContainer su__' + this.eventCode + ' su__width-600';
            fireEvent(null, 'bigscreen' + this.eventCode, false);
        }
        else if (this.maincontainerwidth > 1200) {
            e.className = 'su__searchUnifyContainer su__' + this.eventCode + ' su__width-800';
            fireEvent(null, 'bigscreen' + this.eventCode, true);
        }

    }

    resizeCheck = () => {
        clearTimeout(this.timeout);
        this.timeout = setTimeout(() => {
            this.applyClasses();
            this.fullWidthResults();
        }, 10);
    }

    fullWidthResults = (bigscreenevent) => {
        this.resizeCheck();
        if (bigscreenevent === false) {
            this.resizeclass = 'su__d-none';
            this.resizeclassFilter = 'su__d-none'

        }
        else if ((bigscreenevent === true && !this.fullWidth) || (bigscreenevent === true && this.totalResults !== 0)) {
            this.resizeclass = 'su__d-block ';
            this.resizeclassFilter = 'su__d-block su__w-25 ';
            this.hideDataSection = false;
            this.dataSectionClass = 'su__w-75';
            this.bigscreen = true;
        }
        if (bigscreenevent && this.aggregationsData && this.aggregationsData.length !== 0) {
            this.fullWidth = true
            for (let index = 1; index < this.aggregationsData.length; index++) {
                if (this.aggregationsData[index].values.length) {
                    this.fullWidth = false;
                }
            }
        }
        if ((this.fullWidth && bigscreenevent) || (bigscreenevent && this.totalResults == 0)) {
            this.dataSectionClass = "su__pops"
            this.resizeclassFilter = 'su__d-none';

        }
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

    get shouldDisplay() {
        return this.index = 0;
    }

    get options() {
        return [
            { label: 'Sort By Relevance', value: '_score' },
            { label: 'Sort By Created Date', value: 'post_time' },
        ];
    };

    @wire(getRecord, { recordId: '$recordId', fields: '$myCustomFields' })
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
            this.preSelectedFilters = this.result;
        }
        if (error) {
        }
    }

    @wire(CurrentPageReference) pageRef;
    constructor() {
        super();
        Promise.all([
            loadScript(this, this.s3EndPoint + '/an.js'),
            loadStyle(this, this.s3EndPoint + '/main.css')
        ]).then(() => {
            sendEmail({ userId: this.currentUserId }).then(result => {
                this.currentUserEmail = result;
                this.endPoint = window.scConfiguration.search;
                window.GzAnalytics.setUser(this.currentUserEmail);
                if (window.scConfiguration.resultSharingOptions && window.scConfiguration.resultSharingOptions.length !== 0) {
                    this.linkSharingOptions = window.scConfiguration.resultSharingOptions;
                }
                this.agentHelperConfiguration = window.scConfiguration.agentHelperConfiguration || {};
                this.isAgentHelperEnabled = this.agentHelperConfiguration && this.agentHelperConfiguration.enabled;
                this.getCommunityCustomSettings();
                if (window.scConfiguration.language) {
                    var selectedLanguages = JSON.parse(window.scConfiguration.language).config;
                    this.currentLanguageSelected = selectedLanguages;
                    updateTranslation(window.scConfiguration.language || {});
                    this.translationObject = translationObject;
                }
            }).catch(error => {
                this.error = error;
                console.log(error);
            });
        }).catch(error => {
            if (error) {
                console.log('body error');
                console.log(error);
            }
        });
    }
    connectedCallback() {
        this.eventCode = Math.floor(Math.random() * (10000 - 1 + 1)) + 1;
        if (this.caseSubject_inUtilityBar) {
            this.searchString = this.caseSubject_inUtilityBar;
            this.preSelectedFilters = this.casePreSelectedValues || {};
        }
        this.bookmarkSearches = JSON.parse(localStorage.getItem('bookmark_searches_' + this.uid) || "[]");
        if (this.bookmarkSearches.length > 0) {
            this.isBookmarkExist = true;
            this.showBookMark = true;
        }
        else {
            this.isBookmarkExist = false
            this.showBookMark = false;
        }
        registerListener('checkType' + this.eventCode, this.checkTypeFromSUSortBy, this);
        registerListener('searchPage' + this.eventCode, this.handleSearchPageEvent, this);
        registerListener('getSearchResults' + this.eventCode, this.getData, this);
        registerListener('SID' + this.eventCode, this.sidValue, this);
        registerListener('PageClicked' + this.eventCode, this.handleFooterchat, this);
        registerListener('advancePagination' + this.eventCode, this.handleAdvanceSearch, this);
        registerListener('nextpageclicked' + this.eventCode, this.nextPageClicked, this);
        registerListener('selectchange' + this.eventCode, this.selectChangeMethod, this);
        registerListener('previousbuttoncalled' + this.eventCode, this.previousMethodCalled, this);
        registerListener('processme' + this.eventCode, this.processMeCalled, this);
        registerListener('previousPagesDots' + this.eventCode, this.previousPagesDotsMethod, this);
        registerListener('nextPageDots' + this.eventCode, this.nextDotClicked, this);
        registerListener('languageselected' + this.eventCode, this.langSelecetedMethod, this);
        registerListener('sendLinkEvent' + this.eventCode, this.handleSendLinkEvent, this);
        registerListener('copyLinkEvent' + this.eventCode, this.handleCopyLinkEvent, this);
        registerListener('attachToCaseEvent' + this.eventCode, this.handleAttachToCaseEvent, this);
        registerListener('filterSectionEvent' + this.eventCode, this.handleFilterSectionEvent, this);
        registerListener('tabclicked' + this.eventCode, this.tabClickedMethod, this);
        registerListener('caseCommentEmailEvent' + this.eventCode, this.handleCaseCommentEmailEvent, this);
        registerListener('savetolocal' + this.eventCode, this.saveToLocalMethod, this);
        registerListener('bookmarklistrequired' + this.eventCode, this.sendBookmarkList, this);
        // registering checkboxSelection event from suFilterSection
        registerListener('checkboxSelectedEvent' + this.eventCode, this.checkboxSelectedEvent, this);
        registerListener('removefromlocalstorage' + this.eventCode, this.removefromlocal, this);
        registerListener('getlanglist' + this.eventCode, this.sendList, this);
        registerListener('advfilterclicked' + this.eventCode, this.showClearFilterMethod, this);
        registerListener('filterChangesEvent' + this.eventCode, this.handleFilterChangesEvent, this);
        // registerListener('dataFromContainer'+this.eventCode, this.handleDataFromSuParent, this);
        registerListener('savedbookmarkclicked' + this.eventCode, this.savedBmarkClicked, this);
        registerListener('clearFilterEvent' + this.eventCode, this.handleClearFilterEvent, this);
        registerListener('clearFilterSecEvent' + this.eventCode, this.handleClearFilterSecEvent, this);
        //registering data from headerSu section
        registerListener('headerSUData' + this.eventCode, this.handleDataFromSU, this);
        registerListener('removeStickyFacetEvent' + this.eventCode, this.handleRemoveStickyFacetEvent, this);
        registerListener('trackAnalytics' + this.eventCode, this.handleTrackAnalytics, this);
        registerListener('clearAllFilters' + this.eventCode, this.clearAllFilters, this);
        registerListener('clearSearch' + this.eventCode, this.handleClearSearch, this);
        registerListener('collapseSummary' + this.eventCode, this.handleCollapseSummary, this);
        registerListener('stringChangedFromBanner' + this.eventCode, this.stringChangedFromBanner, this);
        registerListener('filterClosed' + this.eventCode, this.filterClosed, this);
        registerListener('bigscreen' + this.eventCode, this.fullWidthResults, this);
        this.resizeCheck();


        this.customHeight = 'height: calc(100% - 100px)!important; overflow:auto;'
    }

    filterClosed(event) {
        this.hideDataSection = false;
    }

    handleTrackAnalytics(event) {
        if (event.type == 'search') {
            if (!event.objToSend) { event.objToSend = { 'searchString': this.searchString } }
            event.objToSend = {
                ...event.objToSend,
                responseTime: this.searchResultTime,
                isFreshSearch: this.isFreshSearch == -1 ? true : false,
                result_count: this.resultCountReturned,
                filter: this.searchQuery.aggregations,
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
        if (event.type == 'autocomplete') {
            event.type = 'search';
            event.objToSend.searchString = this.searchString;
        }
        window.gza(event.type, event.objToSend);
    }

    clearAllFilters(event) {
        this.exactPhrase = '';
        this.withOneOrMore = '';
        this.withoutTheWords = '';
        if (!this.totalResults) {
            this.searchString = '';
            fireEvent(null, 'setsearchstring' + this.eventCode, this.searchString);
        }
        this.searchString = !this.totalResults ? this.caseSubjectVal : this.searchString;
    }

    handleRemoveStickyFacetEvent(event) {
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
            if (event.type == '_index') {
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
                this.getData(null, 'filterCheck');
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
                fireEvent(this.pageRef, 'nestedFilter' + this.eventCode, { filter: sr });
            }
        }
    }
    //handle removing sticky facet data
    handleRemoveStickyFacetEvent1(event) {
        if (event.aggregations != null) {
            this.aggregationsData = JSON.stringify(event.aggregations);
            this.checkHere = true;
        }
        if (event.obj != null) {
            if (event.obj.label == 'exactPhrase') {
                this.exactPhrase = event.obj.values;
            }
            if (e.target.dataset.name == 'withOneOrMore') {
                this.withOneOrMore = event.obj.values;
            }
            if (e.target.dataset.name == 'withoutTheWords') {
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
        if (this.template.querySelector('[data-id="filterBlock"]')) {
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
        fireEvent(null, 'setsearchstring' + this.eventCode, p.searchString);
        var footerDataObj = {
            "pageNo": p.pageNo,
            "resultsPerPage": p.resultsPerPage
        };
        fireEvent(null, 'sendpaginationdata' + this.eventCode, footerDataObj);
        var sendToDataSection = {
            "pageNo": p.pageNo,
            "aggregations": p.aggregations
        }
        fireEvent(null, 'sendtodatasection' + this.eventCode, sendToDataSection);
        var sendToSortData = {
            "sortby": p.sortby
        }
        fireEvent(null, 'sendsortdata' + this.eventCode, sendToSortData);
        var advSearchObj = {
            "exactPhrase": p.exactPhrase,
            "withOneOrMore": p.withOneOrMore,
            "withoutTheWords": p.withoutTheWords
        }
        fireEvent(null, 'advsearchdata' + this.eventCode, advSearchObj);
        fireEvent(null, 'languagedata' + this.eventCode, p.language);

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
        fireEvent(null, 'closesavedbmark'+this.eventCode, false);
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
        fireEvent(null, 'showclearfilterbtn' + this.eventCode, this.showClearFiltersButton);
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
        fireEvent(null, 'dataFromContainer' + this.eventCode, dataToBeSentToHeaderSUComponent);
        if (event == 'header')
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
        fireEvent(null, 'langListSend' + this.eventCode, this.currentLanguageSelected);
    }
    removefromlocal(data) {
        this.removeBookmarksList(data);
        fireEvent(null, 'bmarkslist' + this.eventCode, this.bookmarkSearches);
    }
    sendBookmarkList(e) {
        fireEvent(null, 'transssferlist' + this.eventCode, this.bookmarkSearches);
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
    }

    //Adding checkboxSelection event from suFilterSection
    checkboxSelectedEvent(event) {
        this.getData(null, 'pageChange');
    }

    handleCaseCommentEmailEvent(event) {
        window.gza('linkSharingViaEmail', {
            caseId: this.recordId,
            id: event.id,
            caseNumber: this.currentCaseNumber,
            subject: this.currentCaseSubject,
            searchString: this.searchString,
            object: event.objName,
            url: this.url,
            index: event.sourceName,
            title: event.ptitle,
            author: this.currentUserEmail
        });
    }

    handleFilterSectionEvent(event) {
        this.pagingAggregation = event.pagingAggregation;
        this.key = event.key;
        this.searchFilterString = event.searchFilterString;
        this.getData(null, event.searchFilterString);

    }

    handleAttachToCaseEvent(event) {
        this.responseListDataBck = JSON.parse(JSON.stringify(this.responseListData));
        this.responseListData = [];
        this.responseListData = JSON.parse(JSON.stringify(this.responseListDataBck));
        this.responseListData[event.index].showDetachButton = event.attached ? true : false;
        this.responseListData[event.index].showAttachButton = event.attached ? false : !(this.responseListData[event.index].record.merge);
        if (event.childindex >= 0) {
            this.responseListData[event.index].record.hits[event.childindex].showDetachButton = event.attached ? true : false;
            this.responseListData[event.index].record.hits[event.childindex].showAttachButton = event.attached ? false : !(this.responseListData[event.index].record.hits[event.childindex].record.merge);
        }
        window.gza('attachToCaseComment', {
            searchString: this.searchString,
            id: event._id,
            articleId: event.Id || event._id,
            url: event.url,
            t: this.responseListData[event.index] && this.responseListData[event.index].record && this.responseListData[event.index].record.highlight && this.responseListData[event.index].record.highlight.TitleToDisplayString[0] ? this.responseListData[event.index].record.highlight.TitleToDisplayString[0] : this.responseListData[event.index].record.href,
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
            caseNumber: this.currentCaseNumber,
            subject: this.currentCaseSubject,
            searchString: this.searchString || this.currentCaseSubject,
            object: event.objName,
            index: event.sourceName,
            url: event.url,
            title: event.title,
            author: this.currentUserEmail
        });
    }
    langSelecetedMethod(data) {
        this.translationObject = {}
        updateTranslation(window.scConfiguration.language, data);
        this.translationObject = JSON.parse(JSON.stringify(translationObject));
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
        fireEvent(null, 'advsearchstickyfltr' + this.eventCode, this.advSearchFilter);
        this.setPagination(this.pageSize, this.pageNum);
        if (this.customSettingsFilled && this.bearer) {
            this.getData(null, 'pageChange');
        }
    }

    handleFooterchat(event) {
        this.getData(null, 'pageChange');
    }
    handleClearSearch(event) {
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

    saveToLocal(event) {
        var a = JSON.parse(localStorage.getItem('bookmark_searches_' + this.uid) || "[]");
        a.push({
            title: this.bookmarkName,
            href: JSON.stringify(this.searchQuery),
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

    setResults(hits) {
        let KnowledgeArticle = [];
        checkArticle({ caseIdd: this.recordId })
            .then((result) => {
                for (let i = 0; i < result.length; i++) {
                    KnowledgeArticle.push(result[i].KnowledgeArticleId);
                }
                //    Add additional key value pair
                if (hits.length)
                    this.showAttachToCase(hits, KnowledgeArticle);

                this.responseListData = [...this.responseListData];
            })
            .catch((error) => {
                this.error = error;
                console.log("error", error)
            });
    }

    showAttachToCase(hits, knowledgeArticle) {
        hits.forEach((value) => {
            if (knowledgeArticle.indexOf(value.record._id.substring(0, 18)) > -1) {
                value.attached = true;
                value.showAttachButton = false;
                value.showDetachButton = value.record.LinkViaAttachArticle;
            } else {
                value.attached = false;
                value.showAttachButton = value.record.LinkViaAttachArticle && !(value.record && value.record.merge > 0);
                value.showDetachButton = false;
            }
            if (value.record.hits && value.record.hits.length) {
                this.showAttachToCase(value.record.hits, knowledgeArticle)
            }
            else return;
        });
    }

    getData(argument, searchType) {
        this.loading = 'su__loading';
        this.selectedTypeFilter = argument && argument.aggregations ? argument.aggregations : this.selectedTypeFilter;
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
                }
            }

            var startTime = new Date();
            if (runLoader == 'true') {
                if (!this.filterSortingLoading) {
                    this.loadingResult = 0;
                }
            }

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
            var filterData = [];
            if (this.checkHere) {
                filterData = this.aggregationsData;
                this.checkHere = false;
            } else {
                filterData = this.selectedTypeFilter;
            }
            var arr = [];
            filterData = typeof filterData == 'string' ? filterData : JSON.stringify(filterData);
            this.selectedTypeFilter = typeof this.selectedTypeFilter == 'string' ? this.selectedTypeFilter : JSON.stringify(this.selectedTypeFilter);
            var filterSelect = {
                "Contentname": filterData && JSON.parse(filterData).length != 0 && JSON.parse(filterData)[0].filter ? JSON.parse(filterData)[0].filter[0] : null,
                "checked": true
            }

            if (filterData && filterData.length != 0 && filterSelect.Contentname && filterSelect.Contentname.indexOf("merged_") > -1) {
                var data = JSON.parse(filterData);
                data[0].filter = arr;
                if (this.checkHere) {
                    filterData = this.aggregationsData;
                    this.checkHere = false;
                } else {
                    filterData = JSON.stringify(data);
                }
            }

            this.bookmark_list = false;
            this.viewSavePopup = false;
            this.viewConfirmPopup = false;

            try {
                if (filterData && JSON.parse(filterData).length != 0) {
                    this.multiVersion = false;
                } else {
                    this.multiVersion = true;
                }
            } catch (error) {
                console.log(error)
            };
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
                "aggregations": filterData ? JSON.parse(filterData) : [],
                "referrer": document.referrer,
                "recommendResult": "",
                "indexEnabled": this.contentSourceTab,
                "sid": window._gr_utility_functions.getCookie("_gz_taid"),
                "cookie": '',
                "uid": this.uid,
                "language": localStorage.getItem('language') || 'en',
                "getAutoTunedResult": true,
                "versionResults": this.multiVersion,
                "mergeSources": this.multiVersion,
                "caseId": this.recordId
            });
            let query = JSON.parse(data);
            this.searchQuery = query;
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
                                this.mergeResultHits = result.result.hits;
                                this.loading = '';
                                fireEvent(this.pageRef, 'API_RESULT' + this.eventCode, { result, querySent: data, selectedTypeFilter: this.selectedTypeFilter });
                                if (this.exactPhrase !== "" || this.withOneOrMore !== "" || this.withoutTheWords !== "") {
                                    this.advancedSearchSelected = true;
                                } else {
                                    this.advancedSearchSelected = false;
                                }
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
                                this.showViewedResults = result.searchClientSettings.ViewedResults == 1 ? 'su__viewed-results su__h-100' : 'su__h-100';
                                this.hiddenFacet = result.searchClientSettings.hiddenFacet && result.searchClientSettings.hiddenFacet.length != 0 ? true : false;
                                this.mergeResults = result.searchClientSettings.mergeSources ? true : false;
                                this.titleToShow = result.searchClientSettings.mergeSourcesTypeIndex ? true : false;

                                try {
                                    if (this.mergeResults && JSON.parse(data).mergeSources) {
                                        this.resultsInAllContentSources = true;
                                        this.mergeSourcesTypeIndex = this.titleToShow ? true : false;
                                    } else {
                                        this.resultsInAllContentSources = false;
                                    }
                                } catch (error) {
                                    console.log(error)
                                }

                                if (this.hiddenFacet) {
                                    this.hideFacetsValues = {
                                        hiddenFacet: this.hiddenFacet,
                                        values: result.searchClientSettings.hiddenFacet
                                    }
                                }
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
                                if (!this.filterSorting) this.handleTrackAnalytics({ type: 'search' });
                                var aggrData = result.aggregationsArray;

                                // merge facet changes
                                if (result.merged_facets && result.merged_facets.length) {
                                    this.mergedArray = JSON.parse(result.merged_facets || '[]');
                                    let self = this;
                                    this.mergedArray.forEach(function (o) {
                                        mergeFilters(o, aggrData, false, self);
                                    });
                                }
                                // All Content hide Filters
                                var found = false;
                                if (this.hideFacetsValues && this.hideFacetsValues.hiddenFacet) {
                                    aggrData.forEach((agg, index) => {
                                        if (aggrData[0].values && aggrData[0].values.length !== 0) {
                                            aggrData[0].values.forEach(elemet => {
                                                if (elemet.selected) {
                                                    found = true;
                                                }
                                            });
                                        }
                                        if (!found) {
                                            this.hideFacetsValues.values.forEach(val => {
                                                if (agg.key == val) {
                                                    Object.assign(aggrData[index], { 'values': [] });
                                                }
                                            });
                                        }
                                    });
                                }
                                let hiddenAggLength = aggrData.filter((f, index) => index != 0 || !f.values || !f.values.length)
                                if (this.hideFacetsValues && this.hideFacetsValues.hiddenFacet && (this.active == 'all_Content' || (Array.isArray(this.active) && !this.active.length))) {
                                    if (hiddenAggLength.length == this.hideFacetsValues.values.length) {
                                        this.allAreHidden = true;
                                    }
                                }
                                else {
                                    this.allAreHidden = false;
                                }
                                // this.keyElement = aggrData[0].key;
                                this.setArray = aggrData;
                                this.searchSummaryLength = result.searchClientSettings.minSummaryLength;
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
                                if (result.result.hits && result.result.hits.length) {
                                    this.manipulateSearchHits(result.result.hits, result.searchClientSettings)
                                    this.responseListData = result.result.hits;
                                }

                                if (this.totalResults == 0) {
                                    this.noResultMsg = "No results found. Kindly search with some other keywords";
                                }

                                this.setStickyFacets(this.setArray);
                                this.setFilters(this.setArray);
                                this.fullWidthResults();

                                this.setClearFilters();
                                if (result.result && result.result.hits && result.result.hits.length) {
                                    this.setResults(result.result.hits);
                                }
                                this.setPagination(this.pageSize, this.pageNum);
                                this.handleDataFromSU();
                                this.componentLoaded = true;//@@@@
                                this.setFlag = false;//@@@@
                                if (!filterData || !filterData.length) fireEvent(this.pageRef, "clearFilterDataEvent" + this.eventCode, null);
                                fireEvent(null, 'setAggregationsData' + this.eventCode, this.aggregationsData);
                                this.suResultsLoader = true;
                            }
                        }
                    }
                }
            };
            // }
        }
    }

    manipulateSearchHits(hits, searchClientSettings) {
        for (var i = 0; i < hits.length; i++) {
            if (hits[i].highlight.TitleToDisplay[0] == null || hits[i].highlight.TitleToDisplay[0] == '') {
                Object.assign(hits[i], { 'highlightTitleToDisplay': true });
            } else {
                Object.assign(hits[i], { 'highlightTitleToDisplay': false });
            }
            if (hits[i].highlight.TitleToDisplayString[0]) {
                Object.assign(hits[i], { 'highlightTitleToDisplayString': hits[i].highlight.TitleToDisplayString[0] });
            } else {
                Object.assign(hits[i], { 'highlightTitleToDisplayString': null });
            }
            if (hits[i]._id != null) {
                Object.assign(hits[i], { 'dataHitscollapseVersionIconID': 'collapseVersion-2-' + hits[i]._id + '_icon' });
                Object.assign(hits[i], { 'dataHitscollapseVersionToggleIconID': 'collapseVersion-2-' + hits[i]._id + '_toggleIcon' });
                Object.assign(hits[i], { 'collapseVersionDataId': 'collapseVersion-2-' + hits[i]._id });
                Object.assign(hits[i], { 'collapseVersionOverlayId': 'collapseVersion-2-' + hits[i]._id + '_overlay' });
            }
            else {
                Object.assign(hits[i], { 'dataHitscollapseVersionIconID': null });
                Object.assign(hits[i], { 'dataHitscollapseVersionToggleIconID': null });
                Object.assign(hits[i], { 'collapseVersionDataId': 'collapseVersion-2-' + hits[i]._id });
                Object.assign(hits[i], { 'collapseVersionOverlayId': 'collapseVersion-2-' + result[i]._id } + '_overlay');
            }
            if (this.summaryCollapsible && hits[i].highlight.SummaryToDisplay.join('').length > (this.maxlength + hits[i].highlight.SummaryToDisplay.length * 5)) {
                hits[i].showMore = true;
                hits[i].highlight.SummaryToDisplayMax = hits[i].highlight.SummaryToDisplay.join('#').split('#');
                hits[i].highlight.SummaryToDisplay = hits[i].highlight.SummaryToDisplay.join('#').substring(0, this.maxlength).split('#');
            } else hits[i].showMore = false;
            if (this.linkSharingOptions && this.linkSharingOptions.length) {
                var foundObj = this.linkSharingOptions.filter((r) => r.selected_object == hits[i].objName && r.content_source_label == hits[i].sourceLabel)
                foundObj.forEach(obj => {
                    if (obj.result_action_id == 1)
                        hits[i].LinkViaEmail = obj.status;
                    if (obj.result_action_id == 2)
                        hits[i].LinkViacaseComment = obj.status;
                    if (obj.result_action_id == 3)
                        hits[i].LinkViaAttachArticle = obj.status;
                    hits[i].merge = obj.merge;
                    hits[i].shareResultLink = hits[i].LinkViaEmail || hits[i].LinkViacaseComment;

                })
            }
            if(hits[i].icon){
                Object.assign(hits[i], { 'iconPresent': true });
            }else {
                Object.assign(hits[i], { 'iconPresent': false });
            }
            if (hits[i].bypass_filter) {
                hits[i].autotuned = false;
            }
            if (hits[i].autotuned) {
                Object.assign(hits[i], { 'autotuned': true });
            } else {
                Object.assign(hits[i], { 'autotuned': false });
            }
            if (hits[i] && hits[i].hits) {
                Object.assign(hits[i], { 'showMR': false });
                Object.assign(hits[i], { 'showMRClass': 'version-field' });
                if (hits[i].hits) {
                    Object.assign(hits[i], { 'multipleVersions': true });
                } else {
                    Object.assign(hits[i], { 'multipleVersions': false });
                }
            }
            Object.assign(hits[i], { 'allowLinkOpenNewTab': true });
            if ((hits[i].objName.toLowerCase().slice(-5) == '__kav' || hits[i].objName.toLowerCase() == 'case') && !this.urlOpensInNewTab)
                Object.assign(hits[i], { 'allowLinkOpenNewTab': false });

            /** added code from setResults **/
            var recordsWrap = {};
            var styleColor;
            if (searchClientSettings.preview && (hits[i].href.toLowerCase().includes('youtube.com') || (hits[i].href.toLowerCase().includes('vimeo.com') && /^\d+$/.test(hits[i].href.split('.com/')[1])) || hits[i].href.includes(window.location.origin)))
                hits[i].showPreview = true;
            else hits[i].showPreview = false;

            if (hits[i].highlight.TitleToDisplayString == this.caseSubjectVal)
                styleColor = 'background-color:#D4E8FF';
            else styleColor = 'background-color:none';

            if (hits[i].metadata && hits[i].metadata.length) {
                hits[i].metadata.sort((a, b) => {
                    return a.value.length - b.value.length;
                })
                for (let j = 0; j < hits[i].metadata.length; j++) {
                    if (hits[i].metadata[j].value.length) {

                        if (hits[i].metadata[j].value.length > 2) {
                            hits[i].metadata[j]['seeMore'] = true;
                            let valueLength = hits[i].metadata[j].value.length
                            hits[i].metadata[j]['original'] = JSON.parse(JSON.stringify((hits[i].metadata[j].value)));
                            hits[i].metadata[j].value.splice(2, valueLength);

                        } else {
                            hits[i].metadata[j]['seeMore'] = false;
                        }

                    }
                }
            }

            let dataContext = hits[i]._id;
            // added for testing
            if (dataContext.startsWith("k"))
                recordsWrap = ({ "showArticles": true, "styleColor": styleColor, "record": hits[i] });
            else
                recordsWrap = ({ "showArticles": false, "styleColor": styleColor, "record": hits[i] });
            hits[i] = recordsWrap;

            /** added code from setResults **/

            if (hits[i].record.hits && hits[i].record.hits.length) {
                this.manipulateSearchHits(hits[i].record.hits, searchClientSettings);
            }
        }
    }
    setFilters(setArray) {
        var self = this;
        var filterValue = [{ "displayName": "All Content", "Contentname": "all_Content", "immediateParent": "_all" }];
        this.tabsFilter = filterValue.concat((setArray && setArray.length && setArray[0].values) || []);
        this.aggregationsData = setArray;
        this.facetSearchIcon = this.s3EndPoint + '/Assets/search-img.svg';
        this.facetSearchClose = this.s3EndPoint + '/Assets/search-close.svg';
        this.aggregationsData = this.aggregationsData.filter(function (facet) {
            if (!facet.values || !facet.values.length) {
                facet.hasValues = false;
                return true;
            };
            facet.hasValues = true;
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
                Object.assign(facet, { 'post_Time_Enable': true });
            } else {
                Object.assign(facet, { 'post_Time_Enable': false });
            }
            if (facet.label == 'Sources') {
                Object.assign(facet, { 'enable_Custom_Sort': true });
            } else {
                Object.assign(facet, { 'enable_Custom_Sort': false });
            }
            if (facet.label == 'Created Date') {
                Object.assign(facet, { 'enable_Created_Date': true });
            } else {
                Object.assign(facet, { 'enable_Created_Date': false });
            }
            if (facet.sort == 'custom') {
                Object.assign(facet, { 'customSortingClass': 'font-12 su__color-black su__px-4 su__py-2 su__cursor su__bg-gray-hover su__filters-sort-active' });
            } else {
                Object.assign(facet, { 'customSortingClass': 'font-12 su__color-black su__px-4 su__py-2 su__cursor su__bg-gray-hover' });
            }
            if (facet.sort == 'term_asc') {
                Object.assign(facet, { 'term_ascSortingClass': 'font-12 su__color-black su__px-4 su__py-2 su__cursor su__bg-gray-hover su__filters-sort-active' });
            } else {
                Object.assign(facet, { 'term_ascSortingClass': 'font-12 su__color-black su__px-4 su__py-2 su__cursor su__bg-gray-hover' });
            }
            if (facet.sort == 'term_desc') {
                Object.assign(facet, { 'term_descSortingClass': 'font-12 su__color-black su__px-4 su__py-2 su__cursor su__bg-gray-hover su__filters-sort-active' });
            } else {
                Object.assign(facet, { 'term_descSortingClass': 'font-12 su__color-black su__px-4 su__py-2 su__cursor su__bg-gray-hover' });
            }
            if (facet.sort == 'count_desc') {
                Object.assign(facet, { 'count_descSortingClass': 'font-12 su__color-black su__px-4 su__py-2 su__cursor su__bg-gray-hover su__filters-sort-active' });
            } else {
                Object.assign(facet, { 'count_descSortingClass': 'font-12 su__color-black su__px-4 su__py-2 su__cursor su__bg-gray-hover' });
            }
            if (facet.sort == 'count_asc') {
                Object.assign(facet, { 'count_ascSortingClass': 'font-12 su__color-black su__px-4 su__py-2 su__cursor su__bg-gray-hover su__filters-sort-active' });
            } else {
                Object.assign(facet, { 'count_ascSortingClass': 'font-12 su__color-black su__px-4 su__py-2 su__cursor su__bg-gray-hover' });
            }
            Object.assign(facet, { 'collapseExampleID': 'collapseExample-' + facet.key + '_icon' });
            Object.assign(facet, { 'collapseExampletoggleIconID': 'collapseExample-' + facet.key + '_toggleIconOn' });
            Object.assign(facet, { 'collapseExampletoggleIconOffID': 'collapseExample-' + facet.key + '_toggleIconOff' });
            Object.assign(facet, { 'collapseExampleEmptyID': 'collapseExample-' + facet.key });
            Object.assign(facet, { 'filterisCollapsed': 'visibilityHidden su__position-absolute ' });
            Object.assign(facet, { 'isCollapsed': 'su__d-none' });
            Object.assign(facet, { 'expanded_Id': facet.key + '_filter_' + facet.order });
            Object.assign(facet, { 'filterSortingLoad': '' });
            Object.assign(facet, { 'filterNonExpanded': facet.values.length > 9 ? 'su__nonExpanded su__filter-content-row su__py-2' : 'su__Expanded su__filter-content-row su__py-1' });
            if (facet.values.length > 9) {
                Object.assign(facet, { 'filtersMoreThan9': true });
            } else {
                Object.assign(facet, { 'filtersMoreThan9': false });
            }
            Object.assign(facet, { 'showmorefacetIcon': 'show-more-facetIcon-' + facet.key });
            if (facet.values.length > 9) {
                Object.assign(facet, { 'filtervalues': true });
            } else {
                Object.assign(facet, { 'filtervalues': false });
            }
            Object.assign(facet, { 'showMoreOrder': facet.key + '_filter_' + facet.order + '_showMore' });
            if (facet.key != '_type') {
                Object.assign(facet, { 'keytype': true });
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

            facet.values.forEach(function (filter) {
                if (filter.value == 0) {
                    Object.assign(filter, { 'disabledValue': 'disabled' });
                } else {
                    Object.assign(filter, { 'disabledValue': 'yes' });
                }
                if (filter.displayName != null) {
                    Object.assign(filter, { 'titleName': filter.displayName });
                } else if (filter.Contentname != null) {
                    Object.assign(filter, { 'titleName': filter.Contentname });
                    Object.assign(filter, { 'displayNameNOTAvailable': true });
                }
                if (filter.childArray) {
                    Object.assign(filter, { 'collapseExampleID': 'collapseExample-' + facet.key + '_' + filter.Contentname + '_icon' });
                    Object.assign(filter, { 'collapseExampletoggleIconID': 'collapseExample-' + facet.key + '_' + filter.Contentname + '_toggleIconOn' });
                    Object.assign(filter, { 'collapseExampletoggleIconOffID': 'collapseExample-' + facet.key + '_' + filter.Contentname + '_toggleIconOff' });
                    Object.assign(filter, { 'collapseExampleEmptyID': 'collapseExample-' + facet.key + '_' + filter.Contentname });
                    filter.showChild = filter.childArray.length && !filter.merged ? 1 : filter.showChild;
                }
                Object.assign(filter, { 'uniqueId': facet.key + '_' + filter.Contentname });

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
                this.preSelectedFilters = this.recordIddFromUtility ? this.casePreSelectedValues || {} : this.preSelectedFilters;
                this.setPreSelectedFilters().then(() => {
                    if (!this.recordIddFromUtility)
                        this.getData(null, 'search');
                    else {
                        this.searchString = this.caseSubject_inUtilityBar;
                        console.log('-- in constructor: ', this.recordIddFromUtility);
                        this.previousCaseId = this.recordId = this.recordIddFromUtility;
                        this.getData(null, 'search');
                    }
                }).catch(error => {
                    this.error = error;
                    console.log(error);
                });
            }
        } else {
            this.customSettingErrorMessage = 'Please configure your SearchUnify and try again.';
        }
    }
    getURLParameter(param) {
        var m = window;
        var s = m.location.href;
        var result;
        let str = s;
        if (window.location.hash != "") {
            str = s.slice(0, s.indexOf(window.location.hash));
        }
        result = decodeURIComponent((new RegExp('[#|s?|&]' + param + '=' + '([^&;]+?)(&|#|;|$)').exec(decodeURIComponent(s)) || [, ""])[1].replace(/\+/g, '%20'))
        return result;
    }


    setClearFilters() {
        this.selectedTypeFilter = typeof this.selectedTypeFilter == 'string' ? this.selectedTypeFilter : JSON.stringify(this.selectedTypeFilter);
        if (JSON.parse(this.selectedTypeFilter || "[]").length || this.exactPhrase != "" || this.withOneOrMore != "" || this.withoutTheWords != "") {

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
    setStickyFacets(setArray) {
        let self = this;
        return new Promise(function (resolve, reject) {
            var stickyArray = JSON.parse(JSON.stringify(setArray));
            var selectedStickyFilter = stickyArray.filter(function (x) {
                x.tempValues = [];
                if (x.key == '_index') {
                    x.values.map(function (o) {
                        if (o.selected) {
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
                    if (f.childArray && (x.order != 0 || (!f.merged || (f.merged && f.showChild != 0)))) {
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
            exactPhrase ? selectedStickyFilter.unshift({ "key": 'exactPhrase', "label": "With the exact phrase", "values": [{ "selected": true, "Contentname": exactPhrase, "sticky_name": exactPhrase }] }) : '';
            withOneOrMore ? selectedStickyFilter.unshift({ "key": 'withOneOrMore', "label": "With one or more words", "values": [{ "selected": true, "Contentname": withOneOrMore, "sticky_name": withOneOrMore }] }) : '';
            withoutTheWords ? selectedStickyFilter.unshift({ "key": 'withoutTheWords', "label": "Without the words", "values": [{ "selected": true, "Contentname": withoutTheWords, "sticky_name": withoutTheWords }] }) : '';
            var stickyFilter_label = selectedStickyFilter.map(function (c) { return c.label });
            self.exactPhrase = exactPhrase;
            self.withOneOrMore = withOneOrMore;
            self.withoutTheWords = withoutTheWords;

            var stickyFilter_label = selectedStickyFilter.map(function (c) { return c.label });
            self.stickyFilter_label = stickyFilter_label;
            self.activeSticky = stickyFilter_label[0];
            self.selectedStickyFilter = selectedStickyFilter;
            self.stickyClass = selectedStickyFilter.length > 2, 'su__selectedFilter-collapse', '';
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
        if (goToTop) {
            goToTop.scrollIntoView();
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

    gridView() {
        this.gridDisplay = true;
    }
    listView() {
        this.gridDisplay = false;
    }

    updateContactHandler(event) {
        this.responseListData = [...event.detail.records]
    }
    stringChangedFromBanner(searchString) {
        this.searchString = searchString.trim().length ? searchString : this.caseSubjectVal;
    }
    setPreSelectedFilters() {
        let self = this;
        return new Promise(function (resolve, reject) {
            self.selectedTypeFilter = [];
            if (!self.myCustomSettings) {
                resolve()
            };
            var c_filterSourceFieldValue = typeof self.myCustomSettings.su_vf_console__FilterFieldName__c == 'undefined' ? '' : self.myCustomSettings.su_vf_console__FilterFieldName__c;
            var c_filterSourceName = typeof self.myCustomSettings.su_vf_console__FilterSourceName__c == 'undefined' ? '' : self.myCustomSettings.su_vf_console__FilterSourceName__c;
            if (!c_filterSourceFieldValue.length || !c_filterSourceName.length) {
                resolve();
            }

            if (self.preSelectedFilters) {
                var filterNameSf = c_filterSourceFieldValue ? c_filterSourceFieldValue.split(",") : [];
                var filterSourceSu = c_filterSourceName ? c_filterSourceName.split(",") : [];
                filterSourceSu.forEach(function (field, i) {
                    if (self.preSelectedFilters[filterNameSf[i]]) {
                        let filter = {
                            "type": field,
                            "filter": self.preSelectedFilters[filterNameSf[i]].split(";")
                        };
                        self.selectedTypeFilter.push(filter);
                    }
                });
                self.selectedTypeFilter = JSON.stringify(self.selectedTypeFilter);
                resolve();
            } else {
                self.selectedTypeFilter = JSON.stringify(self.selectedTypeFilter);
                resolve();
            }
        });
    }
}