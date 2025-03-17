import { api, LightningElement, wire, track } from 'lwc';
import { navigate, NavigationContext, CurrentPageReference } from 'lightning/navigation';
import basePath from '@salesforce/community/basePath';
import { getNavigationMenu } from 'experience/navigationMenuApi';
import { generateTextFormatStyles, generatePaddingClass, generateThemeTextSizeProperty } from 'experience/styling';

export const MENU_ITEMS_TO_SKIP = ['NavigationalTopic', 'SystemLink', 'Event', 'GlobalAction', 'Modal'];

const DEFAULT_ORIENTATION = 'vertical';
const DEFAULT_MAX_DEPTH = 2;
const textNodeMap = {
    h1: 'heading1',
    h2: 'heading2',
    h3: 'heading3',
    h4: 'heading4',
    h5: 'heading5',
    h6: 'heading6',
    p: 'paragraph',
};

/**
 * @typedef {Object} LinkList#LinkListItem
 * @property {string | number} id
 * @property {string} label
 * @property {string} target
 * @property {string} actionType
 * @property {string} [actionValue]
 * @property {string} [imageUrl]
 * @property {Array<LinkList#LinkListItem>} [subMenu=[]]
 * @property {string} [cssClasses]
 * @property {boolean} [isClickable]
 * @property {boolean} [isExternal]
 */

/**
 * A smart list of links to be used in the Experience Builder.
 *
 * @slot header ({ "locked": false, "defaultContent": [{ "descriptor": "dxp_base/textBlock", "attributes": { "text": "Categories", "textAlign": "left", "textDisplayInfo": "{\"textStyle\": \"heading-small\"}", "textDecoration": "{\"bold\": true}" }}] })
 */
export default class bwc_builderLinkList extends LightningElement {
    static renderMode = 'light';

    /**
     * @type {Array<LinkList#LinkListItem> | null}
     * @private
     */
    _items = [];

    /**
     * @type {string | undefined}
     * @private
     */
    _menuEditor;

    /**
     * @type {(LinkListOrientation)}
     * @private
     */
    _orientation = DEFAULT_ORIENTATION;

    /**
     * @type {number}
     * @private
     */
    _maxDepth = DEFAULT_MAX_DEPTH;

    /**
     * @type {string}
     * @private
     */
    _rawTextDisplayInfo = '{}';

    /**
     * @type {TextDisplayInfo}
     * @private
     */
    @track _parsedDisplayInfo = {};

    /**
     * Getter/setter for the naviagtion link set
     * @type {string | undefined}
     */
    @api
    set menuEditor(value) {
        this._menuEditor = typeof value === 'string' && value.trim().length > 0 ? value : undefined;
    }

    get menuEditor() {
        return this._menuEditor;
    }

    /**
     * Getter/setter for the link list's orientation.
     * @param {LinkListOrientation}
     */
    @api
    set orientation(value) {
        this._orientation = value === 'horizontal' ? value : DEFAULT_ORIENTATION;
    }

    get orientation() {
        return this._orientation;
    }

    /**
     * Getter/setter for the maximum depth/level.
     * @type {number}
     */
    @api
    set maxDepth(value) {
        const numberValue = typeof value === 'string' ? parseInt(value, 10) : value;
        this._maxDepth =
            Number.isInteger(numberValue) && (numberValue >= 1 || numberValue === -1) ? numberValue : DEFAULT_MAX_DEPTH;
    }

    get maxDepth() {
        return this._maxDepth;
    }

    /**
     * A link list item's link/anchor color.
     * @type {string | undefined}
     */
    @api linkColor;

    /**
     * A link list item's link/anchor color on hover.
     * @type {string | undefined}
     */
    @api linkHoverColor;

    /**
     * The alignment of the link list items in the container. Default to 'left'
     * @type {string}
     */
    @api textAlign;

    /**
     * The text style for the link list items, e.g. p, h1, h2.
     * @type {string}
     */
    @api
    get textDisplayInfo() {
        return this._rawTextDisplayInfo;
    }
    set textDisplayInfo(value) {
        this._rawTextDisplayInfo = value;
        this._parsedDisplayInfo = JSON.parse(value);
    }

    /**
     * The semantic html tag for the text node
     *
     * @readonly
     * @type {string}
     * @private
     */
    get textNodeTag() {
        return textNodeMap[this._parsedDisplayInfo?.headingTag || 'h3'];
    }

    /**
     * Any text decoration to be added to link list items, e.g. bold, italic.
     * @type {string}
     */
    @api textDecoration = '{}';

    @api targetCategory;

    shouldAddPLPIsVisibleRefinement;

    /**
     * Vertical padding to add between link list items.
     * @type {string}
     */
    @api linkSpacing;

