import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
//import getZipCode from '@salesforce/apex/BWC_geolocateZipcodeController.getZipcode';
import getAddress from '@salesforce/apex/BWC_geolocateZipcodeController.getAddress';
import getAddressBylatLong from '@salesforce/apex/BWC_geolocateZipcodeController.getZipcodeByLatLong';
import zipCodeChannel from '@salesforce/messageChannel/zipCodeChange__c';
import { publish, MessageContext } from 'lightning/messageService'
export default class Bwc_geolocateZipcode extends NavigationMixin(LightningElement) {
  @wire(MessageContext)
  messageContext;
 
  @track map = new Map();
 
  @track zipcode;
  @track fullAddress;

  @api
 
  connectedCallback() {
    this.getLocationCord();
  }

  @api
  getLocationCord() {
    if (navigator.geolocation) {


      navigator.geolocation.getCurrentPosition(position => {
        this.searchCoordinates = position.coords.latitude + ',' + position.coords.longitude;
        getAddressBylatLong({ latLong: this.searchCoordinates })
          .then(result => {
           // console.log('zipcode result===' + result);
    
            this.apiResponseParser(result);

          })
          .catch(error => {
           // console.log(error);
          })
     


      },error=>
      {
        console.log('location denied==='+error.message);
        this.sendCodeToParent();
        this.sendCodeToParentUpdatedZip();
      });
    }
   
  }
  sendCodeToParent() {
    //console.log('event dispatched');
    const selectEvent = new CustomEvent('zipCodeEvent', {
      detail: this.fullAddress, bubbles: true, composed: true
    });
    this.dispatchEvent(selectEvent);
  }
  sendCodeToParentUpdatedZip() {
    //console.log('message dispatched New');
    let message = { message: this.fullAddress };
    publish(this.messageContext, zipCodeChannel, message);

  }
  @api
  sendCodeToParentUpdated(updatedVal) {
    getAddress({ zipCode: updatedVal })
      .then(result => {
      this.apiResponseParser1(result);
       

      })
      .catch(error => {
        //console.log(error);
      })

  }
 
  apiResponseParser(response) {
    const jsonObject = JSON.parse(response);
    if (jsonObject.status === 'OK') {
      let addressComponents = jsonObject.results[0].address_components;
      for (let key in addressComponents) {
        if (addressComponents[key].types.includes('postal_code')) {
          // Add values to the map
        this.map.set('Zipcode', addressComponents[key].long_name);

          
        }
        if (addressComponents[key].types.includes('locality')) {
          this.map.set('City', addressComponents[key].long_name);
        
        }
        if (addressComponents[key].types.includes('administrative_area_level_1')) {
          this.map.set('State', addressComponents[key].long_name);
        
        }
        if (addressComponents[key].types.includes('country')) {
          this.map.set('Country', addressComponents[key].long_name);
         
        }
      
  



      }

     // console.log('this.this.map' + this.map);
      var obj = Object.fromEntries(this.map);
        var jsonString = JSON.stringify(obj);
       this.fullAddress=JSON.parse(jsonString);
       // console.log('address' + this.fullAddress.Zipcode);
        this.sendCodeToParent();
       //this.sendCodeToParentUpdatedZip();
      //  //set sessionStorage and localStorage values
      //  sessionStorage.setItem('zipcode',JSON.stringify( this.fullAddress))
      //  localStorage.setItem('zipcode',JSON.stringify( this.fullAddress));
      

    }

  }
  
  apiResponseParser1(response) {
    const jsonObject = JSON.parse(response);
    if (jsonObject.status === 'OK') {
      let addressComponents = jsonObject.results[0].address_components;
      for (let key in addressComponents) {
        if (addressComponents[key].types.includes('postal_code')) {
          // Add values to the map
        this.map.set('Zipcode', addressComponents[key].long_name);

          
        }
        if (addressComponents[key].types.includes('locality')) {
          this.map.set('City', addressComponents[key].long_name);
        
        }
        if (addressComponents[key].types.includes('administrative_area_level_1')) {
          this.map.set('State', addressComponents[key].long_name);
        
        }
        if (addressComponents[key].types.includes('country')) {
          this.map.set('Country', addressComponents[key].long_name);
         
        }
      
  



      }

     // console.log('this.this.map' + this.map);
      var obj = Object.fromEntries(this.map);
        var jsonString = JSON.stringify(obj);
       this.fullAddress=JSON.parse(jsonString);
       // console.log('address' + this.fullAddress.Zipcode);
       // this.sendCodeToParent();
       this.sendCodeToParentUpdatedZip();
       //set sessionStorage and localStorage values
       sessionStorage.setItem('zipcode',JSON.stringify( this.fullAddress))
       localStorage.setItem('zipcode',JSON.stringify( this.fullAddress));
      

    }

  }
}