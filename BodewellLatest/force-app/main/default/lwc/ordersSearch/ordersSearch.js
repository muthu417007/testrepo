import { LightningElement, api, track, wire } from 'lwc';
import OrdersAPIData from '@salesforce/apex/THD_MDO_OrdersData.ordersData';
import { NavigationMixin } from 'lightning/navigation';
import orderSearch from "@salesforce/messageChannel/orderSearch__c";
import { MessageContext, APPLICATION_SCOPE, publish } from 'lightning/messageService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import bwcOrderSearch from 'c/bwc_orderSearchQuickAction';

export default class UtilitySearch extends NavigationMixin(LightningElement) {
    @wire(MessageContext)
    context;
    @api utilityTitle;
    @track ordersearchflag = true;
    @track OrdersLoading = false;

    connectedCallback() {
        console.log('connected callback method',this.invokedByOrderSummary);
        if(this.invokedByOrderSummary){
            this.getOrdersData();
        } else{
            this.openLightningTab();
        }
    }

    @api ordrnumber; //New Change
    @api invokedByOrderSummary; //New Change

    openLightningTab() {
        console.log('Open Lightning Tab ')
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'THD_MDO_Orders'
            }

        });

    }
    hasWhiteSpace(s) {
        return s.indexOf(' ') >= 0;
    }

    getorderlistdata(pl) {
        this.OrdersLoading = true;
        OrdersAPIData({ body: pl }).then((jsonResponse) => {
            let payload = {
                source: "LWC",
                messageBody: { record: jsonResponse }
            };
            this.OrdersLoading = false;
            console.log('Context > ',this.context,' Order Search > ',orderSearch,' PayLoad > ',payload);
            publish(this.context, orderSearch, payload);
            if(this.invokedByOrderSummary){
                this.dispatchEvent(new CustomEvent('ordereventpublish', {
                    detail: payload
                }));
            //this.dispatchEvent(new CustomEvent('ordereventpublish', { detail: true }));
            }
        })
            .catch((error) => {
                this.OrdersLoading = false;
                //console.log('errorr',error);
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Status Code: '+error.status+' Server Issue',
                    variant: 'error',
                });
                dispatchEvent(evt);
            });
    }
    handleEnter(event){
        if(event.keyCode === 13){
          this.getOrdersData();
        }
    }
    getOrdersData() {
        let ponumber = '';
        let referencenumber = '';
        let ordernumber = '';
        let phonenumber = '';
        let trackingnumber = '';
        let email = '';
        if(!this.invokedByOrderSummary){
            this.openLightningTab();
            ponumber = this.template.querySelector('lightning-input[data-name="ponumber"]').value.trim();
            referencenumber = this.template.querySelector('lightning-input[data-name="referencenumber"]').value.trim();
            ordernumber = this.template.querySelector('lightning-input[data-name="ordernumber"]').value.trim();
            phonenumber = this.template.querySelector('lightning-input[data-name="phonenumber"]').value.trim();
            trackingnumber = this.template.querySelector('lightning-input[data-name="trackingumber"]').value.trim();
            //let firstname=this.template.querySelector('lightning-input[data-name="firstname"]').value.trim();
            //let lastname=this.template.querySelector('lightning-input[data-name="lastname"]').value.trim();
            email = this.template.querySelector('lightning-input[data-name="email"]').value.trim();
            //let zipcode=this.template.querySelector('lightning-input[data-name="zipcode"]').value.trim();
        }else{
            ordernumber = this.ordrnumber;
        }

        //console.log('po number is '+ponumber+', store number : '+storenumber+' ordernumber '+ordernumber);

        if (ordernumber || phonenumber || trackingnumber || ponumber || referencenumber || email) {
            if (ordernumber && phonenumber == '' && trackingnumber == '' && ponumber == '' && referencenumber == '' && email == '') {
                if (ordernumber.length >= 3 && !this.hasWhiteSpace(ordernumber) && !isNaN(ordernumber)) {
                    let inputdata = '{"P_ORDER_NUMBER":"' + ordernumber + '"}';
                    console.log(' ORDER DATA > ',inputdata);
                    this.getorderlistdata(inputdata);
                    /*let payload = {
                        source: "LWC",
                        messageBody: {record:inputdata}
                    };
                    publish(this.context, orderSearch, payload);*/
                }
                else {
                    const evt = new ShowToastEvent({
                        title: 'Invalid Input',
                        message: 'Please provide valid order number',
                        variant: 'error',
                    });
                    dispatchEvent(evt);
                }
            }
            else if (ordernumber == '' && phonenumber && trackingnumber == '' && ponumber == '' && referencenumber == '' && email == '') {
                if (phonenumber.length == 10 && !this.hasWhiteSpace(phonenumber) && !isNaN(phonenumber)) {
                    let inputdata = '{"P_ATTRIBUTE3_NUM":"365","P_PHONE_NUMBER":"' + phonenumber + '"}';
                    this.getorderlistdata(inputdata);
                }
                else {
                    const evt = new ShowToastEvent({
                        title: 'Invalid Input',
                        message: 'Please provide valid phone number',
                        variant: 'error',
                    });
                    dispatchEvent(evt);
                }

            }
            else if (ordernumber == '' && phonenumber == '' && trackingnumber && ponumber == '' && referencenumber == '' && email == '') {
                if (trackingnumber.length >= 3 && !this.hasWhiteSpace(trackingnumber)) {
                    let inputdata = '{"P_TRACKING_NUMBER":"' + trackingnumber.toUpperCase() + '"}';
                    this.getorderlistdata(inputdata);
                }
                else {
                    const evt = new ShowToastEvent({
                        title: 'Invalid Input',
                        message: 'Please provide valid tracking number',
                        variant: 'error',
                    });
                    dispatchEvent(evt);
                }
            }
            else if (ordernumber == '' && phonenumber == '' && trackingnumber == '' && ponumber && referencenumber == '' && email == '') {
                if (ponumber.length >= 3 && !this.hasWhiteSpace(ponumber)) {
                    let inputdata = '{"P_PO_NUMBER":"' + ponumber + '"}';
                    this.getorderlistdata(inputdata);
                }
                else {
                    const evt = new ShowToastEvent({
                        title: 'Invalid Input',
                        message: 'Please provide valid po number',
                        variant: 'error',
                    });
                    dispatchEvent(evt);
                }
            }
            else if (ordernumber == '' && phonenumber == '' && trackingnumber == '' && ponumber == '' && referencenumber && email == '') {

                if (referencenumber.length >= 3 && !this.hasWhiteSpace(referencenumber)) {
                    let inputdata = '{"P_ORIG_SYS_DOCUMENT_REF":"' + referencenumber.toUpperCase() + '"}';
                    this.getorderlistdata(inputdata);
                }
                else {
                    const evt = new ShowToastEvent({
                        title: 'Invalid Input',
                        message: 'Please provide valid reference number',
                        variant: 'error',
                    });
                    dispatchEvent(evt);
                }

            }
            else if (ordernumber == '' && phonenumber == '' && trackingnumber == '' && ponumber == '' && referencenumber == '' && email) {
                if (email.length >= 3 && !this.hasWhiteSpace(email) && email.match(/^\S+@\S+\.\S+/)) {
                    let inputdata = '{"P_EMAIL_ADDRESS":"' + email.toUpperCase() + '"}';
                    this.getorderlistdata(inputdata);
                }
                else {
                    const evt = new ShowToastEvent({
                        title: 'Invalid Input',
                        message: 'Please provide valid email',
                        variant: 'error',
                    });
                    dispatchEvent(evt);
                }
            }
            else {
                const evt = new ShowToastEvent({
                    title: 'Invalid Input',
                    message: 'Please provide only 1 input field to search on',
                    variant: 'error',
                });
                dispatchEvent(evt);
            }
        }
        else {
            const evt = new ShowToastEvent({
                title: 'No Input',
                message: 'Please provide valid input.',
                variant: 'error',
            });
            dispatchEvent(evt);
        }

        /*if(ordernumber){
            console.log('publishing the payload::');
            let inputdata='{"P_LINE_REQUIRED":"Y","P_STORE_NUM":"'+storenumber+'","P_ORDER_NUMBER":"'+ordernumber+'"}';
            let payload = {
                source: "LWC",
                messageBody: {record:inputdata}
            };
            publish(this.context, orderSearch, payload);
        }
        else if(ponumber){
            console.log('publishing the payload::');
            let inputdata='{"P_LINE_REQUIRED":"Y","P_STORE_NUM":"'+storenumber+'","P_PO_NUMBER":"'+ponumber+'"}';
            let payload = {
                source: "LWC",
                messageBody: {record:inputdata}
            };
            publish(this.context, orderSearch, payload);
                
        }
        else {
            const evt = new ShowToastEvent({
                title: 'Invalid Inputs',
                message: 'Store No.+ PO No. or Store No.+ Order No. Valid Inputs',
                variant: 'warning',
            });
            dispatchEvent(evt);
        }    
    }*/
        /*else if(zipcode && firstname && lastname){
            
            let inputdata='{"P_LINE_REQUIRED":"Y","P_CUST_FIRST_NAME":"'+firstname+'","P_CUST_LAST_NAME":"'+lastname+'","P_ZIP_CODE":"'+zipcode+'"}';
            let payload = {
                source: "LWC",
                messageBody: {record:inputdata}
            };
            publish(this.context, orderSearch, payload);
                
        }
        else if(zipcode && address){
            let inputdata='{"P_LINE_REQUIRED":"Y","P_ADDRESS_LINE1":"'+address+'","P_ZIP_CODE":"'+zipcode+'"}';
            let payload = {
                source: "LWC",
                messageBody: {record:inputdata}
            };
            publish(this.context, orderSearch, payload);
            
        }
        else {
            if(storenumber){
                const evt = new ShowToastEvent({
                    title: 'Missing Inputs',
                    message: 'Please use Store No.+ PO Number or Order No.',
                    variant: 'warning',
                });
                dispatchEvent(evt);
            }
        
            else if(ponumber){
                const evt = new ShowToastEvent({
                    title: 'Missing Inputs',
                    message: 'Please use PO Number + Store Number',
                    variant: 'warning',
                });
                dispatchEvent(evt);
            }
            else if(address){
                const evt = new ShowToastEvent({
                    title: 'Missing Inputs',
                    message: 'Please use Address + Zipcode',
                    variant: 'warning',
                });
                dispatchEvent(evt);
            }
            else if(firstname || lastname){
            const evt = new ShowToastEvent({
                title: 'Missing Inputs',
                message: 'Please use Firstname + Lastname + Zipcode',
                variant: 'warning',
            });
            dispatchEvent(evt);
            }
            else if(zipcode){
                const evt = new ShowToastEvent({
                    title: 'Missing Inputs',
                    message: 'Please use Zipcode+[Address or Firstname + Lastname]',
                    variant: 'warning',
                });
                dispatchEvent(evt);
            }
            else {
                const evt = new ShowToastEvent({
                    title: 'Missing Inputs',
                    message: 'No inputs found',
                    variant: 'warning',
                });
                dispatchEvent(evt);
            }
        }*/

    }
    resetInputs() {
        this.template.querySelectorAll('lightning-input[data-id="reset"]').forEach(element => {
            element.value = null;
        });
    }

    closeAction() {
        console.log('Closed action');
        this.dispatchEvent(new CloseActionScreenEvent());
    }


}