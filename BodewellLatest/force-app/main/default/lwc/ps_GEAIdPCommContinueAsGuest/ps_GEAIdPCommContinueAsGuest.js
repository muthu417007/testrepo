import {api, LightningElement} from "lwc";
import {NavigationMixin} from "lightning/navigation";
import Bodewell from "./ps_GEAIdPCommContinueAsGuestBodewell.html";
import GEA from "./ps_GEAIdPCommContinueAsGuest.html";

export default class Ps_GEAIdPCommContinueAsGuest extends NavigationMixin(LightningElement) {
    @api continueAsGuestButtonLabelInternal = "Continue As Guest";
    @api brand = 'GEA';
    @api bodewellContinueAsGuest = "Continue As Guest";

    allowGuest = false;

    currentPageReference = null;
    redirectURL = null;
    guestURL = null;
    redirectState = null;

    render() {
        if (this.brand == "GEA") {
            return GEA;
        } 
         else if (this.brand == "Bodewell") {
            console.log('bodewell Template rendered');
            return Bodewell;
         }
    }

    connectedCallback() { 
        console.log('inside connected call back');
        document.addEventListener("geaidm__shareHeaderCookie", this.getHeaderCookieValue.bind(this));

        document.dispatchEvent(new CustomEvent("geaidm__getHeaderCookie"), {
            bubbles: true,
            composed: true
        });
    }

    handleClick(event) {
        let fullRedirectURL = decodeURIComponent(this.redirectURL);
        if(fullRedirectURL.indexOf('?') === -1) {
            fullRedirectURL += '?';
        }
        if(this.redirectState) {
            fullRedirectURL += '&state=' + this.redirectState;
        }
        fullRedirectURL += '&Login=Guest';
        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
                url: fullRedirectURL
            }
        });
    }

    getHeaderCookieValue(e) {
        console.log('inside get Header cookie value method');
        const allCookies = e.detail.documentCookie?.split(";");
        console.log('allCookies',allCookies);
        const allCookiesMap = new Map();
        for (let cookie of allCookies) {
            const [cookieName, cookieValue] = cookie.split("=");
            allCookiesMap.set(cookieName.trim(), cookieValue.trim());
        }
        console.log('allCookiesMap',allCookiesMap);

        if (allCookiesMap.get("apex__allowGuest") === "1") { 
            this.redirectURL = allCookiesMap.get("apex__redirectURL");
            this.guestURL = allCookiesMap.get("apex__guestURL");
            if(this.guestURL && this.guestURL != '') {
                this.redirectURL = this.guestURL;
            }
            this.redirectState = allCookiesMap.get("apex__state");
            if( this.redirectURL ) {
                this.allowGuest = true;
            }
        }
    }
}