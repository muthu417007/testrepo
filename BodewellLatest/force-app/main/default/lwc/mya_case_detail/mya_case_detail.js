import { LightningElement ,wire,api} from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
//import getCaseDetail from '@salesforce/apex/MYA_CR_Cases.getCaseDetails'; // get case details
//brands templates
import Cafe from "./mya_case_detail_cafe.html";
import GEA from "./mya_case_detail.html";
import Haier from "./mya_case_detail_haier.html";
export default class Mya_case_detail extends LightningElement {
    rid;
    @api brand = 'GEA';
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
    /*@wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
      if (currentPageReference) {
        this.rid = currentPageReference.state.caserecordId;
        this.getCases();
      }
   }
    cases;
    //get case details
    getCases() {
      getCaseDetail({ crnumber: this.rid })
       .then(result => {
          console.log('getCaseList -> response :', result);
          this.cases = result;
       })
      .catch(error => {
           this.error = error;
           console.error('getCaseList -> error response :', error);
       });
    }*/
}