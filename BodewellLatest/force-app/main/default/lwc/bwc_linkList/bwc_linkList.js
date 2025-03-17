import { api, LightningElement } from 'lwc';
import { generateStyleProperties } from 'experience/styling';
import { isClickableItem, isExternalItem } from './util';

const DEFAULT_DEPTH = 0;
const DEFAULT_MAX_DEPTH = -1;
const DEFAULT_ORIENTATION = 'vertical';
const DEFAULT_MARK_ACTIVE = 0;
export const DEFAULT_H3 = 'heading3';

let idCounter = -1;
const uniqueId = () => {
    ++idCounter;
    return `${idCounter}`;
};

/**
 * A presentational list of links.
 *
 * The component accepts the input of an orientation and a maximum depth to take into account for rendering the given
 * list item data. It fires the events "itemclick", "itemmouseenter" and "itemmouseleave" to inform its consumers
 * about certain user interactions.
 *
 * In addition to the input/output API, the component marks its `<li>` elements with a meaningful set of CSS classes.
 *
 * Markers for all list types:
 *
 * * `<ul.is-root>`                    -> Marks the root-level list container
 * * `<ul.is-child.is-child-{$depth}>` -> Marks a nested list container
 * * `<li.is-parent>`                  -> Marks a list item that contains a nested list container
 * * `<li.is-leaf>`                    -> Marks a list item that does not contain further nested list container
 * * `<li.is-hovered>`                 -> Marks a list item and its parents to indicate that the mouse entered the branch
 * * `<li.is-active>`                  -> Marks a list item and its parents to indicate that the user clicked the branch
 *
 * Specific markers for vertical lists:
 *
 * * `<ul.slds-is-nested>`
 *
 * Specific markers for horizontal lists:
 *
 * * `<ul.is-horizontal>`
 * * `<ul.slds-list_horizontal>`
 *
 * @fires LinkList#itemclick
 * @fires LinkList#itemmouseenter
 * @fires LinkList#itemmouseleave
 */
export default class bwc_linkList extends LightningElement {
    static renderMode = 'light';

    /**
     * @type {Array<LinkList#LinkListItem>}
     * @private
     */
    _rawItems = [];

    /**
     * @type {Object.<string, LinkList#LinkListItem>}
     * @private
     */
    _rawItemsMap = {};

    /**
     * @type {Array<LinkList#LinkListItem> | null}
     * @private
     */
    _items = null;

    /**
     * @type {number}
     * @private
     */
    _depth = DEFAULT_DEPTH;

    /**
     * @type {number}
     * @private
     */
    _maxDepth = DEFAULT_MAX_DEPTH;

    /**
     * @type {number}
     * @private
     */
    _maxDepthChildren = DEFAULT_MAX_DEPTH;

    /**
     * @type {(LinkListOrientation)}
     * @private
     */
    _orientation = DEFAULT_ORIENTATION;

    /**
     * @type {number}
     * @private
     */
    _markActive = DEFAULT_MARK_ACTIVE;

    /**
     * Flag used to prevent multiple invocations of `computeItems()` in case of using both the `maxDepth` and the `items`
     * input properties.
     *
     * @type {boolean}
     * @private
     */
    _wasConnected = false;

    /**
     * @type {Array<LinkList#LinkListItem> | null}
     */
    @api
    set items(value) {
        this._rawItems = Array.isArray(value) ? value.map((item) => this.ensureItemId(item)) : [];
        this._rawItemsMap = this._rawItems.reduce((acc, item) => {
            acc[item.id] = item;
            return acc;
        }, {});
        this._items = this.computeItems();
    }

    /**
     * @type {Array<LinkList#LinkListItem> | null}
     */
    get items() {
        return this._items;
    }

    /**
     * Getter/setter for the current depth/level.
     * @param {number | string} [value=0]
     */
    @api
    set depth(value) {
        const numberValue = typeof value === 'string' ? parseInt(value, 10) : value;
        this._depth = Number.isInteger(numberValue) && numberValue >= 0 ? numberValue : DEFAULT_DEPTH;
    }

    get depth() {
        return this._depth;
    }

    get depthChildren() {
        return this._depth + 1;
    }

    /**
     * Getter/setter for the maximum depth/level.
     * @param {number | string} [value=-1]
     */
    @api
    set maxDepth(value) {
        const numberValue = typeof value === 'string' ? parseInt(value, 10) : value;
        const maxDepth = Number.isInteger(numberValue) && numberValue >= 1 ? numberValue : DEFAULT_MAX_DEPTH;

        if (maxDepth === -1) {
            this._maxDepth = this._maxDepthChildren = -1;
        } else {
            this._maxDepth = Math.max(1, maxDepth);
            this._maxDepthChildren = Math.max(0, maxDepth - 1);
        }
        this._items = this.computeItems();
    }

    get maxDepth() {
        return this._maxDepth;
    }

    /**
     * @returns {number}
     * @private
     */
    get maxDepthChildren() {
        return this._maxDepthChildren;
    }

