import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import Id_Field from '@salesforce/schema/Asset.Id';
import Model_Number from '@salesforce/schema/Asset.Model_Number__c';
import OriginalModelNumber from '@salesforce/schema/Asset.OriginalModelNumber__c';
import Serial_Number from '@salesforce/schema/Asset.SerialNumber';
import Install_Date from '@salesforce/schema/Asset.InstallDate';
import Acc_Id from '@salesforce/schema/Asset.AccountId';
import Nickname from '@salesforce/schema/Asset.AssetNickname__c';
import Valid_Model from '@salesforce/schema/Asset.ModelValidityFlag__c';
import deleteAsset from '@salesforce/apex/Mya_ProductDetails.Mya_DeleteAsset';
import getManufactureModel from '@salesforce/apex/Mya_ProductDetails.Mya_GetManufactureModel';
//import getIsGEAProduct from '@salesforce/apex/Mya_ProductDetails.isGeaProduct';
import MYA_ProductDetails1 from '@salesforce/apex/MYA_MyProducts.MYA_ProductDetails1';
import showSchedule from '@salesforce/apex/MYA_ModelValidCheck.MYA_productLineCode';
import mya_GEATeamplate from './mya_ProductDetails_GEA.html';
import mya_CafeTeamplate from './mya_ProductDetails_Cafe.html';
import mya_HaierTeamplate from './mya_ProductDetails_Haier.html';
import mya_BodewellTeamplate from './mya_ProductDetails_Bodewell.html';
import MYA_EndecaResponseDetails from '@salesforce/apex/MYA_EndecaApiHandler.MYA_EndecaResponseDetails';
import getStaticOwnerLinks from '@salesforce/apex/MYA_MetaDataConfigHelper.getStaticOwnerLinks';
import getProductSpecLinks from '@salesforce/apex/MYA_MetaDataConfigHelper.getProductSpecLinks';
// haier icon images
import Parts_Accessories from '@salesforce/resourceUrl/PartsAccessories';
import Product_Specs from '@salesforce/resourceUrl/ProductSpecs';
import Owner_Support from '@salesforce/resourceUrl/OwnerSupport';
import Schedule_Services from '@salesforce/resourceUrl/ScheduleServices';
import Owners_Manual from '@salesforce/resourceUrl/OwnersManual';
import cafeFilter from '@salesforce/resourceUrl/filter';
import CafeFile from '@salesforce/resourceUrl/File';
import cafeBriefcase from '@salesforce/resourceUrl/Briefcase';
import cafe_book from '@salesforce/resourceUrl/Book';
import CafeHelp from '@salesforce/resourceUrl/Help';
import Mya_GetAddressDetails from '@salesforce/apex/Mya_AddressHandler.Mya_GetApplianceAddressDetails';
import Mya_UpdateAddress from '@salesforce/apex/Mya_AddressHandler.Mya_UpdateAddress';
import Mya_UpdateAssetAddress from '@salesforce/apex/Mya_AddressHandler.Mya_UpdateAssetAddress';
import PROUDUCT_IMAGE from '@salesforce/resourceUrl/productimage';
//metadata
import getmyaConfigs from '@salesforce/apex/Mya_ProductDetails.getmyaConfigs';
//css
import MYAGEACSS from '@salesforce/resourceUrl/MYAGEACSS';
import MYACAFECSS from '@salesforce/resourceUrl/MYACAFECSS';
import MYAHAIERCSS from '@salesforce/resourceUrl/MYAHAIERCSS';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

export default class Mya_ProductDetails extends NavigationMixin(LightningElement) {

    @api page_header;
    @api more_info;
    @api model_No_Header;
    @api serial_No_Header;
    @api nickName_Header;
    @api location_Header;
    @api address;
    @api city;
    @api state;
    @api zip_code;
    @api nickName;
    @api install_date;
    @api RelatedParts;
    @api warranty;
    @api Parts_Warranty;
    @api Labor_Warranty;
    @api Warranty_Notes;
    @api brandValue='GEA';
    @track selectedState = '';
    @track showDropdown = false;
    @api bodewellWarrantyHeader;
    @api bodewellLaborWarranty;
    @api bodewellPartsWarranty;
    @api bodewellWarrantyNotes;

    disableAddress = false;
    productimage = PROUDUCT_IMAGE;

