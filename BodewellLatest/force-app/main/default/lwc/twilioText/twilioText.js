import { LightningElement, api, track, wire } from 'lwc'
import { getRecord } from 'lightning/uiRecordApi'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import setTwilioMessage from '@salesforce/apex/Twilio.setTwilioMessage'

const fields = ['Case.Twilio_Phone__c']

export default class TwilioText extends LightningElement {

    @api header
    @api recordId
    @api proxy
    @api phone
    
    @track isSending
    @track phone_outbound

    @wire(getRecord, { recordId: '$recordId', fields })
    init({ error, data }){
        if (data) {
            console.log('has data')
            console.dir(JSON.parse(JSON.stringify(data)))
            this.record = data;
            this.phone_to = data.fields.Twilio_Phone__c.value
            this.error = undefined;

        } else if (error) {
            this.error = error;
            this.record = undefined;
        }
    }

    get phone_from(){ 
        return this.phone
    }

    get phone_to(){
        return this.phone_outbound
    }
    set phone_to(val){
        this.phone_outbound = val
    }
    change_phone(event){
        this.phone_to = event.target.value
    }

    get message(){ 
        return this.template.querySelector('lightning-textarea').value
    }
    set message(value){
        this.template.querySelector('lightning-textarea').value = value
    }

    get outbound_route(){
        return this.proxy+'/outbound'
    }

    get outbound_options(){
        
        return {
            
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                to: this.phone_to,
                from: this.phone_from,
                body: this.message
            })
        }
    }
    
    twilioMessage(SID__c){

        return {
            SID__c,
            To__c: this.phone_to,
            From__c: this.phone_from,
            Message__c: this.message,
            Case__c: this.recordId
        }
    }
    
    async sendSMS(){
        
        try {

            this.isSending = true
            
            const response = await fetch(this.outbound_route, this.outbound_options)

            const data = await response.json()

            if(data.status === 400){

                this.showToast('Error', data.message, 'error')
            }
            else {
            
                const { sid } = data

                const tm = this.twilioMessage( sid )

                await setTwilioMessage({ tm })

                this.showToast('Success', 'Text message sent', 'success')
            }
            
            this.message = ''
            this.isSending = false

            return undefined
        }
        catch(error){
            // eslint-disable-next-line no-console
            console.error(error)
            return error
        }
    }

    showToast(title = 'Info', message = '', variant = 'info') {
        
        const event = new ShowToastEvent({
            title,
            message,
            variant,
        })

        this.dispatchEvent(event)
    }
}