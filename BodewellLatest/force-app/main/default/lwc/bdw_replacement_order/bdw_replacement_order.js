import { LightningElement,api } from 'lwc';

export default class Bdw_replacement_order extends LightningElement {
    url = "https://external-forms-qa.al.ge.com/returnorder/home";
    @api invock(){
        window.open(this.url,'_blank');
        
    }
}