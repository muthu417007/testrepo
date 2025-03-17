import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import { getRecord } from 'lightning/uiRecordApi';
//apex class for logic implementation
import showSchedule from '@salesforce/apex/MYA_ModelValidCheck.MYA_productLineCode';
import getM from '@salesforce/apex/MYA_ModelValidCheck.MYA_modelValidityCheckkforManufacturing';
import getK from '@salesforce/apex/MYA_ModelValidCheck.MYA_modelValidityCheckkforMarketing';
import checkM from '@salesforce/apex/MYA_ModelValidCheck.MYA_manufacturingModelValidityCheck';
import checkK from '@salesforce/apex/MYA_ModelValidCheck.MYA_marketingModelValidityCheck';
import getContacts from '@salesforce/apex/MYA_ModelValidCheck.mya_getContact';
import getResponse from '@salesforce/apex/MYA_EndecaApiHandler.MYA_EndecaResponseDetails';
//metadata
import getmyaConfigs from '@salesforce/apex/Mya_ProductDetails.getmyaConfigs';
import getSourceDocumentTypes from '@salesforce/apex/MYA_MetaDataConfigHelper.getSourceDocumentTypes';
import getStaticOwnerLinks from '@salesforce/apex/MYA_MetaDataConfigHelper.getStaticOwnerLinks';
import getProductSpecLinks from '@salesforce/apex/MYA_MetaDataConfigHelper.getProductSpecLinks';
//resources url
import PROUDUCT_IMAGE from '@salesforce/resourceUrl/GEImageForProducts';
import Register_Appliance from '@salesforce/resourceUrl/RegisterAppliance';
import Parts_Accessories from '@salesforce/resourceUrl/PartsAccessories';
import Product_Specs from '@salesforce/resourceUrl/ProductSpecs';
import Owner_Support from '@salesforce/resourceUrl/OwnerSupport';
import Schedule_Services from '@salesforce/resourceUrl/ScheduleServices';
import Owners_Manual from '@salesforce/resourceUrl/OwnersManual';
import FLAG_CANADA from '@salesforce/resourceUrl/flagcanada';
import CafeHelp from '@salesforce/resourceUrl/Help';
import cafeFilter from '@salesforce/resourceUrl/filter';
import CafeFile from '@salesforce/resourceUrl/File';
import cafeBriefcase from '@salesforce/resourceUrl/Briefcase';
import cafe_book from '@salesforce/resourceUrl/Book';
import cafeRegisterAppliance from '@salesforce/resourceUrl/CafeRegisterAppliance';
import logo_Img from '@salesforce/resourceUrl/logo';
import cafe_logo from '@salesforce/resourceUrl/cafeLogo320x100';
import haier_logo from '@salesforce/resourceUrl/haierLogo320x100';
import RATE_REVIEW from '@salesforce/resourceUrl/rate_review';
import wifi_logo from '@salesforce/resourceUrl/Wifi';
import ScheduleServiceLabel from '@salesforce/label/c.MYA_ScheduledService';
import isGuest from '@salesforce/user/isGuest';
//html templates
import Cafe from "./mya_qrCafePage.html";
import GEA from "./mya_qrPage.html";
import Haier from "./mya_qrHaierPage.html";
import Monogram from "./mya_qrMonogramPage.html";
import ScheduleServiceProductLabel from '@salesforce/label/c.Mya_ScheduleServiceExistingProduct';
import StayInTouchSubject from '@salesforce/schema/User.StayInTouchSubject';

