import { LightningElement, api, wire } from 'lwc';
import { getFormFactor } from 'experience/clientApi';
import { Labels } from './labels';

/**
 * The search facets values check map. This is to keep track of the facets
 *  values that has been checked to create refinements for the search query.
 * @typedef {object} SearchFacetValuesCheckMap
 * @property {SearchFacet} searchFacet
 *  The search facet display-data.
 * @property {Map<string, boolean>} valuesCheckMap
 *  A map of facet-value-id with its check/uncheck state.
 */
export default class bwc_searchFilters extends LightningElement {
    static renderMode = 'light';
    @wire(getFormFactor)
    formFactor;
    get isDesktop() {
        return this.formFactor === 'Large';
    }

    /**
     * The title for the mobile button
     * @type {string}
     * @readonly
     */
    filterHeaderLabel = Labels.filterHeader;

    /**
     * Search Results data passed down by the wrapper component
     * @type {?ProductSearchResultSummary}
     */
    @api
    searchResults;

    /**
     * Ensure Search Results data has needed property
     * @type {FiltersPanelDetail}
     * @readonly
     * @private
     */
    get normalizedSearchFilters() {
        return this.searchResults?.filtersPanel ?? {};
    }

    /**
     * Handles opening the filters modal while on mobile only
     * @param {CustomEvent} event click event
     * @fires SearchFilters#openmodal
     */
    handleOpenSearchFiltersModal(event) {
        event.preventDefault();
        this.dispatchEvent(
            new CustomEvent('openmodal', {
                bubbles: true,
                composed: true,
                cancelable: true,
            })
        );
    }
}