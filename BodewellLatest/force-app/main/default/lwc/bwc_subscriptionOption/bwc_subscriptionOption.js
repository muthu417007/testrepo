import { LightningElement } from 'lwc';
export default class Bwc_subscriptionOption extends LightningElement {
  value = 'None';

    get options() {
        return [
            { label: 'None', value: 'None' },
            { label: '1', value: '1' },
            { label: '3', value: '3' },
            { label: '6', value: '6' },
            { label: '12', value: '12' },
            { label: '18', value: '18' },
        ];
    }

    connectedCallback(){
        console.log('so_Frequncy in local storage->', localStorage.getItem('so_Frequency'));
        localStorage.setItem('so_Frequency', 'None');
    }

    handleChange(event){
        console.log('event.target-->',event.target.value);
        localStorage.setItem('so_Frequency',event.target.value);
    }
}