export default class QrPage extends NavigationMixin(LightningElement) {
    //images variable
    @api RelatedParts = 'Related Parts & Accessories';
    C_book = cafe_book;
    cafe_Briefcase = cafeBriefcase;
    Cafe_File = CafeFile;
    cafe_Filter = cafeFilter;
    Cafe_Help = CafeHelp;
    rateReview = RATE_REVIEW;
    cafe_RegisterAppliance = cafeRegisterAppliance;
    wifiLogo = wifi_logo;
    flagcanada = FLAG_CANADA;
    logoImg1 = logo_Img;
    logoImg2 = cafe_logo;
    logoImg3 = haier_logo;
    proImage = PROUDUCT_IMAGE;
    regappliance = Register_Appliance;
    partsAcc = Parts_Accessories;
    proSpecs = Product_Specs;
    owSupport = Owner_Support;
    schServices = Schedule_Services;
    ownermanual = Owners_Manual;
    personIds;
    myaConfigs;
    isGuestUsers = isGuest;
    brand = 'GEA';
    //errorMessage = true;
    modelNo;
    marketingModelNo;
    serial;
    showUrl;
    showInvalidUrl;
    reviewUrl;
    cafeurl;
    haierUrl;
    geaUrl;
    ownerUrl;
    showOwnerUrl = true;
    monogramUrl;
    hotpointUrl;
    description;
    images;
    kInvalid;
    mInvalid;
    ownerManualUrl;
    showScheduleUrl;
    showInvalidView;
    kInvalidWifi;
    ProdSpecs;
    Partslink;
    ScheduleServiceLink;
    url;
    guestUrl;
    baseUrl;
    urlParams;
    pageReference;
    prodReghref;
    isLoading;
    relParts;
    RelAcc = [];
    RelatedPartsAvailable = false;
    connected = false;
    allParts;
    brandedUrl = false;
    sourceDocumentBrand = 'GEA';
    productBrand;
    productCategory;

