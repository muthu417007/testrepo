import { LightningElement, api } from 'lwc';

export default class VoiceEvents extends LightningElement {
    @api recordId;
    hasRendered = false;
    subscribedEvents = [
        'callstarted',
        'callconnected',
        'callended',
        'hold',
        'resume',
        'mute',
        'unmute',
        'participantadded',
        'participantremoved',
        'conference',
        'swap',
        'pauserecording',
        'resumerecording',
        'transcript',
        'wrapupended'
    ];
    transcript = {
        agent: '',
        caller: '',
        complete: ''
    };
    constructor() {
        super();
        this.telephonyEventListener = this.onTelephonyEvent.bind(this);
    }
    renderedCallback() {
        console.log('VoiceEvents renderedCallback v0.6');
        if (!this.hasRendered) {
            const toolkitApi = this.template.querySelector('lightning-service-cloud-voice-toolkit-api');
            for (const s in this.subscribedEvents) {
                toolkitApi.addEventListener(this.subscribedEvents[s], this.telephonyEventListener);
            }
            this.hasRendered = true;
        }
    }
    onTelephonyEvent(event) {
        console.log('VoiceEvents onTelephonyEvent');
        if (event == null) return;
        console.log(event.type);
        switch (event.type) {
            case 'transcript':
                try {
                    let role = event.detail.sender.role;
                    let text = event.detail.content.text.toLowerCase();
                    console.log('VoiceEvents transcript ==> ' + role + ' - ' + text);
                    if (role == 'Agent') this.transcript.agent += ' ' + text;
                    if (role == 'EndUser') this.transcript.caller += ' ' + text;
                    this.transcript.complete += ' ' + text;
                    let payload = {
                        transcript: this.transcript.complete,
                        agentTranscript: this.transcript.agent,
                        callerTranscript: this.transcript.caller
                    };
                    console.log('VoiceEvents ==> ' + JSON.stringify(payload));
                    const toolkitApi = this.template.querySelector('lightning-service-cloud-voice-toolkit-api');
                    toolkitApi.updateNextBestActions(this.recordId, payload);
                }
                catch (e) {
                    // Ignore errors                    
                }
                break;
            default:
                console.log('VoiceEvents event ==> ' + event.type);
                break;
        }
    }
}