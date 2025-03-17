import { LightningElement, api, track, wire } from 'lwc';
import { navigate, NavigationContext } from 'lightning/navigation';
import deleteCartItem from '@salesforce/apex/BWC_CartController.deleteCartItem';
import getZipcodeServiceInfo from '@salesforce/apex/BWC_CartController.getZipcodeServiceInfo';
import getAvailableDeliveryDates from '@salesforce/apex/BWC_CartController.getDeliveryDates';
import updateCartItem from "@salesforce/apex/BWC_CartController.updateCartItem";
import { publish, subscribe, MessageContext, createMessageContext } from "lightning/messageService";
import bwcCartPage from "@salesforce/messageChannel/bwcCartPage__c";
import getShipTypeFee from '@salesforce/apex/BWC_CartController.getShipTypeFees';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import zipCodeChannel from '@salesforce/messageChannel/zipCodeChange__c';

export default class Bwc_cartPage2 extends LightningElement {

    @track _cartItems = [];
    @track _checkoutItems = [];
    _cartId;
    _quantity;
    _navigationContext;
    _prodQuantity = false;
    _webStoreId;
    _accountId;
    _cartStatus;
    _cartItemCount = 0;
    @track _partsList = [];
    @track _hdList = [];
    @track _prodShippingList = [];
    hdListflag = false;
    partsListflag = false;
    prodShippingListflag = false;
    @track _totalQuantity = 0;
    @track _cartTotal = 0.0;
    // added on 9/5 for temporary
    availableQuantityDummy = 100;
    _deliveryFee = 99;
    _installationFee = 0.0;
    @track totalHdItems;
    // added on 9/10  -- santhosh 
    pickupListflag = false;
    sdsListFlag = false;
    @track _pickupList = [];
    @track _sdsList = [];
    _cartDeliveryTypes = {};
    _deliveryTypeData = {};
    _productRecords = {};
    _zipCodeServiceResp;
    @track _pickupList = [];
    @track _sdsList = [];
    pickupListFlag = false;
    sdsListFlag = false;
    @track minDeliveryDate;
    @track maxDeliveryDate;
    @track expectedDeliveryDate;
    @track expectedpickupDeliveryDate;
    @track fDeliveryData;
    @track pickupDeliveryData;
    @track homeDeliveryFee;
    @track smallPackageFee;
    @track freeStandingInstallFee;
    @track selectedPartsShip;
    @track partsShipFee;
    @track partsShipOptions;
    MONTHS = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    DAYS = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"];
    WEEK = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturaday"];
    @track zipCode;
    @track localStorageZipCode;
    subscription;
    context = createMessageContext();
    connectedCallback() {
        //this.filterCartItems();

        if (localStorage.getItem('zipcode')) {
            this.localStorageZipCode = JSON.parse(localStorage.getItem('zipcode'));
            this.zipCode = this.localStorageZipCode.Zipcode;
            console.log('IF ZIPCODE IS ==> ' + this.zipCode);

        }
        console.log('ZIPCODE IS ==> ' + this.zipCode);
        this.handleSubscribe();



        this.getPriceAndQuantity();
    }

    isRendered;
    renderedCallback() {

        if (!this.isRendered) {
            //this.filterCartItems();
            this.getPriceAndQuantity();
            //this.template.querySelector('c-bwc_product-ship-type').filterCartItems(this._cartItems);
            this.publishMessage();
            this.isRendered = true;
        }

    }

    @wire(getShipTypeFee)
    wiredRecs({ data, error }) {

        if (data) {
            let shipOptions = [];
            console.log('ship resp ' + JSON.stringify(data));
            for (let i = 0; i < data.length; i++) {
                if (data[i].DeveloperName == 'HOME_DELIVERY') {
                    this.homeDeliveryFee = data[i].Price__c;
                } else if (data[i].DeveloperName == 'FREESTANDING_INSTALL_2STEP') {
                    this.freeStandingInstallFee = data[i].Price__c;
                } else if (data[i].DeveloperName == 'SMALL_PACKAGE_DELIVERY') {
                    this.smallPackageFee = data[i].Price__c;
                } else if (data[i].Product_SKU__c == 'PARTS SHIPPING') {
                    let labelval = data[i].MasterLabel + ' $' + data[i].Price__c;
                    console.log('Label Name is ' + labelval);
                    let shipRecord = { label: labelval, value: labelval };
                    console.log('ship record is ' + JSON.stringify(shipRecord));
                    shipOptions.push(shipRecord);
                }

            }
            this.partsShipOptions = shipOptions;
            console.log('SHIPPING OPTIONS ' + JSON.stringify(this.partsShipOptions));

        } else if (error) {

            console.log('error ' + error);

        }
    }
    @wire(MessageContext)
    messageContext;

