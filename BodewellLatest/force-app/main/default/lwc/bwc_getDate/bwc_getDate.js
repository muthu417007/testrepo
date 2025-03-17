import { LightningElement, api, wire, track } from 'lwc';
import getSkew from '@salesforce/apex/BWC_ADC.getADC_Details'
import getProductValues from '@salesforce/apex/BWC_ADC.getProductValues'
import calendarDate from '@salesforce/apex/BWC_CalendarApi.BWC_CalendarApiMethod'
import EstimatedDate from '@salesforce/apex/BWC_CalendarApi.getCalenderResponse'
import EstimatedDateSmallAppliance from '@salesforce/apex/BWC_CalendarApi.getEstimatedDateForSmallAppliance'


import zipCodeChannel from '@salesforce/messageChannel/zipCodeChange__c';
import { ProductAdapter, ProductPricingAdapter } from 'commerce/productApi';
import { subscribe, MessageContext } from 'lightning/messageService';
export default class Bwc_getDate extends LightningElement {
    @track skewData;
    @api skewDataList;
    @api skewError;
    @track arr = [];
    @api val;
    @track zipCode;
    publisherMessage = '';
    subscription = null;
    @api productId;
    @track materialStock;
    @track brand;
    @track sku;
    @track materialStockandBrand = false;
    @track SkuName = false;
    @track partStat = false;
    @track restriction = false;
    @track partStatAndSuperCount = false;
    @track ispickupDate = false;
    @track pickupDate;
    @track availableQuantity;
    @track quantityAndPartstat = false;
    @track etaDate;
    @track partStatFieldData;
    @track isShowShipMessage = false;
    @track isPurchasable;
    @track isPLPVisible;
    @track exploadedParts;
    @track deliveryType;
    @track shipDate;
    @track estimatedDate;
    @track isPart;
    @track supersededPartItem;
    @track isSuperSeded;
    @api isOnClearance;
    @track isClearance = false;
   // @track OOSFlag=false;


    @wire(MessageContext)
    messageContext;
    connectedCallback() {

        if (localStorage.getItem('zipcode')) {
            //An Id key is in the local Storage
            this.localStorageZipCode = JSON.parse(localStorage.getItem('zipcode'));
            this.zipCode = this.localStorageZipCode.Zipcode;
            //Clear local storage after getting the values
            //this.getSkewData();

        }


        this.handleSubscribe();

    }

    getCalenderDate() {
        console.log('pdddIIDD>>' + this.productId);
        console.log('calZipCode>>>' + this.zipCode);
        calendarDate({ postalCodeInstance: this.zipCode, productIdInstance: this.productId, availabilityShipDate: this.shipDate })
            .then(result => {
                console.log('calDate>>>>>>' + result);
                if (result !== '' && result !== null && result !== undefined && ((this.deliveryType != 'sps' && this.deliveryType != 'sps fee') || !this.isShowShipMessage)) {
                    const inputDate = new Date(result);
                    console.log('inpDate>>' + inputDate);
                    const options = { year: 'numeric', month: 'long', day: 'numeric' };
                    const formattedDate = inputDate.toLocaleDateString('en-US', options);
                    console.log('pickupDate>>' + formattedDate);
                    if (formattedDate !== null && formattedDate !== undefined && formattedDate !== '') {
                        this.ispickupDate = true;
                        this.val = "Estimated Pickup Date " + formattedDate;
                        console.log('insideIfGetDate');
                    }
                }
                else {
                    this.getEstimatedDeliveryDate();
                }
            })
            .catch(error => {
                console.log('calError>>>', error);
            })
    }


