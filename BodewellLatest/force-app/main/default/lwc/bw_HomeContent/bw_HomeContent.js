import { LightningElement, track, wire, api } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

import smartq from '@salesforce/resourceUrl/svgsmartq';
import manufacturers from '@salesforce/resourceUrl/svgmanufacturers';
import check from '@salesforce/resourceUrl/svgcheck';
import concierge from '@salesforce/resourceUrl/svgconcierge';
import wrench from '@salesforce/resourceUrl/svgwrench';
import oven from '@salesforce/resourceUrl/svgoven';

export default class Bw_HomeContent extends LightningElement {

    smartqsvg = smartq;
    manufacturerssvg = manufacturers;
    checksvg = check;
    conciergesvg = concierge;
    wrenchsvg = wrench;
    ovensvg = oven;

}