    //called inside handlermethod
    publishMessage() {
        let messagePayload = {
            source: "LWC",
            myObjectField: {
                total: this._cartTotal,
                homeDelivery: (this._hdList.length > 0 || this._sdsList.length > 0) ? this.homeDeliveryFee : null,
                partsDelivery: this._partsList.length > 0 ? this.partsShipFee : null,
                fedexDelivery: this._prodShippingList.length > 0 ? '$0' : null,
                installation: this._installationFee
            }
        };

        publish(this.messageContext, bwcCartPage, messagePayload);
        console.log("myObjectField" + JSON.stringify(messagePayload.myObjectField));
    }

    @api
    get checkout() {
        return this._checkoutItems;
    }
    set checkout(val) {
        this._checkoutItems = val;
        console.log("_checkout ITEMs===> " + JSON.stringify(val));
    }

    @api
    get cartId() {
        return this._cartId;
    }
    set cartId(val) {
        this._cartId = val;
        console.log("_cartId====" + JSON.stringify(val));
    }

    @api
    get webStoreId() {
        return this._webStoreId;
    }
    set webStoreId(val) {
        this._webStoreId = val;
        console.log("_webStoreId====" + val);
    }

    @api
    get acctId() {
        return this._accountId;
    }
    set acctId(val) {
        this._accountId = val;
        console.log(`_accountId==== ${val}`);
    }

    @api
    get cartStatus() {
        return this._cartStatus;
    }
    set cartStatus(val) {
        this._cartStatus = val;
        console.log(`_cartStatus===  ${val}`);
    }

    //this Navigation open the PDP page of the product onclick the product name
    @wire(NavigationContext)
    wiredNavigationContext(context) {
        this._navigationContext = context;
    }
    onclickProductName(event) {
        console.log("Product Id" + event.target.dataset.id);
        navigate(this._navigationContext, {
            type: "standard__recordPage",
            attributes: {
                objectApiName: "Product2",
                recordId: event.target.dataset.id,
                actionName: "view"
            }
        });
    }

    handleSubscribe() {
        if (this.subscription) {
            return;
        }
        this.context = createMessageContext();

        this.subscription = subscribe(this.context, zipCodeChannel, (message) => {
            const fullAddress = message.message;
            this.zipCode = fullAddress.Zipcode;
            console.log('ZIP CODE subscribe page2------ ' + this.zipCode);


        });
    }



    getPriceAndQuantity() {
        console.log("Inside getPrice and Quantity");
        this._totalQuantity = 0;
        this._cartTotal = 0.0;
        if (this._cartItems) {
            for (let i = 0; i < this._cartItems.length; i++) {
                this._totalQuantity += this._cartItems[i].quantity;
                this._cartTotal += this._cartItems[i].salesPrice;
            }
        }
    }

