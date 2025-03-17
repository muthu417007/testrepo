import LightningModal from 'lightning/modal';

export default class bwc_CybersourcePOC_Modal extends LightningModal {

    listenerAdded;
    connectedCallback() {
        if (!this.listenerAdded) {
            if (window.addEventListener) {
                window.addEventListener('message', this.handleMessage);
            } else {
                window.attachEvent('onmessage', this.handleMessage)
            }
        }
    }

    handleMessage(message) {
        console.log(`bwc_CybersourcePOC_Modal::message.data = ${JSON.stringify(message.data, null, 2)}`);
        this.close(message.data);
    }

    //Needed for sending message to iframe
    // iframeWindow;
    // renderedCallback(){
    //     if (!this.iframeWindow) {
    //         this.iframeWindow = this.template.querySelector('iframe').contentWindow;
    //         console.log(`iframeWindow: ${this.iframeWindow}`);
    //         // this.iframeWindow.postMessage('', '*');
    //     }
    // }
}