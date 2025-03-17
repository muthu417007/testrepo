import { LightningElement, api, track } from "lwc";
import { registerListener } from 'c/supubsub';
import getObjectApiName from "@salesforce/apex/su_vf_console.SUVFConsoleController.getObjectApiName"; //Apex class Method
import getCompactLayoutFields from "@salesforce/apex/su_vf_console.SUVFConsoleController.getCompactLayoutFields"; //Apex class Method

export default class SU_ArticlePreviewParent extends LightningElement {
  @api rangerId;
  @api attachments;
  @api articlerecorexists;
  @api titleimage;
  @api attachlink;
  @api showarticlepreview;
  @api item;
  @api fileattachment;
  @api left;
  @api maincontainerwidth
  @api top;
  @api topnew;
  diamond;
  anchorTagOffsetHeight;
  @api eventCode;
  @api utilityWidth;
  @api utilityTop;
  @track compactField = [];
  compactLayoutFields;
  firstLoad = true;
  resultset;
  clientWidth;
  divHeight;
  oldrangerId;
  currentTitle;
  objectName = '';

  connectedCallback() {
    registerListener("sendDataToArticleParentPreview"+this.eventCode, this.getDiamondValue, this);
  }

  getDiamondValue(value) {
    this.diamond = value.diamond;
    this.anchorTagOffsetHeight = value.anchorTagOffsetHeight;
  }

  renderedCallback() {
    var top;
    if (this.firstLoad && this.rangerId) {
      this.getCompactLayoutFields();
      this.firstLoad = false;
    }
    if (this.rangerId != undefined && this.oldrangerId != this.rangerId && Object.keys(this.item).length) {
      this.currentTitle = this.item.highlight && this.item.highlight.TitleToDisplayString != '' && this.item.highlight.TitleToDisplayString[0] || this.item.href;
      if (this.objectName != '' != this.item.objName) {
        if (this.objectName.toLowerCase() != this.item.objName.toLowerCase()) {
          getObjectApiName({ knowledgeId: this.rangerId }).then((result) => {
            this.objectName = result;
            this.error = '';
          })
            .catch((error) => {
              this.error = error;
            });
        }
      }
    }
    // To adjust position of diamond relative to popup
    if (this.template.querySelector("div.mainContainer")) {
      this.divHeight = this.template.querySelector("div.mainContainer").clientHeight;
      this.clientWidth = this.template.querySelector("div.mainContainer").clientWidth;
    }
    const selectEvent = new CustomEvent("selection", {
      detail: {
        divHeight: this.divHeight,
        clientWidth: this.clientWidth
      }
    });
    this.dispatchEvent(selectEvent);
    if(this.template.querySelector("div.mainContainer")) {
      if(this.utilityTop && this.utilityWidth && window.location.href.indexOf('popout') == -1) {
        top = this.topnew - (window.innerHeight - (this.divHeight + 35));
      } else {
        this.template.querySelector("div.mainContainer").style = 'height: calc(100vh - 10vh) !important;';
        top = (this.topnew - (window.innerHeight - this.divHeight) / 2) - 10;
      }
      this.template.querySelector("div.container").style.setProperty("top", top + "px");
    }

    if (!this.diamond && this.template.querySelector('div.container')) {
      this.template.querySelector('div.container').style.setProperty('left', (10 + this.clientWidth - 18) + 'px');
      this.template.querySelector('div.container').style.setProperty('border-top', ' 2px  solid #d8dde6');
      this.template.querySelector('div.container').style.setProperty('border-right', ' 2px  solid #d8dde6');
      this.template.querySelector('div.container').style.setProperty('border-bottom', ' 0px  solid #d8dde6');
      this.template.querySelector('div.container').style.setProperty('border-left', ' 0px  solid #d8dde6');
    } else if (this.template.querySelector('div.container')) {
      this.template.querySelector('div.container').style.setProperty('left', -9 + 'px');
      this.template.querySelector('div.container').style.setProperty('border-bottom', ' 2px  solid #d8dde6');
      this.template.querySelector('div.container').style.setProperty('border-left', ' 2px  solid #d8dde6');
      this.template.querySelector('div.container').style.setProperty('border-top', ' 0px  solid #d8dde6');
      this.template.querySelector('div.container').style.setProperty('border-right', ' 0px  solid #d8dde6');
    }
  }

  crosspreview(event) {
    event.preventDefault();
    const selectEvent = new CustomEvent('closeknowledgewidget', {
      detail: true
    });
    this.dispatchEvent(selectEvent);
  }
  getCompactLayoutFields() {
    getCompactLayoutFields({ knowledgeId: this.rangerId })
      .then(result => {
        this.resultset = JSON.parse(result);
        for (let i = 0; i < this.resultset.fieldItems.length; i++) {
          if (this.resultset.fieldItems[i].label != 'Title') {
            this.compactField.push(this.resultset.fieldItems[i].layoutComponents[0].value);
          }
        }
        this.compactLayoutFields = this.compactField;
      })
      .catch(error => {
        console.log('Error occur while getting compact layout fields ', error);
      });
  }

  handleError(event) {
    let message = event.detail.detail;
    this.compactLayoutFields = [];
    //do some stuff with message to make it more readable
    message = "Something went wrong!";
    this.showToast(TOAST_TITLE_ERROR, message, TOAST_VARIANT_ERROR);
  }
  showToast(theTitle, theMessage, theVariant) {
    const event = new ShowToastEvent({
      title: theTitle,
      message: theMessage,
      variant: theVariant
    });
    this.dispatchEvent(event);
  }

}