import { LightningElement, track } from 'lwc';
import getAllStores from '@salesforce/apex/BWC_OrderOnBehalfOfController.getAllStores';
import getAllUsers from '@salesforce/apex/BWC_OrderOnBehalfOfController.getAllUsers';


export default class Bwc_selectStoreAndUser extends LightningElement {
    selectedStore;
    selectedUser;
    @track availableStore = [];
    @track availableUsers= [];
    @track zipCode;

    async connectedCallback(){
        const stores = await getAllStores();
        console.log('Available Stores Are > '+stores);
        stores.forEach(store => {
            this.availableStore.push({label: store.name, value: store.Id});
        });
        this.availableStore = [...this.availableStore];
        console.log('All Stores > ',this.availableStore);
        const availableUsers = await getAllUsers();
        console.log('All Users> ',availableUsers);
        availableUsers.forEach(user => {
            this.availableUsers.push({label: user.Name, value: user.Id});
        });
        this.availableUsers = [...this.availableUsers];
        console.log('All Usersss > ',this.availableUsers);
    }

    handleStoreChange(event){
        console.log('Selected Store Value Is >> ',event.target.value);
        this.selectedStore = event.target.value;
    }

    handleUserChange(event){
        console.log('Selected User Is >> ',event.target.value);
        this.selectedUser = event.target.value;
    }
    
    handleNextClick(event){
        if(this.selectedUser && this.selectedStore && this.zipCode){
            const evnt = new CustomEvent(
                "storeuserselected",
                {detail: {user: this.selectedUser, store: this.selectedStore, zipCode: this.zipCode}}
            );
            this.dispatchEvent(evnt);
        }
    }

    handleZipChange(event){
        this.zipCode = event.target.value;
    }
}