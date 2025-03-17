import { LightningElement, api } from 'lwc';
import { FacetUiTypeEnum, FACETVALUE_TOGGLE_EVT } from './constants';

/**
 * An event fired when the facet value has been toggled.
 * @event SearchFacetItem#facetvaluetoggle
 * @property {object} detail CustomEvent details
 * @property {string} detail.id
 *   The ID of the facet value
 * @property {boolean} detail.checked
 *   Whether the facet value has been checked or unchecked
 */
/**
 * Wrapper component for facet values
 * @fires SearchFacetItem#facetvaluetoggle
 */
export default class Bwc_searchFacetItemRatings extends LightningElement {
    static renderMode = 'light';

    /**
     * Gets or sets the facet value
     * @type {?DistinctFacetValue}
     */
    @api
    value;

    /**
     * The type of facet being displayed ("radio" or "checkbox")
     * @type {string}
     */
    @api
    type = FacetUiTypeEnum.CHECKBOX;

    /**
     * Indicates whether we should focus on the facet value when it's first rendered
     * @type {boolean}
     */
    @api
    focusOnInit = false;

    /**
     * Whether the facet item has been rendered at least once.
     * @type {boolean}
     * @private
     */
    hasRenderedAtLeastOnce = false;

    /**
     * Whether the component has acquired focus when it was initially displayed.
     * @type {boolean}
     * @private
     */
    hasInitiallyFocused = false;

    /**
     * Focuses on the facet value on inital rendering if flag is true
     * @private
     */
    renderedCallback() {
        const lightningInputElement = this.querySelector('lightning-input');
        if (!this.hasRenderedAtLeastOnce && !this.hasInitiallyFocused && this.focusOnInit) {
            lightningInputElement?.focus();
            this.hasInitiallyFocused = true;
        }
        if (this.type === FacetUiTypeEnum.CHECKBOX) {
            lightningInputElement.setAttribute('disabled', this.value?.productCount === 0 ? 'true' : 'false');
        }
        this.hasRenderedAtLeastOnce = true;       
    }
    disconnectedCallback() {
        this.hasInitiallyFocused = false;
        this.hasRenderedAtLeastOnce = false;
    }

    /**
     * Handler for the 'keyup' event fired from facetItem
     * @param {CustomEvent} event The event object
     */
    handleKeyPress(event) {
        if (event.code === 'Space') {
            this.handleFacetValueToggle(event);
        }
    }

    /**
     * Handler for the 'click' event fired from inputFacet
     * @param {CustomEvent} event The event object
     * @fires SearchFacetItem#facetvaluetoggle
     */
    handleFacetValueToggle(event) {
        const element = event.target;
        //console.log("event facetItemRatings", JSON.stringify(event));
        if (!element.disabled) {
            event.preventDefault();
            element.checked = !element.checked;
            element.focus();
        }
        this.dispatchEvent(
            new CustomEvent(FACETVALUE_TOGGLE_EVT, {
                bubbles: true,
                composed: true,
                cancelable: true,
                detail: {
                    id: element.dataset.id,
                    checked: element.checked,
                },
            })
        );
        //console.log("Detail: searchFacetItemRatings", JSON.stringify(event.detail));
    }

    get showValueAfterStars() {
        let str = this.value.name;
        let index = str.indexOf('&');
        let starValue = str.substring(index);
        // console.log("Star Value", starValue);
        return starValue;
    }

    get showStars() {
        let star;
        if (this.value.rating.includes('1 star')) {
            star = '1';
        } else if (this.value.rating.includes('2 star')) {
            star = '2'
        }
        else if (this.value.rating.includes('3 star')) {
            star = '3'
        }
        else if (this.value.rating.includes('4 star')) {
            star = '4'
        }
        // console.log("Star", star);   
        return star;
    }
    
    get filledStars() {
        let starCount = Number(this.showStars);
        return Array(starCount).fill('');
      }
      
      get emptyStars() {
        let emptyCount = 5 - Number(this.showStars);
        return Array(emptyCount).fill('');
      }

}