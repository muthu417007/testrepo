import { api, LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import { handleError } from 'c/cx_utils'

import getExistingSessions from '@salesforce/apex/CX_OmniChannelTimerController.getExistingSessions';
import saveSession from '@salesforce/apex/CX_OmniChannelTimerController.saveSession';

/**
 * Class responsible for handling the Omni channel Timer logic
 * @extends {NavigationMixin} and {LightningElement}
 */
export default class Cx_omniChannelTimer extends NavigationMixin(LightningElement) {
    userId;
    
    @track sessions = [];
    sessionSource = 'Omni Channel';
    @track currentStatus = '';
    
    @track hideCmp = false;
    cmpHeader = 'Omni Channel Timer';
    hideClock = false;
    allowManual = false;
    autoStart = false;
    hideAgent = true;
    
    /**
    * A lifecycle hook that runs when the component is starting
    */
    async connectedCallback() {
        await this.checkExistingSessions();
    }
    
    /**
    * A method that checks for existing sessions for omni channel user
    */
    async checkExistingSessions() {
        try {
            this.sessions = await getExistingSessions();
        } catch(ex) {
            handleError(this, ex);
        }
    }
    
    /**
     * A public method that handles Omni Channel events
     * @param {event} event - An Omni Channel event
     * @param {string} type - Event type
     */
    @api
    async handleOmniChannelEvents(event, type) {
        if(type === 'statusChanged') {
            await this.handleStatusChangedEvent(event);
        }
        else if(type === 'logout') {
            await this.endCurrentSession();
            this.currentStatus = '';
        }
    }

    /**
     * A method that handles Omni Channel status changed event, ending the current session if needed and starting a new one with the current status
     * @param {event} event - An Omni Channel event
     */
    async handleStatusChangedEvent(event) {
        const isPaused = this.template.querySelector('c-cx_session-timer').isPaused;

        if(!isPaused) {
            await this.endCurrentSession();
        }

        this.currentStatus = event.getParam('statusName');
        this.startNewSession();
    }
    
    /**
    * A method that queries for the timer and starts a new session
    */
    startNewSession() {
        const timer = this.template.querySelector('c-cx_session-timer');
        timer.start();
    }
    
    /**
    * A method that ends the current session and calls another method to save it to SF
    * @param {component} that - An optional component reference
    */
    @api
    async endCurrentSession(that = this) {
        const timer = that.template.querySelector('c-cx_session-timer');
        const currentSession = timer.endCurrentSession(false);
        await that.saveSessionToSalesforce(currentSession);
    }
    
    /**
    * A method that handles a session ended event and calls another method to save it to SF
    * @param {event} event - An session ended event
    */
    async handleSessionEnd(event) {
        const session = event.detail;
        await this.saveSessionToSalesforce(session);
    }
    
    /**
     * A method that calls SF to save a session
     * @param {object} session - An session to be saved
     */
     async saveSessionToSalesforce(session) {
        try {
            session.status = this.currentStatus;
            session.source = this.sessionSource;
            this.sessions =  await saveSession({ sessionStr: JSON.stringify(session) });
        } catch(ex) {
            handleError(this, ex);
        }
    }
    
    /**
    * A method that handles a Pass record id event and opens a tab to another record (Session or agent)
    * @param {event} event - An Pass record id event
    */
    handlePassedRecordId(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.detail,
                actionName: 'view',
            },
        });
    }
}