    @wire(getProductValues, { productId: '$productId' })
    wiredData({ error, data }) {
        if (data) {
            console.log('ProductData-->>', data);
            this.deliveryType = data.productRecord.BWC_Delivery_Type__c;
            this.partStatFieldData = data.productRecord.BWC_PARTSTAT__c;
            this.isPurchasable = data.productRecord.BWC_IsPurchasable__c;
            this.isPLPVisible = data.productRecord.BWC_PLPIsVisible__c;
            this.exploadedParts = data.productRecord.BWC_Exploded_Diagram_Parts__c;
            this.isPart = data.productRecord.BWC_Is_Part__c;
            if (data.productRecord.ProductClass == 'VariationParent') {
                var jsonString = data.productRecord.BWC_Exploded_Diagram_Parts__c;
                var jsonObject = JSON.parse(jsonString);
                this.sku = jsonObject['Exploded Diagram Parts']['sku'];
            }
            else {
                this.sku = data.productRecord.StockKeepingUnit;
            }
            console.log('SKU Value:', this.sku);
            if (data.productRecord.BWC_PARTSTAT__c === 3) {
                this.partStat = true;
            }
            if (data.productRecord.Restrictions__c === 'Yes') {
                this.restriction = true;
            }
            if (data.productRecord.BWC_Material_Stock_Indicator__c === 'AC' && data.productRecord.BWC_Brand__c !== 'Cafe') {
                this.materialStockandBrand = true;
            }
            if (data.productRecord.StockKeepingUnit == 'IM4LED' || data.productRecord.StockKeepingUnit == 'IM4D') {
                this.SkuName = true;
            }
            if (data.productRecord.BWC_SUPERCEDE_COUNT__c > 0 && data.productRecord.BWC_PARTSTAT__c === 2) {
                this.partStatAndSuperCount = true;
            }
            if (data.productRecord.Is_Accessory__c == 'No' && data.productRecord.Is_Finished_Good__c == 'Yes' && data.productRecord.BWC_Delivery_Type__c == 'sps' && data.productRecord.BWC_IsPurchasable__c == true) {
                this.isShowShipMessage = true;
            }
            if (data.relatedItemsList.length && this.isPart == true) {
                this.supersededPartItem = data.relatedItemsList[0].Related_Product__r.StockKeepingUnit;
                this.isSuperSeded = true;
            }
            this.getSkewData();

        }
        else if (error) {
            console.log('errorinProductVals??', error);
        }
    }