    stateOptions = [
        { value: '', label: 'select state' },
        { value: 'AK', label: 'AK' },
        { value: 'AL', label: 'AL' },
        { value: 'AR', label: 'AR' },
        { value: 'AZ', label: 'AZ' },
        { value: 'CA', label: 'CA' },
        { value: 'CO', label: 'CO' },
        { value: 'CT', label: 'CT' },
        { value: 'DC', label: 'DC' },
        { value: 'DE', label: 'DE' },
        { value: 'FL', label: 'FL' },
        { value: 'GA', label: 'GA' },
        { value: 'HI', label: 'HI' },
        { value: 'IA', label: 'IA' },
        { value: 'ID', label: 'ID' },
        { value: 'IL', label: 'IL' },
        { value: 'IN', label: 'IN' },
        { value: 'KS', label: 'KS' },
        { value: 'KY', label: 'KY' },
        { value: 'LA', label: 'LA' },
        { value: 'MA', label: 'MA' },
        { value: 'MD', label: 'MD' },
        { value: 'ME', label: 'ME' },
        { value: 'MI', label: 'MI' },
        { value: 'MN', label: 'MN' },
        { value: 'MO', label: 'MO' },
        { value: 'MS', label: 'MS' },
        { value: 'MT', label: 'MT' },
        { value: 'NC', label: 'NC' },
        { value: 'ND', label: 'ND' },
        { value: 'NE', label: 'NE' },
        { value: 'NH', label: 'NH' },
        { value: 'NJ', label: 'NJ' },
        { value: 'NM', label: 'NM' },
        { value: 'NV', label: 'NV' },
        { value: 'NY', label: 'NY' },
        { value: 'OH', label: 'OH' },
        { value: 'OK', label: 'OK' },
        { value: 'OR', label: 'OR' },
        { value: 'PA', label: 'PA' },
        { value: 'PR', label: 'PR' },
        { value: 'RI', label: 'RI' },
        { value: 'SC', label: 'SC' },
        { value: 'SD', label: 'SD' },
        { value: 'TN', label: 'TN' },
        { value: 'TX', label: 'TX' },
        { value: 'UT', label: 'UT' },
        { value: 'VA', label: 'VA' },
        { value: 'VT', label: 'VT' },
        { value: 'WA', label: 'WA' },
        { value: 'WI', label: 'WI' },
        { value: 'WV', label: 'WV' },
        { value: 'WY', label: 'WY' },
    ];

    //cafe icons
    C_ScheduleService = cafeBriefcase;
    C_OwnersManual = cafe_book;
    C_OwnerSupport = CafeHelp;
    C_Parts = cafeFilter;
    C_ProductSpecs = CafeFile;

    // GE icons
    H_OwnersManual = Owners_Manual;
    H_OwnerSupport = Owner_Support;
    H_Parts = Parts_Accessories;
    H_ProductSpecs = Product_Specs;
    H_ScheduleService = Schedule_Services;

    Brand;
    ImageUrl;
    WarrantyNotes = [];
    Description;
    PartsWarranty = [];
    LaborWarranty = [];
    RelParts;
    Ductless = false;
    ScheduleServiceLink;
    OwnerManualLink;
    Category;
    isConsumerReady;
    // to get assetid from url
    currentPageReference = null;
    urlStateParameters = null;
    AssetId;
    //get url's from metadata
    Urllist;
    domainUrl = window.location.hostname;
    //existing address
    selectOptions = [];
    defaultSelectOption = [{ label: 'Search with other address', value: '' }];
    Existing_Address;
    //remove product
    recordId;
    showModal = false;    
    //to get asset details
    wiredAssetDetails;
    assetDetails;
    AccId;
    AppName;
    modelNo;
    AstDetail;
    SerialNo;
    ValidModel;
    ShowLinks = false;
    showScheduleUrl;
    ConsumerId;
    RelAcc = [];
    ProdSpecs;
    Partslink;
    ownerUrl;
    AllParts;
    imageurl;
    review_links;
    showSerialNoForm = false;
    upSerialNo;
    Address1;
    city;
    state;
    zipcode;
    addForm = false;
    AddName;
    setName;
    nickNameForm = false;
    productBrand;
    productCategory;
    zipCodePattern = '[0-9]{5}$';
    zipCodePatternValidationMessage = 'Please enter a valid zip code';    
    addressFieldPattern = '^[a-zA-Z0-9 ]+$';
    addressPatternValidationMessage = 'Special characters are not allowded.';
    @track Location_Details;
    isGEAProduct;
    displayLinks;
    checkProduct;

