import { LightningElement, api, track, wire } from 'lwc';
import getProductAvailability from '@salesforce/apex/BWC_ADC.getADC_Details';
import updateUserZipcode from '@salesforce/apex/BWC_geolocateZipcodeController.updateUserZipcode';
import USER_ID from '@salesforce/user/Id';
import getAddress from '@salesforce/apex/BWC_geolocateZipcodeController.getAddress';

// changes start by Abhishek
import calendarDate from '@salesforce/apex/BWC_CalendarApi.BWC_CalendarApiMethod'
import EstimatedDate from '@salesforce/apex/BWC_CalendarApi.getCalenderResponse'
import EstimatedDateSmallAppliance from '@salesforce/apex/BWC_CalendarApi.getEstimatedDateForSmallAppliance'
import getProductInformation from '@salesforce/apex/BWC_TagController.getProductInformation';


import { CurrentPageReference } from 'lightning/navigation';
import { SessionContextAdapter } from 'commerce/contextApi';
import { ProductAdapter, ProductPricingAdapter } from 'commerce/productApi';
import getProductValues from '@salesforce/apex/BWC_ADC.getProductValues';
// changes end by  Abhishek
import zipCodeChannel from '@salesforce/messageChannel/zipCodeChange__c';
import { publish, subscribe, MessageContext } from 'lightning/messageService';
export default class BWC_ProductEstimatedAvailabilityDate extends LightningElement {

  sessionStorageZipCode;
  localStorageZipCode;
  error;
  availabilityDate;
  skuList = [];
  _productSKU;
  @track zipCode;
  updatedZipcode;

  // changes start by Abhishek 
  @track availableQuantity;
  @track productId;
  @track ispickupDate = false;
  @track pickupDate;
  @track isEstimatedDate = false;
  @track isOutOfStock = false;
  @track etaDate;
  @track partStat;
  @track supercedeCount;
  @track derivative;
  @track lifePhase;
  @track isShowShipMessage;
  @track productClass;
  @track isPurchasable;
  @track isPLPVisible;
  @track isPart;
  @track explodedParts;
  @track estimatedDate;
  @track deliveryType;
  @api isShowAddToCart = false;
  @api recordId;
  @api customDisplayFields;
  @api _effectiveAccountId;
  @track supersededPartItem;
  @track isSuperSeded;
  @track restriction;
  sessionContext;
  @track buyerGroupNames;
  @track isOnClearance;
  @track isClearance = false;
 // @track noLongerManufactured = false;
  //changes end by Abhishek 
  isZipcode = false;

  publisherMessage = '';
  subscription = null;

  @wire(MessageContext)
  messageContext;
  connectedCallback() {
    console.log('recordId>>>' + this.recordId);
    console.log('eff>' + this.effectiveAccountId);
    if (localStorage.getItem('zipcode')) {
      //An Id key is in the local Storage
      this.localStorageZipCode = JSON.parse(localStorage.getItem('zipcode'));
      this.zipCode = this.localStorageZipCode.Zipcode;
      //Clear local storage after getting the values

    }
    console.log(' this.zipCode' + this.zipCode);
    if (this.zipCode === undefined || this.zipCode === null) {
      this.isZipcode = true;
    }
    else {
      this.isZipcode = false;
    }

    this.handleSubscribe();


  }

  @wire(SessionContextAdapter)
    wireSessionContext({ data }) {
        this.sessionContext = data;
        this.buyerGroupNames = this.sessionContext?.buyerGroups.map(bg => bg.name);
        console.log('buyerGroupNames->',this.buyerGroupNames);
    }

    get productIds(){
      let idList =[];
      idList.push(this.productId);
      return idList;
    }

    @wire(getProductInformation, { buyerGroupNames: '$buyerGroupNames', productIds: '$productIds' })
    wiredGetProductInfo({ data }) {
        if (data) {
          console.log('getInfo->',data);
            if(data.clearance.length){
              this.isOnClearance = true;
            }
        }
    }

