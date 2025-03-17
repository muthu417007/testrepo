import { LightningElement, api } from 'lwc';

export default class Successhandling extends LightningElement {
    @api successmessage;
    

    closeSuccess() {
        //console.log(successmessage);
        
        const closeSuccessEvent = new CustomEvent('successclosed');
    
        this.dispatchEvent(closeSuccessEvent);
      }
}