    getEstimatedDeliveryDate() {
        console.log('this.shipDate>>' + this.shipDate);
        console.log('this.deliveryType>' + this.deliveryType);
        console.log('this.zipCode>' + this.zipCode);
        console.log('this.pickupDAte-->' + this.ispickupDate);
        if (this.deliveryType != 'sps' && this.deliveryType != 'sps fee') {
            const formattedDate = new Date(this.shipDate).toISOString().slice(0, 10);
            console.log('strConvertedDate>>' + formattedDate);

            let payload = '{"zipcode": "' + this.zipCode + '","mode": "' + this.deliveryType.toUpperCase() + '","typeOfCall": "FIRST DATE","startDate": "' + formattedDate + '","noOfDays": 180}';
            console.log('payload>>' + payload);
            EstimatedDate({ calendarPayload: payload })
                .then(result => {
                    console.log('CalendarResult==>', JSON.parse(result));
                    const data = JSON.parse(result);
                    console.log('date>>', data.calendar_dates[0]);
                    this.estimatedDate = data.calendar_dates[0].date;

                    console.log('estimatedDate-->' + this.estimatedDate);
                    const inputDate = new Date(this.estimatedDate);
                    console.log('inputDate>>' + inputDate);
                    const formatUSDate = new Date(this.estimatedDate).toLocaleDateString('en-GB');
                    const parts = formatUSDate.split('/');
                    const etaDate = parts[1] + '-' + parts[0] + '-' + parts[2];
                    console.log('etaDate->', etaDate);
                    const options = { year: 'numeric', month: 'long', day: 'numeric' };
                    const formattedDate = inputDate.toLocaleDateString('en-US', options);
                    console.log('formattedDate->', formattedDate);
                    const dateAfter90Days = new Date();
                    const formattedDateAfter90Days = this.addDays(dateAfter90Days, 90).toLocaleDateString('en-US', options);
                    console.log('fomatted90->', formattedDateAfter90Days);
                    console.log('this.isPurchasable InSkuData>>' + this.isPurchasable);
                    console.log('this.partStatFieldData-->' + this.partStatFieldData);
                    console.log('showShipMessage>>' + this.isShowShipMessage);
                    if (this.availableQuantity == undefined && (this.partStatFieldData == 0 || this.partStatFieldData == 1) && inputDate > dateAfter90Days) {
                        this.quantityAndPartstat = true;
                    }
                    else if (this.isPurchasable === false) {
                        this.val = "This model is no longer manufactured";
                    }
                    else if (formattedDate === "Invalid Date" && (this.zipCode != undefined && this.zipCode != null)) {
                        this.val = "Out of stock online";
                        //this.OOSFlag=true;
                    }
                    else {
                        if (this.availableQuantity !== 10000000000 && this.availableQuantity != undefined && this.isPurchasable !== false && (this.zipCode != undefined && this.zipCode != null)) {
                            this.val = "Estimated Delivery Date " + formattedDate;
                        }
                        else if (this.availableQuantity === 10000000000 && this.isPurchasable !== false && (this.zipCode != undefined && this.zipCode != null)) { // need to compare ship date if the date is under 90 days in future , this is pending
                            this.val = "Estimated Delivery Date " + formattedDate;
                        }
                        else if (this.availableQuantity === 10000000000 && this.isPart == true) {
                            this.val = "<strong>Temporarily Out of Stock.</strong> <br>Earliest Available Date:" + etaDate;
                        }
                        else if (this.isPurchasable === false) {
                            this.val = "This model is no longer manufactured";
                        }
                        else if (this.zipCode === undefined || this.zipCode === null) {
                            this.val = "";
                        }

                        else {
                            this.val = "Out of stock online ";
                            //this.OOSFlag=true;
                        }
                    }
                    console.log('this.val EstimatedDate>>' + this.val);


                })
                .catch(error => {
                    console.log('error in Calendar==>', error);
                    this.val = "Out of stock online";
                    //this.OOSFlag=true;
                    console.log('this.val Error EstimatedDate>>' + this.val);

                })

        }
        else {
            console.log('this.sku>>' + this.sku);
            console.log('zipCode-->' + this.zipCode);
            const skuList = [];
            skuList.push(this.sku);
            let itemType = this.isPart ? 'PARTS_ITEM' : 'FG';
            EstimatedDateSmallAppliance({ skuList: skuList, zipCode: this.zipCode, itemType: itemType })
                .then(result => {
                    console.log('CalendarResultOfSmallAppliance==>', JSON.parse(result));
                    const data = JSON.parse(result);
                    console.log('shipdate-->' + data.availabilityDetails[0].shipDate);
                    this.estimatedDate = data.availabilityDetails[0].shipDate;
                    if (data.availabilityDetails[0].shipDate !== null) {
                        this.estimatedDate = this.estimatedDate.replace(/T\d{2}:\d{2}:\d{2}/, 'T00:00:00');
                    }
                    const inputDate = new Date(this.estimatedDate);
                    console.log('inputDate>>' + inputDate);
                    const formatUSDate = new Date(this.estimatedDate).toLocaleDateString('en-GB');
                    const parts = formatUSDate.split('/');
                    const etaDate = parts[1] + '-' + parts[0] + '-' + parts[2];
                    console.log('etaDate->', etaDate);
                    const options = { year: 'numeric', month: 'long', day: 'numeric' };
                    const formattedDate = inputDate.toLocaleDateString('en-US', options);
                    console.log('formattedDate->', new Date(formattedDate));

                    const dateAfter90Days = new Date();
                    const formattedDateAfter90Days = this.addDays(dateAfter90Days, 90).toLocaleDateString('en-US', options);
                    console.log('fomatted90->', new Date(formattedDateAfter90Days));

                    console.log('this.isPurchasable InSkuData>>' + this.isPurchasable);
                    console.log('this.partStatFieldData-->' + this.partStatFieldData);
                    console.log('showShipMessage>>' + this.isShowShipMessage);
                    if (data.availabilityDetails[0].availableQuantity == undefined && (this.partStatFieldData == 0 || this.partStatFieldData == 1) && inputDate > dateAfter90Days) {
                        this.quantityAndPartstat = true;
                    }
                    else if (this.isShowShipMessage == true && data.availabilityDetails[0].availableQuantity !== 10000000000 && (this.zipCode != undefined && this.zipCode != null)) {
                        this.val = 'Ships in 2-7 Business Days';
                    }
                    else if (this.isPurchasable === false) {
                        this.val = "This model is no longer manufactured";
                    }
                    else if (formattedDate === "Invalid Date" && (this.zipCode != undefined && this.zipCode != null)) {
                        this.val = "Out of stock online";
                        //this.OOSFlag=true;
                    }
                    else {
                        if (data.availabilityDetails[0].availableQuantity !== 10000000000 && data.availabilityDetails[0].availableQuantity != undefined && this.isPurchasable !== false && (this.zipCode != undefined && this.zipCode != null)) {
                            this.val = "Estimated Delivery Date " + formattedDate;
                        }
                        else if (data.availabilityDetails[0].availableQuantity === 10000000000 && this.isPurchasable !== false && (this.zipCode != undefined && this.zipCode != null)) {
                            this.val = "Estimated Delivery Date " + formattedDate;
                        }
                        else if (data.availabilityDetails[0].availableQuantity === 10000000000 && this.isPart == true && (this.zipCode != undefined && this.zipCode != null)) {
                            this.val = "<strong>Temporarily Out of Stock.</strong> <br> Earliest Available Date:" + etaDate;
                        }
                        else if (this.isPurchasable === false) {
                            this.val = "This model is no longer manufactured";
                        }
                        else if (this.zipCode === undefined || this.zipCode === null) {
                            this.val = "";
                        }
                        else {
                            this.val = "Out of stock online";
                            //this.OOSFlag=true;
                        }
                    }
                    console.log('this.val EstimatedDateSmallAppliance>>' + this.val, this.isPLPVisible, this.isPurchasable);

                })
                .catch(error => {
                    console.log('err EstimatedDateSmallAppliance>>' + error);
                    this.val = "Out of stock online";
                   // this.OOSFlag=true;
                })
        }

    }