    publishedState;

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        const app =
            currentPageReference &&
            currentPageReference.state &&
            currentPageReference.state.app;
        if (app === 'commeditor') {
            this.publishedState = 'Draft';
        } else {
            this.publishedState = 'Live';
        }
        console.log('CurrentPageReference')
    }

    @wire(getNavigationMenu, {
        navigationLinkSetDeveloperName: '$menuEditor',
        menuItemTypesToSkip: MENU_ITEMS_TO_SKIP,
        addHomeMenuItem: false,
        includeImageUrl: false,
        publishedState: '$publishedState'
    })

    /**
     * Processes the results from the navigationMenuApi into Link List Items
     *
     * @param {StoreAdapterCallbackEntry} result
     */
    wireNavigationMenu(result) {
        const { data = {} } = result;
        const shouldFilter = !this.menuEditor && this.targetCategory;

        // console.log(`bwc_builderSearchResults::wireNavigationMenu::result = ${JSON.stringify(result, null, 2)}`);
        // console.log(`bwc_builderSearchResults::wireNavigationMenu::this.targetCategory = ${this.targetCategory}`);

        const hasData = data && Array.isArray(data.menuItems);

        let items = hasData ? data.menuItems : [];

        // console.log(`bwc_builderSearchResults::wireNavigationMenu::shouldFilter = ${shouldFilter} hasData = ${hasData}`);

        if (shouldFilter && hasData) {
            // Find Level 2 submenu where label matches targetCategory and assign to variable targetMenu
            let targetMenu;
            items.forEach(menuItem => {   // Level 1
                menuItem.subMenu.forEach(subMenuItem => {  // Level 2
                    if (subMenuItem.label === this.targetCategory) {
                        targetMenu = subMenuItem;
                    }
                });
            });
            if (targetMenu) {
                items = [targetMenu]; //items has to be an array of menu items (in this case only 1 element)
                this.shouldAddPLPIsVisibleRefinement = true;
            }
            // console.log(`bwc_builderSearchResults::wireNavigationMenu::targetMenu = ${JSON.stringify(targetMenu, null, 2)}`);
        }

        this._items = this.prepareItems(items);
    }

    /**
     * Determines whether to show the child linkList UI component
     * @returns {boolean}}
     */
    get hasItems() {
        return this._items.length > 0;
    }

    @wire(NavigationContext)
    navContext;

    /**
     * @param {CustomEvent} event
     * @private
     */
    handleItemClick(event) {
        const { value } = event.detail;
        const { actionType } = value;
        let { actionValue = '' } = value;

        if (actionType === 'InternalLink' && actionValue?.startsWith(basePath)) {
            actionValue = actionValue.substring(basePath.length);
        }

        navigate(this.navContext, {
            type: 'standard__webPage',
            attributes: {
                url: actionValue,
            },
        });
    }

    /**
     * Return array of prepared linkListItems
     * @return {LinkListItem[]}
     */
    prepareItems(items) {
        return items.reduce((acc, item, idx) => {
            acc.push(this.prepareItem(item, String(idx)));
            return acc;
        }, []);
    }

    /**
     * This prepares the given menu items and adds an ID to the data.
     * @returns {LinkListItem}
     */
    prepareItem(item, id) {
        const clone = { ...item, id };
        // console.log(`bwc_builderSearchResults::wireNavigationMenu::clone = ${JSON.stringify(clone, null, 2)}`)
        if (clone.actionType === 'InternalLink') {
            if (this.shouldAddPLPIsVisibleRefinement) {
                clone.actionValue = clone.actionValue + '?refinements=' + encodeURIComponent('[{ "nameOrId": "BWC_PLPIsVisible__c", "type": "DistinctValue", "attributeType": "Custom", "values": ["true"] }]');
            }
        }
        if (Array.isArray(clone.subMenu) && clone.subMenu.length > 0) {
            clone.subMenu = clone.subMenu.map((subItem, subIdx) => this.prepareItem(subItem, `${id}_${subIdx}`));
        }
        return clone;
    }

    /**
     * Gets the dxp size name for the selected text style
     * @returns {string}
     */
    get dxpClassForSize() {
        const _textStyle = this._parsedDisplayInfo?.textStyle || 'heading-small';
        return generateThemeTextSizeProperty(_textStyle);
    }

    /**
     * Gets the style values for the selected text decoration
     * @returns {TextStyles}
     */
    get computedTextStyles() {
        const computedStyles = generateTextFormatStyles(JSON.parse(this.textDecoration));
        return {
            weight: computedStyles.weight ? computedStyles.weight : '',
            style: computedStyles.style ? computedStyles.style : '',
            decoration: computedStyles.decoration ? computedStyles.decoration : '',
        };
    }

    /**
     * Gets the selected text weight. If text decoration for this value is selected, this will be the preferred value. Otherwise, if will default to the value for the text style.
     * @returns {string}
     */
    get linkTextWeight() {
        return this.computedTextStyles.weight || 'var(' + this.dxpClassForSize + '-font-weight)';
    }

    /**
     * Gets the selected text weight. If text decoration for this value is selected, this will be the preferred value. Otherwise, if will default to the value for the text style.
     * @returns {string}
     */
    get linkTextStyle() {
        return this.computedTextStyles.style || 'var(' + this.dxpClassForSize + '-font-style)';
    }

    /**
     * Gets the selected text weight. If text decoration for this value is selected, this will be the preferred value. Otherwise, if will default to the value for the text style.
     * @returns {string}
     */
    get linkTextDecoration() {
        return this.computedTextStyles.decoration || 'var(' + this.dxpClassForSize + '-text-decoration)';
    }

    /**
     * Gets the dxp font size property name for the selected text style
     * @returns {string}
     */
    get linkTextFontSize() {
        return 'var(' + this.dxpClassForSize + '-font-size)';
    }

    /**
     * Gets the dxp font size property name for the selected text style
     * @returns {string}
     */
    get linkTextFontFamily() {
        return 'var(' + this.dxpClassForSize + '-font-family)';
    }

    /**
     * Gets the slds vertical padding class for the selected spacing. Returns an empty string if no value selected.
     * @returns {string}
     */
    get lineItemPadding() {
        return generatePaddingClass(this.linkSpacing || 'none', 'vertical') || '';
    }
}