  /**
 * The product sku
 * @type {?JsonData}
 */

  @api
  get productSku() {
    return this._productSKU;
  }
  set productSku(val) {

    if (val) {
      this._productSKU = val?.fields?.StockKeepingUnit;

    }


    if (this._productSKU && this.zipCode) {

      this.getAvailability(this._productSKU, this.zipCode);
    }
  }

  // changes start by Abhishek

  @api
  get effectiveAccountId() {
    return this._effectiveAccountId;
  }

  /**
     * Sets the effective account - if any - of the user viewing the product
     * and fetches updated cart information
     */
  set effectiveAccountId(newId) {
    this._effectiveAccountId = newId;
  }

  get resolvedEffectiveAccountId() {
    const effectiveAccountId = this.effectiveAccountId || "";
    let resolved = null;

    if (
      effectiveAccountId.length > 0 &&
      effectiveAccountId !== "000000000000000"
    ) {
      resolved = effectiveAccountId;
    }
    console.log('resolved>>' + resolved);
    return resolved;
  }
  @wire(CurrentPageReference)
  getPageReferenceParameters(currentPageReference) {
    if (currentPageReference) {
      this.productId = currentPageReference.attributes.recordId;
      console.log('<<<<<<<<<<<<<<<<<<', currentPageReference.attributes.recordId);
    }
  }

  @wire(getProductValues, { productId: '$productId' })
  wiredData({ data, error }) {
    if (data) {
      console.log('productValues>>', data);
      this.partStat = data.productRecord.BWC_PARTSTAT__c;
      this.supercedeCount = data.productRecord.BWC_SUPERCEDE_COUNT__c;
      this.derivative = data.productRecord.BWC_Derivative__c;
      this.lifePhase = data.productRecord.Item_Lifecycle_Phase__c;
      this.deliveryType = data.productRecord.BWC_Delivery_Type__c;
      this.sku = data.productRecord.StockKeepingUnit;
      this.productClass = data.productRecord.ProductClass;
      this.isPurchasable = data.productRecord.BWC_IsPurchasable__c;
      this.isPLPVisible = data.productRecord.BWC_PLPIsVisible__c;    
      this.isPart = data.productRecord.BWC_Is_Part__c;
      this.explodedParts = data.productRecord.BWC_Exploded_Diagram_Parts__c;
      console.log('this.partStat>>' + this.partStat);
      if (data.productRecord.Is_Accessory__c == 'No' && data.productRecord.Is_Finished_Good__c == 'Yes' && data.productRecord.BWC_Delivery_Type__c == 'sps' && data.productRecord.BWC_IsPurchasable__c == true) {
        this.isShowShipMessage = true;
      }
      if (data.relatedItemsList.length && this.isPart == true) {
        this.supersededPartItem = data.relatedItemsList[0].Related_Product__r.StockKeepingUnit;
        this.isSuperSeded = true;
      }
      if (data.productRecord.Restrictions__c === 'Yes') {
        this.restriction = true;
      }
      /*if (data.productRecord.isPurchasable == false) {
        this.noLongerManufactured = true;
        this.isShowAddToCart= false;
      }*/

    }
    //console.log("Manufacture wire", this.noLongerManufactured);
  }


  getCalenderDate() {
    console.log('pdddIIDD>>' + this.productId);
    console.log('calZipCode>>>' + this.zipCode);
    calendarDate({ postalCodeInstance: this.zipCode, productIdInstance: this.productId, availabilityShipDate: this.availabilityDate })
      .then(result => {
        console.log('' + result);
        if (result !== '' && result !== null && result !== undefined) {
          const inputDate = new Date(result);
          console.log('inpDate>>' + inputDate);
          if (inputDate !== null && inputDate !== undefined && inputDate !== '' && (this.zipCode != undefined && this.zipCode != null)) {
            this.pickupDate = inputDate;
            this.isShowAddToCart = true;
            //test
            this.ispickupDate = this.isShowShipMessage && this.isShowAddToCart?false:true;
          }
        }
        else {
          this.ispickupDate = false;
          this.getEstimatedDeliveryDate();
        }
      })
      .catch(error => {
        console.log('calError>>>', error);
      })
  }
  // changes end by Abhishek