    /**
     * Getter/setter for the link list's orientation.
     * @param {LinkListOrientation} [value='vertical']
     */
    @api
    set orientation(value) {
        this._orientation = value === 'horizontal' ? value : DEFAULT_ORIENTATION;
    }

    get orientation() {
        return this._orientation;
    }

    /**
     * Getter/setter for the link list's text color.
     * @type {string | undefined}
     */
    @api
    linkColor;

    /**
     * Getter/setter for the link list's hover color.
     * @type {string | undefined}
     */
    @api
    linkHoverColor;

    /**
     * Getter/setter for the link list's vertical padding.
     * @type {string | undefined}
     */
    @api
    lineItemPadding;

    /**
     * Getter/setter for the link list's text alignment.
     * @type {string | undefined}
     */
    @api
    linkTextAlignment;

    /**
     * Getter/setter for the link list's text weight.
     * @type {string | undefined}
     */
    @api
    linkTextWeight;

    /**
     * Getter/setter for the link list's text style.
     * @type {string | undefined}
     */
    @api
    linkTextStyle;

    /**
     * Getter/setter for the link list's text decoration values.
     * @type {string | undefined}
     */
    @api
    linkTextDecoration;

    /**
     * Getter/setter for the link list's text font size.
     * @type {string | undefined}
     */
    @api
    linkTextFontSize;

    /**
     * Gets the dxp font size property name for the selected text style
     * @returns {string}
     */
    @api
    linkTextFontFamily;

    /**
     * Getter/setter for the link list's text node tag.
     * @type {string}
     */
    @api
    textNodeTag = DEFAULT_H3;

    /**
     * Whether or not the text element to be displayed is an h1 tag.
     *
     * @readonly
     * @returns {boolean}
     * @private
     */
    get isH1() {
        return this.textNodeTag === 'heading1';
    }

    /**
     * Whether or not the text element to be displayed is an h2 tag.
     *
     * @readonly
     * @returns {boolean}
     * @private
     */
    get isH2() {
        return this.textNodeTag === 'heading2';
    }

    /**
     * Whether or not the text element to be displayed is an h3 tag.
     *
     * @readonly
     * @returns {boolean}
     * @private
     */
    get isH3() {
        return this.textNodeTag === 'heading3';
    }

    /**
     * Whether or not the text element to be displayed is an h4 tag.
     *
     * @readonly
     * @returns {boolean}
     * @private
     */
    get isH4() {
        return this.textNodeTag === 'heading4';
    }

    /**
     * Whether or not the text element to be displayed is an h5 tag.
     *
     * @readonly
     * @returns {boolean}
     * @private
     */
    get isH5() {
        return this.textNodeTag === 'heading5';
    }

    /**
     * Whether or not the text element to be displayed is an h6 tag.
     *
     * @readonly
     * @returns {boolean}
     * @private
     */
    get isH6() {
        return this.textNodeTag === 'heading6';
    }

    /**
     * Whether or not the text element to be displayed is a p tag.
     *
     * @readonly
     * @returns {boolean}
     * @private
     */
    get isBody() {
        return this.textNodeTag === 'paragraph';
    }
    /**
     * Create the custom style definition for the component.
     * @returns {string}
     */
    get customStyles() {
        return generateStyleProperties({
            '--com-c-link-list-anchor-text-color': this.linkColor ?? '',
            '--com-c-link-list-anchor-text-hover-color': this.linkHoverColor ?? '',
            '--com-c-link-list-text-alignment': this.linkTextAlignment ?? '',
            '--com-c-link-list-font-weight': this.linkTextWeight ?? '',
            '--com-c-link-list-font-style': this.linkTextStyle ?? '',
            '--com-c-link-list-decoration': this.linkTextDecoration ?? '',
            '--com-c-link-list-font-size': this.linkTextFontSize ?? '',
            '--com-c-link-list-font-family': this.linkTextFontFamily ?? '',
        });
    }

    /**
     * @type {number}
     * @private
     */
    @api
    set markActive(value) {
        this._markActive = typeof value === 'number' && isFinite(value) ? value : DEFAULT_MARK_ACTIVE;
        if (this._markActive) {
            this.handleMarkActive();
        }
    }

    get markActive() {
        return this._markActive;
    }

    /**
     * After introducing light dom, handleMarkActive selected all li elements that were below a given parent. As a result
     * the active state was sometimes removed from children even though they should have been active. Passing the parent
     * ID to all helped find all siblings with the same parent
     * @type {string}
     */
    @api
    parentId = 'root';

    /**
     * Get the customs classes for the list
     *
     * @returns {string}
     * @private
     */
    get listClasses() {
        const isHorizontal = this._orientation === 'horizontal';
        const isRoot = this._depth === 0;
        const classes = isRoot ? ['is-root'] : ['is-child', `is-child-${this._depth}`];
        if (isHorizontal) {
            classes.push('is-horizontal', 'slds-list_horizontal');
        } else if (!isHorizontal && !isRoot) {
            classes.push('slds-is-nested');
        }

        return classes.join(' ');
    }

    connectedCallback() {
        this._wasConnected = true;
        this._items = this.computeItems();
    }

