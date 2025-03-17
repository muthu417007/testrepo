import { api, LightningElement, track } from 'lwc';
import timerPause from '@salesforce/resourceUrl/timerpause';
import timerPlay from '@salesforce/resourceUrl/timerplay';

import { formatDateToSalesforce } from 'c/cx_utils'

/**
 * Class responsible for handling the Timer logic
 * @extends {LightningElement}
 */
export default class Cx_sessionTimer extends LightningElement {

    //Static Resources
    timerPauseBtn = timerPause;
    timerPlayBtn = timerPlay;
    
    _sessions = [];
    isManual = false;
    
    //Design Attributes
    @api hideCmp = false;
    @api cmpHeader = '';
    @api hideClock = false;
    @api allowManual = false;
    @api autoStart = false;
    @api status = '';
    @api hideAgent = false;
    @api showTotalByStatus = false;

    //Modal
    @track modalClosed = true;
    @track modalClass = 'slds-hide';
    @track manualDate;
    @track manualDuration = '00:00:00';

    //Timer Variables
    @track stime = '00:00:00';
    @track totalFormattedTime = '00:00:00';
    @track totalFormattedTimeByStatus = [];
    @track playing = false;
    @track recording = false;
    totalElapsedSeconds = 0;
    sessionSeconds = 0;
    timerInterval;

    /**
     * A lifecycle hook that runs when the component is starting and starts the timer if autoStart is true
     */
     connectedCallback() {
        if(this.autoStart){              
            this.start();
        }
    } 

    @api
    get sessions() {
        return this._sessions;
    }

    /**
     * A setter that receives the sessions and calls other methods to process them before setting the global var
     * @param {array} value - An array with sessions
     */
    set sessions(value) {        
        const unorderedSessions = this.formatSessionsDuration(JSON.parse(JSON.stringify(value)));
        this._sessions = this.orderSessions(unorderedSessions);
        this.calculateTotalElapsedTime();
    }

    /**
     * A method that gets a session array and formats its durations for showing
     * @param {array} sessions - An array with sessions
     * @return {array} - An array with sessions
     */
    formatSessionsDuration(sessions) {
        return sessions.map(session => {
            session.formattedTime = this.formatSeconds(session.Duration__c);
            return session;
        });
    }

    /**
     * A method that gets a session array and orders it using the session date and created date
     * @param {array} unorderedSessions - An array with unordered sessions
     * @return {array} - An array with sessions
     */
    orderSessions(unorderedSessions) {
        return unorderedSessions.map(session => {
            const dateArray = session.Date__c.split('-');
            session.dateObj = new Date(Number(dateArray[0]), Number(dateArray[1]) - 1, Number(dateArray[2]));
            session.createdDateObj = new Date(session.CreatedDate);

            return session;
        }).sort((a, b) => (b.dateObj - a.dateObj) || (b.createdDateObj - a.createdDateObj));
    }

    /**
     * A method that calculates the total elapsed time from all the sessions
     */
    calculateTotalElapsedTime() {
        if(this._sessions.length) {
            //this.totalElapsedSeconds = this._sessions.map(session => session.Duration__c).reduce((totalTime, duration) => totalTime += duration);
            //this.totalFormattedTime = this.totalElapsedSeconds ? this.formatSeconds(this.totalElapsedSeconds) : '00:00:00';

            if(this.showTotalByStatus) {
                this.calculateTotalElapsedTimeByStatus();
            }
        }
    }

    /**
     * A method that calculates the total elapsed time for each status
     */
    calculateTotalElapsedTimeByStatus() {
        const statuses = [...new Set(this._sessions.map(session => session.Status__c))];

        this.totalFormattedTimeByStatus = statuses.map(status => {
            const statusSessions = this._sessions.filter(session => session.Status__c === status);
            const elapsedSeconds = statusSessions.map(session => session.Duration__c).reduce((totalTime, duration) => totalTime += duration);
            const formattedTime = this.formatSeconds(elapsedSeconds);

            return {
                name: status,
                elapsedSeconds,
                formattedTime
            };
        });
    }

    @api
    get isPaused() {
        return !this.playing;
    }

    /**
     * A public method that starts the timer and sets a 1 second interval 
     */
    @api
    start() {
        this.playing = true;
        this.recording = true;
        this.timerInterval = setInterval(() => {
            this.sessionSeconds++;
            this.stime = this.formatSeconds(this.sessionSeconds);
            this.totalElapsedSeconds++;  
            this.totalFormattedTime = this.totalElapsedSeconds ? this.formatSeconds(this.totalElapsedSeconds) : '00:00:00';
            this.updateTimersInRealTime();  
        }, 1000);  
    }

