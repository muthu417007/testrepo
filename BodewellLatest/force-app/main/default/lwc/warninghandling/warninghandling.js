import { LightningElement, api } from 'lwc';

export default class Successhandling extends LightningElement {
    @api infomessage;
    

    closeWarning() {
        //console.log(successmessage);
        
        const closeWarningEvent = new CustomEvent('warningclosed');
    
        this.dispatchEvent(closeWarningEvent);
      }
}