import { LightningElement, track, api, wire } from "lwc";
import { loadScript } from "lightning/platformResourceLoader";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getOrderDeliveryPaymentSummary from '@salesforce/apex/BWC_StripeSplitController.getOrderDeliveryPaymentSummary';

import { placeOrder } from 'commerce/checkoutApi';
import USER_ID from '@salesforce/user/Id';
import PUBLISHABLE_KEY from "@salesforce/label/c.BWC_StripePublishableKey";
import redirect_URL from "@salesforce/label/c.BWC_Stripe_Return_URL";
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';

//import STRIPE_JS from "@salesforce/resourceUrl/BWC_stripeJs";
import createPaymentIntent from "@salesforce/apex/BWC_StripeSplitController.createPaymentIntent";
import updatePaymentIntent from "@salesforce/apex/BWC_StripeSplitController.updatePaymentIntent";
import authorizePayment from "@salesforce/apex/BWC_StripeSplitController.authorizePayment";
import getPaymentsOnOrderPaymentSummary from "@salesforce/apex/BWC_StripeSplitController.getPaymentsOnOrderPaymentSummary"
const stripe = window.Stripe(PUBLISHABLE_KEY);

export default class Bwc_stripeEStripeOneForm extends NavigationMixin(LightningElement) {
  //   connectedCallback() {
  //   this.initialize();
  // }
  waitingForOrder=false;
  orderPaymentDetails;
  rid;
  _cartSummary;
  _cartIdOriginal;
  @api 
  get cartId()
{
    return this._cartIdOriginal;
  }
  set cartId(val) {
    this._cartIdOriginal = val;
    console.log('Stripe:::::_cartIdOriginal===' + this._cartIdOriginal);
    this.handleInitialize();
  }
  @api get cartSummary() {
    return this._cartSummary;
  }
  set cartSummary(val) {
    this._cartSummary = val;
    console.log('Stripe:::::amount===' + this._cartSummary);
   // this.handleInitialize();
  }
  _customerId;
  @api 
  get customerId()
  {
return this._customerId;
  }
  set customerId(val) {
    this._customerId = val;
    console.log('Stripe:::::customerId===' + this._customerId);
    this.handleInitialize();
  }
  @api sessionData;
  @track spinnerHidden = true;
  _amount;
  amountArray;
  @api get amount() {
    return this.amountArray;
  }
  set amount(val) {
    this.amountArray = val;
    console.log('Stripe:::::amount===' + this.amountArray);
    this.handleInitialize();
  }

  paymentIntentAffirm;
  paymentIntentClientSecretAffirm
  @wire(CurrentPageReference)
  getPageReferenceParameters(currentPageReference) {
    if (currentPageReference) {
      console.log("currentPageReference paymentIntentAffirm-->", currentPageReference.state.payment_intent);
      console.log("currentPageReference payment_intent_client_secret-->", currentPageReference.state.payment_intent_client_secret);

      this.paymentIntentAffirm = currentPageReference.state.payment_intent;
      this.paymentIntentClientSecretAffirm = currentPageReference.state.payment_intent_client_secret;
      if (this.paymentIntentClientSecretAffirm) {
        this.retrieveIntent();

      }
    }
  }
  async retrieveIntent() {
    const { paymentIntent } = await stripe.retrievePaymentIntent(this.paymentIntentClientSecretAffirm);
    this.paymentIntentResultArray = [...this.paymentIntentResultArray, JSON.stringify(paymentIntent)];

    this.authorizePayment();

  }
  // initialize() {
  //   loadScript(this, STRIPE_JS).then(() => {
  //     //this.handleInitialize();
  //   });
  // }
  @track options = [
    { value: 'yes', label: 'Yes', checked: true },
    { value: 'no', label: 'No, charge this amount', checked: false }

  ];

