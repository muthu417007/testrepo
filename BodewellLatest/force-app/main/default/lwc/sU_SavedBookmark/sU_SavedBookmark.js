import { LightningElement, api, track } from 'lwc';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/supubsub';

export default class SU_SavedBookmark extends LightningElement {
    // bookmarksButtonsSaveText = 'Remove Bookmark';
    renderBookmarksButtons = true;
    isSaveBookMark = false;
    isBookmarkExist = true;
    count = 0;
    @api eventCode;
    @api translationObject;
    get renderBookmarksButtons() {
    }
    connectedCallback() {
        registerListener('savebookmarkclicked'+this.eventCode, this.savedBookMarkClicked, this);
        registerListener('bmarkslist'+this.eventCode, this.bookmarkReceived, this);
        registerListener('transssferlist'+this.eventCode, this.bookmarkReceived, this);
        registerListener('closesavedbmark'+this.eventCode, this.closeseIcon2, this);
    }
    closeseIcon2(d) {
        this.isSaveBookMark = false;
    }
    bookmarkReceived(data) {
        if(data.length === 0) {
            this.isBookmarkExist = false;
        } else {
            this.isBookmarkExist = true;
            this.bookmarkSearches = data.reverse();
        }
    }

    savedBookMarkClicked(d) {
        this.count = 0;
        this.isSaveBookMark = true;
        this.renderBookmarksButtons = true;
    }
    closeIcon() {
        this.isSaveBookMark = false;
        this.count = 0;
        this.renderBookmarksButtons = true;
        fireEvent(null, 'closeIconbookmark'+this.eventCode, true);
    }
    closeAndDeleteBmark() {
        let i;
        let deleteList = [];
        let checkboxes = this.template.querySelectorAll('[data-id="checkbox"]')
        for (i = 0; i < checkboxes.length; i++) {
            if (checkboxes[i].checked) {
                let b = {};
                b.href = checkboxes[i].name;
                b.title = checkboxes[i].value;
                deleteList.push(b);
            }
        }
        fireEvent(null, 'removefromlocalstorage'+this.eventCode, deleteList);
        this.closeIcon();
    }
    bookmarkActive(event) {
        if (event.target.checked) {
            this.count++
        } else {
            this.count--
        }
        if (this.count == 0) {
            this.renderBookmarksButtons = true;
        } else {
            this.renderBookmarksButtons = false;
        }
    }
    bookmarkClicked1(e) {
        fireEvent(null, 'savedbookmarkclicked'+this.eventCode, e);
    }
}