import { api, LightningElement } from 'lwc';
import { NUM_FACETVALUES_ALWAYS_DISPLAYED, FACETVALUE_SHOW_MORE_LIMIT } from './constants';
import generateLabel from './inputFacetLabelGenerator';

export default class bwc_searchInputFacet extends LightningElement {
    static renderMode = 'light';

    /**
     * The values of the facet
     * @type {?DistinctFacetValue[]}
     */
    @api
    values;

    /**
     * Gets the defaulted / normalized sequence of facet values to display.
     * @type {DistinctFacetValue[]}
     */
    get normalizedValues() {
        return this.values || [];
    }

    /**
     * The type of facet being displayed
     * @type {?string}
     */
    @api
    type;

    /**
     * The facet name for the values being displayed
     * @type {?string}
     */
    @api
    facetName;

    /**
     * Determines whether we show all the facet's values or not
     * @type {boolean}
     * @private
     */
    _expanded = false;

    getRating(id) {
        switch (id) {
            case '1 &Up':
                return '1 star & Up';
            case '3 &Up':
                return '3 stars & Up';
            case '4 &Up':
                return '4 stars & Up';
            default:
                return 'Rating not available';
        }
    }

    /**
     * Gets the defaulted / normalized sequence of facet values to display.
     * Only show the first 6 values if
     * @type {DistinctFacetValue[]}
     * @readonly
     * @private
     */
    get displayedValues() {
        let facetValues = Array.from(this.normalizedValues);
        facetValues = facetValues.map((facetValue) => {  
          //  console.log("displayedValues showRatingOnFilters facetValue", JSON.stringify(facetValue));              
            return {
                ...facetValue,
                rating: this.getRating(facetValue.id)
            };
        });

        if (this.displayShowMore && !this._expanded) {
            facetValues = facetValues.slice(0, NUM_FACETVALUES_ALWAYS_DISPLAYED);
        } else if (this.displayShowMore && this._expanded) {
            facetValues = facetValues.map((facetValue, index) => ({
                ...facetValue,
                focusOnInit: index === NUM_FACETVALUES_ALWAYS_DISPLAYED,
            }));
        }
        //console.log('displayedValues showRatingOnFilters', JSON.stringify(facetValues),this.displayShowMore,this._expanded);

        return facetValues;
    
    }

    /**
     * Gets whether we should display a "Show More" button or not
     * @type {boolean}
     * @readonly
     * @private
     */
    get displayShowMore() {
        return this.normalizedValues.length > FACETVALUE_SHOW_MORE_LIMIT;
    }

    /**
     * Gets the label for the 'Show More' or 'Show Less' button
     * @type {string}
     * @readonly
     * @private
     */
    get showMoreOrLessLabel() {
        return generateLabel(this._expanded);
    }

    /**
     * Gets the aria label for the 'Show More' or 'Show Less' button
     * @type {string}
     * @readonly
     * @private
     */
    get facetAriaLabel() {
        return generateLabel(this._expanded, this.facetName);
    }

    /**
     * Handle the 'click' event fired from the 'Show More' or 'Show Less' button
     * @private
     */
    handleShowMoreOrLess() {
        this._expanded = !this._expanded;
    }
}