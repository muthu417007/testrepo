import { LightningElement, track, wire, api } from 'lwc';
import { navigate, NavigationContext } from 'lightning/navigation';
import BWC_UI from '@salesforce/resourceUrl/BodewellTheme';
import getAvailableDeliveryDates from '@salesforce/apex/BWC_CartController.getDeliveryDates';
import getConsumerZipcode from '@salesforce/apex/BWC_CartController.getConsumerZipcode';
import addPartsShippingAsLineItem from '@salesforce/apex/BWC_ProtectionPlanController.addPartsShippingAsLineItem';
import { publish, subscribe, MessageContext, createMessageContext } from "lightning/messageService";
import getShipTypeFee from '@salesforce/apex/BWC_CartController.getShipTypeFees';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CheckoutInformationAdapter, updateDeliveryMethod, updateShippingAddress } from 'commerce/checkoutApi';
import zipCodeChannel from '@salesforce/messageChannel/zipCodeChange__c';

// Abhishek change
import calculateTotalAmount from '@salesforce/apex/BWC_CalculateEntirePrice.calculateTotalAmount';
import { restartCheckout } from "commerce/checkoutApi";
import BWC_CallCheckoutIntrgration from "@salesforce/apex/BWC_ShippingAndBillingAddressController.BWC_CallCheckoutIntrgration";
import updateCartStatus from "@salesforce/apex/BWC_ShippingAndBillingAddressController.updateCartStatus";
import CHECKOUT_CHANNEL from "@salesforce/messageChannel/BWC_Checkout__c";
import modifyDeliveryGroup from "@salesforce/apex/BWC_ModifyDeliveryGroup.updateCurrentDeliveryGroup";
import { CartSummaryAdapter } from 'commerce/cartApi'

// Abhishek change


export default class Bwc_checkoutProducts extends LightningElement {

    @track localStorageProducts = {};
    @track _checkoutItems = [];

    @track _cartItems = [];
    _navigationContext;
    _accountId;
    @track _partsList = [];
    @track _hdList = [];
    @track _prodShippingList = [];
    @track _pickupList = [];
    @track _sdsList = [];
    hdListflag = false;
    partsListflag = false;
    prodShippingListflag = false;
    @track _cartTotal = 0.0;
    @track totalHdItems;
    pickupListflag = false;
    sdsListFlag = false;
    _cartDeliveryTypes = {};
    _deliveryTypeData = {};
    _productRecords = {};
    _zipCodeServiceResp;
    @track minDeliveryDate;
    @track maxDeliveryDate;
    @track expectedDeliveryDate;
    @track expectedDeliveryDateNew;
    @track expectedpickupDeliveryDate;
    @track expectedpickupDeliveryDateNew;
    @track fDeliveryData;
    @track pickupDeliveryData;
    @track homeDeliveryFee;
    @track smallPackageFee;
    @track freeStandingInstallFee;
    @track partsShipFee;
    @track partsShipfree='';
    @track partsShipOptions;
    @track selectedPartsShip;
    MONTHS = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    DAYS = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"];
    WEEK = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturaday"];

    @track state;
    @track localStorageZipCode;
    subscription;
    context = createMessageContext();
    @track partsShipOptions = [];
    @track deliveryMethodIdInstance;
    // Abhishek change
    @track cartId;
    @track isPlaceOrderDisabled = false;
    @track skuList = [];
    @track openSpinner;
    isPickUpModel = false;
    // Abhishek change

    HOME_DELIVERY = BWC_UI + '/icons/checkout-icons/in-home-delivery.svg';
    FEDEX_SHIPPING = BWC_UI + '/icons/checkout-icons/Fedex-shipping.svg';
    FREIGHT_SHIPPED = BWC_UI + '/icons/checkout-icons/Freight-shipped.svg';
    ORDER_PICKUP = BWC_UI + '/icons/checkout-icons/Order-Pick-Up.svg';
    PRODUCT_SHIPPED = BWC_UI + '/icons/checkout-icons/Products-shipped.svg';
    PART_SHIPPED = BWC_UI + '/icons/checkout-icons/Parts-shipped.svg';
    DELIVERY_CALENDER = BWC_UI + '/icons/checkout-icons/Delivery-Calendar.svg';

