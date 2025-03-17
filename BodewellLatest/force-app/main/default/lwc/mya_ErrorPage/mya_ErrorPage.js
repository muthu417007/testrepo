import { LightningElement, api } from 'lwc';
import GEA from "./mya_ErrorPage_GEA.html";
import Cafe from "./mya_ErrorPage_Cafe.html";
import Haier from "./mya_ErrorPage_Haier.html";
export default class Mya_ErrorPage extends LightningElement {
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


}