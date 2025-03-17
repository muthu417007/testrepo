import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getMinKeyLengthForSearch from '@salesforce/apex/BWC_PartsSearchController.getMinKeyLengthForSearch';
import getProductBySearchKey from '@salesforce/apex/BWC_PartsSearchController.getProductBySearchKey';
import searchHeading from '@salesforce/label/c.BWC_Parts_Search_Heading';
import searchDescription from '@salesforce/label/c.BWC_Parts_Search_Description';
import modelFinderHyperLinkText from '@salesforce/label/c.BWC_Parts_Search_Model_Finder_Hyperlink';
import modelFinderHelpText from '@salesforce/label/c.BWC_Parts_Search_Model_Helper';
import searchHelperText from '@salesforce/label/c.BWC_Parts_Search_HelperText';
import PARTS_LOGO from '@salesforce/resourceUrl/PartLogos';

export default class Bwc_partsSearch extends NavigationMixin(LightningElement) {

    searchKey;
    @api noResultKey;
    @api isUserServiceTechnician;
    @api initialSearch;
    @api currentUser;
    minSearchKeyLen;
    productsToDisplay;
    isError = false;

    label = {
        searchHeading, 
        searchDescription,
        modelFinderHyperLinkText,
        modelFinderHelpText,
        searchHelperText
    }

    image = {
        PROFILE_LOGO : PARTS_LOGO + '/PartsLogo/Profile.svg',
        MONOGRAM_LOGO : PARTS_LOGO + '/PartsLogo/Monogram.svg',
        HOTPOINT_LOGO : PARTS_LOGO + '/PartsLogo/Hotpoint.svg',
        HAIER_LOGO : PARTS_LOGO + '/PartsLogo/Haier.svg',
        GE_LOGO : PARTS_LOGO + '/PartsLogo/GE.svg',
        CAFE_LOGO : PARTS_LOGO + '/PartsLogo/Cafe.svg',
        MODEL_FINDER : PARTS_LOGO + '/PartsLogo/ModelFinder.png',
        SCANNER : PARTS_LOGO + '/PartsLogo/Scanner.png'
    }

    async connectedCallback(){
        this.minSearchKeyLen = await getMinKeyLengthForSearch();
        this.initialSearch = (this.currentUser === 'Service') ? this.initialSearch : true;
    }

    get serviceUserBg(){
        return this.currentUser === 'Service' ? 'background-color: white;' : '';
    }
    get buttonPadding(){
        return this.currentUser === 'Service' ? 'margin-top: 14px;' : '';
    }
    handleSearch(event){
        this.noResultKey = this.searchKey;
        if(this.searchKey?.length >= this.minSearchKeyLen){
            this.isError = false;
            getProductBySearchKey({key : this.searchKey})
            .then(result => {
                if(result.products.length > 0){
                    this.productsToDisplay = result;
                    if(!this.isUserServiceTechnician && !this.productsToDisplay.showPDP){
                        this[NavigationMixin.Navigate]({
                            type: 'comm__namedPage',
                                attributes: {
                                    name: 'Parts_Search_Results__c'
                                },
                                state: {
                                    matchedResults : this.searchKey
                                }
                        });
                    } else if(!this.isUserServiceTechnician && this.productsToDisplay.showPDP){
                        this[NavigationMixin.Navigate]({
                            type: 'comm__namedPage',
                            attributes: {
                              name: 'Parts_Exploded_Diagram__c'
                            },
                            state: {
                              sku : this.searchKey,
                              pdt : this.productsToDisplay.products[0].Id
                            }
                        })
                    } 
                    else{
                        const partsSearch = new CustomEvent('partsearchresults', {
                            detail: this.productsToDisplay
                        });
                        this.dispatchEvent(partsSearch);
                    }
                } else{
                    this.initialSearch = false;
                }
                })
                .catch(error => {
                    console.error(error);
                });
        }else{
            this.isError = true;
        }
    }

    handleKeyEnter(event){
        this.searchKey = event.target.value;
    }
}