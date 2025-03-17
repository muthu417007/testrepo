import { LightningElement , api, track, wire} from 'lwc';

import parametersValues from '@salesforce/apex/BWC_CyberSourceSignatureConfigController.getParametersValuesLWC';
import signedData from '@salesforce/apex/BWC_CyberSourceSignatureConfigController.getSignature';


export default class Bwc_CyberSourceSignatureForm extends LightningElement {
    paramMap;
    dataParam=[];
    @track
    signedData;
    @track
    signature;
    @track

    parametersValues=[];
    displayParam=true;

    submitForm() {
      const form = this.template.querySelector('form');
      form.target='_blank';
      form.submit();

    }

 
    connectedCallback() {
        console.log('doInit called');
        //parametersValues({ userId : this.userID})
        parametersValues()
            .then((jsonResponse) => {
                console.log('parametersValues response is++>>> '+jsonResponse);
                if(jsonResponse!=null){
                    this.paramMap=jsonResponse;
                    console.log('Manager Name :- '+JSON.stringify(jsonResponse));
                    for(let key in jsonResponse)
                    {
                        this.parametersValues.push({key:key,value:jsonResponse[key]});
                        this.dataParam.push({key:jsonResponse[key]});
                    }
                    
                }
                console.log('dataParam  :- '+JSON.stringify(this.dataParam));
            })
            .catch((error) => {
                console.log('error'+error);
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Failed to load the page.',
                    variant: 'error',
                });
                dispatchEvent(evt);
           });


           signedData()
            .then((jsonResponse) => {
                console.log('signedData response is +++>>> '+jsonResponse);
                this.signature=jsonResponse;
                if(jsonResponse!=null){
                    console.log('Manager Name :- '+jsonResponse);
                }
            })
            .catch((error) => {
                console.log('error'+error);
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Failed to load the page.',
                    variant: 'error',
                });
                dispatchEvent(evt);
           });
    }

}