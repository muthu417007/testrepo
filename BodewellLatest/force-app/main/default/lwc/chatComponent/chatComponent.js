import { LightningElement, api, wire, track } from 'lwc';
import { MessageContext, APPLICATION_SCOPE, publish } from 'lightning/messageService';
import apiDataChannel from "@salesforce/messageChannel/apidatachannel__c";
//import getPersonNames from '@salesforce/apex/GetGraphQLAPIData.getById';
import getChatResponse from '@salesforce/apex/VA_GetChatApiData.getAnalyticsResponse';
import getUserName from '@salesforce/apex/VA_GetChatApiData.getUserName';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createMessageContext, releaseMessageContext, subscribe, unsubscribe } from 'lightning/messageService';
import uid from '@salesforce/user/Id';

export default class ChatComponent extends LightningElement {
    @track userid=uid;
    @track userInput='';
    @track chatrecord={};
    @track chatdata=[];
    @track current='';
    @track isapidatacall=false;
    @track ischatinitiated=false;
    @track isuserinput=false;
    @track selectedvalue='';
    @track apiresponse=[];
    @track subscription=null;
    @track uname='';
    @track applianceType;
    @track problemCategory;
    @track problemCategoryLabel;
    @track model;
    @track serial;
    @track phone;
    @track counter=0;
    @track recordChildId='';
    @track param1;
    @track param2;
    @track analyticsRes='[]';
    @track attachments='';
    @track attachmentFlag=false;
    @track attachmentName;
    @track firstChildSelect = true;
    @track secondChildSelect = false;
    context = createMessageContext();
    connectedCallback() {
        //this.uname=username;
        var d = new Date();
        this.current=(d.getHours()+':'+d.getMinutes()).toString();
        console.log('current time is '+this.current);
        getUserName({userId:this.userid})
        .then((resp)=>{
            this.uname=resp;
        })
        //this.chatrecord={"id":0,"inbound":true,"value":"Message 1","type":"inbound","isbuttondisabled":false,"msg":"List of buttons","data":[{ "label":"Start", "value":"Started the Session"},{ "label":"Stop", "value":"Stoped the Session"},{ "label":"Pause", "value":"Paused the Session"},{ "label":"Hold", "value":"Session is on hold"}],"lastmsg":false};
        //this.chatdata.push(this.chatrecord);
        /*this.chatrecord={"id":2,"inbound":false,"type":"outbound","isbuttondisabled":true,"value":"Message 2","data":[],"msg":"message1","lastmsg":false};
        this.chatdata.push(this.chatrecord);
        this.chatrecord={"id":3,"inbound":true,"type":"inbound","isbuttondisabled":true,"data":[],"value":"Message 3","msg":"message1","lastmsg":false};
        this.chatdata.push(this.chatrecord);
        this.chatrecord={"id":4,"inbound":false,"type":"outbound","isbuttondisabled":true,"data":[],"value":"Message 4","msg":"message1","lastmsg":true};
        this.chatdata.push(this.chatrecord);*/
        //console.log('data is '+this.chatdata[0].type);
        this.handleSubscribe();
        //console.log('user name is '+uname);
    }

    renderedCallback() {
        const scrollArea = this.template.querySelector('[data-scroll-area]');
        scrollArea.scrollTop = scrollArea.scrollHeight;
    }

