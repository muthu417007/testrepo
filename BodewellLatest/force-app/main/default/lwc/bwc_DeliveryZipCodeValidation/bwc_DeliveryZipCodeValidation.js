import { LightningElement,api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";

export default class Bwc_DeliveryZipCodeValidation extends NavigationMixin(LightningElement) {
  @api zipCodeInstance;
  cancelModal(){
    this[NavigationMixin.Navigate]({
      type: "comm__namedPage",
      attributes: {
          name: "Current_Cart"
      }
  });
  }
}