    @api
    get zipCode() {
        return this._zipCode;
    }
    set zipCode(val) {
        this._zipCode = val;
    }

    connectedCallback() {

        /*if (localStorage.getItem('zipcode')) {
            this.localStorageZipCode = JSON.parse(localStorage.getItem('zipcode'));
            this.zipCode = this.localStorageZipCode.Zipcode;
            this.state = this.localStorageZipCode.State;
            console.log('IF ZIPCODE IS ==> ' + this.zipCode + ' ' + JSON.stringify(this.localStorageZipCode));

        }*/
        if (localStorage.getItem('checkoutProducts')) {
            this.localStorageProducts = JSON.parse(localStorage.getItem('checkoutProducts'));
            console.log('Checkout Data is ' + JSON.stringify(this.localStorageProducts));
            this._cartItems = this.localStorageProducts.allItems;
            console.log('this._cartItems-->', this._cartItems);
            this._accountId = this.localStorageProducts.accountId;
            /*this._hdList = this.localStorageProducts.hdList;
            this._sdsList = this.localStorageProducts.sdsList;
            
            this._pickupList = this.localStorageProducts.pickupList;
            this._prodShippingList = this.localStorageProducts.fedexList;
            this.hdListflag = this._hdList.length > 0 ? true : false;
            this.sdsListFlag = this._sdsList.length > 0 ? true : false;
            this.partsListflag = this._partsList.length > 0 ? true : false;
            this.prodShippingListflag = this._prodShippingList.length > 0 ? true : false;
            this.pickupListflag = this._pickupList.length > 0 ? true : false;*/
            this._cartTotal = this.localStorageProducts.total;
            this._partsList = this.localStorageProducts.partsList;
            this.partsIds= this.localStorageProducts.partsList.map(part => part.id);
            this.partsShipOptions = this.localStorageProducts.partsShipOptions;
            this.selectedPartsShip = this.localStorageProducts.partsShipSelected;
            //this.partsShipFee = this.localStorageProducts.partsShipFee;

            /*if (this._hdList.length > 0 || this._sdsList.length > 0) {
                this.totalHdItems = this._hdList.length + this._sdsList.length;
                this.getAvailableDeliveryDates('SDS');
            }
            if (this._pickupList.length > 0) {
                this.getAvailableDeliveryDates('WILLCALL');
            }*/

        }



    }
    shipTypeFlag = false;
    @wire(getConsumerZipcode, { accountId: '$_accountId' })
    getConsumerZip({ error, data }) {
        if (data) {
            console.log('zip and state ' + JSON.stringify(data));
            this._zipCode = data.PostalCode;
            this.state = data.State;
            console.log('zipcode and state are ' + this._zipCode + ' ' + this.state);
            if (this._zipCode && this._cartItems) {
                this.shipTypeFlag = true;
            }
        } else if (error) {
            console.log('error occured ' + error);
        }
    }
    @api
    get checkout() {
        return this._checkoutItems;
    }
    set checkout(val) {
        this._checkoutItems = val;
        console.log("_checkout ITEMs===> " + JSON.stringify(val));
    }