    disconnectedCallback() {
        this.handleUnsubscribe();
    }
    handleSubscribe() {
        if (this.subscription) {
            return;
        }
        this.context = createMessageContext();
        this.subscription = subscribe(this.context, apiDataChannel, (message) => {
            console.log('message is' + message);
            let msg = message.messageBody;
            let dt=msg.record;
            this.applianceType=dt.applianceType;
            this.problemCategory=dt.problemCategory;
            this.problemCategoryLabel = dt.problemCategoryLabel;
            this.phone=dt.phoneNumber;
            this.model=dt.modelNumber;
            this.serial=dt.serialNumber;
            this.param3=dt.description;
            this.ischatinitiated=true;
            this.chatdata=[];
            this.chatrecord={"id":this.chatdata.length,"inbound":true,
            "value":"Message 1",
            "type":"inbound",
            "isbuttondisabled":false,
            "msg":"Hi! I am GE Virtual Assistant. I can provide information that might be helpful before you schedule a service  appointment.",
            "data":[],
            "lastmsg":false}
            this.chatdata.push(this.chatrecord);

            /*this.chatrecord={"id":this.chatdata.length,"inbound":true,
            "value":"Message 2",
            "type":"inbound",
            "isbuttondisabled":false,
            "msg": "Although there are some parts that do require a service call, would you like to replace the easily installable parts yourself?",   //"\"<font color=\"red\">n Dishwasher: Eurotech Brand => Eurotech.n <p>n  FOR SERVICING and FOR PARTS:n </p>n <p>n  Please, call Eurotech atn </p>n <li>n  1-972-238-0794n </li>n <li>n  toll free at 1-800-898-1879n </li>n <p>n  You can also view information on the web atn  <li>n   www.eurotechappliances.com/support/service.phpn  </li>n  <li>n   www.eurotechappliances.comn  </li>n </p>n</font>n<p>n <font color=\"red\">n  <u>n   CALLTAKER:  DOn   <font size=\"2\">n    NOTn   </font>n   SCHEDULE SERVICE WITH A GE TECHNICIAN OR A GE AUTHORIZED SEVICER FOR THIS MODEL IN WARRANTY, OUT OF WARRANTY, OR UNDER SERVICE CONTRACT.n  </u>n  Refer the consumer to the telephone numbers or websites listed above.  Our technicians and independent servicers are not authorized nor trained to service this product.  We also do NOT send parts for these models.n </font>n</p>\"",
            "data":[],
            "lastmsg":false}
            
            this.chatdata.push(this.chatrecord);*/

            this.chatrecord={"id":this.chatdata.length,"inbound":true,
            "value":"Message 3",
            "type":"inbound",
            "isbuttondisabled":false,
            "msg": "Searching solutions for "+this.problemCategoryLabel,     //this.problemCategory.replace("_"," "),
            "data":[],
            "lastmsg":false}
            
            this.chatdata.push(this.chatrecord);

            console.log('json record is '+JSON.stringify(dt));
            //this.handleMessage(dt);
            this.requestAnalyticsData(this.recordChildId,this.counter);
        }, { scope: APPLICATION_SCOPE });
        
    }
    handleMessage(event) {
        if (event) {
            //let message = event.messageBody;
            //let dt=message.record;
            //console.log('msg '+event);
            let res = JSON.parse(event);
            //let source = event.source;
            //console.log('orderDetail response ',res.data);
            //this.isapidatacall=true;
            this.apiresponse=[];
            if("HouseHoldByPhone" in res.data){
                console.log('GraphQL API response is '+res.data.HouseHoldByPhone[0].Phone[0].PhoneNumber);
                for(let i=0;i<res.data.HouseHoldByPhone.length;i++){
                    var rec={"label":res.data.HouseHoldByPhone[i].PersonID,"value":res.data.HouseHoldByPhone[i].PersonID};
                    this.apiresponse.push(rec);
                }
                this.chatrecord={"id":this.chatdata.length,"inbound":true,
                            "value":"Message 1",
                            "type":"inbound",
                            "isbuttondisabled":false,
                            "msg":"Please select from below list of PersonIds",
                            "data":this.apiresponse,
                            "lastmsg":false};
                this.chatdata.push(this.chatrecord);
            
            }
            if("PersonById" in res.data){
                var rec={"label":res.data.PersonById.LastName,"value":res.data.PersonById.PersonID};
                    this.apiresponse.push(rec);
                    this.chatrecord={"id":this.chatdata.length,"inbound":true,
                    "value":"Message 1",
                    "type":"inbound",
                    "isbuttondisabled":false,
                    "msg":"Thank you for selecting person id, person name: "+res.data.PersonById.LastName+" "+res.data.PersonById.FirstName,
                    "data":[],
                    "lastmsg":false};
            this.chatdata.push(this.chatrecord);
    
                
            }
            /*for(let i=0;i<res.data.details.length;i++){
                console.log('person name '+res.data.details[i].name);
                console.log('phone number '+res.data.details[i].phone);
            }*/
        }
    }

    
    prepareResponseRecords() {
        let extractres = JSON.parse(this.analyticsRes);
        if (extractres.status=='S') {
            let res = extractres.records;
            console.log('res prep res records '+JSON.stringify(res));
            this.apiresponse=[];
            let masterHeader='';
            let master_id;
            if(res.length >0){
                for(let i=0;i<res.length;i++){
                    let rec={};
                    if(res[i].child_raw_content!=null &&res[i].child_id!=null ){
                        rec={"label":res[i].child_raw_content,"value":res[i].child_raw_content, "childId": res[i].child_id};
                        this.apiresponse.push(rec);
                    }
                    let headerContent = res[i].master_raw_content;
                    if(headerContent.includes('?')){
                        headerContent = headerContent.split('?')[0]+'?';
                    }
                    if(headerContent.includes('\n')){
                        headerContent = headerContent.replaceAll('\n','');
                        
                    }

                    /*if(headerContent.includes('<p>\n')){
                        console.log('inside header content...');
                        headerContent = headerContent.replaceAll('<p>\n','<p>');
                        headerContent = headerContent.replaceAll('\n </p>','</p>');
                    }
                    if(headerContent.includes('<li>\n')){
                        headerContent = headerContent.replaceAll('<li>\n','<li>');
                        headerContent = headerContent.replaceAll('\n  </li>','</li>');
                    }*/

                    masterHeader = headerContent;
                    master_id=res[i].master_id;
                    if(res[i].attachments!=null && res[i].attachments != ""){
                        console.log('attachment present');
                        this.attachmentFlag=true;
                        this.attachments=res[i].attachments;
                        this.attachmentName = res[i].attachments.trim().split('/').pop();
                    }
                    else {
                        this.attachmentFlag=false;
                        this.attachments='';
                        this.attachmentName = '';
                    }
                }
                let stringToHTML = function (str) {
                    let dom = document.createElement('div');
                    dom.innerHTML = str;
                    return dom;
                
                };
                //console.log('chat raw content '+stringToHTML(masterHeader));
                this.chatrecord={"id":this.chatdata.length,"inbound":true,
                            "value":"Message 1",
                            "type":"inbound",
                            "isbuttondisabled":false,
                            "msg":  masterHeader,         //masterHeader,
                            "attachment": this.attachments,
                            "attachmentName" : this.attachmentName,
                            "attachmentFlag": this.attachmentFlag,
                            "data":this.apiresponse,
                            "lastmsg":false};
                console.log('chat record is '+this.chatrecord+' --- '+JSON.stringify(this.chatrecord));
                this.chatdata.push(this.chatrecord);
                //this.template.querySelector('temp-text').innerHTML = masterHeader;
                if(this.apiresponse.length==0 && master_id!=-2 && master_id!=-1 && !masterHeader.includes('I am unable to locate troubleshooting information')){
                    this.analyticsRes='{ "status": "S", "message": "Successfull", "records": [    {       "master_id":1,       "master_raw_content":"Is your problem solved ?",       "attachments":null,       "child_id":-1,       "child_raw_content":"Yes"    },    {       "master_id":1,       "master_raw_content":"Is your problem solved ?",       "attachments":null,       "child_id":-2,       "child_raw_content":"No"    }    ] }';
                    this.prepareResponseRecords();
                }
                //let sfieldId= this.chatdata.length;
                //this.template.querySelector(`[key="${sfieldId}"]`).focus();
            }
        }
        if (extractres.status == 'E'){

            const evt = new ShowToastEvent({
                title: 'Error',
                message: extractres.message,
                variant: 'error',
            });
            dispatchEvent(evt);
        }
    }
    getUserSelectedProblem(event){
        this.userInput = event.target.value;
        let child_id=event.target.title;
        this.recordChildId=child_id;

        if(this.secondChildSelect){
            this.secondChildSelect = false;
            this.param2 = this.recordChildId;
        }
        if(this.firstChildSelect)
        {
            this.firstChildSelect = false;
            this.param1 =this.recordChildId;
            this.secondChildSelect = true;
        }
        
        console.log('selected button value '+event.target.value);
        console.log('selected button title is '+event.target.title);
        console.log('selected button key '+event.target.key);
        console.log('selected button label is '+event.target.label);
        console.log('selected button data-name is '+JSON.stringify(event.target));
        for(let i=0;i<this.chatdata.length;i++){
            this.chatdata[i].isbuttondisabled=true;
            this.chatdata[i].lastmsg=false;
        }
        this.chatrecord={"id":this.chatdata.length,"inbound":false,"childId": event.target.title,"type":"outbound","isbuttondisabled":true,"value":"Message 2","data":{"label":this.userInput},"msg":"message1","lastmsg":false};
        this.chatdata.push(this.chatrecord);
        if(this.recordChildId!=null && this.recordChildId!='' && this.recordChildId!='-1' && this.recordChildId!='-2'){
            //this.isapidatacall=true;
            this.requestAnalyticsData(this.recordChildId,this.counter);
            //this.isapidatacall=false;
            //this.prepareResponseRecords();
            
        }
        /*else if(this.recordChildId==null || this.recordChildId==''){

            this.analyticsRes='[    {       "master_id":1,       "master_raw_content":"Is your problem solved ?",       "attachments":null,       "child_id":-1,       "child_raw_content":"Yes"    },    {       "master_id":1,       "master_raw_content":"Is your problem solved ?",       "attachments":null,       "child_id":-2,       "child_raw_content":"No"    }    ]';
            this.prepareResponseRecords();
            
        }*/
        else if(this.recordChildId=='-2'){
            this.recordChildId='';
            this.counter+=1;
            console.log('chatdata is -> '+JSON.stringify(this.chatdata));
            if(this.counter<2)
                this.requestAnalyticsData(this.recordChildId,this.counter);
            else {
                this.analyticsRes='{ "status": "S", "message": "Successfull", "records": [    {       "master_id":-2,       "master_raw_content":"Thank you for your feedback.",       "attachments":null,       "child_id":null,       "child_raw_content":null    }  ] }';
                this.prepareResponseRecords();
            
            }
        }
        else if(this.recordChildId=='-1'){
            this.analyticsRes='{ "status": "S", "message": "Successfull", "records": [    {       "master_id":-1,       "master_raw_content":"Thank you.Your feedback is appreciated .",       "attachments":null,       "child_id":null,       "child_raw_content":null    }  ] }';
            this.prepareResponseRecords();
            console.log('chatdata is -> '+JSON.stringify(this.chatdata));
        }
    }
    
