//*********************************************//
//  Name: Kanishtika Gupta
//  Copyright: @ 2022 GE Appliances
//*********************************************
//  Req: CR Case List View
//  
//  
//*********************************************
//  Purpose: CR Cases View
//*********************************************
//  History
//---------------------------------------------
//  Version		Author		Date		Details
//  -------		-------		-------		-------
// 
//*********************************************//
import { LightningElement,wire,track ,api } from 'lwc';
//Navigation to Case detail Page
import { NavigationMixin } from 'lightning/navigation';
//Fetch case list 
import getCaseList from '@salesforce/apex/MYA_CR_Cases.getCaseList';
//case label for No Data aviliability
import casemsg from '@salesforce/label/c.Mya_cr_case_aviliability';
//Brands templates
import GEA from "./mya_cr_cases.html";
import Cafe from "./mya_cr_cases_cafe.html";
import Haier from "./mya_cr_cases_haier.html";
export default class Mya_cr_cases extends NavigationMixin(LightningElement) {
    msg = casemsg;//Case Label (No Data avialiable)
    isLoading = false;
    error;  
    lengthofCase = false; 
    @api brand = 'GEA';
    // UI render based on brand
      render() {
        if (this.brand == "GEA") {
            return GEA;
        } else if (this.brand == "Haier") {
            return Haier;
        } else if (this.brand == "Cafe") {
            return Cafe;
        }
    }
    @wire(getCaseList) wiredcases ({ error, data }){
        this.isLoading = true;
        if (data) {
            this.caseList = data;
            this.isLoading = false;
            if(data.length>0){
            this.lengthofCase = true;
            }
            else{
              this.lengthofCase = false;  
            }
        } else if (error) {
            this.error = error;
            this.isLoading = false;
        }
    }
    //Navigate to case Detail Page
    handleCaseDetails(event) {
        debugger;
        var rid = event.target.value;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/case/'+rid
            },
            state: {
                caserecordId: rid
            }
        });
    }
}