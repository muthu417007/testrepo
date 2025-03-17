import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

import nutsleft from '@salesforce/resourceUrl/svgnutsleft';
import tools from '@salesforce/resourceUrl/svgtools';
import locationpinyellow from '@salesforce/resourceUrl/svglocationpinyellow';
import calliconyellow from '@salesforce/resourceUrl/svgcalliconyellow';
import iconcheck from '@salesforce/resourceUrl/svgiconcheck';


export default class Bw_RetailAreaLocations extends LightningElement {
    nutsleftsvg = nutsleft;
    toolssvg = tools;
    locationpinyellowsvg = locationpinyellow;
    calliconyellowsvg = calliconyellow;
    iconchecksvg = iconcheck;
    nutsleftsvg = nutsleft;
    toolssvg = tools;

    mapMarkers;
    zoomLevel;
    listView;

    isLoading = true;
    @api retailAreaName;
    @api retailAreaNumber;
    @api retailAreaAddressLine1;
    @api retailAreaAddressLine2;
    @api retailAreaAddressLine3;
    @api gMapURL;
    //@api retailCallingNumber;
    @api zipCode;
    @api state;
    @api city;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.retailAreaName = currentPageReference.state.ANa;
            this.retailAreaNumber = currentPageReference.state.ANo;
            this.retailAreaAddressLine1 = currentPageReference.state.A1;
            this.retailAreaAddressLine2 = currentPageReference.state.A2;
            this.city = currentPageReference.state.C;
            this.state = currentPageReference.state.S;
            this.zipCode = currentPageReference.state.Z;
            this.retailAreaAddressLine3 = currentPageReference.state.C + ', ' +
                                            currentPageReference.state.S + ' ' +
                                            currentPageReference.state.Z;

            this.gMapURL = "//www.google.com/maps/dir//" + "Bodewell Appliance Support," +
                currentPageReference.state.A1 +
                currentPageReference.state.A2 +
                currentPageReference.state.C +
                currentPageReference.state.S +
                currentPageReference.state.Z;
        }
    }
    mobileNumber() {
        const phonelink = this.template.querySelector('.phone');
        phonelink.setAttribute('href', 'tel:+1' + this.retailAreaNumber);
        this.isLoading = false;
    }
    connectedCallback() {
        this.mapMarkers = [{
            location: {
                City: this.city,
                Country: "USA",
                PostalCode: this.zipCode,
                State: this.state,
                Street: this.retailAreaAddressLine1
            },
            title: "Bodewell Retail Outlet",
            description: this.retailAreaName,
            icon: "standard:account"
        }];
        this.zoomLevel = 10;
        this.listView = "visible";
    }
}