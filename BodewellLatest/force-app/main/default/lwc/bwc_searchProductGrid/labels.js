import { PRODUCT_COMPARE_CONSTANTS } from './constants';

import labelSearchResults from '@salesforce/label/c.BWC_Search_Results_searchResults';
import labelProductCompareMax from '@salesforce/label/c.BWC_PRODUCT_COMPARE_MAX_PRODUCTS';
import labelProductCompareMin from '@salesforce/label/c.BWC_PRODUCT_COMPARE_MIN_PRODUCTS';

export const i18n = {
    searchResults: labelSearchResults,
};

export const productCompareLabels = {
    max: labelProductCompareMax.replace('{{max}}', PRODUCT_COMPARE_CONSTANTS.MAX),
    min: labelProductCompareMin.replace('{{min}}', PRODUCT_COMPARE_CONSTANTS.MIN)
}