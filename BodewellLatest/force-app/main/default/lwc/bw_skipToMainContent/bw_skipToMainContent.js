import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class Bw_skipToMainContent extends NavigationMixin(LightningElement)
{
    handleNavigate(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            }
        });
    }
}