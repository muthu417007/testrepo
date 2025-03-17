import { LightningElement, api } from 'lwc';

const DEFAULT_LAYOUT = 'desktop';
const MEDIA_QUERY_TABLET = '(min-width: 48em)';
const MEDIA_QUERY_DESKTOP = '(min-width: 64.0625em)';
const layoutOptions = ['mobile', 'tablet', 'desktop'];
const isLayout = (x) => layoutOptions.includes(x);

/**
* @description Minimal Theme layout component for GEA Bodwell that does not include a header
* it handles the following:
* - defines slots
* - handles different form factors 
* @slot Title
* @slot Footer_Customer_Care
* @slot Footer_My_Bodewell
* @slot Footer_Our_Company
* @slot Footer_Logo
* @slot Footer_Social
* @slot Footer_Copyright
*/
export default class bwc_BodewellMinimalLayout extends LightningElement {
    _state = {
        layout: DEFAULT_LAYOUT
    };

    _mqlDesktop = null;
    _mqlTablet = null;
    _calculateLayoutTimeout = null;
    _handleMediaQueryListChange = this.calculateLayout.bind(this);

    /**
     * Configure class variables used for detecting the current layout and changes to it
     */
    constructor() {
        super();
        this._mqlTablet = window.matchMedia(MEDIA_QUERY_TABLET);
        this._mqlDesktop = window.matchMedia(MEDIA_QUERY_DESKTOP);
    }

    /**
     * @description Controls whether the footer is shown or not
     * @type {boolean}
     */
    @api showFooter;

    /**
     * @description Controls what layout to use (mobile, tablet, desktop)
     * @type {string}
     */
    @api
    set layout(value) {
        this.updateState({ layout: isLayout(value) ? value : DEFAULT_LAYOUT });
    }

    get layout() {
        return this._state.layout;
    }

    /**
     * @description Returns whether the current layout is desktop
     * @type {boolean}
     * @readonly
     */
    get isDesktop() {
        return this._state.layout === 'desktop';
    }

     /**
     * @description Returns whether the current layout is tablet
     * @type {boolean}
     * @readonly
     */
    get isTablet() {
        return this._state.layout === 'tablet';
    }

     /**
     * @description Returns whether the current layout is mobile
     * @type {boolean}
     * @readonly
     */
    get isMobile() {
        return this._state.layout === 'mobile';
    }

    /**
     * @description Calculates the layout and sets up event listeners
     */
    connectedCallback() {
        this.calculateLayout();

        this._mqlTablet.addEventListener('change', this._handleMediaQueryListChange);
        this._mqlDesktop.addEventListener('change', this._handleMediaQueryListChange);
    }

    /**
     * @description Disconnects event listeners and clears timeout that calculates layout
     */
    disconnectedCallback() {
        this._mqlTablet.removeEventListener('change', this._handleMediaQueryListChange);
        this._mqlDesktop.removeEventListener('change', this._handleMediaQueryListChange);

        if (this._calculateLayoutTimeout) {
            clearTimeout(this._calculateLayoutTimeout);
            this._calculateLayoutTimeout = null;
        }
    }

    /**
     * @description Update the internal state
     * @param {object} statePartial 
     */
    updateState(statePartial) {
        this._state = { ...this._state, ...statePartial };
    }

    /**
     * Calculate the current layout based on the matchMedia class variables
     * @returns {string}
     */
    obtainLayout() {
        if (this._mqlDesktop.matches) {
            return 'desktop';
        }
        if (this._mqlTablet.matches) {
            return 'tablet';
        }
        return 'mobile';
    }

    /**
     * @description clear the layout in the internal state object and setup a timeout
     * to calculate the layout
     */
    calculateLayout() {
        // This tiny little hack is required to prevent issues due to multiple simultaneous script-based media queries taking effect.
        // Example: The multi-level navigation implements media query driven behavior changing the type of navigation component
        // set into play. This leads to issues as our component effectively removes HTMLSlotElements along with their containers.
        // Via the hack to set the layout to undefined we remove the whole header contents for a tick before we completely set up
        // a new component tree.
        this.updateState({ layout: undefined });

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this._calculateLayoutTimeout = window.setTimeout(() => {
            const layout = this.obtainLayout();
            this._calculateLayoutTimeout = null;
            this.updateState({ layout });
        });
    }
}