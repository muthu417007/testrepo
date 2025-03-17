import { LightningElement, api, track } from 'lwc';
import LightningModal from 'lightning/modal';

export default class Bwc_partsAddedToListModal extends LightningModal {

    @api label;
    @track itemsInList = [];
    @api image;
    @track modalLabel;

    _demo;
    @api 
    get demo(){
        return this._demo;
    }

    set demo(value){
        this._demo = value;
        for(let [key, value] of this._demo){
            const obj = {'key': key, 'value' : value};
            this.itemsInList.push(obj);
        }
    }

    handleOkay(){
        this.close(JSON.stringify(this.itemsInList));
    }

    handleItemDelet(event){
        const deletedSku = event.target.dataset.id;
        this.itemsInList = this.itemsInList.filter(item => item.key !== deletedSku);
    }
}