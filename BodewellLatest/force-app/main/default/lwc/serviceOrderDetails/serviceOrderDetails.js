import { api, track, LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import orderDetails from '@salesforce/apex/ServiceHistory.orderDetails'
import orderDetailsCops from '@salesforce/apex/ServiceHistory.orderDetailsCops'

export default class serviceOrderDetails extends LightningElement {

    @api header
    @api text
    @api value
    @api variant

    @api uniqueKey
    @api orderNumber

    @track loading
    @track active
    @track data = null

    is = 'serviceOrderDetails'

    async show(){
        
        if(this.value){

            this.loading = true
            this.active = true
        }
        else {
            return this.toast(`No extra data found`)
        }



        if(this.variant === 'orders'){

            const { OrderUniqueKey, OrderNumber } = this.value

            this.isOrders = true

            this.data = this.data ? this.data : await this.getOrders( OrderUniqueKey, OrderNumber, orderDetails )            
        }
        else if(this.variant === 'orders_cops'){

            const { COPS_ORDER_NO, COPS_ORD_UNIQUE_KEY } = this.value

            this.isOrders = true

            this.data = this.data ? this.data : await this.getOrders( COPS_ORD_UNIQUE_KEY, COPS_ORDER_NO, orderDetailsCops, false )
        }
        else if(this.variant === 'closedCalls') {
                
            this.data = JSON.parse( JSON.stringify( this.value  ))
            
            this.isClosedCalls = true
        }
        else {
            this.error('issue', `${this.is} doesn't have variant set`)
        }

        this.loading = false

        return undefined
    }
    
    close(){
        this.active = false
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

    /**
     * @description parse key, number from value; use to get more order detail data via apex callout
     */
    async getOrders(uniqueKey, orderNumber, method, flag = true){
        
            // console.log(` using ${uniqueKey} and ${orderNumber} for callout to return data `)

            const response = JSON.parse( await method({ orderNumber, uniqueKey }) )

            const { data, errors } = response

            if(errors && errors.length){
                errors.map(error => this.error( error.errorType, error.message ) )
            }
            else {
                if(flag){
                    return JSON.parse(JSON.parse(JSON.stringify( JSON.parse(JSON.stringify( data)).findServicesExtraInfo )))
                }
                return JSON.parse(JSON.parse(JSON.stringify( JSON.parse(JSON.stringify( data)).findExtraInfo )))
            }
 
        return undefined
    }
}