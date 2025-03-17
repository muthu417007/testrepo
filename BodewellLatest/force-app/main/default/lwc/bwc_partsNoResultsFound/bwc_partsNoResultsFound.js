import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getMinKeyLengthForSearch from '@salesforce/apex/BWC_PartsSearchController.getMinKeyLengthForSearch';
import PARTS_LOGO from '@salesforce/resourceUrl/PartLogos';
import modelFinderHyperLinkText from '@salesforce/label/c.BWC_Parts_Search_Model_Finder_Hyperlink';
import modelFinderHelpText from '@salesforce/label/c.BWC_Parts_Search_Model_Helper';

export default class Bwc_partsNoResultsFound extends LightningElement {
    @api searchKey;

    label = {
        modelFinderHyperLinkText,
        modelFinderHelpText
    }

    image = {
        MODEL_FINDER : PARTS_LOGO + '/PartsLogo/ModelFinder.png'
    }

    async connectedCallback(){
        this.minSearchKeyLen = await getMinKeyLengthForSearch();
    }

    handleSearch(event){
        this.searchKey = event.target.value;
        if(event.keyCode === 13 && this.searchKey?.length >= this.minSearchKeyLen){
            getProductBySearchKey({key : this.searchKey})
            .then(result => {
                if(result.products.length > 0){
                    this.productsToDisplay = result;
                    this[NavigationMixin.Navigate]({
                        type: 'comm__namedPage',
                            attributes: {
                                name: 'Parts_Search_Results__c'
                            },
                            state: {
                                matchedResults : this.searchKey
                            }
                    });
                } else{
                    this.initialSearch = false;
                }
            })
            .catch(error => {
                console.error(error);
            });
        }
    }

}