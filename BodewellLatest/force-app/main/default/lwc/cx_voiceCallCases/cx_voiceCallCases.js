import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { getRecordNotifyChange } from "lightning/uiRecordApi";
import getCases from "@salesforce/apex/CX_CaseManagementController.getCases";
import createCase from "@salesforce/apex/CX_CaseManagementController.createCase";
import attachCase from "@salesforce/apex/CX_CaseManagementController.attachCase";
import getMatchingContacts from "@salesforce/apex/CX_CaseManagementController.getMatchingContacts";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class CX_VoiceCallCases extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  @api strategyName;

  contactId;
  caseId;
  cases = [];
  loaded = true;
  columns = [
    { type: "text", fieldName: "CaseNumber", label: "Case #" },
    { type: "text", fieldName: "Subject", label: "Subject" },
    { type: "text", fieldName: "Status", label: "Status" },
    { type: "date", fieldName: "CreatedDate", label: "Created" },
    {
      type: "action",
      typeAttributes: {
        rowActions: [
          { label: "Open", name: "open" },
          { label: "Attach", name: "attach" }
        ]
      }
    }
  ];

  connectedCallback() {
    getMatchingContacts({
      strategyName: this.strategyName,
      recordId: this.recordId
    }).then((res) => {
      let evt;
      if (res && res.length) {
        if (res.length > 1) {
          evt = new ShowToastEvent({
            title: "Multiple Contact Matches",
            message: "We found multiple contacts with this phone number.",
            variant: "info"
          });
        } else {
          this.contactId = res[0].Id;
          this.loadCases();
          evt = new ShowToastEvent({
            title: "Contact found",
            message: "We found a contact matching this phone number.",
            variant: "success"
          });
        }
      } else {
        evt = new ShowToastEvent({
          title: "No Matching Contact",
          message: "We couldn't found a contact with this phone number.",
          variant: "info"
        });
      }
      this.dispatchEvent(evt);
    });
  }

  /**
   * Reloads the cases list when the contact is changed.
   * @param {*} evt
   */
  handleContactChange(evt) {
    this.contactId = evt.target.value;
    this.loadCases();
  }

  /**
   * Gets the cases associated with the contact selected.
   */
  loadCases() {
    if (this.contactId) {
      this.loaded = false;
      getCases({
        strategyName: this.strategyName,
        contactId: this.contactId
      })
        .then((data) => {
          this.loaded = true;
          this.cases = data;
        })
        .catch((error) => {
          window.console.error(error);
        });
    } else {
      this.cases = [];
    }
  }

  /**
   * Opens a subtab with the attached/created case.
   */
  openCaseSubtab(event) {
    if (!this.caseId) {
      this.caseId = event.target.dataset.caseId
    }
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.caseId,
        actionName: "view"
      }
    });
  }

  /**
   *  Creates a new case associated to the voice call.
   */
  newCaseClick() {
    this.loaded = false;
    createCase({
      strategyName: this.strategyName,
      recordId: this.recordId,
      contactId: this.contactId
    }).then((result) => {
      this.caseId = result.Id;
      this.loadCases();
      this.loaded = true;
      this.openCaseSubtab();
      getRecordNotifyChange([{ recordId: this.recordId }]);
      eval("$A.get('e.force:refreshView').fire();");
    });
  }

  /**
   * Attaches a case to the voice call.
   * @param {*} event
   */
  attachCaseClick(event) {
    this.loaded = false;
    this.caseId = event.target.dataset.caseId;
    attachCase({
      strategyName: this.strategyName,
      recordId: this.recordId,
      caseId: this.caseId
    }).finally(() => {
      this.loaded = true;
      getRecordNotifyChange([{ recordId: this.recordId }]);
      eval("$A.get('e.force:refreshView').fire();");
      this.openCaseSubtab();
      this.loaded = true;
    });
  }
}