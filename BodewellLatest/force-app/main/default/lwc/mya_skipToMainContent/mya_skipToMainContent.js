import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
// Templates
import Cafe from "./mya_skipToMainContent_Cafe.html";
import GEA from "./mya_skipToMainContent_GEA.html";
import Haier from "./mya_skipToMaincontent_Haier.html";

export default class Mya_skipToMainContent extends NavigationMixin(LightningElement) {
    @api brand = 'GEA';
    @api SectionId = 'main';
    // UI render based on brand and user status
      render() {
        if (this.brand == "GEA") {
            return GEA;
        } else if (this.brand == "Haier") {
            return Haier;
        } else if (this.brand == "Cafe") {
            return Cafe;
        }
    }
    /*handleClick(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes:
            {
                name: 'MYA_My_Products__c'
            },
        });
    }*/
    handleMainContent(event){
        let targetId = event.target.dataset.targetId;
        let target = this.template.querySelector(`[data-target-id="${targetId}"]`);
        target.scrollIntoView();
        let source = event.target;
        source.style.position = "absolute";
        source.style.top='10px';
        source.style.left='-1999px';
        source.style.zindex=200;
        source.addEventListener("focus", function () {
            this.style.left = "0px";  
          });
    }
}