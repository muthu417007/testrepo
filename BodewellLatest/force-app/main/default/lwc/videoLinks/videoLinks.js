import { LightningElement, api, wire, track } from 'lwc';

export default class VideoLinks extends LightningElement {

    videolinksdisplayed=false;

    connectedCallback(){

        this.videolinksdisplayed=true;
    }
}