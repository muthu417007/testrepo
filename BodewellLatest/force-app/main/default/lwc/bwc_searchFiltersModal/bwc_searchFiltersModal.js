import LightningModal from 'lightning/modal';
import { api } from 'lwc';

export default class bwc_searchFiltersModal extends LightningModal {
    /**
     * The search results data
     * @type {?ProductSearchResultSummary}
     */
    @api
    displayData;

    /**
     * The current page reference
     * @type {PageReference}
     */
    @api
    pageRef;

    /**
     * The facets panel details to pass to the modal
     * @type {FiltersPanelDetail}
     * @private
     * @readonly
     */
    get normalizedDisplayData() {
        return this.displayData?.filtersPanel ?? {};
    }

    /**
     * Gets the total count of product items.
     * @type {number}
     * @readonly
     * @private
     */
    get totalItemCount() {
        return this.displayData?.total ?? 0;
    }
    handleClose() {
        this.close();
    }
}