    render() {
        if (this.BrandValue == "GEA") {
            return mya_GEATeamplate
        } else if (this.BrandValue == "Haier") {
            return mya_HaierTeamplate
        } else if (this.BrandValue == "Cafe") {
            return mya_CafeTeamplate
        } else if (this.brandValue == "Bodewell") {
            return mya_BodewellTeamplate
        }
    }


    // CSS loader function
    //   renderedCallback() {
    //     if (this.BrandValue == "GEA") {
    //         Promise.all([
    //             loadStyle(this, MYAGEACSS + '/MYAGEACSS/mya_ProductDetails_GEA.css')
    //         ]);
    //     }
    //     else if (this.BrandValue == "Haier") {
    //         Promise.all([
    //             loadStyle(this, MYAHAIERCSS + '/MYAHAIERCSS/mya_ProductDetails_Haier.css')
    //         ]);
    //     }
    //     else if (this.BrandValue == "Cafe") {
    //         Promise.all([
    //             loadStyle(this, MYACAFECSS + '/MYACAFECSS/mya_ProductDetails_Cafe.css')
    //         ]);
    //     }
    // }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.AssetId = currentPageReference.state.c__assetrecordId;
        }
    }

    UpdAddressHandler(event) {
        if (event.target.value != '') {
            this.Existing_Address = event.target.value;
            this.disableAddress = true;
            // Revalidate address fields
            Promise.resolve().then(() => {
                let inputFields = this.template.querySelectorAll('.validate');
                inputFields.forEach(inputField => {
                    inputField.reportValidity();
                });
            });
        } else {
            this.Existing_Address = null
            this.disableAddress = false
        }
    }

    openModal(event) {
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
    }

    handledelete() {
        deleteAsset({ Id: this.AssetId })
            .then((result) => {
                this.showModal = false;
                this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                    attributes: {
                        name: 'MYA_My_Products__c',
                    }
                })
            }).catch((error) => {
                console.error('deleteAsset: ',error)
            });
    }

    @wire(getRecord, { recordId: '$AssetId', fields: [Model_Number, OriginalModelNumber, Serial_Number, Install_Date, Acc_Id, Nickname, Valid_Model] })
    WiredAsset(result) {
        this.wiredAssetDetails = result;
        if (result) {
            
            this.assetDetails = result;
            console.log('this.assetDetails in mya_productDetails',this.assetDetails)
           
            getmyaConfigs({})
                .then(configs => {
                    this.Urllist = configs;
                    if (this.assetDetails.data) {
                        this.AccId = this.assetDetails.data.fields.AccountId.value
                        this.SerialNo = this.assetDetails.data.fields.SerialNumber.value
                        this.ValidModel = this.assetDetails.data.fields.ModelValidityFlag__c.value
                        
                        this.AppName = this.assetDetails.data.fields.AssetNickname__c.value ?
                                        this.assetDetails.data.fields.AssetNickname__c.value : 
                                        'Appliance';
                        
                        this.modelNo = this.assetDetails.data.fields.Model_Number__c.value;
                        if(!this.modelNo) {
                            this.modelNo = this.assetDetails.data.fields.OriginalModelNumber__c.value;
                        }
                        if (this.ValidModel == true) {
                            this.ShowLinks = true;
                           
                            MYA_EndecaResponseDetails({ SKU: this.modelNo }) //call endeca function to get product details
                                .then((res) => {
                                    this.AstDetail = res.ProductInfo;
                                    console.log(res.productInfo);
                                    this.InfoDetails();
                                }).catch((error) => {
                                    console.error('Product Details: ',error);
                                });
                            
                        } else {
                            this.OwnerSupport();
                        }
                        this.getProductAddress();
                        
                        MYA_ProductDetails1({ assetId: this.AssetId })
                            .then(result1 => {
                                this.ConsumerId = result1.Contact.Global_Customer_Id__c
                                if(result1.ModelValidityFlag__c) {
                                    this.ScheduleServiceLink = this.Urllist.EService_Source_URL__c + encodeURI(this.Urllist.EService_Target_Url__c + 'idpRequestToken') + '&language=en_US&allowGuest=1&state=' + encodeURI(this.Urllist.EService_Target_Url__c + 'confirmzipcode?personId=' + this.ConsumerId) + '%26K%3D' + result1.Model_Number__c + '%26M%3D' + result1.OriginalModelNumber__c + '%26S%3D' + this.SerialNo
                                } else {
                                    this.ScheduleServiceLink = this.Urllist.EService_Source_URL__c + encodeURI(this.Urllist.EService_Target_Url__c + 'idpRequestToken') + '&language=en_US&allowGuest=1&state=' + encodeURI(this.Urllist.EService_Target_Url__c + 'confirmzipcode?personId=' + this.ConsumerId) + '%26K%3D' + result1.OriginalModelNumber__c + '%26M%3D' + result1.OriginalModelNumber__c + '%26S%3D' + this.SerialNo
                                }
                            }).catch(error => {
                                console.log('MYA_ProductDetails: ',error);
                            });
                    }
                })
                .catch(error => {
                    console.error('getmyaConfigs: ',error);
                });           
        }
    }
    getProductAddress(){
        Mya_GetAddressDetails() //address details related to particular asset
                            .then(result => {
                                this.selectOptions = this.defaultSelectOption;
                                for (const list of result) {
                                    if (list.Account__c == this.AccId) {
                                        this.Location_Details = list;
                                    }
                                    const option = {
                                        label: list.Account__r.BillingStreet,
                                        value: list.Account__c
                                    };
                                    this.selectOptions = [...this.selectOptions, option];
                                }
                            }).catch(error => {
                                console.log('Mya_GetAddressDetails: ', error)
                            });
    }
    //get manufacture model number

    @wire(getManufactureModel, { ModelNo: '$modelNo' })
    if (result) {
        this.ManufactureModelNo = result.data;
        if (this.ManufactureModelNo) {
            //this.ManfactureModel = this.ManufactureModelNo.MN__c; //manufacture model number
            this.ManfactureModel = this.ManufactureModelNo.StockKeepingUnit; //manufacture model number
        }
    }

