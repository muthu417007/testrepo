import { LightningElement, track, wire} from 'lwc';
import fetchPrices from '@salesforce/apex/BWC_CartController.fetchPrices';

export default class Bwc_productSavingsMemberPDP extends LightningElement {

  
    @track memberProdSavings = 0.0;  
    _productId;
    currencyCode='USD';
   
    connectedCallback(){           
        const currentURL = `${window.location.pathname}`;
        const parts = currentURL.split('/');
        this._productId =parts[parts.length - 1];
        console.log("productId PDP",currentURL, this._productId);
        if (this._productId) {
        this.handleMemProductSavings();
        }
    }

    async handleMemProductSavings() {       
        await fetchPrices({ productIds: [this._productId], quantities: [1] })
            .then(result => {
                console.log("##productId method ", this._productId);
                //this._memberSavings = result.totalDifference;
                if (result.totalDifference != undefined && result.totalDifference > 0) {
                    this.memberProdSavings = (result.totalDifference).toFixed(2);
                }
                else {
                    this.memberProdSavings = 0;
                }
                console.log('##Product Savings from apex PDP' + JSON.stringify(result));
            })
            .catch(error => {
                console.log('## Erro Product Savings from apex PDP' + JSON.stringify(error));
            })
    }

    handleJoinNow()
    {
        this.dispatchEvent(
        new CustomEvent('openmodal'),
        { bubbles: true, composed: true });
         console.log("event dispatched PDP");
    }

 
}