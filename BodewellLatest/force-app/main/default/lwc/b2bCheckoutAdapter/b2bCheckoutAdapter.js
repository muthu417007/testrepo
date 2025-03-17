import { LightningElement,wire } from 'lwc';
import { CheckoutInformationAdapter ,restartCheckout,updateContactPointAddress} from 'commerce/checkoutApi';
import { refreshCartSummary } from 'commerce/cartApi';

export default class B2bCheckoutAdapter extends LightningElement {
    @wire(CheckoutInformationAdapter)
    CheckoutInformationAdapterMethod({ error, data }) {
        if (data) {
            console.log("checkoutData-->", data);
        }
    }
    handleClick(){
        restartCheckout();
        //refreshCartSummary('0a68B0000000BPZQA2');
        // let address = {"city": "Tampa","companyName": "","country": "US","firstName": "MOHAMAD","lastName": "FEROZ","name": "MOHAMAD FEROZ","postalCode": "33602","region": "FL","street": "401 N Ashley Dr, Tampa,\nTampa"};
        // var a = updateContactPointAddress({addressId : '8lW8B000000RN5RUAW'});
        // console.log('a==>',a);
        // console.log('a==>'+JSON.stringify(a));
        location.reload();
    }
}