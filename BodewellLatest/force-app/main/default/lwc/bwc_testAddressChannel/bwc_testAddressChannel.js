import { LightningElement, api, track, wire } from 'lwc';

export default class Bwc_testAddressChannel extends LightningElement {
    sessionStorageOptionId;
    localStorageOptionId;
 
  connectedCallback() {
 
    //check if any values were passed in
    if(sessionStorage.getItem('id')){
        //An Id key is in the session Storage
        console.log('sessionStorageOptionId=='+sessionStorageOptionId);
        this.sessionStorageOptionId = sessionStorage.getItem('id');
console.log('sessionStorageOptionId=='+sessionStorageOptionId);
        //Clear session storage after getting the Id
        sessionStorage.clear();
    }

    if(localStorage.getItem('id')){
        //An Id key is in the local Storage
        console.log('localStorageOptionId=='+localStorageOptionId);
        this.localStorageOptionId = localStorage.getItem('id');
        console.log('localStorageOptionId=='+localStorageOptionId);
        //Clear local storage after getting the values
        localStorage.clear();
    }


 
  }
 

}