    getSkewData() {
        console.log('childSku InFunction>>' + this.sku);
        this.arr = [];
        this.arr.push(this.sku);
        console.log('arr2>>>' + this.arr);
        console.log('zipCodeinGetSkew>>>' + this.zipCode);
        getSkew({
            skuList: this.arr,
            postalCodeInstance: this.zipCode
        })
            .then(result => {
                this.skewData = result;
                console.log('resultOfSkew>>', result);
                this.availableQuantity = this.skewData.availabilityDetails[0].availableQuantity;
                this.shipDate = this.skewData.availabilityDetails[0].shipDate;
                console.log('clearance->', this.isOnClearance);

                if (this.isOnClearance && (this.availableQuantity <= 0 || this.availableQuantity == null || this.availableQuantity == undefined) && new Date(this.shipDate) < new Date()) {
                    console.log('into clearance condition');
                    this.isClearance = true;
                }
                this.val = '';
                this.getCalenderDate();

            })
            .catch(error => {
                this.skewError = error;
                console.log('skuError', error);
            })
    }

    addDays(date, days) {
        const result = new Date(date);
        result.setDate(result.getDate() + days);
        return result;
    }

    handleSubscribe() {
        if (this.subscription) {
            return;
        }
        this.subscription = subscribe(this.messageContext, zipCodeChannel, (message) => {
            console.log('msg>>>' + message.message);

            const fullAddress = message.message;
            this.zipCode = fullAddress.Zipcode;
            if (this.zipCode) {

                this.getSkewData();

            }

        });
    }
}