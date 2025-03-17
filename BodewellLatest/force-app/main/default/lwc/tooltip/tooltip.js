import { api, track, LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import orderDetails from '@salesforce/apex/ServiceHistory.orderDetails'

export default class Tooltip extends LightningElement {

    @api uid
    @api value

    @track loading
    @track active
    @track data
    @track test

    async show(){

        this.loading = true
        this.active = true

        this.data = this.data ? this.data : await this.getInfo()

        this.loading = false
    }
    
    close(){
        this.active = false
    }

    async getInfo(){
        
        try {

            //console.log(`
            //    use ${this.uid} and/or ${this.value} for callout to return data
            //`)

            const response = JSON.parse( await orderDetails({ orderNumber: this.value, uniqueKey: this.uid}) )

            const { data, errors } = response

            if(errors && errors.length){
                errors.map(error => this.error( error.errorType, error.message ) )
            }
            else {

                const object = JSON.parse( data.findServicesExtraInfo )

                return JSON.parse( JSON.stringify( object ) )
            }
        }
        catch(error){
            return this.error( error.message, 'Error')
        }

        return undefined
    }

    error(type, message){
        this.toast(message, type, 'error')
    }

    toast( message = '', title = 'Info', variant = 'info') {
        
        const event = new ShowToastEvent({
            title,
            message,
            variant,
        })

        this.dispatchEvent(event)
    }
}