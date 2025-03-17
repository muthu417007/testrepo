import { LightningElement ,api,wire} from 'lwc';
import GEA from "./mYA_ChangePassword.html";
import Cafe from "./mYA_ChangePasswordCafe.html";
import Haier from "./mYA_ChangePasswordHaier.html";
import {
    FlowNavigationBackEvent,
    FlowNavigationNextEvent
  } from "lightning/flowSupport";
  import { NavigationMixin } from 'lightning/navigation'; 
export default class MYA_ChangePassword extends LightningElement {

@api brand='GEA';
@api brandVal='GEA';
@api NewPass;
@api OldPass;
@api ReEnterPass;
@api Message;
@api isMess;
@api newUrl='https://mya-appliances.cs44.force.com/GEA/s/mya-account-details';
delayInMilliseconds=2000;
handleChange(event){
if(event.target.name=='oldPass'){
    this.OldPass=event.target.value;
   
}
else if(event.target.name=='newPass'){
    this.NewPass=event.target.value;
}else{
    this.ReEnterPass=event.target.value;

}
}
connectedCallback(){
    
}

render() {
   // debugger;
    if(this.Message=='Password Change is Successful'){
        console.log('inside success mess');
        this.isMess=false;
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'MYA_Account_Details__c'
            }
        });
    }else if(this.Message!=null && this.Message!='Password Change is Successful'){
        console.log('mess'+this.Message);
        this.isMess=true;
        setTimeout(() => {
           window.location.reload();
        }, 5000);
    }
    
    if (this.brand == "GEA") {
        return GEA;
    }
    else if (this.brand == "Cafe") {
        return Cafe;
    }
    else if(this.brand == "Haier")
    {
        return Haier;
    }

    
}

handleContinue(event){
   
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
     
}



}