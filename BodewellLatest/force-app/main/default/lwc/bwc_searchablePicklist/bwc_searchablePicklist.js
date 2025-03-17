import { LightningElement, api, track } from 'lwc';

export default class CmtSearchablePicklist extends LightningElement {
    @api dropdownOpen;
    @api picklistOptions = [];
    @api dropDown;
    @api cssClass;
    @track selectedValue;
    @track show = false;
    @api picklistDisabled;
    @track picklistOptionsClone = [];
    @api sortList;
    @api label;

    @api get value() {
        return this.selectedValue;
    }


    set value(value) {
        this.selectedValue = value;
        if (this.selectedValue === undefined || this.selectedValue === '' && (this.picklistOptionsClone?.length > 0)) {
            this.selectedValue = this.picklistOptionsClone[0]?.label;
            return;
        }
        let selectedOptionMatch = this.picklistOptionsClone.filter(option => option.label === this.selectedValue);
        if (selectedOptionMatch?.length > 0) {
            selectedOptionMatch[0].selected = true;
        }
    }

    hideDiv = (event) => {
        const activeElement = this.template.activeElement;
        if (activeElement?.dataset.id != "picklistDiv") {
            this.dropdownOpen = false;
            this.picklistDisabled = false;
        }
        const hideDropdown = new CustomEvent('click', {
            bubbles: true,
            composed: true,
            detail: this.dropdownOpen
        });
        this.dispatchEvent(hideDropdown);
    }

    connectedCallback() {
        document.addEventListener('click', this.hideDropdown.bind(this));
        let noneLabel;
        this.cssClass = this.cssClass + ' textInput';
        this.picklistOptions = JSON.parse(JSON.stringify(this.picklistOptions));
        const picklistOpt = this.picklistOptions;
        this.picklistOptionsClone = [...picklistOpt];
        this.picklistOptionsClone.forEach(option => {
            option['css'] = option.label + " slds-listbox__item eachItem";
            option['selected'] = false;
        });
        if (this.picklistOptionsClone[0].label.toUpperCase() === 'Show me diagram number') {
            noneLabel = this.picklistOptionsClone.splice(0, 1);
        }
        if (this.sortList) {
            this.picklistOptionsClone.sort((a, b) => (a.label.toLowerCase() > b.label.toLowerCase()) ? 1 : ((b.label.toLowerCase() > a.label.toLowerCase()) ? -1 : 0));
            this.picklistOptionsClone.unshift(noneLabel[0]);
        }
    }

    @api
    changePicklistValues(){
        let found = this.picklistOptions.find((val, index) => {
            return this.picklistOptionsClone.includes(val)
          });
        if(found === undefined){
        let noneLabel;
        this.cssClass = this.cssClass + ' textInput';
        this.picklistOptions = JSON.parse(JSON.stringify(this.picklistOptions));
        const picklistOpt = this.picklistOptions;
        this.picklistOptionsClone = [...picklistOpt];
        this.picklistOptionsClone.forEach(option => {
            option['css'] = option.label + " slds-listbox__item eachItem";
            option['selected'] = false;
        });
        if (this.picklistOptionsClone[0].label.toUpperCase() === 'Show me diagram number') {
            noneLabel = this.picklistOptionsClone.splice(0, 1);
        }
        if (this.sortList) {
            this.picklistOptionsClone.sort((a, b) => (a.label.toLowerCase() > b.label.toLowerCase()) ? 1 : ((b.label.toLowerCase() > a.label.toLowerCase()) ? -1 : 0));
            this.picklistOptionsClone.unshift(noneLabel[0]);
        }
    }
    }

    disconnectedCallback() {
        document.removeEventListener('click', this.hideDropdown.bind(this));
    }

    hideDropdown(event) {
        if (event.target.nodeName == 'C-BWC_PARTS-DIAGRAM') {
        }
        else {
            this.dropdownOpen = false;
        }
    }

    handleSearchChange(event) {
        try {
            this.dropdownOpen = true;
            this.dispatchEvent(new CustomEvent('showchange', { detail: this.dropdownOpen }));
            const searchTerm = event.target.value.toLowerCase();
            this.picklistOptionsClone = this.picklistOptions.filter(option =>
                option.label.toLowerCase().includes(searchTerm)
            ).sort((a, b) => {
                const includesTermA = a.label.toLowerCase().includes(searchTerm);
                const includesTermB = b.label.toLowerCase().includes(searchTerm);
                if (includesTermA && !includesTermB) {
                    return -1;
                } else if (!includesTermA && includesTermB) {
                    return 1;
                } else {
                    return 0;
                }
            });
            if(this.picklistOptionsClone == null || this.picklistOptionsClone == undefined || this.picklistOptionsClone.length == 0 || this.searchTerm == ''){
                const picklistOpt = this.picklistOptions;
                this.picklistOptionsClone = [...picklistOpt];
            }
        } catch (e) {
            console.error("Error >> ", e);
        }
    }

    selectPicklistOption(event) {
        event.preventDefault();
        const selectedValue = event.currentTarget.dataset.id;
    
    this.picklistOptionsClone = this.picklistOptionsClone.map(option => {
        if (option.value === selectedValue) {
            return { ...option, selected: true };
        } else {
            return { ...option, selected: false };
        }
    });
    
    const selectedOption = this.picklistOptionsClone.find(option => option.value === selectedValue);
    this.value = selectedOption?.label; 

        const optionSelected = new CustomEvent('selection', {
            bubbles: true,
            composed: true,
            detail: { ...selectedOption }
        });
        this.dispatchEvent(optionSelected);
        this.dropdownOpen = false;
        this.picklistDisabled = false;
    }

    @api
  handleClick(event) {
    this.dropdownOpen = !this.dropdownOpen;
    const childClickEvent = new CustomEvent('childclick', {
      bubbles: true // Allow event to bubble up to parent
    });
    this.dispatchEvent(childClickEvent);
  }

}