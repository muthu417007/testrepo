import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class Cx_sessionTimerItem extends NavigationMixin(LightningElement) {
    @track formattedTime;
    @track agentURL;
    @track sessionURL;     
    _session;

    @api hideAgent;
    
    @api 
    get session(){
        return this._session;        
    }

    /**
     * A setter that receives the session and store it's value
     * @param {object} value - A session
     */
    set session(value){     
        if(value){
            this._session = value;        
            this.formattedTime = value.formattedTime;
        }           
    }

    /**
     * A method that handles a click in the agent name or session duration and dispatches an sendrecordid event
     * @param {event} event - A click event
     */
    handleClickedRecord(event){
        const recId = event.target.dataset.targetId;

        const sendRecordIdEvent = new CustomEvent('sendrecordid',{
            detail : recId,
        });

        this.dispatchEvent(sendRecordIdEvent);
    }
}