  elementsArray = [];
  clientSecretArray = [];
  paymentIntentResultArray = [];
  Total = 1000;
  selectedOption;
  handleChange(event) {
    this.selectedOption = event.target.value;
    // Handle the selected option value here
  }
  handleAmountChange(event) {
    let radioList = this.template.querySelectorAll(`[data-name="split"]`);
    const changedIndex = event.target.dataset.index;
    console.log('==changedIndexchangedIndex' + changedIndex);
    for (let i = 0; i < radioList.length; i++) {
      console.log('radioList[i].value' + radioList[i].value);
      if (radioList[i].checked == true && radioList[i].value == 'no') {

        this._amount = event.target.value;

        // let amt=this.TotalAmount-this.inputAmount;
        // this.total=amt;
        // this.childComponents = [...this.childComponents, amt];

        const changeEvent = new CustomEvent('amountchange', { detail: { amount: this._amount, val: changedIndex } });
        this.dispatchEvent(changeEvent);
      }
    }

  }
  paymentElement;
  paymentElementArray=[];
  clientSecretNew;
  elementsInstance;
  async handleInitialize() {
    console.log('this.amountArray[i].length==' + this.amountArray.length);
    this.elementsArray = [];
    this.clientSecretArray = [];
    if(this.paymentElementArray)
    {
      for (let i = 0; i < this.paymentElementArray.length; i++) {
      
        this.paymentElementArray[i].unmount();

      }
    }
    console.log('this.cartId[i].amount==' + this._cartIdOriginal);
    if(this.amountArray &&this._cartIdOriginal && this._customerId)
    {
      for (let i = 0; i < this.amountArray.length; i++) {
        console.log('this.amountArray[i].amount==' + this.amountArray[i].amount);
  
        try {
          const result = await createPaymentIntent({ amount: this.amountArray[i].amount, customerId: this._customerId, cartId: this._cartIdOriginal });
  
  
  
          if (result.error) {
            console.log(JSON.stringify('Stripe:::::error' + result.error));
            this.showToast("Error", result.error.message, "error");
          } else {
  
            console.log(JSON.stringify('Stripe:::::result intent' + result));
            console.log('Stripe:::::response=====' + result);
            const clientSecret = (JSON.parse(result)).client_secret;
            console.log('Stripe:::::clientSecret=====' + clientSecret);
            this.clientSecretArray = [...this.clientSecretArray, clientSecret];
            this.clientSecretNew = clientSecret;
  
            const appearance = {
              theme: 'stripe',
            };
            const elements = stripe.elements({ appearance, clientSecret });
  
            this.elementsArray = [...this.elementsArray, elements]
            this.elementsInstance = elements;
  
  
  
  
            const paymentElementOptions = {
              layout: {
                type: 'accordion',
                defaultCollapsed: true,
                radios: true,
                spacedAccordionItems: false
              },
              terms:{

                card:'always'
              },
              fields: {
                billingDetails: {
                  name: 'auto',
                }
              }

            };
            let amounttemp = this.amountArray[i].amount;
            this.paymentElement = elements.create("payment", paymentElementOptions);
            // const options = {
            //   amount: amounttemp,
            //   currency: 'USD',
            //   logoColor: 'primary',
            //   fontSize: '16px',
            //   textAlign: 'left',
            // };
            // let affirmid = this.amountArray[i].affirmId;
            // const affirmMessageElement = elements.create('affirmMessage', options);
            // affirmMessageElement.mount(this.template.querySelector("[data-id='" + affirmid + "']"));
            // paymentElement.mount(this.template.querySelector("#payment-element"));
            let id = this.amountArray[i].id;
            console.log('this id==' + id);
            this.paymentElement.mount(this.template.querySelector("[data-id='" + id + "']"));
  this.paymentElementArray=[...this.paymentElementArray,this.paymentElement];
            this.template.querySelector('[data-id="submit"]').disabled = false;
  
            this.template.querySelector('[data-id="submit"]')
              .addEventListener("click", (event) => {
                event.preventDefault();
                this.handleSubmit(this.paymentElement, clientSecret);
              });
  
          }
        } catch (error) {
          console.error('error create payment intent'+JSON.stringify(error));
          this.showToast("Error", "An unexpected error occurred.", "error");
        }
       
      }
  

    }
   
  }
  //   async handleSubmit() {

  //     this.spinnerHidden = false;
  //     const spinner = this.template.querySelector('[data-id="spinner"]');
  //     const buttonText = this.template.querySelector('[data-id="button-text"]');
  //     console.log('elements==='+this.elementsArray.length);
  //     for (let i = 0; i < this.elementsArray.length; i++) {
  //       let elements = this.elementsArray[i];
  // console.log('elements==='+JSON.stringify(elements));

  //       try {
  //         const result = await stripe.confirmPayment({
  //           elements: elements,
  //           confirmParams: {
  //             // Make sure to change this to your payment completion page
  //             return_url: "https://geapp--stripe.sandbox.my.site.com/bodewellCommerce/checkout",
  //           },
  //           redirect: 'if_required',
  //         });

