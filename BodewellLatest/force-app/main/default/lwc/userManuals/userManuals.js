import { LightningElement, api, wire, track } from 'lwc';
//import MYA_EndecaResponseDetails from '@salesforce/apex/MYA_EndecaApiHandler.MYA_EndecaResponseDetails';
import { MessageContext, APPLICATION_SCOPE, publish } from 'lightning/messageService';
import modeleventchannel from "@salesforce/messageChannel/modeleventchannel__c";
import Owners_Manual from '@salesforce/resourceUrl/OwnersManual';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createMessageContext, releaseMessageContext, subscribe, unsubscribe } from 'lightning/messageService';
import uid from '@salesforce/user/Id';


export default class UserManuals extends LightningElement {
    H_OwnersManual = Owners_Manual;
    manualsdisplayed=false;
    OwnerManualLink;
    assetDetail;
    @track modelno='';
    @track mktmodel;
    @track subscription=null;
    context = createMessageContext();
    
    connectedCallback(){
        console.log('manuals page');
        this.manualsdisplayed=true;
        this.handleSubscribe();
    }
    disconnectedCallback() {
        this.handleUnsubscribe();
    }
    handleUnsubscribe() {
        unsubscribe(this.subscription);
        this.subscription = undefined;
        releaseMessageContext(this.context);
    }
    get subscribeStatus() {
        return this.subscription ? 'TRUE' : 'FALSE';
    }
    
    
    handleSubscribe() {
        console.log('insdie subscribe method : user manuals');
        if (this.subscription) {
            return;
        }
        console.log('creating context');
        this.context = createMessageContext();
        this.subscription = subscribe(this.context, modeleventchannel, (message) => {
            let msg = message.messageBody;
            let dt=msg.record;
            this.handleMessage(dt);
        }, { scope: APPLICATION_SCOPE });
        
    }
    handleMessage(event){
        if (event) {
            //console.log('event is '+event);
            let res=JSON.parse(event);
            console.log('MODEL NO--- '+res.model);
            this.modelno=res.model;
            let originalModel=res.model;
            if(res.mktmodel!=''){
                this.mktmodel = res.mktmodel;
                originalModel = res.mktmodel;
            }
            this.modelno = originalModel;
            let filteredUserManual = res.results.filter(a => a.hasOwnProperty("records"));
            if(filteredUserManual.length>0){
                if("records" in filteredUserManual[0] && "products" in filteredUserManual[0].records && originalModel in filteredUserManual[0].records.products){
                    let products=filteredUserManual[0].records.products;
                    let userManuals=products[originalModel].filter(a=>a.hasOwnProperty("Documents"));
                    if("Documents" in userManuals[0]){
                        let documents=userManuals[0].Documents;
                        const keys = Object.keys(documents);
                        for(let t=0;t<keys.length;t++){
                            //console.log('document is record is --> '+JSON.stringify(documents[keys[t]]));
                            if(documents[keys[t]].Document_Type=='Use_and_Care_Manual'){
                                console.log('owner manual link gets generated');
                                this.OwnerManualLink='https://products.geappliances.com/MarketingObjectRetrieval/Dispatcher?RequestType=PDF&Name='+documents[keys[t]].Name;
                            }
                        }
                    }
                }
            }
            /*Object.keys(documents).forEach(function(key) {
                console.log('Key : ' + key + ', Value : ' + JSON.stringify(documents[key]));
                if(documents[key].Document_Type=='Use_and_Care_Manual'){
                    this.OwnerManualLink='https://products.geappliances.com/MarketingObjectRetrieval/Dispatcher?RequestType=PDF&Name='+documents[key].Name;
                }
              });*/
              
            //console.log('filter user manual is '+JSON.stringify(userManuals));
            /*MYA_EndecaResponseDetails({ SKU: this.modelno })
            .then((resp)=>{
                this.assetDetail=resp.ProductInfo;
                this.userManualLink();
            })*/
            
        }
    }
    userManualLink(){
        if(this.assetDetail){
            
            this.OwnerManualLink = this.assetDetail.UserManualUrl;
            console.log('user manual link is '+this.OwnerManualLink);
        }
        else{
            console.log('no manuals link for provided model');
        }
    }
    
}