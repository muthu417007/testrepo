import { api, LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import { handleError } from 'c/cx_utils'

import getExistingSessions from '@salesforce/apex/CX_ScvTimerController.getExistingSessions';
import getOngoingVoiceCall from '@salesforce/apex/CX_ScvTimerController.getOngoingVoiceCall';
import saveSession from '@salesforce/apex/CX_ScvTimerController.saveSession';

/**
 * Class responsible for handling the SCV Timer logic
 * @extends {NavigationMixin} and {LightningElement}
 */
export default class Cx_scvTimer extends NavigationMixin(LightningElement) {
    @api recordId;

    caseId;

    @track hideCmp = false;
    cmpHeader = 'Voice Call Timer';
    hideClock = false;
    allowManual = false;
    autoStart = false;
    showTotalByStatus = true;

    @track sessions = [];
    sessionSource = 'Voice Call';
    currentSessionStatus = '';

    voiceCall;

    /**
     * A lifecycle hook that runs when the component is starting
     */
    async connectedCallback() {
        await Promise.all([
            this.checkExistingSessions(),
            this.checkVoiceCall()
        ]);
    }

    /**
     * A method that checks for existing sessions for the voice call
     */
    async checkExistingSessions() {
        try {
            this.sessions = await getExistingSessions({ voiceCallId: this.recordId });
        } catch(ex) {
            handleError(this, ex);
        }
    }

    /**
     * A method that checks for ongoing voice calls for the voice call
     */
    async checkVoiceCall() {
        try {
            const ongoingCall = await getOngoingVoiceCall({ voiceCallId: this.recordId });
            this.processNewVoiceCall(ongoingCall);
        } catch(ex) {
            handleError(this, ex);
        }
    }

    /**
     * A method that checks if there is a ongoing call and start the timer if so
     * @param {array} ongoingCall - An array with a ongoing call
     */
    processNewVoiceCall(ongoingCall) {
        if(!ongoingCall.length) {
            return;
        }

        this.voiceCall = ongoingCall[0];
        this.caseId = ongoingCall[0].RelatedRecordId;
        this.currentSessionStatus = 'On Call';
        
        this.startNewSession();
    }

    /**
     * A method that handles SCV events, such as CALL_ENDED, HOLD AND RESUME
     * @param {event} event - An SCV event
     */
    @api
    async handleScvEvent(event) {
        if(!this.voiceCall || this.voiceCall.VendorCallKey !== event.detail.callId) {
            return;
        }

        if(event.type === 'CALL_ENDED') {
            await this.endCurrentSession();
            this.currentSessionStatus = 'Call Ended';
        } 
        else if(event.type === 'HOLD') {
            await this.endCurrentSession();
            this.currentSessionStatus = 'On Hold';
            this.startNewSession();
        } 
        else if(event.type === 'RESUME') {
            await this.endCurrentSession();
            this.currentSessionStatus = 'On Call';
            this.startNewSession();
        }
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
            session.caseId = this.caseId;
            session.voiceCallId = this.recordId;
            session.status = this.currentSessionStatus;
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