  getEstimatedDeliveryDate() {
    console.log('this.shipDate>>' + this.availabilityDate);
    console.log('this.deliveryType>' + this.deliveryType);
    console.log('this.zipCode>' + this.zipCode);
    if (this.deliveryType != 'sps' && this.deliveryType != 'sps fee' && this.availabilityDate != undefined) {
      const formattedDate = new Date(this.availabilityDate).toISOString().slice(0, 10);;
      console.log('strConvertedDate>>' + formattedDate);
      let payload = '{"zipcode": "' + this.zipCode + '","mode": "' + this.deliveryType.toUpperCase() + '","typeOfCall": "FIRST DATE","startDate": "' + formattedDate + '","noOfDays": 180}';
      console.log('payload>>' + payload);
      EstimatedDate({ calendarPayload: payload })
        .then(result => {
          console.log('CalendarResult==>', JSON.parse(result));
          const data = JSON.parse(result);
          console.log('date>>', data.calendar_dates[0]);
          this.estimatedDate = new Date(data.calendar_dates[0].date);
          const formatUSDate = new Date(this.estimatedDate).toLocaleDateString('en-GB');
          const parts = formatUSDate.split('/');
          this.etaDate = parts[1] + '-' + parts[0] + '-' + parts[2];
          console.log('etaDatePDP->', this.etaDate);
          console.log('estimatedDate>>' + this.estimatedDate);
          const inputDate = new Date(this.estimatedDate);
          const options = { year: 'numeric', month: 'long', day: 'numeric' };
          const formattedDate = inputDate.toLocaleDateString('en-US', options);
          const currentDate = new Date();
          const formattedDateAfter90Days = this.addDays(currentDate, 90).toLocaleDateString('en-US', options);
          console.log('PurchaseCheck>>' + this.isPurchasable);
          if ((this.availableQuantity == 0 || this.availableQuantity == null) && inputDate > currentDate && (this.zipCode != undefined && this.zipCode != null)) {
            this.isOutOfStock = false;
            this.isEstimatedDate = false;
          }
          else if (this.isShowShipMessage == true && (this.zipCode != undefined && this.zipCode != null)) {
            this.isOutOfStock = false;
            this.isEstimatedDate = false;
          }
         /* else if (this.isPurchasable === false) {
            this.noLongerManufactured = true;
            this.isShowAddToCart = false;
            this.isOutOfStock = false;
          }*/
          else if (formattedDate !== null && formattedDate !== '' && formattedDate !== "Invalid Date" && this.estimatedDate != null && inputDate > currentDate && (this.zipCode != undefined && this.zipCode != null)) {
            if (this.productClass === 'VariationParent') {
              console.log('intoVarParent');
              if (this.availableQuantity === 10000000000 && formattedDate >= formattedDateAfter90Days) {
                if (this.isPart == true) {
                  this.isEstimatedDate = false;
                  this.isOutOfStock = true;
                }
                else {
                  this.isEstimatedDate = false;
                  this.isOutOfStock = false;
                }
              }
              else if (this.isPurchasable === true && this.isPart == true && (this.partStat != 0 || this.partStat != 1 || this.supercedeCount != 0 || this.lifePhase === 'Near End of Life') && (this.zipCode != undefined && this.zipCode != null)) {
                this.isEstimatedDate = true;
                this.isOutOfStock = false;
              }
              else if (this.isPurchasable === true && this.isPart == true && this.derivative != 'DUAL' && this.lifePhase == 'Near End of Life' && (this.zipCode != undefined && this.zipCode != null)) {
                this.isEstimatedDate = true;
                this.isOutOfStock = false;
              }
              else if (this.isPurchasable === false && this.isPart == false && (this.zipCode != undefined && this.zipCode != null)) {
                this.isEstimatedDate = false;
              }
              else if ((this.zipCode != undefined && this.zipCode != null) && this.isPurchasable === true) {
                this.isEstimatedDate = true;
              }
             /* else if (this.isPurchasable === false) {
              this.noLongerManufactured = true;
              this.isShowAddToCart = false;
              this.isOutOfStock = false;
            }*/
            }
            else {
              if (this.availableQuantity !== 10000000000 && this.isPurchasable == true) {
                this.isEstimatedDate = true;
                this.isOutOfStock = false;
              }
              else if (this.availableQuantity === 10000000000 && new Date(formattedDate) <= new Date(formattedDateAfter90Days) && this.isPurchasable == true) {
                this.isEstimatedDate = true;
                this.isOutOfStock = false;
              }
              else if (this.availableQuantity === 10000000000 && new Date(formattedDate) >= new Date(formattedDateAfter90Days) && this.isPart == true) {
                this.isEstimatedDate = false;
                this.isOutOfStock = true;
              }
              /* else if (this.isPurchasable === false) {
                this.noLongerManufactured = true;
                this.isShowAddToCart = false;
                this.isOutOfStock = false;
              }*/
              else {
                this.isEstimatedDate = false;
                this.isOutOfStock = false;
              }
            }
          }
          else if (this.zipCode === undefined || this.zipCode === null) {
            this.isEstimatedDate = false;
            this.isOutOfStock = false;
          }
          else {
            this.isEstimatedDate = false;
            this.isOutOfStock = false;
          }
          console.log('estimatedCheck>>' + this.isEstimatedDate);
          if (this.isEstimatedDate === true || (this.isShowShipMessage === true && this.availableQuantity != undefined && this.availableQuantity !== 10000000000 && new Date(formattedDate) <= new Date(formattedDateAfter90Days))) {
            this.isShowAddToCart = true;
          }


        })
        .catch(error => {
          console.log('error in Calendar==>', error);
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
          console.log('estimatedDate>>' + this.estimatedDate);
          const inputDate = new Date(this.estimatedDate);
          const formatUSDate = new Date(this.estimatedDate).toLocaleDateString('en-GB');
          const parts = formatUSDate.split('/');
          this.etaDate = parts[1] + '-' + parts[0] + '-' + parts[2];
          console.log('etaDatePDP->', this.etaDate);
          const options = { year: 'numeric', month: 'long', day: 'numeric' };
          const formattedDate = inputDate.toLocaleDateString('en-US', options);
          const currentDate = new Date();
          const formattedDateAfter90Days = this.addDays(currentDate, 90).toLocaleDateString('en-US', options);
          console.log('PurchaseCheck>>' + this.isPurchasable);
          if ((data.availabilityDetails[0].availableQuantity == 0 || data.availabilityDetails[0].availableQuantity == null) && inputDate > currentDate && (this.zipCode != undefined && this.zipCode != null)) {
            this.isOutOfStock = false;
            this.isEstimatedDate = false;
          }
          else if (this.isShowShipMessage == true && (this.zipCode != undefined && this.zipCode != null)) {
            this.isOutOfStock = false;
            this.isEstimatedDate = false;
          }
          /* else if (this.isPurchasable === false) {
            this.noLongerManufactured = true;
            this.isShowAddToCart = false;
            this.isOutOfStock = false;
          }*/
          else if (formattedDate !== null && formattedDate !== '' && formattedDate !== "Invalid Date" && this.estimatedDate != null && inputDate > currentDate && (this.zipCode != undefined && this.zipCode != null)) {
            if (this.productClass === 'VariationParent') {
              console.log('intoVarParent');
              if (data.availabilityDetails[0].availableQuantity === 10000000000 && new Date(formattedDate) >= new Date(formattedDateAfter90Days)) {
                if (this.isPart == true) {
                  this.isEstimatedDate = false;
                  this.isOutOfStock = true;
                }
                else {
                  this.isEstimatedDate = false;
                  this.isOutOfStock = false;
                }
              }
              /* else if (this.isPurchasable === false) {
                this.noLongerManufactured = true;
                this.isShowAddToCart = false;
                this.isOutOfStock = false;
              }*/
              else if (this.isPurchasable === true && this.isPart == true && (this.partStat != 0 || this.partStat != 1 || this.supercedeCount != 0 || this.lifePhase === 'Near End of Life') && (this.zipCode != undefined && this.zipCode != null)) {
                this.isEstimatedDate = true;
                this.isOutOfStock = false;
              }
              else if (this.isPurchasable === true && this.isPart == true && this.derivative != 'DUAL' && this.lifePhase == 'Near End of Life' && (this.zipCode != undefined && this.zipCode != null)) {
                this.isEstimatedDate = true;
                this.isOutOfStock = false;
              }
              else if (this.isPurchasable === false && this.isPart == false && (this.zipCode != undefined && this.zipCode != null)) {
                this.isEstimatedDate = false;
              }
              else if ((this.zipCode != undefined && this.zipCode != null) && this.isPurchasable === true) {
                this.isEstimatedDate = true;
              }
            }
            else {
              if (data.availabilityDetails[0].availableQuantity !== 10000000000 && this.isPurchasable == true) {
                this.isEstimatedDate = true;
                this.isOutOfStock = false;
              }
              else if (data.availabilityDetails[0].availableQuantity === 10000000000 && new Date(formattedDate) <= new Date(formattedDateAfter90Days) && this.isPurchasable == true) {
                this.isEstimatedDate = true;
                this.isOutOfStock = false;
              }
              else if (data.availabilityDetails[0].availableQuantity === 10000000000 && new Date(formattedDate) >= new Date(formattedDateAfter90Days) && this.isPart == true) {
                this.isEstimatedDate = false;
                this.isOutOfStock = true;
              }
              /* else if (this.isPurchasable === false) {
                this.noLongerManufactured = true;
                this.isShowAddToCart = false;
                this.isOutOfStock = false;
              }*/
              else {
                this.isEstimatedDate = false;
                this.isOutOfStock = false;
              }
            }
          }
          else if (this.zipCode === undefined || this.zipCode === null) {
            this.isEstimatedDate = false;
            this.isOutOfStock = false;
          }
          /* else if (this.isPurchasable === false) {
                this.noLongerManufactured = true;
                this.isShowAddToCart = false;
                this.isOutOfStock = false;
          }*/
          else {
            this.isEstimatedDate = false;
            this.isOutOfStock = false;
          }
          console.log('estimatedCheck>>' + this.isEstimatedDate);
          if (this.isEstimatedDate === true || (this.isShowShipMessage === true && this.availableQuantity != undefined && this.availableQuantity !== 10000000000 && new Date(formattedDate) <= new Date(formattedDateAfter90Days))) {
            this.isShowAddToCart = true;
          }

        })
        .catch(error => {
          console.log('err>>' + error);
        })
    }
    console.log("Manufacture", this.isPurchasable);
  }