    /**
     * A public method that stops the timer and clears the interval
     */
    @api
    stop() {
        this.playing = false;
        this.recording = false;
        clearInterval(this.timerInterval);
    }

    /**
     * A public method that ends the current session, call a method that fires an session ended event and returns the session
     * @param {boolean} fireEvent - Should a event be fired?
     * @param {component} that - An optional component reference
     * @return {object} - The just stopped session
     */
    @api
    endCurrentSession(fireEvent, that = this) {
        that.stop();

        const currentSession = {
            'sessionDate': formatDateToSalesforce(new Date()),
            'sessionTime': that.stime,
            'sessionSeconds': that.sessionSeconds,
            'uniqueId': that.createUniqueKey(),
            'isManual': this.isManual
        };

        if(fireEvent) {
            that.fireSessionEndEvent(currentSession);
        }

        that.stime = '00:00:00';
        that.sessionSeconds = 0;
        return currentSession;
    }

    /**
     * A method that fires an session ended event
     * @param {object} session - An ended session
     * @param {component} that - An optional component reference
     */
    fireSessionEndEvent(session, that = this) {
        that.dispatchEvent(new CustomEvent('sessionended', { detail: session }));
    }

    /**
     * A method that calls another method to start/pause the timer
     */
    toggleTimer(){
        if(this.isPaused) {
            this.start();
        } else {
            this.stop();
        }
    }

    /**
     * A method that handles an event and fires another event sending a recordId 
     * @param {event} event - An send record id event
     */
    handleRecordIdSent(event){
        const recordId = event.detail;

        const passingRecordIdEvent = new CustomEvent('passrecordid',{ detail : recordId });
        this.dispatchEvent(passingRecordIdEvent);
    }


    /**
     * A method that opens/close the manual input modal
     */
    toggleModal(){
        this.modalClosed = !this.modalClosed;
        this.modalClass = this.modalClosed ? 'slds-hide' : '';
    }

    /**
     * A method that handles input events from the manual modal and store the values in variables
     * @param {event} event - An send record id event
     */
    handleFormInput(event){
        if( event.target.name == 'manualDate' ){
            this.manualDate = event.target.value;
        }
        else if( event.target.name == 'manualDuration' ){
            this.manualDuration = event.target.value;
        }
    }

    /**
     * A method that calls another methods to save a manual session and clear/close the manual modal
     */
    handleSaveSession(){

        const manualSession = {
            'sessionDate': this.manualDate,
            'sessionTime': this.manualDuration,
            'uniqueId': this.createUniqueKey(),
            'isManual': true
        };

        this.fireSessionEndEvent(manualSession);
        this.clearInputs();
        this.toggleModal();
    }

    /**
     * A method that clears the manual modal input fields
     */
    clearInputs(){
        this.manualDate = null;
        this.manualDuration = '00:00:00';       
    }

    /**
     * A method that handles a manual start for the session and calls another method to start it
     * @param {event} event - A click event
     */
    toggleTimerManually(event){
        if(!this.allowManual) {
            return;
        }
        
        var id = event.target.dataset.id;
        this.isManual = true;
        this.toggleTimer(id === 'start');      
    }

    /**
     * A method that transforms seconds in a 'HH:MM:SS' formatted string
     * @param {integer} seconds - Seconds to be formatted
     * @return {string} - Formatted time
     */
    formatSeconds(seconds){   
        var h, m, s = 0;
        
        h = Math.floor( seconds / (60 * 60 ) );
        seconds = seconds % (60 * 60 );
        m = Math.floor( seconds / (60 ) );
        seconds = seconds % (60 );
        s = Math.floor( seconds );
        
        return this.pad(h, 2) + ':' + this.pad(m, 2) + ':' + this.pad(s, 2);
    }

    /**
     * A method that pads a number with 0
     * @param {integer} num - Number to be formatted
     * @param {integer} size - Size of the padded string
     * @return {string} - Padded string
     */
    pad(num, size){
        var s = '0000' + num;
        return s.substr(s.length - size);
    }

    /**
     * A method that creates a unique key for the session
     * @return {string} - The session key
     */
    createUniqueKey(){
        var uniqueKeyLength = 10;
        var resultArray = [];
        var characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        var charactersLength = characters.length;
        for ( var i = 0; i < uniqueKeyLength; i++ ) {
            resultArray.push(characters.charAt(Math.floor(Math.random() *
                charactersLength)));
        }
        return resultArray.join('');
    }

    updateTimersInRealTime() {
        this.totalFormattedTimeByStatus.forEach(status => {
            if (status.name == this.status) {

                status.elapsedSeconds++;
                status.formattedTime = this.formatSeconds(status.elapsedSeconds);
            }
        });        
        //this.calculateTotalElapsedTimeByStatus();
    }
}