    /*get partsShipOptions() {
        return [
            { label: 'Standard Shipping: 3-5 Business Days, $5.95', value: 'Standard Shipping: 3-5 Business Days, $5.95' },
            { label: 'Second Day: 2 Days $12.95', value: 'Second Day: 2 Days $12.95' },
            { label: 'Next Day: 1 Day $14.95', value: 'Next Day: 1 Day $14.95' }
        ]
    }*/
    handlePartsShipType(event) {
        this.selectedPartsShip = event.detail.value;

        if (this.selectedPartsShip.includes('7.95')) {
            this.partsShipFee = '$7.95';

        }
        if (this.selectedPartsShip.includes('17.95')) {
            this.partsShipFee = '$17.95';

        }
        if (this.selectedPartsShip.includes('19.95')) {
            this.partsShipFee = '$19.95';

        }
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
        getAvailableDeliveryDates({
                accountId: this.acctId,
                deliveryType: mode
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
                    this.maxDeliveryDate = calenderDates[calenderDates.length - 1].date;
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
                    for (let i = 0; i < calenderDates.length; i++) {
                        cDate = this.stringToDate(calenderDates[i].date, "mm/dd/yyyy", "/");
                        tDates.push(cDate);
                        if (calenderDates[i].available && !expectedFlag) {
                            let deDate = cDate;
                            if (mode == 'SDS')
                                this.expectedDeliveryDate = this.WEEK[deDate.getDay()] + ', ' + this.MONTHS[deDate.getMonth()] + ' ' + deDate.getDate();
                            if (mode == 'WILLCALL')
                                this.expectedpickupDeliveryDate = this.WEEK[deDate.getDay()] + ', ' + this.MONTHS[deDate.getMonth()] + ' ' + deDate.getDate();

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
                    if (allKeys.length >= 1 && mode == 'SDS') {
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
                    if (mode == 'SDS')
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
            if (deliveryType == 'SDS')
                this.expectedDeliveryDate = this.WEEK[selectedDate.getDay()] + ', ' + this.MONTHS[selectedDate.getMonth()] + ' ' + selectedDate.getDate();
            if (deliveryType == 'WILLCALL')
                this.expectedpickupDeliveryDate = this.WEEK[selectedDate.getDay()] + ', ' + this.MONTHS[selectedDate.getMonth()] + ' ' + selectedDate.getDate();

        }
        //Categorisation of products
    filterCartItems(event) {

        this._hdList = [];
        this._prodShippingList = [];
        this._partsList = [];
        this._sdsList = [];
        this._pickupList = [];
        //this._totalQuantity = 0;
        //this._cartTotal = 0.0;
        if (this._cartItems) {
            const segregagatedProductList = event.detail.shipTypeProducts;
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
            console.log('flags --<> ' + this.pickupListFlag + ' ' + this.hdListflag + ' ' + this.sdsListFlag);
            if (this._hdList.length > 0 || this._sdsList.length > 0) {
                this.totalHdItems = this._hdList.length + this._sdsList.length;
                this.getAvailableDeliveryDates('SDS');
            }
            if (this._pickupList.length > 0) {
                console.log('will call items');
                this.getAvailableDeliveryDates('WILLCALL');
            }
            this.publishMessage();
        }

        return false;
    }

    // cartQuantity(){
    //     for(let i=0; i<(this._cartItems).length; i++){
    //         this._totalQuantity+=this._cartItems[i].quantity;
    //         console.log("Total Cart Quantity==>" +this._totalQuantity);
    // }
    // }

    handleValueChange(event) {
        const value = event.detail.value;
        const cartItemId = event.detail.cartItemId;
        const itemPrice = this._cartItems.find(
            (item) => item.id === cartItemId
        ).price;

        updateCartItem({
                webstoreId: this._webStoreId,
                effectiveAccountId: this._accountId,
                activeCartOrId: this._cartStatus,
                cartItemId: cartItemId,
                newQuantity: value,
                cartItemPrice: itemPrice * value
            })
            .then(() => {
                console.log("reached updatecartItem in Cart Comp");
                this.changeCartItem(cartItemId, value, itemPrice * value);

            })
            .catch((e) => {

                console.log("Error in changeCartItem Method===" + JSON.stringify(e));
            });
    }

    //UI changes on update - product price, exclusive savings? promotional savings?
    changeCartItem(cartItemId, newQuantity, cartItemPrice) {

        let updatedCartItems = JSON.parse(JSON.stringify(this._cartItems));
        (updatedCartItems || []).map((item) => {
            console.log("MAP" + item);
            if (item.id === cartItemId) {
                item.quantity = newQuantity;
                item.salesPrice = cartItemPrice;
            }
            return false;
        });
        this._cartItems = updatedCartItems;
        //this.filterCartItems();
        this.getPriceAndQuantity();
        this.template.querySelector('c-bwc_product-ship-type').filterCartItems(this._cartItems);

        this.publishMessage();
    }

    clearCartItem(evt) {
        let cartItemId = evt.target.dataset.id;
        console.log(cartItemId);
        deleteCartItem({
                webstoreId: this._webStoreId,
                effectiveAccountId: this._accountId,
                activeCartOrId: this._cartStatus,
                cartItemId: cartItemId
            })
            .then(() => {
                this.removeCartItem(cartItemId);
                console.log("CartItemId in clearcartItem Method===" + cartItemId);
            })
            .catch((e) => {
                console.log("Error in clearcartItem Method===" + e);
            });
    }

    removeCartItem(cartItemId) {
        const removedItem = (this._cartItems || []).filter(
            (item) => item.id === cartItemId
        )[0];
        console.log("RemovedItem===" + JSON.stringify(removedItem));
        const quantityOfRemovedItem = removedItem ? removedItem.quantity : 0;
        console.log("RemovedItemQuantity===" + quantityOfRemovedItem);
        const updatedCartItems = (this._cartItems || []).filter(
            (item) => item.id !== cartItemId
        );
        // Update the cartItems with the change
        this._cartItems = updatedCartItems;
        //this.filterCartItems();
        this.getPriceAndQuantity();
        this.template.querySelector('c-bwc_product-ship-type').filterCartItems(this._cartItems);

        console.log(
            "UpdatedCartItems:after RemovedItem===" + JSON.stringify(this._cartItems)
        );
    }
}