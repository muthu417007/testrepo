import { LightningElement } from 'lwc';

const events = {};

/**
 * Confirm that two page references have the same attributes
 * @param {object} pageRef1 - The first page reference
 * @param {object} pageRef2 - The second page reference
 */

const samePageRef = (pageRef1, pageRef2) => {
    const obj1= pageRef1.attributes;
    const obj2= pageRef2.attributes;
    return Object.keys(obj1).concat(Object.keys(obj2)).every((key)=> { return obj1[key] === obj2[key]});
}

/**
 * Register a callback for event
 * @param {string} eventName - Name of the event to listen for
 * @param {function} callback - Function to invoke when said event is fired.
 * @param {object} thisArg - The value to be passed as the this parameter to the callback function is bound.
 */

const registerListener = (eventName, callback, thisArg) => {
    if(!thisArg.pageRef) {
        throw new Error(
            'pubsub listner need a "@wire(CurrentPageReference) pageRef" property'
        );
    }

    if(!events[eventName]) {
        events[eventName] = [];
    }

    const duplicate = events[eventName].find((listener) => {
        return listener.callback === callback && listener.thisArg === thisArg;
    });

    if(!duplicate) {
        events[eventName].push({callback, thisArg});
    }
};

/**
 * Unregister a callback for event
 * @param {string} eventName - Name of the event to listen for
 * @param {function} callback - Function to invoke when said event is fired.
 * @param {object} thisArg - The value to be passed as the this parameter to the callback function is bound.
 */
const unregisterListener = (eventName, callBack, thisArg) => {
    if(events[eventName]) {
        events[eventName] = events[eventName].filter(
            (listener) => listener.callBack !== callBack || listener.thisArg !== thisArg
        )
    }
}

/**
 * Unregister all event listener bound to an object
 * @param {object} thisArg - All the callbacks bound to this object will beremoved.
 */

const unregisterAllListeners = (thisArg) => {
    Object.keys(events).forEach((eventName) => {
        events[eventName] = events[eventName].filter(
            (listener) => listener.thisArg !== thisArg 
        )
    })
}

/**
 * Fires an event to listener
 * @param {object} pageRef - Reference of the page that represent the event scope.
 * @param {string} eventName - NAme of the event to fired.
 * @param {*} payload - Payload of the event to fire.
 */
const fireEvent = (pageRef, eventName, payload) => {
    if(events[eventName]) {
        const listeners = events[eventName];
        listeners.forEach((listener) => {
            if(samePageRef(pageRef, listener.thisArg.pageRef)) {
                try {
                    listener.callback.call(listener.thisArg, payload);
                } catch (error) {
                    // fail silently
                }
            }
        });
    }
};


export {
    registerListener,
    unregisterListener,
    unregisterAllListeners,
    fireEvent
}