    requestAnalyticsData(childId,cntr){
        // call analytics api and get the chat api response;
        this.analyticsRes='[]';
        this.isapidatacall=true;
        getChatResponse({ category: this.problemCategory,
            childId: childId,
            counter: cntr.toString(),
            prdIn: this.applianceType,
            model: this.model,
            serial: this.serial,
            phone: this.phone,
            param1: this.param1!=null?this.param1:'',
            param2: this.param2!=null?this.param2:'',
            param3 : this.param3!=null?this.param3.replaceAll(' ','_'):''
        })
        .then((jsonResponse) => {
            //console.log('json res is '+JSON.stringify(jsonResponse));
            this.analyticsRes=jsonResponse;
            this.isapidatacall=false;
            this.prepareResponseRecords();
            console.log('<<<');
        })
        .catch((error) => {
            this.isapidatacall=false;
            console.log('chat error '+JSON.stringify(error));
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'API Service Error',
                variant: 'error',
            });
            dispatchEvent(evt);
       });
        //this.analyticsRes='[    {       "master_id":0,       "master_raw_content":"(CALLTAKER: I didnt understand your description. Select the problem the consumer is having with the trash compactor.)",       "attachments":null,       "child_id":52,       "child_raw_content":"Mail Out/Damaged/Missing Parts"    },    {       "master_id":0,       "master_raw_content":"(CALLTAKER: I didnt understand your description. Select the problem the consumer is having with the trash compactor.)",       "attachments":null,       "child_id":48,       "child_raw_content":"[Not Listed]"    },    {       "master_id":0,       "master_raw_content":"(CALLTAKER: I didnt understand your description. Select the problem the consumer is having with the trash compactor.)",       "attachments":null,       "child_id":26,       "child_raw_content":"Not Working Properly"    },    {       "master_id":0,       "master_raw_content":"(CALLTAKER: I didnt understand your description. Select the problem the consumer is having with the trash compactor.)",       "attachments":null,       "child_id":24,       "child_raw_content":"Drawer Hard to Open/Wont Open"    },    {       "master_id":0,       "master_raw_content":"(CALLTAKER: I didnt understand your description. Select the problem the consumer is having with the trash compactor.)",       "attachments":null,       "child_id":20,       "child_raw_content":"hard to open/won\'t open"    },    {       "master_id":0,       "master_raw_content":"(CALLTAKER: I didnt understand your description. Select the problem the consumer is having with the trash compactor.)",       "attachments":null,       "child_id":31,       "child_raw_content":"Not Compacting"    },    {       "master_id":0,       "master_raw_content":"(CALLTAKER: I didnt understand your description. Select the problem the consumer is having with the trash compactor.)",       "attachments":null,       "child_id":33,       "child_raw_content":"Odor/Smell"    } ]';
            
    
    }
    /*collectInput(event){

        this.userInput = event.target.label;
        console.log('selected button is '+this.userInput);
        console.log('selected button value '+event.target.value);
        console.log('selected button title is '+event.target.title);
        console.log('selected button data-name is '+event.target);
        for(let i=0;i<this.chatdata.length;i++){
            this.chatdata[i].isbuttondisabled=true;
            this.chatdata[i].lastmsg=false;
        }
        this.chatrecord={"id":this.chatdata.length,"inbound":false,"type":"outbound","isbuttondisabled":true,"value":"Message 2","data":{"label":this.userInput},"msg":"message1","lastmsg":false};
        this.chatdata.push(this.chatrecord);
        this.isapidatacall=true;
        getPersonNames({personid:this.userInput})
        .then((jsonResponse) => {
            console.log('json res is '+jsonResponse);
            this.isapidatacall=false;
            this.handleMessage(jsonResponse);
        })
        .catch((error) => {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Error encountered while selecting an option',
                variant: 'error',
            });
            dispatchEvent(evt);
       });
        //this.chatrecord={"id":this.chatdata.length,"inbound":true,"type":"inbound","isbuttondisabled":false,"data":[{"label":"YES","value":"YES"},{"label":"NO","value":"NO"}],"value":"Message 3","msg":"The selected option is "+this.userInput,"lastmsg":true};
        //this.chatdata.push(this.chatrecord);
        
    }*/
    handlePublish(event){
        console.log('you have selected a phone number');
        let clickedButtonLabel = event.target.label;
        this.selectedvalue=event.target.label;
        this.isuserinput=true;
        console.log('button label name -'+clickedButtonLabel+event.target.title);

    }
    handleUnsubscribe() {
        unsubscribe(this.subscription);
        this.subscription = undefined;
        releaseMessageContext(this.context);
    }
    get subscribeStatus() {
        return this.subscription ? 'TRUE' : 'FALSE';
    }
    

}