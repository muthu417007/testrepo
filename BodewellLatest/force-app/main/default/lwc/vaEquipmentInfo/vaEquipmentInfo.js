import { LightningElement, api, wire, track } from 'lwc';
import { MessageContext, APPLICATION_SCOPE, publish } from 'lightning/messageService';
import modeleventchannel from "@salesforce/messageChannel/modeleventchannel__c";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createMessageContext, releaseMessageContext, subscribe, unsubscribe } from 'lightning/messageService';
import uid from '@salesforce/user/Id';
export default class VaEquipmentInfo extends LightningElement {

    @track subscription=null;
    model;
    slides;
    slideIndex=1;
    imglength=0;
    dots;
    serial;
    imgurl1;
    mktmodel;
    applianceType;
    applianceTypeLabel;
    @track imageview=false;
    context = createMessageContext();
    @track equipmentFeatures=[];
    @track equipmentImages=[];
    isVaEquipmentInfo=false;
    connectedCallback(){
        this.isVaEquipmentInfo=true;
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
            //console.log('EQUIPMENT INFO :-> '+JSON.stringify(event));
            let res=JSON.parse(event);
            let originalModel=res.model;
            this.model=res.model;
            if(res.mktmodel!=''){
                this.mktmodel = res.mktmodel;
                originalModel = res.mktmodel;
            }
            this.serial=res.serial;
            this.applianceType=res.appliancetype;
            this.applianceTypeLabel = res.appliancetypelabel;
            let filteredRecords = res.results.filter(a => a.hasOwnProperty("records"));
            if(filteredRecords.length>0){
                if("records" in filteredRecords[0] && "products" in filteredRecords[0].records && originalModel in filteredRecords[0].records.products){
                    let products=filteredRecords[0].records.products;
                    let benefitCopyRecords=products[originalModel];
                    let equipInfo = benefitCopyRecords.filter(a=>a.hasOwnProperty('BenefitCopy'));
                    let equipInfoImgs = benefitCopyRecords.filter(a=>a.hasOwnProperty('Images'));
                    let equipImgInfo=benefitCopyRecords.filter(a=>a.hasOwnProperty('Relationships'));
                    /*for(let x=0;x<benefitCopyRecords.length;x++){
                        if("BenefitCopy" in benefitCopyRecords[x]){
                            equipInfo= benefitCopyRecords[x];
                            
                        }
                    }*/
                    if("BenefitCopy" in equipInfo[0]){
                        let features=equipInfo[0].BenefitCopy;
                        const keys = Object.keys(features);
                        console.log('keys are '+keys);
                        let equipmentFeaturesRes=[];
                        for(let t=0;t<keys.length;t++){
                            equipmentFeaturesRes.push({"label":t,"feature":features[keys[t]].Feature});
                            //console.log('Features -> '+features[keys[t]].Feature);
                        }
                        this.equipmentFeatures=equipmentFeaturesRes;
                        console.log('features '+JSON.stringify(this.equipmentFeatures));
                        
                    }
                    let equipmentImgs=[];
                    let tem_var=1;
                    if("Relationships" in equipImgInfo[0]){
                        let imgsObject=equipImgInfo[0].Relationships;
                        let imgs=imgsObject["Cross-Sell Colors_"];
                        //console.log('images '+JSON.stringify(imgsObject["Cross-Sell Colors_"]));
                        //console.log('IMAGES :-->'+imgs["0"].Images_DisplayImageName);
                        let equipImgs=[];
                        //let tval=1;
                        /*for(let ky in imgs){
                            let imgurl="https://products.geappliances.com/MarketingObjectRetrieval/Dispatcher?RequestType=Image&Name="+imgs[ky].Images_DisplayImageName;
                            equipImgs.push({"id":tval,"img_name":imgs[ky].Images_DisplayImageName,"img_url": imgurl});
                            tval+=1;
                        }*/
                        //this.imglength=tval-1;
                        //this.equipmentImages=equipImgs;
                        /*let ky="00";
                        if(ky in imgs){    
                            this.imgurl1='https://products.geappliances.com/MarketingObjectRetrieval/Dispatcher?RequestType=Image&Name='+imgs[ky].Images_DisplayImageName;
                            equipmentImgs.push({"id":tem_var,"img_name":imgs[ky].Images_DisplayImageName,"img_url": this.imgurl1});
                            tem_var+=1;
                        }*/
                    }

                    if("Images" in equipInfoImgs[0]){
                        let temp_imgs=equipInfoImgs[0].Images;
                        const Imgkeys = Object.keys(temp_imgs);
                        console.log('keys are '+Imgkeys);
                        
                        for(let t=0;t<Imgkeys.length;t++){
                            let imgurl="https://products.geappliances.com/MarketingObjectRetrieval/Dispatcher?RequestType=Image&Name="+temp_imgs[Imgkeys[t]].Name;
                            
                            equipmentImgs.push({"id":tem_var,"img_name":temp_imgs[Imgkeys[t]].Name,"img_url": imgurl});
                            //console.log('Features -> '+features[keys[t]].Feature);
                            tem_var+=1;
                        }
                        this.imglength=tem_var-1;
                        this.equipmentImages=equipmentImgs;
                        //if(this.imgurl1==null || this.imgurl1==undefined)
                            this.imgurl1='https://products.geappliances.com/MarketingObjectRetrieval/Dispatcher?RequestType=Image&Name='+temp_imgs[Imgkeys[0]].Name;
                        
                        
                    }
                }
            }
            
        }
    }
     
    closeImgView(event){
        this.imageview=false;
    }
    async openImgView(event){
        this.imageview=true;
        this.slides = await this.template.querySelectorAll('.mySlides');
        this.dots = await this.template.querySelectorAll('.demo');
        this.slideIndex=1;
        this.showSlides(this.slideIndex);
        
    }
    movePrevious(){
        this.slideIndex-=1;
        this.showSlides(this.slideIndex);
    }
    moveNext(){
        this.slideIndex+=1;
        this.showSlides(this.slideIndex);

    }
    selectImg(event){
        let temp=event.target.id;
        let imgId=temp.split("-")[0];
        console.log(imgId);
        this.slideIndex=parseInt(imgId);
        this.showSlides(this.slideIndex);

    }
    showSlides(n) {
        let i;

        this.slides = this.template.querySelectorAll('.mySlides');
        this.dots = this.template.querySelectorAll('.demo');
        console.log('dots' + this.dots.length);
        
        //let captionText = document.getElementById("caption");
        if (n > this.slides.length) {this.slideIndex = 1}
        if (n < 1) {this.slideIndex = this.slides.length}
        for (i = 0; i < this.slides.length; i++) {
          this.slides[i].style.display = "none";
        }
        for (i = 0; i < this.dots.length; i++) {
          this.dots[i].className = this.dots[i].className.replace(" active", "");
        }
        this.slides[this.slideIndex-1].style.display = "block";
        this.dots[this.slideIndex-1].className += " active";
        //captionText.innerHTML = this.dots[this.slideIndex-1].alt;
      }
}