//hide links for non GEA product
  /*  @wire(getIsGEAProduct, { assetId: '$AssetId' })
    if (result) {
        this.displayLinks = result.data;
        console.log('is GEA product',this.displayLinks);
        
      
      
        /* for(const prodt of this.checkProduct ){
            this.isGEAProduct = prodt.Product2.Is_GEA_Product__c;
            console.log('this.isGEAProduct',this.isGEAProduct)
            if(this.isGEAProduct === 'Yes'){
                this.displayLinks = true;
                console.log('this.displayLinks true/false',this.displayLinks);
            }
            else{
                this.displayLinks = false;
                console.log('this.displayLinks true/false',this.displayLinks);
               
            } 
        }*/
       
       
    

    //get details from endeca response
    InfoDetails() {
        if(this.AstDetail) {            
            this.isConsumerReady = this.AstDetail.IsConsumerReady;
            this.Description = this.AstDetail.ProductDescription;
        } 
        if(this.AstDetail && this.isConsumerReady) {
            this.Brand = this.AstDetail.Brand;               
            //this.ImageUrl = this.AstDetail.DefaultImageUrl + '&Variant=ViewLarger';
            this.ImageUrl = this.AstDetail.DefaultImageUrl; // changed as part of SPR-146 Salsify-endeca transisiton project changes
            this.PartsWarranty = this.AstDetail.PartsWarranty;
            this.WarrantyNotes = this.AstDetail.WarrantyNotes;
            this.LaborWarranty = this.AstDetail.LaborWarranty;
            this.RelParts = this.AstDetail.RelatedParts;
            this.Ductless = this.AstDetail.IsDuctless;
            this.OwnerManualLink = this.AstDetail.UserManualUrl;
            this.Category = this.AstDetail.CommercialCategories; 
            this.Relparts();                    
            this.ProdSpeclink();
            this.ReviewLinks();
            this.showScheduleCheck();
        }
        if(!this.AstDetail || !this.isConsumerReady) {
            this.OwnerSupport();
        }
    }

    showScheduleCheck() {
        showSchedule({ SKU: this.modelNo }) //get product code from smc_model_ca
                                .then(result => {
                                    //if (result != '47' || result != '48' || result != '49' || result != '621' || result != '6211' || result != '622' || result != '6221' || result != '622N' || result != '62' || result != '623') 
                                    //if(this.Urllist.CampaignId_Parameter__c.includes(result))
                                    if(result == 1)
                                    {
                                        this.showScheduleUrl = false;
                                    } else {
                                        this.showScheduleUrl = true;
                                    }
                                }).catch(error => {
                                    console.log('showSchedule: ',error);
                                    this.error = error.message;
                                    this.showScheduleUrl = false;
                                });
    }

    //related parts and accessories
    isRelatedExecuted = false;
    Relparts() {
        if (this.RelParts && !this.isRelatedExecuted) {
            for (const rel of this.RelParts) {
                const Details = {
                    PDes: rel.Description,
                    Plink: this.Urllist.PartsSiteBaseUrl__c + '/store/parts/spec/' + rel.SKU,
                    //iLink: this.Urllist.Image_Url__c + rel.Images_DisplayImageName + '&Variant=SpecPage',
                    iLink: rel.Images_Path, // changed as part of SPR-146 Salsify-endeca transisiton project changes
                    PModel: rel.SKU,
                };
                this.RelAcc = [...this.RelAcc, Details];
            }
            this.isRelatedExecuted = true;
        }
    }
    //schedule service and product specs links
    ProdSpeclink() {
        let product;
        if(this.AstDetail) {            
            product = this.AstDetail;
        }
        getProductSpecLinks({})
            .then(result => {
                if(product) {
                    if (product.Brand.includes("GE")) {                    
                        if (product.IsDuctless == false) {
                            this.ProdSpecs = result.filter(item => item.Brand__c == 'GEA')[0].Spec_Link__c + this.modelNo;
                        } else if (product.IsDuctless == true) {
                            this.ProdSpecs = result.filter(item => item.Brand__c == 'GEA')[0].Ductless_Spec_Link__c;
                        }
                    } else if (product.Brand == 'Cafe') {
                        this.ProdSpecs = result.filter(item => item.Brand__c == 'Cafe')[0].Spec_Link__c + this.modelNo;
                    } else if (product.Brand == 'Hotpoint') {
                        this.ProdSpecs = result.filter(item => item.Brand__c == 'Hotpoint')[0].Spec_Link__c + this.modelNo;
                    } else if (product.Brand == 'Monogram') {
                        this.ProdSpecs = result.filter(item => item.Brand__c == 'Monogram')[0].Spec_Link__c + this.modelNo;
                    } else if (product.Brand == 'Haier') {                    
                        if (product.IsDuctless == false) {
                            this.ProdSpecs = result.filter(item => item.Brand__c == 'Haier')[0].Spec_Link__c + this.modelNo;
                        } else if (product.IsDuctless == true) {
                            this.ProdSpecs = result.filter(item => item.Brand__c == 'Haier')[0].Ductless_Spec_Link__c;
                        }
                    } else {
                        this.ProdSpecs = result.filter(item => item.Brand__c == 'GEA')[0].Spec_Link__c + this.modelNo;
                    }
                } else {
                    this.ProdSpecs = result.filter(item => item.Brand__c == this.BrandValue)[0].Spec_Link__c + this.modelNo;
                }
                
            }).catch(error => {
                console.error('getProductSpecLinks: ', error);
            });
        
        // if (this.Brand.includes("GE")) {
        //     this.ProdSpecs = this.Urllist.Product_Specs_GEA__c + '/appliance/gea-specs/' + this.modelNo
        // }
        // if (this.Brand == 'Cafe') {
        //     this.ProdSpecs = this.Urllist.Product_Specs_Cafe__c + '/appliances/' + this.modelNo + '/overview'
        // }
        // if (this.Brand == 'Haier') {
        //     this.ProdSpecs = this.Urllist.Product_Specs_Haier__c + '/appliance/specs/' + this.modelNo
        // }
        // if (this.Brand == 'Hotpoint') {
        //     this.ProdSpecs = this.Urllist.Product_Specs_Hotpoint__c + '/appliance/hotpoint-specs/' + this.modelNo
        // }
        // if (this.Brand == 'Monogram') {
        //     this.ProdSpecs = this.Urllist.Product_Specs_Monogram__c + '/us/specs/' + this.modelNo
        // }
        // if (this.Brand == null || this.Brand == '') {
        //     this.ProdSpecs = this.Urllist.Product_Specs_GEA__c + '/appliance/gea-specs/' + this.modelNo
        // }

        this.AllParts = this.Urllist.Owner_Support_GEA__c + '/ge/parts/?icid=GEARpartsflyout-allparts'
        this.Partslink = this.Urllist.PartsSiteBaseUrl__c + '/store/parts/KeywordSearch?q=' + this.modelNo + '&icid=QR_RelatedParts'
        
        // this.ScheduleServiceLink = this.Urllist.EService_Source_URL__c+encodeURI(this.Urllist.EService_Target_Url__c+'idpRequestToken')+'&language=en_US&allowGuest=1&state='+encodeURI(this.Urllist.EService_Target_Url__c+'confirmzipcode?personId='+this.ConsumerId)+'%26K%3D'+this.modelNo+'%26M%3D'+this.ManfactureModel+'%26S%3D'+this.SerialNo
        // console.log('link->'+this.ScheduleServiceLink)
        // if (this.Brand == 'Haier') {
        //     if (this.Ductless == false) {
        //         this.ScheduleServiceLink = this.Urllist.Product_Specs_Haier__c + '/support/schedule-service'
        //     }
        //     if (this.Ductless == true) {
        //         this.ScheduleServiceLink = this.Urllist.Product_Specs_Haier__c + '/find-a-dealer/us'
        //     }
        // }
        // if (this.Brand.includes("GE")) {
        //     if (this.Ductless == true) {
        //         this.ScheduleServiceLink = this.Urllist.Product_Specs_GEA__c + '/ductless'
        //     }
        // }
        this.OwnerSupport();
    }

    //owner support links
    OwnerSupport() {
        
        if (this.ValidModel == false || !this.isConsumerReady) {
            if (this.BrandValue.includes("GE") || this.BrandValue == 'Hotpoint' || this.BrandValue == 'Monogram') {
                this.ownerUrl = this.Urllist.Owner_Support_GEA__c + '/ge/service-and-support/'
            } else if (this.BrandValue == 'Haier') {
                this.ownerUrl = this.Urllist.Product_Specs_Haier__c + '/support/products'
            } else if (this.BrandValue == 'Cafe') {
                this.ownerUrl = this.Urllist.Product_Specs_Cafe__c + '/support/contact-us'
            }
        } else if (this.ValidModel == true) {
            if (this.Brand.includes("GE")) {
                if (this.Ductless == false) {
                    this.ownerUrl = this.Urllist.Product_Specs_GEA__c + '/appliance/gea-specs/' + this.modelNo + '/support'
                } else if (this.Ductless == true) {
                    if (this.Category == 'Room Air Conditioners' || this.Category == 'Split-System') {
                        this.ownerUrl = this.Urllist.Owner_Support_GEA__c + '/ductless/'
                    }
                }
            } else if (this.Brand == 'Cafe') {
                this.ownerUrl = this.Urllist.Product_Specs_Cafe__c + '/shop?search_query=' + this.modelNo + '&results=manuals';
            } else {
                let product = this.AstDetail;
                this.productBrand = product.Brand;
                this.productCategory = product.CommercialCategories;
                if(product.IsDuctless) {
                    this.productCategory = 'Ductless';
                }
                getStaticOwnerLinks({}) 
                        .then(result => {            
                            let data = result.filter(item=> item.Category__c == this.productCategory);
                            if(data.length > 0){
                                this.setStaticLink(this.productBrand, data);
                            } else {
                                let matchingdata = result.filter(item=> (item.Category__c).indexOf(this.productCategory) !== -1);
                                if(matchingdata.length > 0){
                                    this.setStaticLink(this.productBrand, matchingdata);
                                } else {
                                    let defaultData = result.filter(item=> item.Category__c == 'Default');
                                    this.setStaticLink(this.productBrand, defaultData);
                                }  
                            }                        
                        }).catch(error => {
                            console.error('getStaticOwnerLinks: ',error);
                        });       
            }
        }
    }
    // set static owner url
    setStaticLink(brand, data){
        if (brand == 'Hotpoint') {
            this.ownerUrl = data[0].Hotpoint_Link__c;
        } else if (brand == 'Monogram') {
            this.ownerUrl = data[0].Monogram_Link__c;
        } else if (brand == 'Haier') {
            this.ownerUrl = data[0].Haier_Link__c;
        }
    }
    //related parts site redirection    
    redirectlink(event) {
        this.imageurl = event.target.value;
        window.location(imageurl);
    }
    
    //review_linkG
    //review_linkC
    //review_linkH
    ReviewLinks() {
        if (this.Brand.includes("GE")) {
        this.review_links = this.Urllist.Appliance_review_link_GEA__c + this.modelNo + this.Urllist.Appliance_Campaign_Parameter_GEA__c
        }
        if (this.Brand == 'Cafe'){
        this.review_links = this.Urllist.Appliance_review_link_cafe__c + this.modelNo + this.Urllist.Appliance_Campaign_Parameter_Cafe__c
        }
        if (this.Brand == 'Haier'){
        this.review_links = this.Urllist.Appliance_review_link_Haier__c + this.modelNo + this.Urllist.Appliance_Campaign_Parameter_Haier__c
        }
        if (this.Brand == 'Hotpoint'){
            this.review_links = this.Urllist.Review_Url_Hotpoint__c + this.modelNo + '&bvcampaignId=HotpointMYA_SpecPg'
        }
        if (this.Brand == 'Monogram') {
            this.review_links = this.Urllist.Review_Link_Monogram__c + this.modelNo + '&bvcampaignId=MonogramMYA_SpecPg'
        }
    }
    //serial number
    editSerialNoHandler() {
        this.showSerialNoForm = true
    }

    closeFormHandler() {
        this.showSerialNoForm = false
    }
    
    serialNumberHandler(event) {
        this.upSerialNo = event.target.value;
    }

    SaveSerial() {
        //code to save the serial number
        const fields = {};
        fields[Id_Field.fieldApiName] = this.AssetId;
        fields[Serial_Number.fieldApiName] = this.upSerialNo;
        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.showSerialNoForm = false
                return refreshApex(this.wiredAssetDetails);
            })
    }

    //address update 
    locationUpHandler() {
        this.addForm = true
        
    }

    closeLocationHandler() {
        this.addForm = false
    }

    AddressHandle(event) {
        this.Address1 = event.target.value
    }

    CityHandler(event) {
        this.city = event.target.value
    }

    StateHandler(event) {
        //alert(event.currentTarget.dataset.value);
        this.state = event.target.value;
    }

    CodeHandler(event) {
        this.zipcode = event.target.value
    }
    
    AddNameHandler(event) {
            this.AddName = event.target.value
        }
        //update address record
    addressHandler() {
        if (this.Existing_Address) {
            Mya_UpdateAssetAddress({ AccountId: this.Existing_Address, ProdId: this.AssetId })
                .then((result) => {
                    this.AccId = this.Existing_Address;
                    this.getProductAddress();
                    this.addForm = false;
                    //location.reload();
                    //this.handleRefresh();
                    //return refreshApex(this.wiredAssetDetails);
                }).catch(error => {
                    console.error('Mya_UpdateAssetAddress: ', error);
                })
        } else {
            if (this.isInputValid()) {
                Mya_UpdateAddress({ Address: this.Address1, City: this.city, State: this.state, Code: this.zipcode, Name: this.AddName, ProdId: this.AssetId })
                    .then(result => {
                        console.log("result ", result);
                        /*if (result.Success) {*/
                            this.AccId=result[0].AccountId;
                            this.getProductAddress();
                            this.addForm = false;
                            //this.handleRefresh();  
                        //   return refreshApex(this.wiredAssetDetails);
                        /*} else {
                            console.error('Mya_UpdateAddress: ', result);
                        }*/
                    })
                    .catch(error => {
                        console.error('Mya_UpdateAddress: ', error);
                    })
            }
        }
    }
    handleRefresh() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: (window.location.origin).concat(window.location.pathname)
            }
        });
    }

    // Custom validation method for validate class fields

    isInputValid() {

        let isValid = true;

        let inputFields = this.template.querySelectorAll('.validate');

        inputFields.forEach(inputField => {

            if (!inputField.checkValidity()) {

                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }

    //asset nick anme
    nameHandler(event) {
        this.setName = event.target.value
    }

    setNickNameHandler(event) {
        //code for nickname
        const fields = {};
        fields[Id_Field.fieldApiName] = this.AssetId;
        fields[Nickname.fieldApiName] = this.setName;
        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.nickNameForm = false
                return refreshApex(this.wiredAssetDetails)
            })
    }

    UpNickNameHandler() {
        this.nickNameForm = true
    }

    CloseNickNameHandler() {
        this.nickNameForm = false
    }


    updateNickName() {
        //code to save nickname
        const fields = {};
        fields[Id_Field.fieldApiName] = this.AssetId;
        fields[Nickname.fieldApiName] = this.setName;
        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.nickNameForm = false
                return refreshApex(this.wiredAssetDetails)
            })
    }
}