    handlePartsShipType(event) {
        this.selectedPartsShip = event.detail.value;
        console.log("##Selected Option", this.selectedPartsShip);
       
        this.addPartsShippingAsLineItem();

        if (this.selectedPartsShip=='Standard_Shipping') {
            if (this.localStorageProducts.isUserMember === true) {
                this.partsShipfree = 'FREE';
            }
            else {
                this.partsShipfree = '';
            }
            //console.log("this.free from summary", this.free);
            this.partsShipFee = this.partsShipOptions.find(record => record.value === 'Standard_Shipping').additionalParam;
           // console.log("##partsShipFee", this.partsShipFee);
            

        }
        if (this.selectedPartsShip=='Second_Day') {
            this.partsShipfree='';
            this.partsShipFee = this.partsShipOptions.find(record => record.value === 'Second_Day').additionalParam;
           

        }
        if (this.selectedPartsShip=='Next_Day') {
            this.partsShipfree='';
            this.partsShipFee = this.partsShipOptions.find(record => record.value === 'Next_Day').additionalParam;
           
        }

        const updatedCheckOutProducts = JSON.parse(localStorage.getItem('checkoutProducts'));
        updatedCheckOutProducts.partsShipSelected = this.selectedPartsShip;
        localStorage.setItem('checkoutProducts', JSON.stringify(updatedCheckOutProducts));
        location.reload();

        /*if (this.selectedPartsShip.includes('7.95')) {
            this.partsShipFee = 7.95;

        }
        if (this.selectedPartsShip.includes('17.95')) {
            this.partsShipFee = 17.95;

        }
        if (this.selectedPartsShip.includes('19.95')) {
            this.partsShipFee = 19.95;
        } 

        const updatedCheckOutProducts = JSON.parse(localStorage.getItem('checkoutProducts'));
        updatedCheckOutProducts.partsShipSelected = this.selectedPartsShip;
        updatedCheckOutProducts.partsShipFee = this.partsShipFee;
        localStorage.setItem('checkoutProducts', JSON.stringify(updatedCheckOutProducts));
        location.reload();
        console.log("updatedCheckOutProducts", JSON.stringify(updatedCheckOutProducts));
        */
    }

    addPartsShippingAsLineItem() {
          addPartsShippingAsLineItem({ sku: this.selectedPartsShip, cartId: this.cartId, cartItemIdList: this.partsIds})
            .then(result => {
                this.partsShipFee=result[0].BWC_Service_Price__c;
                console.log("##partsShipFee checkoutProducts",this.partsShipFee);
                console.log('##Parts Ship Fee Result checkoutProducts===' + JSON.stringify(result));
            })
            .catch(error => {
                console.log(' ##Parts Ship Fee error checkoutProducts===' + JSON.stringify(error));


            })
        }

