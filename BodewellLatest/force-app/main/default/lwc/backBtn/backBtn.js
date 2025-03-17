import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class BackBtn extends NavigationMixin(LightningElement) {
  @api pageName;

  navToPage() {
    this[NavigationMixin.Navigate]({
      type: "comm__namedPage",
      attributes: {
        name: this.pageName
      }
    });
  }
}