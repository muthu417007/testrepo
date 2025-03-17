import { showTostEvent } from "lightning/platformShowToastEvent";

var callbacks = {};

const _servercall = (_serveraction, _params, _onsuccess, _onerror) =>{
    if(!_params){
        _params = {};
    }
console.log('inside _servercall');
console.log('_serveraction-->'+_serveraction);
console.log('_params-->'+_params);
    _serveraction({MeetCompIds: _params})
        .then(_result =>{
            console.log(_result);
            if(_result && _onsuccess){
                _onsuccess(_result);
            }
        })
        .catch(_error =>{
            if(_error && _onerror){
                _onerror(_error);
            }
        })
}
export default {
    _servercall 
}