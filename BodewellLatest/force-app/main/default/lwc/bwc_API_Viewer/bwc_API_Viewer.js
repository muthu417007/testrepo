import { LightningElement, wire } from 'lwc';
import hitMuleAPI from '@salesforce/apex/BWC_API_ViewerController.hitMuleAPI';
import fetchMuleApiRecords from '@salesforce/apex/BWC_API_ViewerController.fetchMuleApiRecords';
export default class Bwc_API_Viewer extends LightningElement {

    muleList = [];
    responseDisplay;
    @wire(fetchMuleApiRecords)
    fetchMuleApiRecordsFunction({ error, data }) {
        if (data) {
            console.log('api data', data);
            this.muleList = data;
        }
        else if (error) {
            console.log('api error??', error);
        }
    }

    handleClick(event) {
        hitMuleAPI({
            Name: event.target.value
        })
            .then(result => {
                console.log("result-->", result);
                this.responseDisplay = result;
            })
            .catch(error => {
                console.log("error-->", error);
                this.responseDisplay = error;
            })
    }
}