    /**
     * @param {Event} event
     * @fires LinkList#itemclick
     * @private
     */
    handleClick(event) {
        event.preventDefault();
        // Anchor Element is wrapped in a text style element to allow styling property options
        const textStyleElement = event.currentTarget.parentElement;
        // Access parent LI for the Anchor Element
        const parentLIElement = textStyleElement?.parentElement;
        const listEl = parentLIElement;
        // Apply the `data-active` marker so that the mark active cascade triggered by `broadcastMarkActive()`
        // knows what list elements are to-be-marked in the update cycle.
        listEl.dataset.active = 'true';

        if (this._depth === 0) {
            this.broadcastMarkActive();
        }

        this.dispatchEvent(this.createItemEvent('itemclick', listEl));
    }

    /**
     * @param {CustomEvent} event
     * @private
     */
    handleChildClick(event) {
        const { currentTarget } = event;
        currentTarget.parentElement.dataset.active = 'true';

        if (this._depth === 0) {
            this.broadcastMarkActive();
        }
    }

    /**
     * @param {MouseEvent} event
     * @fires LinkList#itemmouseenter
     * @private
     */
    handleMouseEnter(event) {
        const { currentTarget } = event;
        const listEl = currentTarget;
        listEl.classList.add('is-hovered');
        this.dispatchEvent(this.createItemEvent('itemmouseenter', listEl));
    }

    /**
     * @param {MouseEvent} event
     * @fires LinkList#itemmouseleave
     * @private
     */
    handleMouseLeave(event) {
        const { currentTarget } = event;
        const listEl = currentTarget;
        listEl.classList.remove('is-hovered');
        this.dispatchEvent(this.createItemEvent('itemmouseleave', listEl));
    }

    /**
     * @param {('itemclick' | 'itemmouseenter' | 'itemmouseleave')} type
     * @param {HTMLLIElement} target
     * @private
     */
    createItemEvent(type, target) {
        /**
         * @event LinkList#itemclick
         * @type {CustomEvent}
         * @property {{ value: LinkList#LinkListItem }} detail
         */

        /**
         * @event LinkList#itemmouseenter
         * @type {CustomEvent}
         * @property {{ value: LinkList#LinkListItem }} detail
         */

        /**
         * @event LinkList#itemmouseleave
         * @type {CustomEvent}
         * @property {{ value: LinkList#LinkListItem }} detail
         */

        const { id } = target.dataset;
        return new CustomEvent(type, {
            bubbles: true,
            cancelable: true,
            composed: true,
            detail: {
                value: this._rawItemsMap[id],
            },
        });
    }

    /**
     * @param {LinkList#LinkListItem} item
     * @returns {LinkList#LinkListItem}
     * @private
     */
    ensureItemId(item) {
        if (
            item &&
            (typeof item.id === 'string' || (typeof item.id === 'number' && isFinite(item.id))) &&
            String(item.id).trim().length > 0
        ) {
            return item;
        }
        const id = uniqueId();
        return { ...item, id };
    }

    /**
     * @returns {Array<LinkList#LinkListItem> | null}
     * @private
     */
    computeItems() {
        if (!this._wasConnected || this._rawItems.length === 0) {
            return null;
        }

        if (this._maxDepthChildren === 0) {
            // We reached the maximum depth here to be displayed, so we can cut off the child elements.
            // We will also add the padding class to the line items
            return this._rawItems.map((item) => ({
                ...item,
                subMenu: [],
                isClickable: isClickableItem(item),
                isExternal: isExternalItem(item),
                cssClasses: `is-leaf${this.lineItemPadding ? ' ' + this.lineItemPadding : ''}`,
            }));
        }

        // We need to augment empty `subMenu` entries so that no further nesting containers are added to the DOM
        // We will also add the padding class to the line items
        return this._rawItems.map((item) => {
            const hasChildren = Array.isArray(item.subMenu) && item.subMenu.length;
            return {
                ...item,
                subMenu: hasChildren ? [...item.subMenu] : [],
                isClickable: isClickableItem(item),
                isExternal: isExternalItem(item),
                cssClasses: `${hasChildren ? 'is-parent' : 'is-leaf'}${
                    this.lineItemPadding ? ' ' + this.lineItemPadding : ''
                }`,
            };
        });
    }

    /**
     * Broadcasts to all child elements that they should call themselves out as `is-active`, or alternatively
     * remove an eventually existing active marker in case the `data-active` marker is not set.
     * @private
     */
    broadcastMarkActive() {
        this._markActive = this._markActive + 1;
        this.handleMarkActive();
    }

    /**
     * Identifies all direct children. The ones that are marked via `data-active` get the
     * `is-active` class applied. All others get this marker class removed.
     * @private
     */
    handleMarkActive() {
        const listEls = this.querySelectorAll(`ul > li[data-parent-id="${this.parentId}"]`);
        listEls.forEach((listEl) => {
            if (listEl.dataset.active === 'true') {
                listEl.classList.add('is-active');
                delete listEl.dataset.active;
            } else {
                listEl.classList.remove('is-active');
            }
        });
    }
}