    //QR code redirection -- method to read parameters of url
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (!this.connected && currentPageReference) {
            this.isLoading = true;
            var data = currentPageReference.state;
            if (data.P && data.P != '') {
                getSourceDocumentTypes({})
                    .then(types => {
                        let isFound = false;
                        let row = 0;
                        do {
                            if (Object.values(types[row]).indexOf(data.P) !== -1) {
                                this.sourceDocumentBrand = types[row].Brand__c;
                                isFound = true;
                            } else {
                                row++;
                            }
                        } while (!isFound && row < types.length);
                        this.brand = this.sourceDocumentBrand;
                        this.brandRedirection(this.sourceDocumentBrand, data);
                    })
                    .catch(error => {
                        console.error('getSourceDocumentTypes: ', error);
                    });
            } else {
                this.brand = this.sourceDocumentBrand;
                this.brandRedirection(this.sourceDocumentBrand, data);
            }
        }
    }

    connectedCallback() {
        this.connected = true;
    }
    //LWC callback method to render different html template
    render() {
        if (this.brand == "GEA") {
            return GEA;
        } else if (this.brand == 'Hotpoint' || this.brand == 'Monogram') {
            return Monogram;
        } else if (this.brand == "Haier") {
            return Haier;
        } else if (this.brand == "Cafe") {
            return Cafe;
        }
    }

    brandRedirection(brand, data) {
        if (brand == 'Hotpoint' || brand == 'Monogram') {
            brand = 'GEA';
        }
        let location = window.location;
        if (location.pathname.indexOf('/' + brand + '/') == -1) {
            let pathname = location.pathname;
            const pathArray = pathname.split("/");
            let brandUrl = location.origin + '/' + brand + '/' + pathArray[2] + '/' + pathArray[3] +
                '?language=en_US&P=' + data.P + '&K=' + data.K + '&M=' + data.M +
                '&S=' + data.S + '&L=' + data.L + '&D=' + data.D;
            window.location.href = brandUrl;
        } else {
            this.brandedUrl = true;
            this.pageInit(data, brand);
        }
    }
    pageInit(data, brand) {
        if (data != null) {
            getmyaConfigs({})
                .then(configs => {
                    this.myaConfigs = configs;
                    this.modelNo = (data.M && data.M != '') ? data.M : data.K;
                    this.marketingModelNo = (data.K && data.K != '') ? data.K : data.M;
                    if (data.K && data.K != '') { //if K value is there
                        this.getMarketingModelDetails(data, brand);
                    }
                    if ((!data.K || data.K == '') && data.M) { //if M is not null in url parameter
                        this.getManufacturingModelDetails(data, brand);
                    }
                    if (!data.K && !data.M) {
                        //this.errorMessage = false;                
                        this.showInvalidPage(data);
                    }
                })
                .catch(error => {
                    console.error('getmyaConfigs: ', error);
                });
        }
    }

    setProductSpecUrl(modelNumber, product) {
        getProductSpecLinks({})
            .then(result => {
                if (product.Brand.includes("GE")) {                    
                    if (product.IsDuctless == false) {
                        this.ProdSpecs = result.filter(item => item.Brand__c == 'GEA')[0].Spec_Link__c + modelNumber;
                    } else if (product.IsDuctless == true) {
                        this.ProdSpecs = result.filter(item => item.Brand__c == 'GEA')[0].Ductless_Spec_Link__c;
                    }
                } else if (product.Brand == 'Cafe') {
                    this.ProdSpecs = result.filter(item => item.Brand__c == 'Cafe')[0].Spec_Link__c + modelNumber;
                } else if (product.Brand == 'Hotpoint') {
                    this.ProdSpecs = result.filter(item => item.Brand__c == 'Hotpoint')[0].Spec_Link__c + modelNumber;
                } else if (product.Brand == 'Monogram') {
                    this.ProdSpecs = result.filter(item => item.Brand__c == 'Monogram')[0].Spec_Link__c + modelNumber;
                } else if (product.Brand == 'Haier') {                    
                    if (product.IsDuctless == false) {
                        this.ProdSpecs = result.filter(item => item.Brand__c == 'Haier')[0].Spec_Link__c + modelNumber;
                    } else if (product.IsDuctless == true) {
                        this.ProdSpecs = result.filter(item => item.Brand__c == 'Haier')[0].Ductless_Spec_Link__c;
                    }
                } else {
                    this.ProdSpecs = result.filter(item => item.Brand__c == 'GEA')[0].Spec_Link__c + modelNumber;
                }
            }).catch(error => {
                console.error('getProductSpecLinks: ', error);
            });
    }

    setReviewUrl(modelNumber) {
        this.haierUrl = this.myaConfigs.Review_Link_Haier__c + modelNumber + this.myaConfigs.QR_Review_Link_for_Haier__c;
        this.cafeurl = this.myaConfigs.Review_Link_Cafe__c + modelNumber + this.myaConfigs.QR_Review_link_Cafe__c;
        this.geaUrl = this.myaConfigs.Review_Link_GEA__c + modelNumber + this.myaConfigs.QR_Review_link_GEA__c;
        this.monogramUrl = this.myaConfigs.Review_Link_Monogram__c + modelNumber + this.myaConfigs.QR_Review_link_Monogram__c;
        this.hotpointUrl = this.myaConfigs.Review_Url_Hotpoint__c + modelNumber + this.myaConfigs.QR_Review_link_Hotpoint__c;
        if (this.brand == "GEA") {
            this.reviewUrl = this.geaUrl;
        } else if (this.brand == 'Hotpoint') {
            this.reviewUrl = this.hotpointUrl;
        } else if (this.brand == 'Monogram') {
            this.reviewUrl = this.monogramUrl;
        } else if (this.brand == "Haier") {
            this.reviewUrl = this.haierUrl;
        } else if (this.brand == "Cafe") {
            this.reviewUrl = this.cafeurl;
        }
    }

    getScheduleUrl(myaConfigs, data) {

        this.schdUrl = myaConfigs;
        this.ScheduleServiceLink = this.schdUrl.EService_Source_URL__c +
            encodeURI(this.schdUrl.EService_Target_Url__c + 'idpRequestToken') +
            '&language=en_US&allowGuest=1&state=';

        if (!this.isGuestUsers) {
            getContacts({})
                .then(contactResult => {
                    this.personIds = contactResult;
                    this.ScheduleServiceLink = this.ScheduleServiceLink +
                        encodeURI(this.schdUrl.EService_Target_Url__c + 'confirmzipcode?personId=' + contactResult) +
                        '%26K%3D' + this.marketingModelNo + '%26M%3D' + this.modelNo + '%26S%3D' + data.S;
                    this.isLoading = false;
                })
                .catch(error => {
                    console.error('getContacts: ', error);
                });
        } else {
            this.ScheduleServiceLink = this.ScheduleServiceLink +
                encodeURI(this.schdUrl.EService_Target_Url__c + 'confirmzipcode?') +
                'K%3D' + this.marketingModelNo + '%26M%3D' + this.modelNo + '%26S%3D' + data.S;
            this.isLoading = false;
        }
    }

    setRegistrationUrl(data, brand) {

        if (brand == 'GEA') {
            this.baseUrl = (window.location.origin).concat('/GEA/s/');
            this.url = (window.location.origin).concat('/GEA/s/mya-product-registration?language=en_US&brand=GEA'); //get base url
            this.guestUrl = (window.location.origin).concat('/GEA/s/mya-guest-product-registration?language=en_US&brand=GEA');
            this.urlParams = '?language=en_US&brand=GEA';
            this.brand = 'GEA';
        } else if (brand == 'Cafe') {
            this.baseUrl = (window.location.origin).concat('/Cafe/s/');
            this.url = (window.location.origin).concat('/Cafe/s/mya-product-registration?language=en_US&brand=Cafe'); //get base url
            this.guestUrl = (window.location.origin).concat('/Cafe/s/mya-guest-product-registration?language=en_US&brand=Cafe'); //get base url
            this.urlParams = '?language=en_US&brand=Cafe';
        } else if (brand == 'Haier') {
            this.baseUrl = (window.location.origin).concat('/Haier/s/');
            this.url = (window.location.origin).concat('/Haier/s/mya-product-registration?language=en_US&brand=Haier'); //get base url
            this.guestUrl = (window.location.origin).concat('/Haier/s/mya-guest-product-registration?language=en_US&brand=Haier'); //get base url
            this.urlParams = '?language=en_US&brand=Haier';
        }

        //create Url's if M is there
        if (data.M || data.S) {
            this.url = this.url + '&model=' + this.modelNo + '&serial=' + data.S;
            this.guestUrl = this.guestUrl + '&model=' + this.modelNo + '&serial=' + data.S;
            this.urlParams = this.urlParams + '&model=' + this.modelNo + '&serial=' + data.S;
            this.serial = data.S;
            this.Partslink = this.myaConfigs.ReturnBaseURL__c + '/store/parts/KeywordSearch?q=' + data.M + '&icid=QR_RelatedParts';
            this.getScheduleUrl(this.myaConfigs, data);
            //this.ownerUrl = 'https://products.geappliances.com/appliance/gea-specs/' + data.M + '/support'
        }
        //create urls's if M is blank and K is there
        if (!data.M && data.K) {
            this.url = this.url + '&model=' + this.modelNo + '&serial=' + data.S;
            this.guestUrl = this.guestUrl + '&model=' + this.modelNo + '&serial=' + data.S;
            this.urlParams = this.urlParams + '&model=' + this.modelNo + '&serial=' + data.S;
            this.Partslink = this.myaConfigs.ReturnBaseURL__c + '/store/parts/KeywordSearch?q=' + data.K + '&icid=QR_RelatedParts';
            this.getScheduleUrl(this.myaConfigs, data);
            //this.ownerUrl = 'https://products.geappliances.com/appliance/gea-specs/' + data.K + '/support'
        }

        let regBaseUrl = (window.location.origin).concat('/GEA/apex/CustomerSSO');
        this.prodReghref = regBaseUrl + '?redirectURL=' + encodeURIComponent(this.url) + '&language=en_US&allowGuest=1&state=&guestURL=' + encodeURIComponent(this.guestUrl) + '&internalRedirect=1';

    }

    setAllPartsLink() {
        this.allParts = this.myaConfigs.ReturnBaseURL__c + '/store/parts/KeywordSearch?q=' + this.modelNo + '&icid=QR_RelatedParts';
    }

    SetRelatedparts() {
        if (this.relParts) {
            for (const rel of this.relParts) {
                const Details = {
                    PDes: rel.Description,
                    Plink: this.myaConfigs.ReturnBaseURL__c + '/store/parts/spec/' + rel.SKU,
                    //iLink: this.myaConfigs.Image_Url__c + rel.Images_DisplayImageName + '&Variant=SpecPage',
                    iLink: rel.Images_Path,                    
                    PModel: rel.SKU,
                };
                this.RelAcc = [...this.RelAcc, Details];
                this.RelatedPartsAvailable = true;
            }
            this.setAllPartsLink();
        }
    }

    handleProductRegistration() {

        const payload = { url: window.location.href };
        localStorage.setItem('qrLink', JSON.stringify(payload));
    }

    checkMfg(input, brand) {
        checkM({ manufacturingModelNumber: input.M })
            .then(result => {
                if (result.Success && !result.IsValid) {
                    this.modelNo = input.K;
                }
                this.setRegistrationUrl(input, brand);
            });
    }

    getMarketingModelDetails(input, brand) {
        getK({ marketingModel: input.K }) //check K i.e manufacturing model is valid or not---passing k value to method
            .then(result => {
                if (result == 0) {
                    this.getManufacturingModelDetails(input, brand);
                } else {
                    this.showInvalidUrl = false; //else show valid view
                    this.kInvalid = false; //k is not invalid
                    this.checkMfg(input, brand);
                    this.setReviewUrl(input.K);
                    //get image and description of product from endeca services
                    getResponse({ SKU: input.K })
                        .then(result => {
                            this.description = result.ProductInfo.ProductDescription;
                            this.images = result.ProductInfo.DefaultImageUrl;
                            this.ownerManualUrl = result.ProductInfo.UserManualUrl;
                            this.kInvalidWifi = result.ProductInfo.IsWifiConnect;
                            this.relParts = result.ProductInfo.RelatedParts;
                            this.SetRelatedparts();
                            this.OwnerSupport(result.ProductInfo, this.myaConfigs, input.K);                            
                            this.setProductSpecUrl(input.K, result.ProductInfo);
                        })
                        .catch(error => {
                            this.error = error.message;
                            console.error('getResponse of product details: ', error);
                        });
                }
                //method to check product schedule should be dispaly or not for a prodcut  
                showSchedule({ SKU: input.K }) //send model as an argument and check if for this category schedulable url needs to dispaly or not
                    .then(result => {
                        if (result != 1) {
                            this.showScheduleUrl = true;
                        } else {
                            this.showScheduleUrl = false;
                        }
                    }).catch(error => {
                        this.error = error.message;
                        this.showScheduleUrl = false;
                        console.error('showSchedule: ', error);
                    })
            })
            .catch(error => {
                this.showInvalidUrl = true;
                this.error = error.message;
                console.error('getK: ', error);
                if (this.showInvalidUrl) {
                    if (this.brand != 'Haier' && this.brand != 'Cafe') {
                        this.ownerUrl = this.myaConfigs.Owner_Support_GEA__c + '/ge/service-and-support/';
                    } else if (this.brand == 'Haier') {
                        this.ownerUrl = this.myaConfigs.Product_Specs_Haier__c + '/support/products';
                    } else {
                        this.ownerUrl = this.myaConfigs.Product_Specs_Cafe__c + '/support/contact-us';
                    }
                }
            });
    }

    getManufacturingModelDetails(input, brand) {
        checkM({ manufacturingModelNumber: input.M })
            .then(result => {
                if (result.Success && !result.IsValid) { //M is invalid that's why result is 0 show invalid view
                    // this.showInvalidUrl = true;
                    // this.mInvalid = true;
                    // this.showInvalidView = true;
                    this.showErrorPage();
                } else if (result.Success && result.IsValid) { //M is valid then based on K validity display  view
                    if (!this.kInvalid) {
                        this.showInvalidView = false;
                        this.showInvalidUrl = false;
                    } else {
                        this.showErrorPage();
                    }
                    this.marketingModelNo = result.ModelRelation[0].MR_PKMOD__c;
                    this.mInvalid = false;                    
                    this.setReviewUrl(result.ModelRelation[0].MR_PKMOD__c);
                    this.setRegistrationUrl(input, brand);
                    //get response based on M value from endeca
                    getResponse({ SKU: result.ModelRelation[0].MR_PKMOD__c })
                        .then(result => {
                            this.description = result.ProductInfo.ProductDescription;
                            this.images = result.ProductInfo.DefaultImageUrl;
                            this.ownerManualUrl = result.ProductInfo.UserManualUrl;
                            this.kInvalidWifi = result.ProductInfo.IsWifiConnect;
                            this.relParts = result.ProductInfo.RelatedParts;
                            this.SetRelatedparts();
                            this.OwnerSupport(result.ProductInfo, this.myaConfigs, result.ModelRelation[0].MR_PKMOD__c);
                            this.setProductSpecUrl(result.ModelRelation[0].MR_PKMOD__c, result.ProductInfo);
                        })
                        .catch(error => {
                            this.error = error.message;
                            console.error('getResponse for product details: ', error);
                        });
                }
                showSchedule({ SKU: input.M }) //Check schedule Service Url should be displayed or not based on product line code
                    .then(result => {
                        if (result != 1) {
                            this.showScheduleUrl = true;
                        } else {
                            this.showScheduleUrl = false;
                        }
                    }).catch(error => {
                        this.error = error.message;
                        this.showScheduleUrl = false;
                        console.error('showSchedule: ', error);
                    })
            })
            .catch(error => {
                console.error('checkM: ', error);
                this.showInvalidUrl = true;
                if (this.showInvalidUrl) {
                    if (this.brand != 'Haier' && this.brand != 'Cafe') {
                        this.ownerUrl = this.myaConfigs.Owner_Support_GEA__c + '/ge/service-and-support/';
                    } else if (this.brand == 'Haier') {
                        this.ownerUrl = this.myaConfigs.Product_Specs_Haier__c + '/support/products';
                    } else {
                        this.ownerUrl = this.myaConfigs.Product_Specs_Cafe__c + '/support/contact-us';
                    }
                }
            });
    }

    showErrorPage() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'MYA_Error_Page__c',
                componentName: 'c-mya_-error-page'
            }
        });
    }

    showInvalidPage(data) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'MYA_Invalid_Register__c',
                componentName: 'c-mya_-invalid-mobile-register'
            },
            state: {
                M: data.M ? data.M : '',
                K: data.K ? data.K : '',
                S: data.S ? data.S : '',
                L: data.L ? data.L : '',
                D: data.D ? data.D : '',
                P: data.P ? data.P : ''
            }
        });
    }

    //owner support links
    OwnerSupport(product, config, modelNumber) {
        debugger;
        if (product.Brand.includes("GE")) {
            if (product.IsDuctless == false) {
                this.ownerUrl = config.Product_Specs_GEA__c + '/appliance/gea-specs/' + modelNumber + '/support'
            } else if (product.IsDuctless == true) {
                if (product.CommercialCategories == 'Room Air Conditioners' || product.CommercialCategories == 'Split-System') {
                    this.ownerUrl = config.Owner_Support_GEA__c + '/ductless/'
                }
            }
        } else if (product.Brand == 'Cafe') {
            this.ownerUrl = config.Product_Specs_Cafe__c + '/shop?search_query=' + modelNumber + '&results=manuals';
        } else {
            this.productBrand = product.Brand;
            this.productCategory = product.CommercialCategories;
            if (product.IsDuctless) {
                this.productCategory = 'Ductless';
            }
            getStaticOwnerLinks({})
                .then(result => {
                    let data = result.filter(item => item.Category__c == this.productCategory);
                    if (data.length > 0) {
                        this.setStaticLink(this.productBrand, data);
                    } else {
                        let matchingdata = result.filter(item => (item.Category__c).indexOf(this.productCategory) !== -1);
                        if (matchingdata.length > 0) {
                            this.setStaticLink(this.productBrand, matchingdata);
                        } else {
                            let defaultData = result.filter(item => item.Category__c == 'Default');
                            this.setStaticLink(this.productBrand, defaultData);
                        }
                    }
                }).catch(error => {
                    console.error('getStaticOwnerLinks: ', error);
                });
                
        }
    }

    setStaticLink(brand, data) {
        if (brand == 'Hotpoint') {
            this.ownerUrl = data[0].Hotpoint_Link__c;
        } else if (brand == 'Monogram') {
            this.ownerUrl = data[0].Monogram_Link__c;
        } else if (brand == 'Haier') {
            this.ownerUrl = data[0].Haier_Link__c;
        }
    }
}