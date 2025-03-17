import { LightningElement, wire, api, track } from 'lwc';

//apex classes
import getProductImage from '@salesforce/apex/MYA_EndecaApiHandler.MYA_EndecaResponseDetails';
import getServices from '@salesforce/apex/MYA_serviceData.MYA_getAccountProduct';
import getOpenServices from '@salesforce/apex/MYA_serviceData.MYA_getAccountProduct1';
import getCancelServicesC360 from '@salesforce/apex/MYA_serviceData.MYA_getAccountProductC360';

//metadata
import getmyaConfigs from '@salesforce/apex/Mya_ProductDetails.getmyaConfigs';

export default class Mya_serviceScheduleList extends LightningElement {
    proImage;
    serviceData;
    @track closedService = [];
    @track closedServiceC360 = [];
    pastServices;
    serviceOpenData;
    serviceCancelData;
    dateFormat;
    Urllist;
    trackUrl;
    ishaier;
    iscafe;
    @api brand;
    @track serviceJson = [];
    @track serviceOpenJson = [];
    @track serviceCancelJson = [];
    isServiceOpenFlag = false;
    isServiceCancelFlag = false;
    isServiceClosedFlag = false;
    showAllUrl = false;


    connectedCallback() {

        if (this.brand == "Haier") {
            this.ishaier = true;

        } else if (this.brand == "Cafe") {
            this.iscafe = true;

        }

        getServices({})
            .then(result => {
                this.pastServices = result;
                result.forEach((item, index) => 
                {
                    this.closedService.push({});
                    this.closedService[index].invoice = item.invoice ? item.invoice:'';
                    this.closedService[index].serviceDate = item.serviceDate? item.serviceDate:'-';
                    this.closedService[index].modelNo = item.modelNo? item.modelNo:'-';
                    this.closedService[index].serialNo = item.serialNo ? item.serialNo:'-';
                    this.closedService[index].description = item.description ? item.description:'-';
                    this.closedService[index].serviceType = item.serviceType ? item.serviceType:'-';
                    this.closedService[index].serviceBy = item.serviceBy ? item.serviceBy:'-';
                    this.closedService[index].serviceAmount = item.serviceAmount ? item.serviceAmount:'0.00';
                    this.closedService[index].productImageLink = item.productImageLink;
                    this.closedService[index].productDescription = item.productDescription;
                    this.closedService[index].isExpand = false;
                    this.isServiceClosedFlag = true;
                });
            })
            .catch(error => {
                this.error = error.message;
            });
        
        getCancelServicesC360({})
            .then(result => {
                console.log('result response ' + JSON.stringify(result));
                this.serviceData = result.ser;
                this.assets = result.ass;
                this.serviceData.forEach((item, index) => {

                    if(item.invoicenumber__c)
                    {
                        console.log(`${index} : ${item}`);
                        this.closedServiceC360.push({});
                        this.closedServiceC360[index].invoice = item.invoicenumber__c ? item.invoicenumber__c : '';
                        this.closedServiceC360[index].serviceDate = item.servicedate__c.substring(0, 10);
                        this.closedServiceC360[index].assetss = item.assetid__c ? item.assetid__c : '';
                        this.closedServiceC360[index].isExpand = false;
                        this.isServiceClosedFlag = true;
                        this.assets.forEach((itemsAss, ind) => {
                            if (this.closedServiceC360[index].assetss == this.assets[ind].assetid__c) {
                                this.closedServiceC360[index].modelNo = itemsAss.originalmodelnumber__c ? itemsAss.originalmodelnumber__c : '';
                                this.closedServiceC360[index].serialNo = itemsAss.serialnumber__c ? itemsAss.serialnumber__c : '';
                            }
                        })

                        this.closedServiceC360[index].description = item.servicejobtypedescription__c ? item.servicejobtypedescription__c : '';
                        this.closedServiceC360[index].serviceType = item.servicejobtypeid__c ? item.servicejobtypeid__c : '';
                        this.closedServiceC360[index].serviceBy = item.servicertechnicianid__c ? item.servicertechnicianid__c : '';
                        if (item.servicenetcost__c != null) {
                            this.closedServiceC360[index].serviceAmount = item.servicenetcost__c;
                        } else {
                            this.closedServiceC360[index].serviceAmount = 0;
                        }

                        if (this.closedServiceC360[index].modelNo ) {
                            getProductImage({ SKU: this.closedServiceC360[index].modelNo })
                                .then(result => {
                                    console.log('result inside get product image' + JSON.stringify(result));
                                    this.closedServiceC360[index].productImageLink = result.ProductInfo.DefaultImageUrl;
                                    this.closedServiceC360[index].productDescription = result.ProductInfo.ProductDescription;
                                })
                                .catch(error => {
                                    console.log('error inside get product image' + error);
                                    this.error = error.message;
                                })
                        }
                    }
                console.log(this.closedServiceC360);
                });
            })
            .catch(error => {
                this.error = error.message;
            });

        getmyaConfigs({})
            .then(configs => {
                this.Urllist = configs;
                //display active service apointment related to logged in user
                getOpenServices({})
                    .then(result => {
                        this.serviceOpenData = result;
                        console.log('results open', result);
                        this.getURL();
                        result.forEach((item, index) => {
                            console.log(`${index} : ${item}`);
                            this.serviceOpenJson.push({});
                            this.serviceOpenJson[index].service1 = item.Call_Number__c ? item.Call_Number__c : '';
                            this.serviceOpenJson[index].confirmation1 = item.Call_Number__c ? item.Call_Number__c : '';

                            this.serviceOpenJson[index].isServiceCancelFlag = false;
                            if (item.MYA_Service_Status__c == 'C' || item.MYA_Service_Status__c == 'Cancelled') {
                                this.serviceOpenJson[index].status1 = 'Cancelled'
                                this.serviceOpenJson[index].isServiceCancelFlag = true;
                            } else if (item.MYA_Service_Status__c == 'R') {
                                this.serviceOpenJson[index].status1 = 'Rescheduled'
                            } else {
                                this.serviceOpenJson[index].status1 = 'Open'
                            }
                            this.serviceOpenJson[index].time1 = item.Service_Appt_Time__c ? item.Service_Appt_Time__c : '';
                            this.serviceOpenJson[index].serviceDate1 = item.Service_Date__c ? item.Service_Date__c : '';
                            this.serviceOpenJson[index].model1 = item.Asset__r ? item.Asset__r.Model_Number__c : '';
                            this.serviceOpenJson[index].natureOfProb1 = item.natureOfProblem__c ? item.natureOfProblem__c : '';
                            this.serviceOpenJson[index].scheduleUrl1 = this.Urllist.Source_URL__c + 'detail?callno=' + this.serviceOpenJson[index].service1 + '&lastname=' + item.Contact__r.LastName + '&uid=' + item.Contact__r.Global_Customer_Id__c;
                            this.serviceOpenJson[index].trackUrl1 = this.Urllist.Redirection_Links__c + 'job/' + this.serviceOpenJson[index].service1 + '/' + item.Contact__r.LastName;
                            if (item.Asset__r && item.Asset__r.ModelValidityFlag__c && item.Asset__r.Model_Number__c) {
                                getProductImage({ SKU: item.Asset__r.Model_Number__c })
                                    .then(result => {
                                        console.log('result inside get product image' + JSON.stringify(result));
                                        this.serviceOpenJson[index].image1 = result.ProductInfo.DefaultImageUrl;
                                        this.serviceOpenJson[index].description1 = result.ProductInfo.ProductDescription;
                                    })
                                    .catch(error => {
                                        console.log('error inside get product image' + error);
                                        this.error = error.message;
                                    })
                            }

                        });
                        if (this.serviceOpenJson.length > 0) {
                            this.isServiceOpenFlag = true;
                        }
                        console.log('serviceOpenJson' + JSON.stringify(this.serviceOpenJson));
                    })
                    .catch(error => {
                        console.log('error open services' + error);
                        this.error = error.message;
                    });
            })
            .catch(error => {
                console.log(error)
            });
    }
    getURL() {
        getmyaConfigs({})
            .then(result => {
                this.Urllist = result;
                this.trackUrl = this.Urllist.Redirection_Links__c + 'track';
            })
            .catch(error => {
                console.log(error)
            });
    }
    showAll(e) {
        this.closedService[e.currentTarget.dataset.id].isExpand = true;
    }
    showSome(e) {
        this.closedService[e.currentTarget.dataset.id].isExpand = false;
    }
    showAllC(e) {
        this.closedServiceC360[e.currentTarget.dataset.id].isExpand = true;
    }
    showSomeC(e) {
        this.closedServiceC360[e.currentTarget.dataset.id].isExpand = false;
    }
}