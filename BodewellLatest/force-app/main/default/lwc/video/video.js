import { LightningElement, api, wire } from 'lwc';
import basePath from '@salesforce/community/basePath';
import getContent from '@salesforce/apex/ManagedContentController.getContent';

export default class Video extends LightningElement {
    @api contentId;
    initialMute = true;
    url;

    mute(){
        //some browsers don't mute the video since it is
        //being dynamically loaded onto the page. This mutes
        //the video the first time it autoplays
        var element = this.template.querySelector('video');
        if(element&&this.initialMute){
            element.muted = "muted";
            this.initialMute = false;
        }
    }

    @wire(getContent, {
        contentId: '$contentId',
        page: 0,
        pageSize: 1,
        language: 'en_US',
        filterby: ''
    })
    results({ data, error }) {
        if (data) {
            this.url = data.URL.value;
            this.error = undefined;
        } else if (error) {
            console.log('Error: ' + JSON.stringify(error));
        }
    }
}