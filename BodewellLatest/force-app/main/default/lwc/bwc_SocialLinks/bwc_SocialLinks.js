import { LightningElement, wire, track } from "lwc";
import { NavigationMixin } from 'lightning/navigation';
import getSocialMediaLinks from "@salesforce/apex/BWC_SocialLinksController.getSocialMediaLinks";

export default class Bwc_SocialLinks extends NavigationMixin(LightningElement) {
   

  @track socialMediaLinks = {};

  @track sMediaLink = {};

  @wire(getSocialMediaLinks)
  wiredSocialMediaLinks({ error, data }) {
    if (data) {
      this.socialMediaLinks = data;
      
    
      data.forEach((currentItem) => {
        this.sMediaLink[currentItem.DeveloperName] = currentItem.newUrl__c;
      });
      
    } else if (error) {
      // Handle the error if needed
      //console.error("Error loading social media links:", error);
    }
  }
}