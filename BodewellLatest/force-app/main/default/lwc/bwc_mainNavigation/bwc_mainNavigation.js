import { LightningElement, api, track} from 'lwc';

/**
 * @slot subMenu1
 * @slot subMenu2
 * @slot subMenu3
 * @slot subMenu4
 * @slot navSearch
 */

export default class Bwc_mainNavigation extends LightningElement {

    @track _handler;
    isPreview = false;

    @api menu1Label;
    @api menu2Label;
    @api menu3Label;
    @api menu4Label;

    @api editMode;
    @api editMode1;
    @api editMode2;
    @api editMode3;
    @api editMode4;

    connectedCallback() {
        this.isPreview = this.isInSitePreview();
        // Close the dropdown menu if the user clicks outside of it
        this._handler = this.closeGlobalMenu.bind(this);
        window.addEventListener('click', this._handler);
    }

    disconnectedCallback() {
        window.removeEventListener('click', this._handler);
    }

    get menuOneClasses() {
        let classNames = 'menu-1 dropdown-content';
        if (this.isPreview){
            if (this.editMode1) {
                classNames += ' show edit';
            } 
        }
        return classNames; 
    }
    get menuTwoClasses() {
        let classNames = 'menu-2 dropdown-content';
        if (this.isPreview){
            if (this.editMode2) {
                classNames += ' show edit';
            } 
        }
        return classNames; 
    }
    get menuThreeClasses() {
        let classNames = 'menu-3 dropdown-content';
        if (this.isPreview){
            if (this.editMode3) {
                classNames += ' show edit';
            } 
        }
        return classNames; 
    }
    get menuFourClasses() {
        let classNames = 'menu-4 dropdown-content';
        if (this.isPreview){
            if (this.editMode4) {
                classNames += ' show edit';
            } 
        }
        return classNames; 
    }

    isInSitePreview() {
        let url = document.URL;
        return (url.indexOf('sitepreview') > 0 
            || url.indexOf('livepreview') > 0
            || url.indexOf('live-preview') > 0 
            || url.indexOf('live.') > 0
            || url.indexOf('.builder.') > 0);
    }

    displaySubMenu(e) {
        console.log('Derek ' + e.target.tagName);
        if (this.isPreview){
            if (this.editMode1 || this.editMode2 || this.editMode3 || this.editMode4) {
                return;
            } 
        }
        let navBtn = e.currentTarget.dataset.id;
        let dropdown = this.template.querySelector('.' + navBtn);
        
        let dropdowns = this.template.querySelectorAll('.dropdown');
        let content = this.template.querySelectorAll('.dropdown-content');

        if (!dropdown.classList.contains('show')) {
            // set active border on link
            e.currentTarget.classList.add('is-active');
            // show the submenu
            dropdown.classList.add('show');
        } else if ( e.target.tagName == 'SPAN' && e.currentTarget.classList.contains('is-active')) {
            e.currentTarget.classList.remove('is-active');
            dropdown.classList.remove('show');
        } 
    
        // // Get all other open dropdowns and close them/ remove active state
        Array.prototype.forEach.call(content, function (con) {
            if (con === dropdown) return;
            con.classList.remove('show');
        });
        Array.prototype.forEach.call(dropdowns, function (drop) {
            if (drop === e.currentTarget) return;
            drop.classList.remove('is-active');
        });
    }

    // Mobile Menu Accordion View
    displayMobileMenu(e) {
        e.currentTarget.classList.toggle('active');
        let panel = e.currentTarget.nextElementSibling;
        if (panel.classList.contains('show')) {
            panel.classList.remove('show');
        } else {
            panel.classList.add('show');
        }
    }

    //if click is from outside the component
    closeGlobalMenu(e) {
        if (this.isPreview){
            if (this.editMode1 || this.editMode2 || this.editMode3 || this.editMode4) {
                return;
            } 
        }
        if(e.target !== undefined && e.target !== null) {
            if(e.target.tagName !== 'C-BWC_MAIN-NAVIGATION') {
                let dropdowns = this.template.querySelectorAll('.dropdown');
                for(let drop of dropdowns) {
                    drop.classList.remove('is-active')
                }         
                let content = this.template.querySelectorAll('.dropdown-content');
                for(let con of content) {
                    con.classList.remove('show')
                }
            }
        }
    }

}