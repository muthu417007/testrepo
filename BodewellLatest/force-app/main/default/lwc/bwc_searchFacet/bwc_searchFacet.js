import { LightningElement, api } from 'lwc';
import generateLabel from './facetLabelGenerator';

 /**
  * An event fired when a facet has been selected
  * @event SearchFacet#facetvaluetoggle
  * @type {CustomEvent}
  * @property {object} detail CustomEvent details
  * @property {string} detail.id
  *   ID or internal name of the facet value
  * @property {boolean} detail.checked
  *   Whether the value is selected.
  * @property {string} detail.facetId
  *   The selected facet id
  */

 /**
  * General facet display component
  * @fires SearchFacet#facetvaluetoggle
  */
 export default class bwc_searchFacet extends LightningElement {
     static renderMode = 'light';

     /**
      * Determines whether we expand to show the facet's values or not
      * @type {boolean}      */

    
     _expanded = true;

     /**
      * Sorts the values if its Rating field, and send as default for rest of the fields
      * @type {?SearchFacet}
      */

     getDisplayDataValues(data){
      //  console.log("data SearchFacet::", JSON.stringify(data));
       if(data.values.length){
       // console.log("data.displayName", data.displayName);
        const sortedValues = [...data.values];
         if(data.displayName=='Rating'){
            sortedValues.sort((a, b) => {
                const numberA = parseInt(a.id.match(/\d+/)[0]);
                const numberB = parseInt(b.id.match(/\d+/)[0]);
               // console.log("data numA numB", numberA,numberB,numberB-numberA);
                return numberB - numberA;
            });
            //console.log("data.values SearchFacet before::", JSON.stringify(sortedValues));

         }
         //console.log("data.values SearchFacet::", JSON.stringify(sortedValues));
         return sortedValues;
       }
       return [];

     }
     /**
      * Gets or sets the facet display-data.
      * @type {?SearchFacet}
      */
     @api
     displayData;
     get normalizedDisplayData() {
        /*console.log('Normalized Display Data:', {
            ...(this.displayData ?? {}),
            displayData:JSON.stringify(this.displayData),
            nameOrId: this.displayData?.nameOrId ?? '',
            displayType: this.displayData?.displayType ?? 'checkbox',
           // values: JSON.stringify(this.displayData?.values) ?? [],
            values: this.getDisplayDataValues(this.displayData),
        }); */

         return {
             ...(this.displayData ?? {}),
             nameOrId: this.displayData?.nameOrId ?? '',
             displayType: this.displayData?.displayType ?? 'checkbox',
             //values: this.displayData?.values ?? [],
             values: this.getDisplayDataValues(this.displayData),

         };
     }

    get rating(){
        if(this.normalizedDisplayData.displayName=='Rating'){
            return true;
        }
    }
     /**
      * Gets the type of facet being displayed.
      * Types supported: 'checkbox', 'radio', 'range', 'datetime'
      * @type {?string}
      * @private
      * @readonly
      */
     get type() {
         return this.normalizedDisplayData.displayType;
     }

     /**
      * Gets the display name of facet to be displayed.
      * @type {?string}
      * @private
      * @readonly
      */
     get name() {
         return this.normalizedDisplayData.displayName;
     }

     /**
      * Gets the values of the facet
      * @type {DistinctFacetValue[]}
      * @private
      * @readonly
      */
     get values() {
         return this.normalizedDisplayData.values;
     }

     /**
      * Determines whether the facet is a slider
      * @type {boolean}
      */
     get isSlider() {
         return this.type === 'range';
     }

     /**
      * Determines whether the facet is a date-time
      * @type {boolean}
      * @private
      * @readonly
      */
     get isDateTime() {
         return this.type === 'datetime';
     }

     /**
      * Determines whether the facet is a date-time or slider
      * @type {boolean}
      * @private
      * @readonly
      */
     get isDateTimeOrSlider() {
         return this.isDateTime || this.isSlider;
     }

     /**
      * The minimum value count for the facet, if it is a slider
      * @type {?number}
      * @private
      * @readonly
      */
     get minValue() {
         return this.values[0].productCount;
     }

     /**
      * The maximum value count for the facet, if it is a slider
      * @type {?number}
      * @private
      * @readonly
      */
     get maxValue() {
         return this.values[1].productCount;
     }

     /**
      * The icon for the facet toggle button
      * @type {string}
      * @private
      * @readonly
      */
     get iconName() {
         return this._expanded ? 'utility:chevrondown' : 'utility:chevronup';
     }

     /**
      * The CSS classes for the facet toggle button
      * @type {string}
      * @private
      * @readonly
      */
     get facetDisplayClasses() {
         return this._expanded ? '' : 'slds-hide';
     }

     /**
      * Gets the label for the facet toggle.
      * @type {string} the generated label
      * @private
      * @readonly
      */
     get facetToggleLabel() {
         return generateLabel(this._expanded);
     }
     handleFacetHeaderToggle() {
         this._expanded = !this._expanded;
     }

     /**
      * Handle the 'click' event fired from the facet body
      * @param {CustomEvent} event The event object
      * @fires SearchFacet#facetvaluetoggle
      */
     handleFacetToggle(event) {
         event.stopImmediatePropagation();
         this.dispatchEvent(
             new CustomEvent('facetvaluetoggle', {
                 bubbles: true,
                 composed: true,
                 cancelable: true,
                 detail: {
                     ...event.detail,
                     facetId: this.normalizedDisplayData.id,
                 },                
             })
         );
        // console.log('facetvaluetoggle in searchFacet', JSON.stringify(event.detail));

     }
 }