import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const fields = ['Log__c.Name', 'Log__c.Status__c', 'Log__c.Body__c']

export default class Logger extends LightningElement {

    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields })
    log

    get name() {

        if (!this.log.data) { return '' }

        return this.log.data.fields.Name.value
    }

    get header() {

        if (!this.log.data) { return '' }

        return `Overall Status: ${this.log.data.fields.Status__c.value}`
    }

    get body() {
        
        if (!this.log.data) { return '' }

        const body = JSON.parse(this.log.data.fields.Body__c.value)

        const formatted = this.format(body) //raw.replace(/"/g, '').replace(/\\/g, '')

        return formatted
    }
    
    // Implimented https://github.com/lydell/json-stringify-pretty-compact
    format(passedObj, options) {

        const stringOrChar = /("(?:[^\\"]|\\.)*")|[:,]/g;

        return stringify(passedObj, options)

        // eslint-disable-next-line no-shadow
        function stringify(passedObj, options) {
            
            let indent, maxLength, replacer;

            options = options || {};

            indent = JSON.stringify(
                [1],
                undefined,
                options.indent === undefined ? 2 : options.indent
            ).slice(2, -3);

            maxLength =
                indent === ""
                    ? Infinity
                    : options.maxLength === undefined
                        ? 80
                        : options.maxLength;

            replacer = options.replacer;

            return (function _stringify(obj, currentIndent, reserved) {
                // prettier-ignore
                let end, index, items, key, keyPart, keys, length, nextIndent, prettified, start, string, value;

                if (obj && typeof obj.toJSON === "function") {
                    obj = obj.toJSON();
                }

                string = JSON.stringify(obj, replacer);

                if (string === undefined) {
                    return string;
                }

                length = maxLength - currentIndent.length - reserved;

                if (string.length <= length) {
                    prettified = string.replace(stringOrChar, function (match, stringLiteral) {
                        return stringLiteral || match + " ";
                    });
                    if (prettified.length <= length) {
                        return prettified;
                    }
                }

                if (replacer != null) {
                    obj = JSON.parse(string);
                    replacer = undefined;
                }

                if (typeof obj === "object" && obj !== null) {
                    nextIndent = currentIndent + indent;
                    items = [];
                    index = 0;

                    if (Array.isArray(obj)) {
                        start = "[";
                        end = "]";
                        length = obj.length;
                        for (; index < length; index++) {
                            items.push(
                                _stringify(obj[index], nextIndent, index === length - 1 ? 0 : 1) ||
                                "null"
                            );
                        }
                    } else {
                        start = "{";
                        end = "}";
                        keys = Object.keys(obj);
                        length = keys.length;
                        for (; index < length; index++) {
                            key = keys[index];
                            keyPart = JSON.stringify(key) + ": ";
                            value = _stringify(
                                obj[key],
                                nextIndent,
                                keyPart.length + (index === length - 1 ? 0 : 1)
                            );
                            if (value !== undefined) {
                                items.push(keyPart + value);
                            }
                        }
                    }

                    if (items.length > 0) {
                        return [start, indent + items.join(",\n" + nextIndent), end].join(
                            "\n" + currentIndent
                        );
                    }
                }

                return string;
            })(passedObj, "", 0);
        }
    }
}