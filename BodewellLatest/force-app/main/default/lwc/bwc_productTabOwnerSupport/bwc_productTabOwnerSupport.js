import { LightningElement, api, wire, track } from 'lwc';

export default class Bwc_productTabOwnerSupport extends LightningElement {



    /**
       * @type {?JsonData}
       * @private
       */
    _productDetails;

   @track _documentsAndCad = [];
    _Cad;
    _documents;


    /**
     * The product to select variants for.
     * @type {?JsonData}
     */

    @api
    get product() {
        return this._productDetails;
    }
    set product(val) {
        this._productDetails = val;



        if (val) {
console.log('this.val'+JSON.stringify(val));
            this._Cad =JSON.parse(val?.fields?.BWC_CAD__c);
                     this._documents = JSON.parse(val?.fields?.BWC_Documents__c);
console.log('this._documents'+JSON.stringify(this._documents));
console.log('this._Cad'+JSON.stringify(this._Cad));
this._documentsAndCad=[];
            if (this._documents) {

                this.docObjectdoc(this._documents.Documents);
            }
            if (this._Cad) {
                this.docObjectcad(this._Cad.CAD);
            }




        }


    }


    docObjectdoc(cad) {
        // for (let key in documents) {
        //   this._documentsAndCad.push({ key: key, value: documents[key] });
        // }
      
        for (let key in cad) {
            if (key != 'sku') {
                // console.log(key);
                // console.log(cad[key]);
                var keyWithoutPrefix = key.replace(/^Documents_\d+_/i, ""); // Remove the prefix
                this._documentsAndCad.push({ key: keyWithoutPrefix, value: cad[key] });
            }

        }

    }

    docObjectcad(cad) {
     
        for (let key in cad) {
            if (key != 'sku') {
                // console.log(key);
                // console.log(cad[key]);
                var keyWithoutPrefix = key.replace(/^CAD_\d+_/, "CAD FILES "); // Remove the prefix
                this._documentsAndCad.push({ key: keyWithoutPrefix.replace('_', " "), value: cad[key] });
            }

        }
console.log('shubh ==doc'+JSON.stringify(this._documentsAndCad));
    }




}