  getAvailability(val, zip) {
    console.log('ChildCheck>>>' + this.explodedParts);
    let SKU;
    if (this.productClass == 'VariationParent') {
      var jsonString = this.explodedParts;
      var jsonObject = JSON.parse(jsonString);
      SKU = jsonObject['Exploded Diagram Parts']['sku'];

    }
    else {
      SKU = this.sku;
    }
    console.log('SKU Value:', SKU);
    this.skuList.push(SKU);
    if ((this.skuList).length > 0) {
      getProductAvailability({ skuList: this.skuList, postalCodeInstance: zip })
        .then((results) => {

          console.log('results==' + JSON.stringify(results));
          this.availabilityDate = results?.availabilityDetails[0]?.shipDate

          //changes start by Abhishek

          this.availableQuantity = results?.availabilityDetails[0]?.availableQuantity;
          if(this.isOnClearance && (this.availableQuantity >=0 || this.availableQuantity == null || this.availableQuantity == undefined) || new Date(this.availabilityDate) < new Date()){
            console.log('into the condition of clearance');
            this.isClearance = true;
          }
          console.log('quantityOutOfStock??' + this.availableQuantity);
          console.log('quantityOutOfStock??', this.availableQuantity);
          this.getCalenderDate();


          // changes end by Abhishek 
        })

        .catch((error) => {
          console.log('Error:' + JSON.stringify(error));

        });
    }

  }
  //changes start by Abhishek
  addDays(date, days) {
    const result = new Date(date);
    result.setDate(result.getDate() + days);
    return result;
  }

