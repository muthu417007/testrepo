import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getNavigationMenuItems from '@salesforce/apex/BDW_NavigationController.getNavigationMenuItems';

import basepath from '@salesforce/community/basePath';
import arrowbottom from '@salesforce/resourceUrl/svgarrow';
import logolight from '@salesforce/resourceUrl/svglogolight';
import menu from '@salesforce/resourceUrl/svgmenu';
import logo from '@salesforce/resourceUrl/svglogo';
import close from '@salesforce/resourceUrl/svgclose';
import location from '@salesforce/resourceUrl/svglocation';
import concierge from '@salesforce/resourceUrl/svgconcierge';
import contNumber from '@salesforce/label/c.bw_NavBarContactNumber';

export default class Bw_navigationBar extends NavigationMixin(LightningElement) {
    menuItems = [];
    arrowbottomsvg = arrowbottom;
    logolightsvg = logolight;
    menusvg = menu;
    logosvg = logo;
    conciergesvg = concierge;
    closesvg = close;
    locationsvg = location;
    @api NavBarName;
    @api redirectURL;
    displayNumber;
    @track dniContactNumber;

    BasePath;

    connectedCallback() {
        this.BasePath = basepath;
        this.displayNumber = contNumber;
    }

    callMe() {
        // this.gtmEvent();
        // window.location = "tel:+1" + contNumber.replaceAll('-', '');
        this.dniContactNumber = this.template.querySelector('.nav-comp1').innerHTML;
        this.dniContactNumber = this.dniContactNumber.replaceAll('Call ','');
        this.gtmEvent();
        window.location = "tel:+1" + this.dniContactNumber.replaceAll('-','');
    }

    isHomeLoaded;
    handleHome()
    {
        this.isHomeLoaded = true;
        if(this.isHomeLoaded)
        {
            this.isHomeLoaded = false;
            this.gtmEventNavBarHome();
        }
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            }
        });
    }

    gtmEventNavBarHome() {
        let gtmEventNavBarEvent = new CustomEvent(
            'gtm__navHeader', {
                detail: {
                    navLocation: "header",
                    navElementText: "Home",
                    navURL: this.BasePath
                }
            });
        document.dispatchEvent(
            gtmEventNavBarEvent, {
                bubbles: true,
                composed: true
            });
    }

    gtmEvent() {
        let contactUsCallEvent = new CustomEvent(
            'gtm__contactUsCall', {
                detail: {
                    contact: "Header or mobile dropdown menu"
                }
            });
        document.dispatchEvent(
            contactUsCallEvent, {
                bubbles: true,
                composed: true
            });
    }



    @wire(getNavigationMenuItems, {
        menuName: 'BodewellStandardNavBar',
        publishedStatus: 'Draft'
    })
    wiredMenuItems({ error, data }) {
        if (data) {
            this.menuItems = data;
            console.log(this.menuItems);

        } else if (error) {
            console.log(error);
        }
    }

    pgName;
    handleNavigation(e) {
        //var pgName = e.currentTarget.dataset.value;
        this.pgName = e.currentTarget.dataset.value;
        this.gtmEventNavBar();
        this.redirectURL = this.BasePath + this.pgName;
        this.myFunctionClose();
    }
    myFunctionopen() {

        var x = this.template.querySelector(".third");
        var imgh = this.template.querySelector(".first");
        var imgcl = this.template.querySelector(".second");
        if (x.style.display === "block") {
            x.style.display = "none";
            imgh.style.display = "block";
            imgcl.style.display = "none";
        } else {
            x.style.display = "contents";
            imgcl.style.display = "block";
            imgh.style.display = "none";
        }


    }
    myFunctionClose() {
            var x = this.template.querySelector(".third");
            var imgh = this.template.querySelector(".first");
            var imgcl = this.template.querySelector(".second");
            if (x.style.display === "block") {
                x.style.display = "contents";
                imgcl.style.display = "block";
                imgh.style.display = "none";
            } else {
                x.style.display = "none";
                imgh.style.display = "block";
                imgcl.style.display = "none";
            }
            console.log("dropdown closed");

        }
        // Skip content function
    handlefocus(e) {
        const skipbox = this.template.querySelector('.skip-to-main-content');
        const navpositiononfocus = this.template.querySelector('.navbar-full');
        const skipbutton = this.template.querySelector('.generic-button');
        const atag = this.template.querySelector('.link--skipToMain');
        skipbox.style.position = "fixed";
        navpositiononfocus.style.top = "80px";
        skipbox.style.zindex = "200";
        skipbox.style.height = "80px";
        skipbutton.style.display = "block";
        atag.style.outlinestyle = "none !important";
        atag.style.outlinecolor = "transparent !important";
    }
    handleblur(e) {
        const skipboxblur = this.template.querySelector('.skip-to-main-content');
        const navpositiononblur = this.template.querySelector('.navbar-full');
        const skipbuttonblur = this.template.querySelector('.generic-button');
        skipboxblur.style.position = "absolute";
        skipboxblur.style.zindex = "1";
        skipboxblur.style.height = "0px";
        skipbuttonblur.style.display = "none";
        navpositiononblur.style.top = "0px";
    }
    handleNavigate() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            }
        });
        const skipcontent = this.template.querySelector('.skip-to-main-content');
        const navpositionon = this.template.querySelector('.navbar-full');
        const skipbutton = this.template.querySelector('.generic-button');
        skipcontent.style.position = "absolute";
        skipcontent.style.zindex = "1";
        skipcontent.style.height = "0px";
        skipbutton.style.display = "none";
        navpositionon.style.top = "0px";

    }
    gtmEventNavBar() {
        let gtmEventNavBarEvent = new CustomEvent(
            'gtm__navHeader', {
                detail: {
                    navLocation: "header",
                    navElementText: this.pgName.replaceAll('/', ''),
                    navURL: this.BasePath + this.pgName
                }
            });
        document.dispatchEvent(
            gtmEventNavBarEvent, {
                bubbles: true,
                composed: true
            });
    }
}