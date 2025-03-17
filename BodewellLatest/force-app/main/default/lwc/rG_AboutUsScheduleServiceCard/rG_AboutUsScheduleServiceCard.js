// purpose:- Using on About Us Page of Repair GE 
// Author:- Kanishtika Gupta
// Created By:- Kanishtika Gupta
import { LightningElement, api } from 'lwc';
import basepath from '@salesforce/community/basePath';
import RG_ScheduleServiceLink from '@salesforce/label/c.RG_ScheduleServiceLink';

export default class RG_AboutUsScheduleServiceCard extends LightningElement {
  @api content;
  @api buttonlabel;
  @api redirectionLink;
  @api navigationtype;
  @api buttonArea;
  basePath = basepath;
  redirectURL;

  connectedCallback() {
    debugger;
    if (!this.redirectionlink) {
      this.redirectionlink = RG_ScheduleServiceLink;
    }
    if (this.navigationtype == 'Site Page') {
      this.redirectURL = basePath + this.redirectionlink;
    }
    else if (this.navigationtype == 'External Link') {
      this.redirectURL = this.redirectionlink;
    }
  }

  handleClick(e) {
    debugger
    if (this.buttonlabel && this.buttonlabel.toLowerCase().indexOf('schedule service') > -1) {
      let scheduleServiceEvent = new CustomEvent(
        "gtm__serviceSchedule", {
        detail: {
          clickLocation: this.buttonArea
        }
      });
      document.dispatchEvent(scheduleServiceEvent, {
        bubbles: true,
        composed: true
      });
    }
  }
}