  // changes end by Abhishek 


  handleSubscribe() {
    if (this.subscription) {
      return;
    }
    this.subscription = subscribe(this.messageContext, zipCodeChannel, (message) => {
      console.log('date------' + message.message);

      const fullAddress = message.message;
      this.zipCode = fullAddress.Zipcode;
      if (this._productSKU && this.zipCode) {
        this.getAvailability(this._productSKU, this.zipCode);
      }
      if (this.zipCode === undefined || this.zipCode === null) {
        this.isZipcode = true;
      }
      else {
        this.isZipcode = false;
      }

    });
  }

  updatedZipcode;
  changeZipCodeHandler(event) {
    this.updatedZipcode = this.template.querySelector('input').value;
    this.zipCode = this.updatedZipcode;
    getAddress({ zipCode: this.updatedZipcode })
      .then(result => {
        console.log('result===', result);
        this.apiResponseParser1(result);


      })
      .catch(error => {
        console.log(error);
      })



  }
  fullAddress;
  @track map = new Map();
  apiResponseParser1(response) {
    const jsonObject = JSON.parse(response);
    if (jsonObject.status === 'OK') {

      this.error = '';
      this.openModal = false;
      let addressComponents = jsonObject.results[0].address_components;
      for (let key in addressComponents) {
        if (addressComponents[key].types.includes('postal_code')) {
          // Add values to the map
          this.map.set('Zipcode', addressComponents[key].long_name);


        }
        if (addressComponents[key].types.includes('locality')) {
          this.map.set('City', addressComponents[key].long_name);

        }
        if (addressComponents[key].types.includes('administrative_area_level_1')) {
          this.map.set('State', addressComponents[key].long_name);

        }
        if (addressComponents[key].types.includes('country')) {
          this.map.set('Country', addressComponents[key].long_name);

        }





      }

      // console.log('this.this.map' + this.map);
      var obj = Object.fromEntries(this.map);
      var jsonString = JSON.stringify(obj);
      this.fullAddress = JSON.parse(jsonString);
      this.zipCode = this.fullAddress.Zipcode;
      console.log('address' + this.fullAddress);
      // this.sendCodeToParent();
      this.sendCodeToParentUpdatedZip();
      //set sessionStorage and localStorage values
      sessionStorage.setItem('zipcode', JSON.stringify(this.fullAddress))
      localStorage.setItem('zipcode', JSON.stringify(this.fullAddress));

      if (this.zipCode) {
        console.log('zip->' + this.zipCode);
        console.log('userId->' + USER_ID);
        updateUserZipcode({ userId: USER_ID, zipCode: this.zipCode })
          .then(result => {
            console.log('user result' + JSON.stringify(result));
          })
          .catch(error => {
            // console.log('user error' + error);
          })
      }
      if (this._productSKU && this.zipCode) {

        this.getAvailability(this._productSKU, this.zipCode);
      }
      if (this.zipCode === undefined || this.zipCode === null) {
        this.isZipcode = true;
      }
      else {
        this.isZipcode = false;
      }
    }
    else {
      this.error = 'Enter Valid Zip Code';
      if (this.zipCode === undefined || this.zipCode === null) {
        this.isZipcode = true;
      }
      else {
        this.isZipcode = false;
      }
    }

  }
  sendCodeToParentUpdatedZip() {
    //console.log('message dispatched New');
    let message = { message: this.fullAddress };
    publish(this.messageContext, zipCodeChannel, message);

  }
}