    stringToDate(_date, _format, _delimiter) {
        var formatLowerCase = _format.toLowerCase();
        var formatItems = formatLowerCase.split(_delimiter);
        var dateItems = _date.split(_delimiter);
        var monthIndex = formatItems.indexOf("mm");
        var dayIndex = formatItems.indexOf("dd");
        var yearIndex = formatItems.indexOf("yyyy");
        var month = parseInt(dateItems[monthIndex]);
        month -= 1;
        var formatedDate = new Date(dateItems[yearIndex], month, dateItems[dayIndex]);
        return formatedDate;
    }
    getAvailableDeliveryDates(mode) {
        console.log('Delivery MODE is ' + mode);
        console.log('State is  ' + this.state);
        console.log('Zipcode is  ' + this._zipCode);
        console.log('skuList is  ' + this.skuList);
        getAvailableDeliveryDates({
            zipCode: this._zipCode,
            state: this.state,
            deliveryType: mode,
            skuList: this.skuList
        })
            .then((res) => {
                console.log('resp is ' + res);
                if (res == 'Delivery Not available') {
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: 'Delivery Not Available.',
                        variant: 'error',
                    });
                    dispatchEvent(evt);

                } else {
                    let resp = JSON.parse(res);

                    let calenderDates = resp.calendar_dates;
                    this.minDeliveryDate = calenderDates[0].date;
                    this.maxDeliveryDate = calenderDates[29].date;
                    console.log('maxDelivery Date of M1 ' + this.maxDeliveryDate);
                    let dDates = [],
                        expectedFlag = false,
                        aMonths = [],
                        cDate, aYear = [],
                        aDates = [],
                        tDates = [],
                        allDatesofM1 = [],
                        firstDayofM1,
                        calenderDateRes = {};
                    let fMonAllDates = [],
                        fMonAllDateAsDates = [],
                        fMonAvaDates = [],
                        fStartDate, fFirstDay, fLastDate, fcnt = 1,
                        fFirstMonth, fYear,
                        fMonfWeek = [],
                        fMonBlank = [],
                        fMonAllWeeks = [];
                    let sMonAllDates = [],
                        sMonAllDateAsDates = [],
                        sMonAvaDates = [],
                        sStartDate, sFirstDay, sLastDay, sLastDate, scnt = 1,
                        sFirstMonth, sYear,
                        sMonfWeek = [],
                        sMonBlank = [],
                        sMonAllWeeks = [];
                    let deliveryMonths = {};
                    for (let i = 0; i < 30; i++) {
                        cDate = this.stringToDate(calenderDates[i].date, "mm/dd/yyyy", "/");
                        tDates.push(cDate);
                        if (calenderDates[i].available && !expectedFlag) {
                            let deDate = cDate;
                            if (mode == 'SDS' || mode == 'HD')
                                this.expectedDeliveryDate = this.WEEK[deDate.getDay()] + ', ' + this.MONTHS[deDate.getMonth()] + ' ' + deDate.getDate();
                            if (mode == 'WILLCALL')
                                this.expectedpickupDeliveryDate = this.WEEK[deDate.getDay()] + ', ' + this.MONTHS[deDate.getMonth()] + ' ' + deDate.getDate();
                            this.expectedpickupDeliveryDateNew = deDate;
                            this.expectedDeliveryDateNew=deDate;
                            expectedFlag = true;
                        }
                        let cMonth = this.MONTHS[cDate.getMonth()];
                        if (!(aMonths.includes(cMonth)))
                            aMonths.push(cMonth);
                        let cYear = cDate.getFullYear();
                        if (!(aYear.includes(cYear)))
                            aYear.push(cYear);
                        let key = cMonth + cYear.toString();

                        if (key in calenderDateRes) {
                            calenderDateRes[key].push({ 'date': cDate, 'available': calenderDates[i].available });
                        } else {
                            calenderDateRes[key] = [{ 'date': cDate, 'available': calenderDates[i].available }];
                        }

                    }
                    console.log('calender date of seperate months ' + JSON.stringify(calenderDateRes));
                    let allKeys = Object.keys(calenderDateRes);
                    if (allKeys.length >= 1 && (mode == 'SDS' || mode == 'HD')) {
                        let k1 = allKeys[0];

                        let firstMonth = calenderDateRes[k1];
                        for (let i = 0; i < firstMonth.length; i++) {
                            fMonAllDates.push(firstMonth[i].date);
                            fMonAllDateAsDates.push(firstMonth[i].date.getDate());
                            if (firstMonth[i].available)
                                fMonAvaDates.push(firstMonth[i].date.getDate());
                        }
                        console.log('availble dates of M1 ' + JSON.stringify(fMonAvaDates));
                        let stringDate = fMonAllDates[0].getMonth() + 1 + '/01/' + fMonAllDates[0].getFullYear();
                        fFirstDay = this.stringToDate(stringDate, "mm/dd/yyyy", "/").getDay();
                        fFirstMonth = this.MONTHS[fMonAllDates[0].getMonth()];
                        fYear = fMonAllDates[0].getFullYear();
                        let fLastDate2 = new Date(fMonAllDates[0].getFullYear(), fMonAllDates[0].getMonth() + 1, 0);
                        fLastDate = fLastDate2.getDate();
                        console.log('first month last date ' + fLastDate);
                        for (let x = 0; x < fFirstDay; x++) {
                            let fRecord = {
                                "id": x,
                                "available": false,
                            }
                            fMonBlank.push(fRecord);
                        }
                        let fMon = fMonAllDates[0].getMonth() + 1;
                        for (let x = fFirstDay; x < 7; x++) {
                            let fRecord = {
                                "id": fcnt,
                                "available": fMonAvaDates.includes(fcnt) ? true : false,
                                "date": fMon + '/' + fcnt + '/' + fYear
                            }
                            fMonfWeek.push(fRecord);
                            fcnt += 1;
                        }

                        let fMonMaxDate = Math.max(...fMonAllDateAsDates);
                        while (fcnt <= fLastDate) {
                            let pt = 0;
                            let tempWeek = [];
                            while (pt < 7 && fcnt <= fLastDate) {
                                let fRecord = {
                                    "id": fcnt,
                                    "available": fMonAvaDates.includes(fcnt) ? true : false,
                                    "date": fMon + '/' + fcnt + '/' + fYear
                                }
                                tempWeek.push(fRecord);
                                pt += 1;
                                fcnt += 1;
                            }
                            fMonAllWeeks.push(tempWeek);

                        }
                        deliveryMonths = {
                            "hasFirstMonth": true,
                            "fFirstDay": fFirstDay,
                            "fMonth": fFirstMonth,
                            "fMonAvaDates": fMonAvaDates,
                            "fMonBlank": fMonBlank,
                            "fMonfWeek": fMonfWeek,
                            "fMonAllWeeks": fMonAllWeeks,
                            "fYear": fYear,
                            "hasSecondMonth": false
                        }
                        if (allKeys.length >= 2) {
                            let k2 = allKeys[1];
                            let secondMonth = calenderDateRes[k2];
                            for (let i = 0; i < secondMonth.length; i++) {
                                sMonAllDates.push(secondMonth[i].date);
                                sMonAllDateAsDates.push(secondMonth[i].date.getDate());

                                if (secondMonth[i].available)
                                    sMonAvaDates.push(secondMonth[i].date.getDate());
                            }
                            stringDate = sMonAllDates[0].getMonth() + 1 + '/01/' + sMonAllDates[0].getFullYear();
                            sFirstDay = this.stringToDate(stringDate, "mm/dd/yyyy", "/").getDay();
                            sFirstMonth = this.MONTHS[sMonAllDates[0].getMonth()];
                            sYear = sMonAllDates[0].getFullYear();
                            let sLastDate2 = new Date(sMonAllDates[0].getFullYear(), sMonAllDates[0].getMonth() + 1, 0);
                            sLastDate = sLastDate2.getDate();
                            for (let x = 0; x < sFirstDay; x++) {
                                let fRecord = {
                                    "id": x,
                                    "available": false,
                                }
                                sMonBlank.push(fRecord);
                            }
                            let sMon = sMonAllDates[0].getMonth() + 1;
                            for (let x = sFirstDay; x < 7; x++) {
                                let fRecord = {
                                    "id": scnt,
                                    "available": sMonAvaDates.includes(scnt) ? true : false,
                                    "date": sMon + '/' + scnt + '/' + sYear
                                }
                                sMonfWeek.push(fRecord);
                                scnt += 1;
                            }

                            let sMonMaxDate = Math.max(...sMonAllDateAsDates);
                            while (scnt <= sLastDate) {
                                let pt = 0;
                                let tempWeek = [];
                                while (pt < 7 && scnt <= sLastDate) {
                                    let fRecord = {
                                        "id": scnt,
                                        "available": sMonAvaDates.includes(scnt) ? true : false,
                                        "date": sMon + '/' + scnt + '/' + sYear
                                    }
                                    tempWeek.push(fRecord);
                                    pt += 1;
                                    scnt += 1;
                                }
                                sMonAllWeeks.push(tempWeek);

                            }

                            deliveryMonths["hasSecondMonth"] = true;
                            deliveryMonths["sFirstDay"] = sFirstDay;
                            deliveryMonths["sMonth"] = sFirstMonth;
                            deliveryMonths["sMonAvaDates"] = sMonAvaDates;
                            deliveryMonths["sMonBlank"] = sMonBlank;
                            deliveryMonths["sMonfWeek"] = sMonfWeek;
                            deliveryMonths["sMonAllWeeks"] = sMonAllWeeks;
                            deliveryMonths["sYear"] = sYear;
                        }


                    }
                    if (mode == 'SDS' || mode == 'HD')
                        this.fDeliveryData = deliveryMonths;
                    if (mode == 'WILLCALL')
                        this.pickupDeliveryData = deliveryMonths;

                }
                console.log('days --> ' + JSON.stringify(this.fDeliveryData));
            })
            .catch(error => {
                console.log('error occured' + error);
            })
    }

    getSelectedDeliveryDate(event) {
        console.log('event detail value ' + JSON.stringify(event));
        let deliveryType = event.target.name;
        let selectedDate = this.stringToDate(event.target.value, "mm/dd/yyyy", "/");
        console.log('deliveryType===' + deliveryType);
        console.log('selectedDate===' + selectedDate);
        this.expectedDeliveryDateNew = selectedDate;
        if (deliveryType == 'SDS')
            this.expectedDeliveryDate = this.WEEK[selectedDate.getDay()] + ', ' + this.MONTHS[selectedDate.getMonth()] + ' ' + selectedDate.getDate();
        if (deliveryType == 'WILLCALL')
            this.expectedpickupDeliveryDate = this.WEEK[selectedDate.getDay()] + ', ' + this.MONTHS[selectedDate.getMonth()] + ' ' + selectedDate.getDate();
        console.log(' this.expectedDeliveryDate====' + this.expectedDeliveryDate);
        console.log(' this.expectedpickupDeliveryDate====' + this.expectedpickupDeliveryDate);

    }
    pickupLocation = {};
    filterCartItems(event) {

        this._hdList = [];
        this._prodShippingList = [];
        this._partsList = [];
        this._sdsList = [];
        this._pickupList = [];
        console.log('this._cartItems2-->', this._cartItems);

        if (this._cartItems) {
            const segregagatedProductList = event.detail.shipTypeProducts;
            console.log('segregagatedProductList-->', segregagatedProductList);
            this._hdList = segregagatedProductList.hdList;
            this._partsList = segregagatedProductList.partsList;
            this._prodShippingList = segregagatedProductList.prodShippingList;
            this._pickupList = segregagatedProductList.pickupList;
            this._sdsList = segregagatedProductList.sdsList;
            this.hdListflag = segregagatedProductList.hdFlag;
            this.sdsListFlag = segregagatedProductList.sdsFlag;
            this.partsListflag = segregagatedProductList.partsFlag;
            this.prodShippingListflag = segregagatedProductList.prodFlag;
            this.pickupListflag = segregagatedProductList.pickupFlag;
            this.pickupLocation = segregagatedProductList.pickupLocation;
            if (this._hdList.length > 0 || this._sdsList.length > 0) {
                for (let i = 0; i < this._hdList.length; i++) {
                    this.skuList.push(this._hdList[i].ProductDetails.sku);
                    console.log('skuList-->' + JSON.stringify(this.skuList));
                }
                for (let i = 0; i < this._sdsList.length; i++) {
                    this.skuList.push(this._sdsList[i].ProductDetails.sku);
                    console.log('skuList-->' + JSON.stringify(this.skuList));
                }
                this.totalHdItems = this._hdList.length + this._sdsList.length;

                if (this._sdsList.length === 0) {
                    this.getAvailableDeliveryDates('HD');
                }
                else {
                    this.getAvailableDeliveryDates('SDS');
                }
            }
            if (this._pickupList.length > 0) {
                for (let i = 0; i < this._pickupList.length; i++) {
                    this.skuList.push(this._pickupList[i].ProductDetails.sku);
                    console.log('skuList-->' + JSON.stringify(this.skuList));
                }
                console.log('will call items');
                this.getAvailableDeliveryDates('WILLCALL');
            }
        }
    }

    @wire(CartSummaryAdapter)
    getCartId({ error, data }) {
        if (data) {
            console.log('CartSummaryAdapter CHeckout-->>>>>>>', data);
            console.log('CartIdINCHeckout-->', data.cartId);
            this.cartId = data.cartId;
        }
        else if (error) {
            console.log('error===' + JSON.stringify(error));
        }
    }

    getServiceCharge() {
        calculateTotalAmount({ cartId: this.cartId })
            .then(result => {
                console.log('ServiceResult-->' + result);
                localStorage.setItem('serviceAmount', result);
            })
            .catch(error => {
                console.log('error in CalculateEntirePrice apex class-->' + error);
            })
    }


    calculatingTax() {
       // this.callIntegration();
       restartCheckout();
        this.checkDeliveryMethod();
        this.getServiceCharge();
        // console.log('placeOrderDisbaled-->' + this.isPlaceOrderDisabled);
        // if (this.isPlaceOrderDisabled) {
        //     const payLoad = { enablePlaceOrder: false };
        //     publish(this.messageContext, CHECKOUT_CHANNEL, payLoad);
        //     console.log(
        //         'bwc_billingAddressCheckout::shippingAddress()::enabling "Place Order" button via message channel::payload = ' +
        //         JSON.stringify(payLoad)
        //     );
        // } else {
        //     const payLoad = { enablePlaceOrder: true };
        //     publish(this.messageContext, CHECKOUT_CHANNEL, payLoad);
        //     console.log(
        //         'bwc_billingAddressCheckout::shippingAddress()::enabling "Place Order" button via message channel::payload = ' +
        //         JSON.stringify(payLoad)
        //     );
        // }

    }

    placeOrderButtonDisbaled(isPlaceOrderDisabled) {
        if (isPlaceOrderDisabled) {
            const payLoad = { enablePlaceOrder: false };
            publish(this.context, CHECKOUT_CHANNEL, payLoad);
            console.log(
                'bwc_billingAddressCheckout::shippingAddress()::enabling "Place Order" button via message channel::payload = ' +
                JSON.stringify(payLoad)
            );
        } else {
            const payLoad = { enablePlaceOrder: true };
            publish(this.context, CHECKOUT_CHANNEL, payLoad);
            console.log(
                'bwc_billingAddressCheckout::shippingAddress()::enabling "Place Order" button via message channel::payload = ' +
                JSON.stringify(payLoad)
            );
        }
    }

    checkCartStatus() {
        updateCartStatus({ cartId: this.cartId })
            .then(result => {
                console.log('Cart updated success', result);
            })
            .catch(error => {
                console.log('Cart updation error', error);
            })
    }

    callIntegration() {
        this.checkCartStatus();
        this.openSpinner = true;
        // setTimeout(() => {
        //     this.openSpinner = true;
        // }, 1500);

        console.log('spinner-->' + this.openSpinner);
        BWC_CallCheckoutIntrgration({ cartId: this.cartId })
            .then(result => {
                this.isPlaceOrderDisabled = false;
                this.placeOrderButtonDisbaled(this.isPlaceOrderDisabled);
                console.log(" customer Integration Call result==>" + result);
                console.log(" customer Integration Call result22==>" , result);
                console.log(" customer Integration Call result33==>" + JSON.stringify(result));


                restartCheckout();
                this.openSpinner = false;
            })
            .catch(error => {
                this.isPlaceOrderDisabled = true;
                this.placeOrderButtonDisbaled(this.isPlaceOrderDisabled);
                this.openSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error!",
                        message: "This item is not available, please try another one",
                        variant: "error"
                    })
                );
                console.log("shubh error==>" + JSON.stringify(error));
            });
    }

    checkDeliveryMethod() {
        modifyDeliveryGroup()
            .then(result => {
                console.log(
                    "orderDeliveryMethod present in Cart Delivery Group-->" + result
                );
            })
            .catch(error => {
                console.log("Error occured in cartDelivreryGroup-->" + error);
            });
    }

    handleShippingContinue() {
        //Abhishek Changes
        this.calculatingTax();
        //Abhishek Changes
        console.log('this._sdsList==' + JSON.stringify(this._sdsList));

        let payload = {
            ExpectedDeliveryDate: this.expectedDeliveryDateNew,
            hdCartItems: this._hdList,
            ExpectedpickupDeliveryDate: this.expectedpickupDeliveryDateNew,
            pickupcartItems: this._pickupList,
            shipType: this.selectedPartsShip,
            shipcartItems: this._partsList,
            shipFee: this.partsShipFee,
            prodShippingList: this._prodShippingList,
            pickupLocation: this.pickupLocation,
            sdsList: this._sdsList
        }


        console.log('payload==' + JSON.stringify(payload));
        console.log('payload==' + JSON.stringify(payload));
        //this.isPickUpModel = true;
        //setTimeout(() => {
            this.sendCodeToParent(payload);
       // }, 6000);
        //updateDeliveryMethod(this.deliveryMethodIdInstance);
    }
    sendCodeToParent(ShippingMethodpayload) {
        console.log('event dispatched');
        const selectEvent = new CustomEvent('ShipDateAndMethod', {
            detail: ShippingMethodpayload, bubbles: true, composed: true
        });
        this.dispatchEvent(selectEvent);
    }
}