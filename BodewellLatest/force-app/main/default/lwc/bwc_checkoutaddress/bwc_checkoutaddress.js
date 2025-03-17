import { LightningElement, wire, track, api } from 'lwc';
import { CheckoutInformationAdapter } from 'commerce/checkoutApi';
import CONTACT_POINT_ADDRESS from '@salesforce/schema/ContactPointAddress'
import ISDEFAULT from '@salesforce/schema/ContactPointAddress.IsDefault'
import ID_FIELD from '@salesforce/schema/ContactPointAddress.Id'
import { updateRecord } from 'lightning/uiRecordApi'
import CheckoutController from '@salesforce/apex/BWC_CheckoutAddressController.setActiveAddress'
export default class Bwc_checkoutaddress extends LightningElement {
    @track deliveryAddressStreet;
    @api recordId;
    @wire(CheckoutInformationAdapter)
    CheckoutAddressAdapterMethod({ error, data }) {
        if (data) {
            console.log('data In checkOutAddress>>>', data);
            this.deliveryAddressStreet = data.deliveryGroups.items[0].deliveryAddress.street;
            this.checkController();
            // var shippingAddressObject={};
            //  shippingAddressObject['shippingCityInstance']=data.deliveryGroups.items[0].deliveryAddress.city;
        }
        else if (error) {
            console.log('error in checkoutAddress>>', error);
        }
    }
   checkController(){
    CheckoutController({ deliveryAddressStreet: this.deliveryAddressStreet})
    .then(result=>{
        console.log('res>>'+result);
            this.recordId=result;
            console.log('recId>>'+this.recordId);
            const fields={};
            fields[ID_FIELD.fieldApiName] = this.recordId;
            fields[ISDEFAULT.fieldApiName] = true;
            const recordInput = { fields };
            console.log('recordInput---->',recordInput);

            updateRecord(recordInput).then(() => {
                console.log('record updated--->>');
            })
            .catch(error=>{
                console.log('error in update',error);
            })
    })
    .catch(error=>{
        console.log('checkout error--->',error);
        console.log('checkout error--->'+JSON.stringify(error));
    })
        
    }
}