  //         if (result.error) {
  //           console.log(JSON.stringify('Stripe:::::error' + JSON.stringify(result.error)));
  //           this.showToast("Error", result.error.message, "error");
  //         } else {
  //           console.log(JSON.stringify(result));
  //           this.showToast("Success", "Payment succeeded!", "success");
  //           console.log(JSON.stringify('Stripe:::::result' + result));
  //         }
  //       } catch (error) {
  //         console.error(error);
  //         this.showToast("Error", "An unexpected error occurred.", "error");
  //       } finally {
  //         this.spinnerHidden = true;
  //         spinner.classList.add("hidden");
  //         buttonText.classList.remove("hidden");
  //       }
  //     }
  //   }
  async handleSubmit() {
    this.waitingForOrder = true;
    this.paymentIntentResultArray = [];
    this.spinnerHidden = false;
    const spinner = this.template.querySelector('[data-id="spinner"]');
    const buttonText = this.template.querySelector('[data-id="button-text"]');
    for (let i = 0; i < this.elementsArray.length; i++) {
      let elements = this.elementsArray[i];

      // const { paymentIntent } = await stripe.retrievePaymentIntent(this.clientSecretArray[i]);
      // console.log('paymentIntent===='+JSON.stringify(paymentIntent));
      try {
        const result = await stripe.confirmPayment({
          elements: elements,
          confirmParams: {
            // Make sure to change this to your payment completion page
            return_url: redirect_URL,
          },
          redirect: 'if_required',
        });

        if (result.error) {
          console.log(JSON.stringify('Stripe:::::error' + JSON.stringify(result.error)));
          this.showToast("Error", result.error.message, "error");
        } else {
          console.log(JSON.stringify(result));
          this.paymentIntentResultArray = [...this.paymentIntentResultArray, JSON.stringify(result.paymentIntent)];
          this.showToast("Success", "Payment succeeded!", "success");

          console.log(JSON.stringify('Stripe:::::result' + result));
        }
      } catch (error) {
        console.error(error);
        this.showToast("Error", "An unexpected error occurred.", "error");
      } finally {
        this.spinnerHidden = true;
        spinner.classList.add("hidden");
        buttonText.classList.remove("hidden");
      }
    }

    this.authorizePaymentStripe();
  }
  cardMethods;
  authorizePaymentStripe() {
    console.log(' this.paymentIntentResultArray===' + this.paymentIntentResultArray);

    let _cartId = (JSON.parse(this._cartSummary)).cartId;
    let _webstoreId = (JSON.parse(this._cartSummary)).webstoreId;
    console.log(' this._cartSummary.webstoreId===' + _cartId);
    console.log(' this._cartSummary.cartId===' + _webstoreId);
    console.log(' this._cartSummary.userId===' + USER_ID);
    console.log(' this._cartSummary.grandTotalAmount===' + (JSON.parse(this._cartSummary)).grandTotalAmount);

    authorizePayment({ cartId: this.cartId, webstoreId: _webstoreId, userId: USER_ID, paymentIntentResult: this.paymentIntentResultArray })
      .then((result) => {
        console.log('Place order===' + JSON.stringify(result));
        this.cardMethods = result;
        return placeOrder();


      })
      .then(result => {
        // result should look like this: { "errors": [], "orderReferenceNumber": "2ADMS-IXH45-FULN6-BYD5W" }
        //this.navigateToOrderConfirmation(result.orderReferenceNumber);
        console.log('result confirmpayment' + JSON.stringify(result));
        this.rid = result.orderReferenceNumber;
     

      })
      .catch(error => {
        // this._shouldDisablePlaceOrder = false;
        console.log('stripe::handlePayment::authorizePayment()::error =' + JSON.stringify(error));
        this.showToast("Error", result.message, "error");
        this.waitingForOrder = false;
      });
  }


  @wire(getOrderDeliveryPaymentSummary, { orderSummaryId: '$rid' })
  bodewellPaymentSummary({ data, err }) {
    console.log(' PaymentSummary Orders', data);
    if (data) {
      if (data.paymentSummaryId) {
        this.orderPaymentDetails = data;
        this.createPayments();
      }
      else {
        console.log(err)
        this.rid = this.rid + ' ';
      }

    }

    else if (err) {
      console.log(`::getOrderDeliveryPaymentSummary::error: ${JSON.stringify(err)}`);
    }

  }

  showToast(title, message, variant) {
    console.log('Stripe:::::event toast');


    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: message,
        variant: variant

      })
    );

  }
  createPayments() {
    getPaymentsOnOrderPaymentSummary({ ordRefNumber: (this.orderPaymentDetails).paymentSummaryId, methods: this.cardMethods })
      .then(result => {
        console.log('result getPaymentsOnOrderPaymentSummary' + JSON.stringify(result));
        this.waitingForOrder = false;
        this.updateIntentWithOrderNumber();
        this.navigateToOrderConfirmation(this.rid);
      })
      .catch(error => {
        console.log('stripe::handlePayment::getPaymentsOnOrderPaymentSummary()::error =' + JSON.stringify(error));
        // this.showToast("Error", result.message, "error");
      })
  }


  updateIntentWithOrderNumber()
  {
    updatePaymentIntent({intentArray:this.paymentIntentResultArray,orderNumber:this.rid})
    .then(result => {
      console.log('result updateIntentWithOrderNumber' + JSON.stringify(result));
      
    })
    .catch(error => {
      console.log('stripe::::updateIntentWithOrderNumber()::error =' + JSON.stringify(error));
      // this.showToast("Error", result.message, "error");
    })
  }
  /**
    * @description navigate to the order confirmation page
    * @param {String} orderNumber
    */
  navigateToOrderConfirmation(orderNumber) {
    this[NavigationMixin.Navigate]({
      type: 'comm__namedPage',
      attributes: {
        name: 'Order',
      },
      state: {
        orderNumber: orderNumber,
      }
    });
  }





}