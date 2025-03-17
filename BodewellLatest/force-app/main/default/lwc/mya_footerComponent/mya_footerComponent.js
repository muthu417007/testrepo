import { LightningElement, api } from 'lwc';
import GEA from "./mya_footerComponent.html";
import Cafe from "./mya_footerComponentCafe.html";
import Haier from "./mya_footerComponentHaier.html";


export default class FooterComponent extends LightningElement {
    @api brand = "GEA";
    render() {
        if (this.brand == "GEA") {
            return GEA;
        } else if (this.brand == "Haier") {
            return Haier;
        } else if (this.brand == "Cafe") {
            return Cafe;
        }
    }

    handleClick() {
        try {
            document.dispatchEvent(new CustomEvent('OneTrust_ToggleInfoDisplay', { detail: 'OneTrust' }), { bubbles: true, composed: true });
        } catch (ex) {
            console.error("Test Case error: ", ex);
        }
    }

}